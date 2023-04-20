validateSlopePAAdescriptorparam <- function(param = NULL) {
  
  if (missing(param) || !is.list(param)) {
    val_param <- list(Slope = validateSlopedescriptorparam(),
                      PAA = validatePAAdescriptorparam())
    return(val_param)
  }
  
  if (!is.null(param$Slope)) {
    param_slope <- param$Slope
    val_param_slope <- validateSlopedescriptorparam(param_slope)
  } else {
    val_param_slope <- validateSlopedescriptorparam()
  }
  
  if (!is.null(param$PAA)) {
    param_paa <- param$PAA
    val_param_paa <- validatePAAdescriptorparam(param_paa)
  } else {
    val_param_paa <- validatePAAdescriptorparam()
  }
  
  val_param <- list(Slope = val_param_slope, PAA = val_param_paa)
  return(val_param)
  
}