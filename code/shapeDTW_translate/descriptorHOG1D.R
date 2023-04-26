# Histogram of Oriented Gradients, also known as HOG, is a feature descriptor 
# like the Canny Edge Detector, SIFT (Scale Invariant and Feature Transform). 
# It is used in computer vision and image processing for the purpose of object detection. 
# The technique counts occurrences of gradient orientation in the localized portion 
# of an image/time series. This method is quite similar to Edge Orientation Histograms 
# and Scale Invariant and Feature Transformation (SIFT). The HOG descriptor 
# focuses on the structure or the shape of an object.

# Inspired by great performance of HOG descriptor on 2D images and HOG3D
# descriptors on 3D videos, we introduce HOG1D into time series with L2 normalization
descriptorHOG1D <- function(sequences, param=NULL) {
  
  # Check if param is provided, otherwise use default parameter values
  if (is.null(param)) {
    param <- list(
      # blocks=c(1,2), # unit: cell
      cells=c(1,25), # unit: t
      overlap=12, 
      gradmethod="centered", 
      nbins=8,
      sign=TRUE,
      # cutoff=c(2,51), 
      xscale=0.1
      )
  }
  
  # Check if the input sequences is provided, otherwise throw an error
  if (missing(sequences)) {
    stop("Not enough inputs\n")
  }
  
  # In this function, instead of considering zero padding, the input
  # 'sequences' is usually longer than the target sequences, therefore,
  # additional parameter 'cutoff' is necessary to specify the front and
  # end 'cutoff' locations of the target sequences in terms of the reference sequences
  
  # Validate HOG1D parameter values
  val_param <- validateHOG1Dparam(param)
  cells <- val_param$cells
  gradmethod <- val_param$gradmethod
  nbins <- val_param$nbins
  dx_scale <- val_param$xscale
  # cutoff <- val_param$cutoff
  sequences <- sequences[,1]
  seqlen <- length(sequences)
  
  # Calculate cell length and overlap
  sCell <- cells[2]
  overlap <- val_param$overlap
  
  # Define angle ranges for HOG descriptors
  if (val_param$sign) {
    angles <- seq(-pi/2, pi/2, length.out=nbins+1)
  } else {
    angles <- seq(0, pi/2, length.out=nbins+1)
  }
  
  centerAngles <- numeric(nbins)
  for (i in 1:nbins) {
    centerAngles[i] <- (angles[i] + angles[i+1])/2
  }
  
  # Now we only support maximal number of 10 blocks
  ref_lens <- numeric(10)
  for (i in 1:10) {
    ref_lens[i] <- sCell * i - overlap * (i-1)
  }

  idx <- which.min(abs(ref_lens - length(sequences)))
  if ((length(sequences) - ref_lens[idx]) > 0 && (length(sequences) - ref_lens[idx]) < 2) {
    sequences <- c(sequences[1], sequences, sequences[length(sequences)])
  } 
  else if ((length(sequences) - ref_lens[idx]) <= 0) {
    margin <- ref_lens[idx] - length(sequences) + 2
    leftMargin <- round(margin/2)
    rightMargin <- margin - leftMargin
    sequences <- c(rep(sequences[1], leftMargin), sequences, rep(sequences[length(sequences)], rightMargin))
  }
  
  nBlock <- idx
  descriptor <- matrix(0, nBlock, nbins)
  idx_start <- 1
  
  for (i in 1:nBlock) {
    for (j in 1:sCell) {
      idx <- i*sCell - (i-1)*overlap - sCell + j
      cidx <- idx_start + idx - 1
      
      switch (gradmethod, 
              "uncentered" = {
                sidx <- cidx
                eidx <- cidx + 1
                if (sidx < 1 || eidx > seqlen) {
                  next
                }
                dx <- 1*dx_scale
                dy <- sequences[eidx] - sequences[sidx]
                ang <- atan2(dy, dx)
                mag <- dy/dx
              }
              "centered" = {
                sidx <- cidx - 1
                eidx <- cidx + 1
                if (sidx < 1 || eidx > seqlen) {
                  next
                }
                dx <- 2*dx_scale
                dy <- sequences[eidx] - sequences[sidx]
                ang <- atan2(dy, dx)
                mag <- dy/dx
              }
      )
      
      switch (val_param$sign, 
              "false" = {
                stop("Now param.sign can only be true\n")
              },
              "true" = {
                n <- whichInterval(angles, ang)
                if (n == 1 && ang <= centerAngles[1]) {
                  descriptor[i, n] <- descriptor[i, n] + abs(mag)
                } 
                else if (n == nbins && ang > centerAngles[nbins]) {
                  descriptor[i, n] <- descriptor[i, n] + abs(mag)
                } 
                else {
                  if (abs(angles[n] - ang) > abs(angles[n+1] - ang)) {
                    ang1 <- centerAngles[n]
                    ang2 <- centerAngles[n+1]
                    
                    descriptor[i, n] <- descriptor[i, n] + abs(mag) * cos(ang1-ang)
                    descriptor[i, n+1] <- descriptor[i, n+1] + abs(mag) * cos(ang2-ang)
                  } 
                  else {
                    ang1 <- centerAngles[n-1]
                    ang2 <- centerAngles[n]
                    
                    descriptor[i, n-1] <- descriptor[i, n-1] + abs(mag) * cos(ang1-ang)
                    descriptor[i, n] <- descriptor[i, n] + abs(mag) * cos(ang2-ang)
                  }                        
                }
              }
      )
    }
  }
  # epsilon <- 1.0e-6
  # descriptor <- descriptor / (matrix(sqrt(rowSums(descriptor^2)), ncol = nbins, byrow = TRUE) + epsilon)
  
  subdescriptors <- descriptor
  descriptor <- t(descriptor)
  descriptor <- as.vector(descriptor)
  
  #epsilon <- 1.0e-6
  #descriptor <- descriptor / (sqrt(sum(descriptor * descriptor)) + epsilon)
}