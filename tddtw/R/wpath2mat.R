wpath2mat <- function(p) {
  lenSignal <- p[length(p)]
  lenPath <- length(p)
  
  wMat <- matrix(0, nrow = lenPath, ncol = lenSignal)
  
  for (i in 1:lenPath) {
    wMat[i, p[i]] <- 1
  }
  
  return(wMat)
}