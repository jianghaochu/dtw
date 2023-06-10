descriptorSlope <- function(subsequence, param) {
  subsequence <- as.vector(subsequence)
  val_param <- validateSlopedescriptorparam(param)
  PAAparam <- list("segNum" = val_param$segNum, 
                   "segLen" = NULL, 
                   "priority" = "segNum")
  xscale <- val_param$xscale
  slopeMethod <- val_param$fit
  
  if (!slopeMethod == "regression") {
    stop("Only support regression to fit the slope\n")
  }
  
  paa <- PAA(subsequence, PAAparam)
  idx_seg <- paa$idx_seg
  segNum <- length(idx_seg) - 1
  slopes <- numeric(segNum)
  
  for (i in 1:segNum) {
    interval <- subsequence[(idx_seg[i] + 1):(idx_seg[i + 1])]
    if (length(interval) == 1) {
      slopes[i] <- 0
      next
    }
    x <- 1:length(interval)
    x <- xscale * x
    p <- lm(interval ~ x)
    slopes[i] <- coef(p)[2]
  }
  
  return(slopes)
}