validateDWTdescriptorparam <- function(param) {
  if (missing(param) || !is.list(param)) {
    val_param <- list(numLevels = 2, selection = 'Haar', n = 2)
    return(val_param)
  }
  
  val_param <- param
  
  if (!'numLevels' %in% names(param)) {
    val_param$numLevels <- 2
  }
  
  if (!'selection' %in% names(param)) {
    val_param$selection <- 'Haar'
  }
  
  if (!'n' %in% names(param)) {
    val_param$n <- 2
  }
  
  return(val_param)
}