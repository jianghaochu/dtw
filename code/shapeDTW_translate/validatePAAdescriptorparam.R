validatePAAdescriptorparam <- function(param) {

  if (missing(param) || !is.list(param)) { # If no param is specified or it is not a list
    val_param <- list(segNum = 10, segLen = NULL, priority = "segNum")
    return(val_param)
  }
  
  val_param <- validatePAAparam(param) # If param is a list of specified parameters, then validate
  return(val_param)

}