validateHOG1Dparam <- function(param = NULL) {
  
  # a typical valid setting
  # param.blocks <- c(1, 2) # unit: cell
  param.cells <- c(1, 25) # unit: t
  val_param <- list(cells = param.cells, overlap = 0, gradmethod = 'centered', nbins = 8, sign = 'true', xscale = 0.1)
  
  if (is.null(param)) {
    return(val_param)
  }
  
  if (!is.list(param)) {
    return(val_param)
  }
  
  if (!'overlap' %in% names(param)) {
    val_param$overlap <- 12
  } else {
    val_param$overlap <- param$overlap
  }
  
  if (!'xscale' %in% names(param)) {
    val_param$xscale <- 0.1
  } else {
    val_param$xscale <- param$xscale
  }
  
  if (!'cells' %in% names(param)) {
    val_param$cells <- c(1, 25)
  } else {
    val_param$cells <- param$cells
  }
  
  if (!'gradmethod' %in% names(param)) {
    val_param$gradmethod <- 'uncentered'
  } else {
    val_param$gradmethod <- param$gradmethod
  }
  
  if (!'nbins' %in% names(param)) {
    val_param$nbins <- 8
  } else {
    val_param$nbins <- param$nbins
  }
  
  if (!'sign' %in% names(param)) {
    val_param$sign <- 'true'
  } else {
    val_param$sign <- param$sign
  }
  
  return(val_param)
}
