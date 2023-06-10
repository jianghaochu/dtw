rm(list = ls())
library(data.table)
library(magrittr)
library(Rcpp)
source("dpfast.R")
source("dist2.R")
sourceCpp("shapeDTW_translate/dpcore.cpp")
sourceCpp("shapeDTW_translate/dpcore_window.cpp")
source("shapeDTW_translate/hist_cost_2.R")
source("shapeDTW_translate/zNormalizeTS.R")
source("shapeDTW_translate/shapeDTW.R")
source("shapeDTW_translate/hist_cost_2.R")
source("shapeDTW_translate/samplingSequencesIdx.R")
source("shapeDTW_translate/calcDescriptor.R")
source("shapeDTW_translate/descriptorPAA.R")
source("shapeDTW_translate/PAA.R")
source("shapeDTW_translate/descriptorHOG1D.R")
source("shapeDTW_translate/validatePAAparam.R")
source("shapeDTW_translate/validatePAAdescriptorparam.R")
source("shapeDTW_translate/validateHOG1Dparam.R")
source("shapeDTW_translate/validateDWTdescriptorparam.R")
source("shapeDTW_translate/whichInterval.R")
source("shapeDTW_translate/wpath2mat.R")

# Load data
ts <- fread("UCRArchive_2018/Beef/Beef_TRAIN.tsv")
nInstances <- nrow(ts)
seqlen <- 20  # Subsequence length
ts_data <- ts[, -1] # Time series data
ts_labels <- ts[, 1] # Label

# Randomly sample two sequences and normalize the sequences
p <- zNormalizeTS(unlist(ts_data[sample(nInstances, 1), ]))
q <- zNormalizeTS(unlist(ts_data[sample(nInstances, 1), ]))

# Process p and q
p <- p %>% as.data.frame()
q <- q %>% as.data.frame()
cat(paste0("Dimension of 1st Sequence: ", paste(dim(p), collapse = " x "),
           "\nDimension of 2nd Sequence: ", paste(dim(q), collapse = " x ")))

# Sequences length
lenp <- nrow(p)
lenq <- nrow(q)

# HOG1D
#hog <- validateHOG1Dparam()
#hog$cells <- c(1, round(seqlen/2)-1)
#hog$overlap <- 0
#hog$xscale <- 0.1
#descriptorSetting <- list(method = "HOG1D", param = hog)

# Descriptor: PAA
paa <- validatePAAdescriptorparam() # list(segNum = 10, segLen = NULL, priority = "segNum")
paa$priority <- "segNum"
segNum <- ceiling(seqlen/5)
paa$segNum <- segNum # segNum = 10
descriptorSetting <- list(method = "PAA", param = paa)

# Validate parameters
descriptorName <- descriptorSetting$method
descriptorParam <- descriptorSetting$param
val_param <- validatePAAdescriptorparam(descriptorParam)

# First compute descriptor at each point, and transform the univariate time series to multivariate one
p_subsequences <- samplingSequencesIdx(p, seqlen, 1:lenp)$subsequences
q_subsequences <- samplingSequencesIdx(q, seqlen, 1:lenq)$subsequences

######################################################################
# Test PAA Descriptor step by step
val_param <- validatePAAparam(val_param)
len <- length(p_subsequences[[1]])

switch(val_param$priority,
       'segNum' = {
         segNum <- val_param$segNum
         segLen <- floor(len / segNum)
         
         if (segLen < 1) {
           segNum <- 1
           segLen <- len
         }
       },
       'segLen' = {
         segLen <- val_param$segLen
         segNum <- floor(len / segLen)
         
         if (segNum < 1) {
           segNum <- 1
           segLen <- len
         }
       }
)

val_params <- list(
  'priority' = val_param$priority,
  'segNum' = segNum,
  'segLen' = segLen
)

if (segNum * segLen < len) {
  segLens <- c(rep(segLen, segNum - 1), len - segLen * (segNum - 1))
} else if (segNum * segLen == len) {
  segLens <- rep(segLen, segNum)
} else {
  segLens <- c(rep(segLen, segNum - 1), segLen - (segLen * segNum - len))
}

idx_seg <- c(0, cumsum(segLens))
segs <- numeric(segNum)
for (i in 1:segNum) {
  segs[i] <- mean(p[(idx_seg[i] + 1):idx_seg[i + 1], 1])
}
######################################################################

# Compute descriptor of sequence p
p_nsubsequences <- length(p_subsequences)
p_descriptors <- vector("list", p_nsubsequences)
for (j in 1:p_nsubsequences) {
  seq <- p_subsequences[[j]]
  p_descriptors[[j]] <- calcDescriptor(seq, descriptorName, descriptorParam)$descriptor
}
p_descriptors <- do.call(rbind, p_descriptors)

# Compute descriptor of sequence q
q_nsubsequences <- length(q_subsequences)
q_descriptors <- vector("list", q_nsubsequences)
for (j in 1:q_nsubsequences) {
  seq <- q_subsequences[[j]]
  q_descriptors[[j]] <- calcDescriptor(seq, descriptorName, descriptorParam)$descriptor
}
q_descriptors <- do.call(rbind, q_descriptors)

# Match multivariate time series 'p_descriptors' & 'q_descriptors': Euclidean distance
d <- dist2(p_descriptors, q_descriptors)
d <- sqrt(d)

# Get the alignment path and optimal cost
dtw_res <- dpfast(d)
idxp <- dtw_res[[1]]
idxq <- dtw_res[[2]]
cD <- dtw_res[[3]]
pc <- dtw_res[[4]]
match <- cbind(idxp, idxq)
lPath <- length(idxp)
distDescriptor <- sum(pc)

# Compute distance using raw signals, instead of descriptor distances
wp <- wpath2mat(idxp) %*% as.matrix(p)
wq <- wpath2mat(idxq) %*% as.matrix(q)
distRaw <- sum(sqrt((wp-wq)^2))


return(list("distRaw" = distRaw,   
            "distDescriptor" = distDescriptor,
            "lPath" = lPath,
            "match" = match))
