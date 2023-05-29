DTWfast <- function(p, q) {

  p <- as.matrix(p)
  q <- as.matrix(q)
  stopifnot(ncol(p) == ncol(q))

  d <- dist2(p, q)
  dp_result <- dpfast(d)
  
  idxp <- dp_result$p
  idxq <- dp_result$q
  cD <- dp_result$D
  pc <- dp_result$sc
  
  match <- cbind(idxp, idxq)
  dist <- sum(pc)
  
  return(list(dist = dist, match = match))

}

# Example usage
p <- matrix(c(1, 2, 3, 4, 5), ncol = 1)
q <- matrix(c(6, 7, 8, 9, 10), ncol = 1)

result <- DTWfast(p, q)
dist <- result$dist
match <- result$match