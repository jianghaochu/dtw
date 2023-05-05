descriptorDWT <- function(subsequence, param) {
  
  val_param <- validateDWTdescriptorparam(param)
  subsequence <- as.vector(subsequence)
  seqlen <- length(subsequence)
  
  # Now only support subsequences with length less than 1024
  refLens <- 2^(1:10)
  gaps <- abs(refLens - seqlen)
  idx <- which.min(gaps)
  newlen <- 2^idx
  
  if (newlen < seqlen) {
    subsequence <- subsequence[1:newlen]
  } 
  else {
    subsequence <- c(subsequence, mean(subsequence) * rep(1, newlen - seqlen))
  }
  
  selection <- val_param$selection
  numLevels <- val_param$numLevels
  n <- val_param$n
  
  listCoef <- wavecoef(selection, n)
  h <- listCoef[[1]]
  g <- listCoef[[2]]
  
  cntLevels <- 0
  w <- NULL
  s <- subsequence
  
  while (length(s) >= 4 && cntLevels < numLevels) {
    listCoef <- fwt1step(s, h, g)
    sout <- listCoef[[1]]
    dout <- listCoef[[2]]
    w <- rbind(dout, w)
    s <- sout
    cntLevels <- cntLevels + 1
  }
  
  if (cntLevels == numLevels) {
    w <- rbind(sout, w)
    rep <- t(w)
    return(rep)
  } 
  else if (cntLevels < numLevels && length(s) < 4) {
    listCoef <- fwt1step(s, h, g)
    sout <- listCoef[[1]]
    dout <- listCoef[[2]]
    w <- rbind(sout, dout, w) # semicolon in MATLAB suggests new row
    rep <- t(w)
    return(rep)
  }
 
}
