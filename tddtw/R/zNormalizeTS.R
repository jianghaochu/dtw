zNormalizeTS <- function(ts) {
  std_ts <- sd(ts)
  me_ts <- mean(ts)
  zn_ts <- (ts - me_ts) / std_ts
  return(zn_ts)
}