# This version gives the same results as dp.m, but uses dpcore.mex to run ~200x faster.
# dpfast(M, C, T, G, window_size = NULL) --> [p, q, D, sc]
#    Use dynamic programming to find a minimum cost path through matrix M.
#
#    Return: 
#    - p, q: state sequence
#    - D: full minimum cost matrix 
#    - sc: local costs along best path
# 
#    Input: 
#    - M: distance matrix
#    - C: step matrix, with rows (i step, j step, cost factor)
#         Default is [1 1 1.0;0 1 1.0;1 0 1.0];
#         symmetric2 in dtw package [1 1 2.0;0 1 1.0;1 0 1.0];
#         Another good one is [1 1 1;1 0 1;0 1 1;1 2 2;2 1 2]
#    - T: selects traceback origin: 0 is to any edge; 1 is top right (default);
#         T > 1 finds path to min of anti-diagonal T points away from top-right
#    - G: optional, defines length of 'gulleys' for T=0 mode; default 0.5
#         (i.e. accept path to only 50% of edge nearest top-right)
#
# 2023-05-25 yanxinli@utexas.edu 
# Copyright (c) 2023 Yanxin Li <yanxinli@utexas.edu>

dpfast <- function(M, C, window_size, T = 1, G = 0.5) {

    if (missing(M)) {
        stop("Error: M is missing")
    }
    
    # Default step / cost matrix
    if (missing(C)) {
        C = matrix(c(1, 1, 1.0, 0, 1, 1.0, 1, 0, 1.0), ncol=3, byrow=TRUE) # symmetric1
    }
    
    # Default: path to top-right
    if (missing(T)) {
        T = 1
    }
    
    # How big are gulleys?
    if (missing(G)) {
        G = 0.5  # half the extent
    }
    
    if (sum(is.nan(M)) > 0) {
        stop("Error: Cost matrix includes NaNs")
    }
    
    if (min(M) < 0) {
        warning("Warning: cost matrix includes negative values; results may not be what you expect")
    }
    
    r <- nrow(M)
    c <- ncol(M)
    
    # Core cumulative cost calculation coded as mex
    if (missing(window_size)){
        window_size <- NULL
        D_phi <- dpcore(M, C)
    }
    else{
        D_phi <- dpcore_window(M, C, ws=window_size) 
    }
    
    D <- D_phi$D
    phi <- D_phi$phi
    
    p <- NULL
    q <- NULL
    
    ## Traceback from top left?
    #i <- r; j <- c
    if (T == 0) {
        # Traceback from lowest cost "to edge" (gulleys)
        TE <- D[r,]
        RE <- D[,c]
        # Eliminate points not in gulleys
        TE[1:round((1-G)*c)] <- max(D)
        RE[1:round((1-G)*r)] <- max(D)
        if (min(TE) < min(RE)) {
            i <- r
            j <- max(which(TE==min(TE)))
        } else {
            i <- max(which(RE==min(RE)))
            j <- c
        }
    } else {
        if (min(dim(D)) == 1) {
            # Degenerate D has only one row or one column - messes up diag
            i <- r
            j <- c
        } else {
            # Traceback from min of antidiagonal
            #stepback = floor(0.1*c)
            stepback <- T
            DD = D[, c:1]
            slice <- DD[row(DD) == col(DD)+(r-stepback)]
            ii <- which.min(slice)
            i <- r - stepback + ii
            j <- c + 1 - ii
        }
    }
    
    p <- i
    q <- j
    sc <- c()# M[p, q]
    
    while (i >= 1 && j >= 1) {
        if (i == 1 && j == 1) {
            break
        }
        tb <- phi[i, j]
        sc <- c(M[i, j] * C[tb,3], sc) ## UPDATE local cost with corresponding steppattern
        i <- i - C[tb, 1]
        j <- j - C[tb, 2]
        p <- c(i, p)
        q <- c(j, q)
    }
    sc <- c(M[i, j], sc) ## UPDATE
    
    return(list(p = p, q = q, D = D, sc = sc))

}