generateSlopePAAdescriptorFileName <- function(param) {
  
  if (missing(param)) {
    val_param <- validateSlopePAAdescriptorparam()
  } else {
    val_param <- validateSlopePAAdescriptorparam(param)
  }
  
  if (!("Slope" %in% names(val_param))) {
    param_slope <- validateSlopedescriptorparam()
  } else {
    param_slope <- val_param$Slope
  }
  
  if (!("PAA" %in% names(val_param))) {
    param_paa <- validatePAAdescriptorparam()
  } else {
    param_paa <- val_param$PAA
  }
  
  fileName_slope <- generateSlopedescriptorFileName(param_slope)
  fileName_paa <- generatePAAdescriptorFileName(param_paa)
  
  fileName <- paste0("SlopePAA-", fileName_slope, "-", fileName_paa)
  
  return(fileName)
}