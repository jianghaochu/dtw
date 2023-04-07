hist_cost_2 <- function(BH1, BH2) {
  
  # same as hist_cost.m but BH1 and BH2 can be of different lengths
  
  nsamp1 <- dim(BH1)[1]
  nbins <- dim(BH1)[2]
  nsamp2 <- dim(BH2)[1]
  
  BH1n <- BH1 / matrix(rep(rowSums(BH1)+eps, nbins), nrow=nsamp1, byrow=TRUE)
  BH2n <- BH2 / matrix(rep(rowSums(BH2)+eps, nbins), nrow=nsamp2, byrow=TRUE)
  
  tmp1 <- array(rep(BH1n, each=nsamp2), dim=c(nsamp1, nsamp2, nbins))
  tmp2 <- array(rep(t(BH2n), each=nsamp1), dim=c(nsamp1, nsamp2, nbins))
  
  HC <- 0.5 * apply((tmp1 - tmp2)^2 / (tmp1 + tmp2 + eps), c(1, 2), sum)
  
  return(HC)
}
