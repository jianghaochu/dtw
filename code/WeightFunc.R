# Define weight function - relative and absolute
weight_fcn <- function(i, j, m, type, g = 0.1, w_max = 1) {
    
    if (!type %in% c("relative", "absolute")) {
        stop("Type should be either 'relative' or 'absolute'")
    }
    
    m_c <- round(m/2, 0)
    idx_diff <- (type == "relative") * abs(i-j) + (type == "absolute") * i
    weight <- w_max / (1 + exp(-g *(idx_diff - m_c)) )
    return(weight)
    
}

# Define modified logistic weight function by adding time-dependent weights: most recent time will get higher weights 
weight_fcn_prod <- function(i, j, m, type = 'relative', g = 0.1, w_max = 1) {

    m_c <- round(m/2, 0)
    weight <- sqrt(w_max / (1 + exp(-g *(abs(i-j) - m_c)) ) * w_max / (1 + exp(-g *(i - m_c))))
    return(weight)

}

mlwf <- function(d, m, g = 0.1, w_max = 1) {

    m_c <- round(m/2, 0)
    weight <- w_max / (1 + exp(-g *(d- m_c)) )
    return(weight)
    
}