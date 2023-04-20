descriptorSlopePAA <- function(subsequence, param) {
  subsequence <- c(subsequence) # turn a subsequence to a flatten vector
  val_param <- validateSlopePAAdescriptorparam(param)
  param_paa <- val_param$PAA
  param_slope <- val_param$Slope
  rep_slope <- descriptorSlope(subsequence, param_slope)
  rep_paa <- descriptorPAA(subsequence, param_paa)
  rep <- c(rep_slope, rep_paa)
  return(rep)
}