generatePAAdescriptorFileName <- function(param) {
  
  if (missing(param)) {
    val_param <- validatePAAdescriptorparam()
  } else {
    val_param <- validatePAAdescriptorparam(param)
  }
  
  switch(val_param$priority,
         'segNum' = {
           fileName <- sprintf('PAA-segNum-%d', val_param$segNum)
         },
         'segLen' = {
           fileName <- sprintf('PAA-segLen-%d', val_param$segLen)
         }
  )
  
  return(fileName)
}