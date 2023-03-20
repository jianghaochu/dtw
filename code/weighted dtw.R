rm(list = ls())

# Load Package and Data
library('ggplot2')
library("dtw")
data("aami3a")

# Check data
ref <- window(aami3a, start = 0, end = 2)
test <- window(aami3a, start = 2.7, end = 5)
# length(ref)/length(test) = 0.87

df_ref <- data.frame('time'=c(1:length(ref)), 'value'=c(ref), 'type'='ref')
df_test <- data.frame('time'=c(1:length(test)), 'value'=c(test), 'type'='test')
df <- rbind(df_ref, df_test)
ggplot(data=df, aes(x=time, y=value, color=type)) + geom_line()

# Move time label
df$time_align <- df$time
df[df$type =='test',]$time_align <- df[df$type =='test',]$time - 
  c(length(test)-length(ref) - 5)

ggplot(data=df, aes(x=time_align, y=value, color=type)) + geom_line()

# DTW
alignment <- dtw(ref, test, keep.internals = TRUE)
plot(alignment, type = "two", off = 1, match.lty = 2, match.indices = 100)
title("DTW Alignment")

# Weighted DTW (Jeong el al. 2011)
# x, y: scalars of values to be compared
# tx, ty: corresponding indices
# p: power of distance
# g: empirical constant that controls the level of MLWF curvature 
#    g = 0, constant Weight
#    g = 0.05, nearly linear
#    g = 0.25, normal sigmoid pattern
#    g = 3, two distinct weights (similar to step or indicator function)

# plot(seq(1, 10, length.out=100)-5, 
#      1/(1 + exp(-(seq(1, 10, length.out=100)-5))))

weighted_dtw_distance <- function(x, y, tx, ty, p = 1, g = 0.25) {
  # eq(2) where w_ij is given by eq(3)
  # the common choice of p is 1 or 2
  gamma = abs(x[1]-y[1])^p
  
  # Modified Logistic Weight Function (MLWF)
  # w_ij = w_max / (1 + exp( -g*( abs(tx - ty)- m_c )))
  # w_max does not affect the algorithm and is hence set to be 1
  # m_c is the midpoint of a sequence
  # (how to understand m_c when comparing two seq?)
  # m_c is the midpoint of i seq where i is distance btwn two data point
  # thus, m_c is the midpoint of max(i)
  
  # MLWF = 1 / (1 + exp(-g*( abs(tx-ty)/(length(x)+length(y)) )))
  MLWF = 1 / (1 + exp(-g*( abs(tx-ty) - max(length(x)-length(y))/2 )))
  return(gamma * MLWF)
}

# need to add an argument restricting the difference window (i.e., max(tx-ty))
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
  cost_mat <- calc_cost_matrix(sequence1, sequence2, dist.method = dist.method)
  return(dtw(cost_mat, keep.internals = TRUE))
}

alignment_w <- weighted_dtw(ref, test, weighted_dtw_distance)
plot(alignment_w, xts=ref, yts=test, type="two", off=1, match.lty=2, 
     match.indices=100)
title("Weighted DTW Alignment")


# Exponentially Weighted DTW
# need to change StepPattern in dtw()? e.g., in symmetric2, every step counts 1 
# in exponential weights across time, every step should be related to its weight
exponential_weighted_distance <- function(x, y, tx, ty, p = 1, alpha = 0.99) {
  return(alpha ^ -(tx+ty) * abs(x-y) ^ p)
}
alignment_ew = weighted_dtw(ref, test, exponential_weighted_distance)
plot(alignment_ew, xts=ref, yts=test, type="two", off=1, match.lty=2, match.indices=100)
title("Exponentially Weighted DTW Alignment")