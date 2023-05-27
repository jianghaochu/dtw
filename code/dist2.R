dist2 <- function(x, c, wt_func) {
    
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
    
    if (missing(wt_func)) {
        for (i in 1:ncentres) {
            n2[, i] <- sqrt(colSums((t(x) - t(c)[, i])^2)) 
        }
    } else {
        for (i in 1:ncentres) {
            w_i <- wt_func(i = i, j = 1:ndata, m = ndata, type = 'relative')
            n2[, i] <- sqrt(rowSums((w_i * t(t(x) - t(c)[, i]))^2)) 
        }
    }    

    return(n2)

}