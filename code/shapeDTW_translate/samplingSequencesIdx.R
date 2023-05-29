# Sample sequence from designated points
# Given: the sequence of feature points
# Return: subsequences
samplingSequencesIdx <- function(sensordata, seqlen, idx) {
  # Check if the correct number of arguments have been provided
  if(missing(idx)) {
    stop("Insufficient number of arguments")
  }
  
  # Get the number of timestamps and dimensions
  nTimeStamps <- nrow(sensordata)
  nDims <- ncol(sensordata)
  
  # Check if the input matrix is in the correct format
  if(nTimeStamps < nDims) {
    warning("Synchronized signals should be arranged column-wisely\n")
  }
  
  # Initialize variables
  mask <- 1:seqlen
  mask <- mask - ceiling(seqlen/2)
  nSeqs <- length(idx)
  sequences <- list()
  tAnchor <- idx
  cnt <- 0
  
  # Loop through each subsequence
  for(i in 1:nSeqs) {
    iloc <- idx[i]
    imask <- mask + iloc
    
    # Check if the subsequence is within the bounds of the input matrix
    if(imask[1] <= 0 && imask[length(imask)] <= nTimeStamps) {
      tmp <- matrix(rep(sensordata[1, ], (1-imask[1])*nDims), ncol=nDims, byrow=TRUE)
      isequence <- rbind(tmp, as.matrix(sensordata[1:imask[length(imask)], ]))
    } 
    else if(imask[length(imask)] > nTimeStamps && imask[1] >= 1) {
      tmp <- matrix(rep(sensordata[nTimeStamps, ], (imask[length(imask)]-nTimeStamps)*nDims), ncol=nDims, byrow=TRUE)
      isequence <- rbind(as.matrix(sensordata[imask[1]:nTimeStamps, ]), tmp)
    } 
    else if(imask[1] <= 0 && imask[length(imask)] > nTimeStamps) {
      tmp1 <- matrix(rep(sensordata[1, ], (1-imask[1])*nDims), ncol=nDims, byrow=TRUE)
      tmp2 <- matrix(rep(sensordata[nTimeStamps, ], (imask[length(imask)]-nTimeStamps)*nDims), ncol=nDims, byrow=TRUE)
      isequence <- rbind(tmp1, as.matrix(sensordata), tmp2)
    } 
    else {
      isequence <- as.matrix(sensordata[imask, ])
    }
    
    cnt <- cnt + 1
    tAnchor[cnt] <- iloc
    sequences[[cnt]] <- isequence
  }
  
  tAnchor <- tAnchor[1:cnt]
  
  return(list("subsequences" = sequences, "tAnchor" = tAnchor))
}