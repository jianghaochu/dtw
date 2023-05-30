PAA <- function(sequences, param) {

  val_param <- validatePAAparam(param)
  len <- length(sequences)
  
  switch(val_param$priority,
         "segNum" = {
           segNum <- val_param$segNum
           segLen <- floor(len / segNum)
           
           if (segLen < 1) {
             segNum <- 1
             segLen <- len
           }
         },
         "segLen" = {
           segLen <- val_param$segLen
           segNum <- floor(len / segLen)
           
           if (segNum < 1) {
             segNum <- 1
             segLen <- len
           }
         }
  )
  
  if (segNum > length(sequences)) {
    stop("Inconsistency found between parameter setting and input sequences\n")
  }
  
  # Redefine a new list of validated parameters that are used in PAA
  val_params <- list(
    "priority" = val_param$priority,
    "segNum" = segNum,
    "segLen" = segLen
  )
  
  # If segment length * segment number < length of the sequences, add the remaining to last segment
  if (segNum * segLen < len) {
    segLens <- c(rep(segLen, segNum - 1), len - segLen * (segNum - 1))
  } else if (segNum * segLen == len) {
    segLens <- rep(segLen, segNum)
  } else {
    # If segment length * segment number > length of the sequences, remove extra from the segment
    segLens <- c(rep(segLen, segNum - 1), segLen - (segLen * segNum - len))
  }
  
  idx_seg <- c(0, cumsum(segLens))
  
  segs <- numeric(segNum)
  for (i in 1:segNum) {
    segs[i] <- mean(sequences[(idx_seg[i] + 1):idx_seg[i + 1]])
  }
  
  out <- list("descriptor" = segs,
              "segLens" = segLens,
              "idx_seg" = idx_seg,
              "val_params" = val_params)
  return(out)

}