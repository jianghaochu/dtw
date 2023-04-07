validateHOG1Dparam <- function(param = NULL) {
  # a typical valid setting
  # {
  #   param.blocks    = [1 2];  # unit: cell
  #   param.cells     = [1 25]; # unit: t
  #   param.gradmethod = 'centered'; # 'centered'
  #   param.nbins = 8;
  #   param.sign = 'true';
  # }
  if (is.null(param) || !is.list(param)) {
    val_param <- list(
      # blocks = c(1, 2),
      cells = c(1, 25),
      overlap = 0,
      gradmethod = "centered",
      nbins = 8,
      sign = "true",
      xscale = 0.1
      # cutoff = c(2, 51)
    )
    return(val_param)
  }
  
  val_param <- param
  
  if (!("overlap" %in% names(val_param))) {
    val_param$overlap <- 12
  }
  
  if (!("xscale" %in% names(val_param))) {
    val_param$xscale <- 0.1
  }
  
  if (!("cells" %in% names(val_param))) {
    val_param$cells <- c(1, 25)
  }
  
  if (!("gradmethod" %in% names(val_param))) {
    val_param$gradmethod <- "uncentered"
  }
  
  if (!("nbins" %in% names(val_param))) {
    val_param$nbins <- 8
  }
  
  if (!("sign" %in% names(val_param))) {
    val_param$sign <- "true"
  }
  
  return(val_param)
}