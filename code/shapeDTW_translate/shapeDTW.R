shapeDTW <- function(p, q, seqlen, descriptorSetting = NULL, metric = "Euclidean") {

  if (!is.vector(p) || !is.vector(q)) {
    stop("Only support univariate time series\n")
  }
  
  if (is.null(metric)) {
    metric <- "Euclidean"
  }
  
  p <- p %>% as.data.frame() 
  q <- q %>% as.data.frame()

  lenp <- nrow(p)
  lenq <- nrow(q)
  
  if (is.null(descriptorSetting)) {
    hog <- validateHOG1Dparam()
    hog$cells <- c(1, round(seqlen/2)-1)
    hog$overlap <- 0
    hog$xscale <- 0.1
    
    paa <- validatePAAdescriptorparam()
    paa$priority <- "segNum"
    segNum <- ceiling(seqlen/5)
    paa$segNum <- segNum
    
    numLevels <- 3
    dwt <- validateDWTdescriptorparam()
    dwt$numLevels <- numLevels

    # descriptorSetting = NULL, descriptor HOG1D will be applied 
    descriptorSetting <- list(method = "HOG1D", param = hog)
  }
  
  # First compute descriptor at each point, and transform the univariate time series to multivariate one
  p_subsequences <- samplingSequencesIdx(p, seqlen, 1:lenp)$subsequences
  q_subsequences <- samplingSequencesIdx(q, seqlen, 1:lenq)$subsequences
  
  # Descriptor
  descriptorName <- descriptorSetting$method
  descriptorParam <- descriptorSetting$param
  
  p_nsubsequences <- length(p_subsequences)
  p_descriptors <- vector("list", p_nsubsequences)
  for (j in 1:p_nsubsequences) {
    seq <- p_subsequences[[j]]
    p_descriptors[[j]] <- calcDescriptor(seq, descriptorName, descriptorParam)$descriptor
  }
  p_descriptors <- do.call(rbind, p_descriptors)
  
  q_nsubsequences <- length(q_subsequences)
  q_descriptors <- vector("list", q_nsubsequences)
  for (j in 1:q_nsubsequences) {
    seq <- q_subsequences[[j]]
    q_descriptors[[j]] <- calcDescriptor(seq, descriptorName, descriptorParam)$descriptor
  }
  q_descriptors <- do.call(rbind, q_descriptors)
  
  # Match multivariate time series 'p_descriptors' & 'q_descriptors'
  switch(metric,
         "Euclidean" = {
           d <- dist2(p_descriptors, q_descriptors)
           d <- sqrt(d)
         },
         "chi-square" = {
           d <- hist_cost_2(p_descriptors, q_descriptors)
         },
         stop("Only support two distance metrics\n")
  )
  
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

}