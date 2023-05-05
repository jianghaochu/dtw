validateSlopedescriptorparam <- function(param = NULL) {
  
  val_param <- list()
  
  if (is.null(param) || !is.list(param)) {
    val_param$xscale <- 0.1
    val_param$segNum <- 10
    val_param$fit <- "regression"
    return(val_param)
  }
  
  if (!is.null(param$xscale)) {
    val_param$xscale <- param$xscale
  } else {
    val_param$xscale <- 0.1
  }
  
  if (!is.null(param$segNum)) {
    val_param$segNum <- param$segNum
  } else {
    val_param$segNum <- 10
  }
  
  if (!is.null(param$fit)) {
    val_param$fit <- param$fit
  } else {
    val_param$fit <- "regression"
  }
  
  return(val_param)
}