PAA <- function(subsequence, param) {
  val_param <- validatePAAparam(param)
  len <- length(subsequence)
  
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
  
  if (segNum > length(subsequence)) {
    stop('Inconsistency found between parameter setting and input sequences\n')
  }
  
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
    segs[i] <- mean(subsequence[(idx_seg[i] + 1):idx_seg[i + 1]])
  }
  
  out <- list(
    'rep' = segs,
    'segLens' = segLens,
    'idx_seg' = idx_seg,
    'val_params' = val_params
  )
  
  return(out)
}