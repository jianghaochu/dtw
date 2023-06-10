validatePAAparam <- function(param) {
  if (missing(param) || !is.list(param)) {
    val_param <- list(segNum = 10, segLen = NULL, priority = "segNum")
    return(val_param)
  }
  
  val_param <- list()
  
  if (!is.null(param$segNum)) {
    if (param$segNum <= 0) {
      val_param$segNum <- 10
    } else {
      val_param$segNum <- param$segNum
    }
  } else {
    val_param$segNum <- 10
  }
  
  if (!is.null(param$segLen)) {
    if (param$segLen <= 0) {
      val_param$segLen <- 5
    } else {
      val_param$segLen <- param$segLen
    }
  } else {
    val_param$segLen <- 5
  }
  
  if (!is.null(param$priority)) {
    val_param$priority <- param$priority
  } else {
    val_param$priority <- "segNum"
  }
  
  switch(val_param$priority,
         "segNum" = {
           if (is.null(val_param$segNum) || val_param$segNum <= 0) {
             val_param$segNum <- 10
           }
         },
         "segLen" = {
           if (is.null(val_param$segLen) || val_param$segLen <= 0) {
             val_param$segLen <- 5
           }
         },
         {
           val_param$priority <- "segNum"
           if (is.null(val_param$segNum) || val_param$segNum <= 0) {
             val_param$segNum <- 10
           }
         }
  )
  
  return(val_param)
  
}

#validatePAAparam()
