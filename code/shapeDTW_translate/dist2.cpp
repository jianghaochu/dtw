#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
NumericMatrix dist2(NumericMatrix x, NumericMatrix c) {
    // Get the number of data points and dimensions in x
    int ndata = x.nrow();
    int dimx = x.ncol();
    
    // Get the number of centres and dimensions in c
    int ncentres = c.nrow();
    int dimc = c.ncol();

    // Check that the dimensions of x and c match
    if ((dimx < dimc) | (dimx > dimc)) {
        Rprintf("Data dimension does not match dimension of centres");
    }

    // Calculate the squared Euclidean distance between 
    // each data point in x and each centre in c
    // n2 = matrix(0, nrow = ndata, ncol = ncentres)
    // for (i in 1:ncentres) {
    //     n2[, i] <- colSums((t(x) - t(c)[,i])^2)
    // }
}