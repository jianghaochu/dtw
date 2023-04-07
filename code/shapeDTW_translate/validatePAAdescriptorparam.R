validatePAAdescriptorparam <- function(param = NULL) {
  
  if (is.null(param) || !is.list(param)) {
    val_param <- list(segNum = 10, segLen = NULL, priority = "segNum")
    return(val_param)
  }
  
  val_param <- validatePAAparam(param)
  return(val_param)
  
}