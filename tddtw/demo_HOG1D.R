rm(list = ls())
library(data.table)
source("shapeDTW_translate/descriptorHOG1D.R")
source("shapeDTW_translate/validateHOG1Dparam.R")
source("shapeDTW_translate/zNormalizeTS.R")
source("shapeDTW_translate/samplingSequencesIdx.R")
source("shapeDTW_translate/whichInterval.R")

# Load data
ts <- fread("UCRArchive_2018/Beef/Beef_TRAIN.tsv")
nInstances <- nrow(ts)
seqlen <- 39  # Subsequence length
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

# Get the subsequences for each sequence
p_subsequences <- samplingSequencesIdx(p, seqlen, 1:lenp)$subsequences
q_subsequences <- samplingSequencesIdx(q, seqlen, 1:lenq)$subsequences

# HOG1D parameters
param <- list(
  # blocks=c(1,2), # unit: cell, one block is equivalent to one cell
  cells=c(1,25), # unit: t， 25 values
  overlap=12, # Allow overlap of 12 values between blocks/cells
  gradmethod="centered", 
  nbins=8,
  sign=TRUE,
  # cutoff=c(2,51), 
  xscale=0.1
)

# Validate HOG1D parameter values
val_param <- validateHOG1Dparam(param)
cells <- val_param$cells
gradmethod <- val_param$gradmethod
nbins <- val_param$nbins
dx_scale <- val_param$xscale
# cutoff <- val_param$cutoff
sequences <- p_subsequences[[50]][,1]
seqlen <- length(sequences)

# Calculate cell length and overlap
sCell <- cells[2]
overlap <- val_param$overlap

# Define angle ranges for HOG descriptors
if (val_param$sign) {
  angles <- seq(-pi/2, pi/2, length.out=nbins+1)
} else {
  angles <- seq(0, pi/2, length.out=nbins+1)
}

# Calculate center angles for each bin
centerAngles <- numeric(nbins)
for (i in 1:nbins) {
  centerAngles[i] <- (angles[i] + angles[i+1])/2
}

# Now we only support maximal number of 10 blocks
ref_lens <- numeric(20) # The maximum subsequence length can be 142
for (i in 1:20) {
  ref_lens[i] <- sCell * i - overlap * (i-1)
}

# Find number of blocks
idx <- which.min(abs(ref_lens - length(sequences)))
# If length of subsequence is greater than the number of cells, 
# then add the first value and last value to the subsequence.
# If not, duplicate # of length difference values to the subsequence
if ((length(sequences) - ref_lens[idx]) > 0 && (length(sequences) - ref_lens[idx]) < 2) {
  sequences <- c(sequences[1], sequences, sequences[length(sequences)])
} else if ((length(sequences) - ref_lens[idx]) <= 0) {
  margin <- ref_lens[idx] - length(sequences) + 2
  leftMargin <- round(margin/2)
  rightMargin <- margin - leftMargin
  sequences <- c(rep(sequences[1], leftMargin), sequences, rep(sequences[length(sequences)], rightMargin))
}

nBlock <- idx
descriptor <- matrix(0, nBlock, nbins)
idx_start <- 1

# Calculate feature descriptor
for (i in 1:nBlock) {
  for (j in 1:sCell) {
    idx <- i*sCell - (i-1)*overlap - sCell + j
    cidx <- idx_start + idx - 1
    
    switch (gradmethod, 
            "uncentered" = {
              sidx <- cidx
              eidx <- cidx + 1
              if (sidx < 1 || eidx > seqlen) {
                next
              }
              dx <- 1*dx_scale
              dy <- sequences[eidx] - sequences[sidx] # next one - current one
              ang <- atan2(dy, dx)
              mag <- dy/dx
            },
            "centered" = {
              sidx <- cidx - 1
              eidx <- cidx + 1
              if (sidx < 1 || eidx > seqlen) {
                next
              }
              dx <- 2*dx_scale
              dy <- sequences[eidx] - sequences[sidx] # next one - previous one
              ang <- atan2(dy, dx)
              mag <- dy/dx
            }
    )
    
    n <- whichInterval(angles, ang)
    if (n == 1 && ang <= centerAngles[1]) {
      descriptor[i, n] <- descriptor[i, n] + abs(mag)
    } 
    else if (n == nbins && ang > centerAngles[nbins]) {
      descriptor[i, n] <- descriptor[i, n] + abs(mag)
    } 
    else {
      if (abs(angles[n] - ang) > abs(angles[n+1] - ang)) {
        ang1 <- centerAngles[n]
        ang2 <- centerAngles[n+1]
        
        descriptor[i, n] <- descriptor[i, n] + abs(mag) * cos(ang1-ang)
        descriptor[i, n+1] <- descriptor[i, n+1] + abs(mag) * cos(ang2-ang)
      } 
      else {
        ang1 <- centerAngles[n-1]
        ang2 <- centerAngles[n]
        
        descriptor[i, n-1] <- descriptor[i, n-1] + abs(mag) * cos(ang1-ang)
        descriptor[i, n] <- descriptor[i, n] + abs(mag) * cos(ang2-ang)
      }
    }
  }
}
subdescriptors <- descriptor
descriptor <- matrix(t(descriptor), nrow = 1, ncol = nBlock * nbins)
