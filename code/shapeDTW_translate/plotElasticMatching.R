plotElasticMatching <- function(s, t, match, f_shift = TRUE, h = NULL) {
  if (length(s) != length(unlist(s)) || length(t) != length(unlist(t))) {
    stop("Only support vector inputs\n")
  }
  
  if (ncol(match) != 2) {
    match <- t(match)
  }
  
  if (!exists("f_shift") || is.null(f_shift)) {
    f_shift <- TRUE
  }
  
  if (!exists("h") || is.null(h)) {
    h <- NULL
  }
  
  if (f_shift) {
    mins <- min(s)
    maxs <- max(s)
    mint <- min(t)
    maxt <- max(t)
    
    shift <- max(maxt - mint, maxs - mins)
  } else {
    shift <- 0
  }
  
  s <- s + shift
  
  xs <- match[, 1]
  xt <- match[, 2]
  
  ys <- s[xs]
  yt <- t[xt]
  
  lPath <- length(match)
  
  plot(s, type = "o", col = "red", pch = 16, lwd = 2, xlab = "", ylab = "", xlim = c(1, length(s)), ylim = range(s, t))
  points(t, type = "s", col = "black", pch = 15, lwd = 2)
  for (i in 1:lPath) {
    lines(c(xs[i], xt[i]), c(ys[i], yt[i]), col = "blue")
  }
  axis(1, at = NULL, labels = FALSE)
  axis(2, at = NULL, labels = FALSE)
}

# Example usage
#s <- c(1, 2, 3, 4, 5)
#t <- c(6, 7, 8, 9, 10)
#match <- matrix(c(1, 1, 2, 2, 3, 3, 4, 4, 5, 5), ncol = 2)

#plotElasticMatching(s, t, match)
