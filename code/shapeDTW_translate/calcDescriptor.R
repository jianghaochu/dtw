calcDescriptor <- function(subsequence, descriptorName = "HOG1D", param = NULL) {
  
  if (ncol(subsequence) != 1) {
    stop("The input subsequence should be one-dimensional\n")
  }
  
  if (missing(param)) {
    param <- validateHOG1Dparam()
  }
  
  switch(descriptorName,
         "HOG1D" = {
           val_param <- validateHOG1Dparam(param)
           descriptor <- descriptorHOG1D(subsequence, val_param)
         },
         "Windau" = {
           # val_param <- validateWindauparam(param)
           # bGravityDirection <- val_param$bYDirection
           descriptor <- descriptorWindau(subsequence)
         },
         "Baydogan" = {
           val_param <- validateBaydoganparam(param)
           descriptor <- descriptorBaydogan(subsequence, val_param)
         },
         "PAA" = {
           val_param <- validatePAAdescriptorparam(param)
           descriptor <- descriptorPAA(subsequence, val_param)
         },
         "PLA" = {
           val_param <- validatePLAdescriptorparam(param)
           descriptor <- descriptorPLA(subsequence, val_param)
         },
         "dePLA" = {
           val_param <- validatedePLAdescriptorparam(param)
           descriptor <- descriptordePLA(subsequence, val_param)
         },
         "self" = {
           descriptor <- descriptorSelf(subsequence)
         },
         "SlopePAA" = {
           val_param <- validateSlopePAAdescriptorparam(param)
           descriptor <- descriptorSlopePAA(subsequence, val_param)
         },
         "HOG1DPAA" = {
           val_param <- validateHOG1DPAAdescriptorparam(param)
           descriptor <- descriptorHOG1DPAA(subsequence, val_param)
         },
         "HOG1DDWT" = {
           val_param <- validateHOG1DDWTdescriptorparam(param)
           descriptor <- descriptorHOG1DDWT(subsequence, val_param)
         },
         "DFT" = {
           val_param <- validateDFTdescriptorparam(param)
           descriptor <- descriptorDFT(subsequence, val_param)
         },
         "DWT" = {
           val_param <- validateDWTdescriptorparam(param)
           descriptor <- descriptorDWT(subsequence, val_param)
         },
         "Slope" = {
           val_param <- validateSlopedescriptorparam(param)
           descriptor <- descriptorSlope(subsequence, val_param)
         },
         "Gradient" = {
           val_param <- validateGradientdescriptorparam(param)
           descriptor <- descriptorGradient(subsequence, val_param)
         },
         "GradientSelf" = {
           val_param <- validateGradSelfdescriptorparam(param)
           descriptor <- descriptorGradSelf(subsequence, val_param)
         },
         "HOG1DDSP" = {
           val_param <- validateHOG1DDSPparam(param)
           descriptor <- descriptorHOG1DDSP(subsequence, val_param)
         },
         "ShapeContext" = {
           val_param <- validateShapeContextparam(param)
           descriptor <- descriptorShapeContext(subsequence, val_param)
         },
         stop("Only support 17 descriptors\n")
  )
  
  return(descriptor)
}
