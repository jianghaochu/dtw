library("dtw")
data("aami3a")
ref <- window(aami3a,start=0,end=2)
test <- window(aami3a,start=2.7,end=5)

# DTW
alignment <- dtw(test,ref)
ref <- window(aami3a,start=0,end=2)
test <- window(aami3a,start=2.7,end=5)
plot(dtw(test, ref, k=TRUE), type="two", off=1, match.lty=2, match.indices=100)
title("DTW Alignment")

# Weighted DTW (Jeong el al. 2011)
# x, y: scalars to compare where x[1] is the value of x, x[2] is the index of x.
# p: power of distance
# g: empirical constant that controls the level of curvature of Modified Logistic Weight Function (MLWF)
#    g = 0, constant Weight
#    g = 0.05, nearly linear
#    g = 0.25, normal sigmoid pattern
#    g = 3, two distinct weights (similar to step or indicator function)
weighted_dtw_distance <- function(x, y, tx, ty, p = 1, g = 0.25) {
  # return((abs(x[1]-y[1])^p) / (1 + exp(-g*(abs(x[2]-y[2])-length(x)%/%2))))  # weight become 0
  return((abs(x[1]-y[1])^p) / (1 + exp(-g*(abs(tx-ty) / (length(x)+length(y))))))  # modify to avoid 0 weight
}

calc_cost_matrix <- function(x, y, dist.method) {
  cost_matrix = matrix(nrow = length(x), ncol = length(y))
  for (i in 1:length(x)) {
    for (j in 1:length(y)) {
      cost_matrix[i, j] = dist.method(x[i], y[j], length(x)-i, length(y)-j)
    }
  }
  return(cost_matrix)
}

weighted_dtw <- function(sequence1, sequence2, dist.method) {
  return(dtw(calc_cost_matrix(sequence1, sequence2, dist.method = dist.method), k=TRUE))
}
alignment = weighted_dtw(ref, test, weighted_dtw_distance)
plot(alignment, xts=ref, yts=test, type="two", off=1, match.lty=2, match.indices=100)
title("Weighted DTW Alignment")

# Exponentially Weighted DTW
exponential_weighted_distance <- function(x, y, tx, ty, p = 1, alpha = 0.99) {
  return(alpha ^ -(tx+ty) * abs(x-y) ^ p)
}
alignment = weighted_dtw(ref, test, exponential_weighted_distance)
plot(alignment, xts=ref, yts=test, type="two", off=1, match.lty=2, match.indices=100)
title("Exponentially Weighted DTW Alignment")