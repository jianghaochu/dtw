dist2 <- function(x, c) {
  # get dimensions of input matrices
  ndata <- nrow(x)
  dimx <- ncol(x)
  ncentres <- nrow(c)
  dimc <- ncol(c)
  
  # check if dimensions match
  if (dimx != dimc) {
    stop("Data dimension does not match dimension of centres")
  }
  
  # calculate squared Euclidean distance
  n2 <- (matrix(rep(1, ncentres), nrow = ndata, ncol = ncentres) %*% t(colSums(x^2))) +
    (matrix(rep(1, ndata), nrow = ndata, ncol = ncentres) %*% t(colSums(c^2))) -
    2 * x %*% t(c)
  
  # return result
  return(n2)
}

# Not working for the following example:
# > dist2(matrix(c(1, 2, 3, 4, 5, 6), ncol = 3), matrix(c(1, 2, 3, 4, 5, 6), ncol = 3))
# Error in (matrix(rep(1, ncentres), nrow = ndata, ncol = ncentres) %*%  : 
#   non-conformable arrays
