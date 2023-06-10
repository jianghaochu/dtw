dist2 <- function(x, c) {
    # Get the number of data points and dimensions in x
    ndata <- nrow(x)
    dimx <- ncol(x)
    
    # Get the number of centres and dimensions in c
    ncentres <- nrow(c)
    dimc <- ncol(c)
    
    # Check that the dimensions of x and c match
    if (dimx != dimc) {
        stop("Data dimension does not match dimension of centres")
    }
    
    # Calculate the squared Euclidean distance between each data point in x and each centre in c
    n2 <- matrix(0, nrow = ndata, ncol = ncentres)
    for (i in 1:ncentres) {
        n2[, i] <- colSums((t(x) - t(c)[,i])^2)
    }
    
    #n2 <- matrix(rowSums(x^2), ndata, 1) %*% matrix(rep(1, ncentres), ncol = ncentres) + 
    #      matrix(rep(rowSums(c), ndata), ncol = ncentres, byrow = TRUE) -
    #      2 * x %*% t(c)
    
    # Return the squared Euclidean distance matrix
    return(n2)
}