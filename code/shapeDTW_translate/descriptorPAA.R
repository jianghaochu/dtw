descriptorPAA <- function(subsequence, param) {
  val_param <- validatePAAdescriptorparam(param)
  rep_paa <- PAA(subsequence, val_param)
  
  #epsilon <- 1.0e-6
  #rep_paa <- rep_paa / (sqrt(sum(rep_paa * rep_paa)) + epsilon)
  
  return(rep_paa)
}