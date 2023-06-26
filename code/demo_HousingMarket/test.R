rm(list = ls())
setwd("C:/Users/yh-wa/github/dtw/code")

library(data.table)
library(magrittr)
library(ggplot2)
library(Rcpp)
library(dtw)
library(CausalImpact)
library(bsts)
library(zoo)

sourceCpp("shapeDTW_translate/dpcore.cpp")
source("dpfast.R")
source("dist2.R")
source("weightFunc.R")
source("shapeDTW_translate/shapeDTW.R")
source("shapeDTW_translate/DTWfast.R")
source("shapeDTW_translate/hist_cost_2.R")
source("shapeDTW_translate/zNormalizeTS.R")
source("shapeDTW_translate/samplingSequencesIdx.R")
source("shapeDTW_translate/calcDescriptor.R")
source("shapeDTW_translate/descriptorPAA.R")
source("shapeDTW_translate/PAA.R")
source("shapeDTW_translate/descriptorHOG1D.R")
source("shapeDTW_translate/validatePAAparam.R")
source("shapeDTW_translate/validatePAAdescriptorparam.R")
source("shapeDTW_translate/validateHOG1Dparam.R")
source("shapeDTW_translate/validateDWTdescriptorparam.R")
source("shapeDTW_translate/whichInterval.R")
source("shapeDTW_translate/wpath2mat.R")
source("shapeDTW_translate/plotElasticMatching.R")

options(repr.plot.width = 16, repr.plot.height = 5)

# Load data
dt <- fread("demo_HousingMarket/data_sfh.csv")
str(dt)

# Check number of NA's
as.data.frame(colSums(is.na(dt)))

# Select metros without NAs
dt[, ':='(id_NA = max(is.na(median_sale_price)|is.na(median_ppsf)), n_month = .N), by='region']
dt_nonNA <- dt[id_NA == FALSE]

metro_list_all <- unique(dt$region)
metro_list_nonNA <- unique(dt_nonNA$region)
cat(paste0("Number of All Regions: ", length(metro_list_all),
           "\nNumber of Regions w/o NAs: ", length(metro_list_nonNA)))

# Check the distribution of data length by metro
table(dt_nonNA[, .(len = unique(n_month)), by = "region"]$len)

# Find metros of interest
metro_interest <- c("Austin, TX", "New York, NY", "Seattle, WA", "San Jose, CA", "Detroit, MI", "Chicago, IL")
for (m in metro_interest) {
  metro <- grep(m, metro_list_nonNA, value = TRUE)
  print(dt_nonNA[region %in% metro
                 , .(start = min(period_begin), end = max(period_begin), n_month = unique(n_month))
                 , by = "region"])
}

# Select metros with the same length of data (7 years and 4 months up to April 2023)
date_initial <- as.Date("2016-01-01")
dt_sel <- dt_nonNA[period_begin >= date_initial][
  , sel := max(sum(period_begin >= date_initial) == ((2023 - year(date_initial)) * 12 + 4))
  , by = "region"][sel == 1]

# Get the list of metros
metro_list_sel <- unique(dt_sel$region)
print(paste("Number of regions is", length(metro_list_sel)))
print(paste("Number of observations is", nrow(dt_sel)))

# Initialization
steppattern <- matrix(c(1, 1, 2.0, 0, 1, 1.0, 1, 0, 1.0), ncol = 3, byrow = TRUE)
metrics <- c("dtw", "wdtw", "td_wdtw", "shapedtw", "td_shapedtw")

# Normalize the target variables
var_sel <- c("median_sale_price", "median_ppsf")
dt_sel[, (paste0(var_sel, "_normalized")) := lapply(.SD, zNormalizeTS)
       , .SDcols = var_sel, by = "region"]


library(foreach)
library(doParallel)

numCores <- detectCores()
print(numCores)
cl <- makeCluster(numCores/2)
clusterExport(cl, c("dist2", "dpfast", "dpcore", "weight_fcn"))
registerDoParallel(cl)

# stopCluster(cl)

m <- 50
set.seed(20230625)
random_metro <- sample(unique(dt_sel$region), m, replace = FALSE)
print(random_metro)

metro_name <- random_metro[1]


# Results initialization
metro_t_dist <- dt_sel[, .(dtw = 0, wdtw = 0, td_wdtw = 0, shapedtw = 0, td_shapedtw = 0), by = "region"]
metro_t_dist_results <- list()

# Treatment metro sequence, ie, query sequence
metro_t <- grep(metro_name, metro_list_sel, value = TRUE)
seq_q <- as.matrix(dt_sel[region == metro_t]$median_sale_price_normalized, ncol = 1)

# https://stackoverflow.com/questions/25062383/cant-run-rcpp-function-in-foreach-null-value-passed-as-symbol-address
res <- 
  foreach (i = 1:8, .packages = c("data.table", "Rcpp"),
           .noexport = c('dpcore')) %dopar% {
    m <- metro_list_sel[i]
    # Reference sequences
    seq_ref <- as.matrix(dt_sel[region == m]$median_sale_price_normalized, ncol = 1)
    
    sourceCpp("shapeDTW_translate/dpcore.cpp")
    
    # DTW
    dist_DTW <- dist2(x = seq_q, c = seq_ref)
    align_DTW <- dpfast(dist_DTW, C = steppattern)
    # WDTW
    dist_WDTW <- dist2(x = seq_q, c = seq_ref, wt_func = weight_fcn)
    align_WDTW <- dpfast(dist_WDTW, C = steppattern)
    # TD-WDTW
    dist_td_WDTW <- dist2(x = seq_q, c = seq_ref, wt_func = weight_fcn_prod)
    align_td_WDTW <- dpfast(dist_td_WDTW, C = steppattern)
    # ShapeDTW
    align_shapeDTW <- shapeDTW(c(seq_q), c(seq_ref), seqlen = 5)
    # TD-ShapeDTW
    align_td_shapeDTW <- shapeDTW(c(seq_q), c(seq_ref), seqlen = 5, wt_func = weight_fcn_prod)
    
    list('full' = list("align_DTW" = align_DTW,
              "align_WDTW" = align_WDTW,
              "align_td_WDTW" = align_td_WDTW,
              "align_shapeDTW" = align_shapeDTW,
              "align_td_shapeDTW" = align_td_shapeDTW),
         'simple' = list('dtw' = sum(align_DTW$sc),
              'wdtw' = sum(align_WDTW$sc),
              'td_wdtw' = sum(align_td_WDTW$sc),
              'shapedtw' = align_shapeDTW$distDescriptor,
              'td_shapedtw' = align_td_shapeDTW$distDescriptor))
  }

length(res)

res[[1]]


# Loop through all regions and calculate varying distances
tik <- Sys.time()
foreach (i = 1:8, .packages = c("data.table")) %dopar% {
  m <- metro_list_sel[i]
  # Reference sequences
  seq_ref <- as.matrix(dt_sel[region == m]$median_sale_price_normalized, ncol = 1)

  # DTW
  dist_DTW <- dist2(x = seq_q, c = seq_ref)
  align_DTW <- dpfast(dist_DTW, C = steppattern)
  # WDTW
  dist_WDTW <- dist2(x = seq_q, c = seq_ref, wt_func = weight_fcn)
  align_WDTW <- dpfast(dist_WDTW, C = steppattern)
  # TD-WDTW
  dist_td_WDTW <- dist2(x = seq_q, c = seq_ref, wt_func = weight_fcn_prod)
  align_td_WDTW <- dpfast(dist_td_WDTW, C = steppattern)
  # ShapeDTW
  align_shapeDTW <- shapeDTW(c(seq_q), c(seq_ref), seqlen = 5)
  # TD-ShapeDTW
  align_td_shapeDTW <- shapeDTW(c(seq_q), c(seq_ref), seqlen = 5, wt_func = weight_fcn_prod) 

  metro_t_dist_results[m] <- list(list("align_DTW" = align_DTW,
                                       "align_WDTW" = align_WDTW,
                                       "align_td_WDTW" = align_td_WDTW,
                                       "align_shapeDTW" = align_shapeDTW,
                                       "align_td_shapeDTW" = align_td_shapeDTW))

  metro_t_dist[region==m, ":="(dtw = sum(align_DTW$sc),
                               wdtw = sum(align_WDTW$sc),
                               td_wdtw = sum(align_td_WDTW$sc),
                               shapedtw = align_shapeDTW$distDescriptor,
                               td_shapedtw = align_td_shapeDTW$distDescriptor)]
}
tok <- Sys.time()
print(round(tok-tik, 2))

















calMetroDist <- function(metro_name){
  
  # Results initialization
  metro_t_dist <- dt_sel[, .(dtw = 0, wdtw = 0, td_wdtw = 0, shapedtw = 0, td_shapedtw = 0), by = "region"]
  metro_t_dist_results <- list()
  
  # Treatment metro sequence, ie, query sequence
  metro_t <- grep(metro_name, metro_list_sel, value = TRUE)
  seq_q <- as.matrix(dt_sel[region == metro_t]$median_sale_price_normalized, ncol = 1)
  
  # Loop through all regions and calculate varying distances
  tik <- Sys.time()
  foreach (i = 1:length(metro_list_sel)) %dopar% {
    m <- metro_list_sel[i]
    # Reference sequences
    seq_ref <- as.matrix(dt_sel[region == m]$median_sale_price_normalized, ncol = 1)
    
    # DTW
    dist_DTW <- dist2(x = seq_q, c = seq_ref)
    align_DTW <- dpfast(dist_DTW, C = steppattern)
    # WDTW
    dist_WDTW <- dist2(x = seq_q, c = seq_ref, wt_func = weight_fcn)
    align_WDTW <- dpfast(dist_WDTW, C = steppattern)
    # TD-WDTW
    dist_td_WDTW <- dist2(x = seq_q, c = seq_ref, wt_func = weight_fcn_prod)
    align_td_WDTW <- dpfast(dist_td_WDTW, C = steppattern)
    # ShapeDTW
    align_shapeDTW <- shapeDTW(c(seq_q), c(seq_ref), seqlen = 5)
    # TD-ShapeDTW
    align_td_shapeDTW <- shapeDTW(c(seq_q), c(seq_ref), seqlen = 5, wt_func = weight_fcn_prod) ### ???
    
    metro_t_dist_results[m] <- list(list("align_DTW" = align_DTW,
                                         "align_WDTW" = align_WDTW,
                                         "align_td_WDTW" = align_td_WDTW,
                                         "align_shapeDTW" = align_shapeDTW,
                                         "align_td_shapeDTW" = align_td_shapeDTW))
    
    metro_t_dist[region==m, ":="(dtw = sum(align_DTW$sc),
                                 wdtw = sum(align_WDTW$sc),
                                 td_wdtw = sum(align_td_WDTW$sc),
                                 shapedtw = align_shapeDTW$distDescriptor,
                                 td_shapedtw = align_td_shapeDTW$distDescriptor)]
  }
  tok <- Sys.time()
  print(round(tok-tik, 2))
  
  metro_t_dist[, (paste0(metrics, "_rank")) := lapply(.SD, function(x) frank(x, ties.method = "min"))
               , .SDcols=metrics]
  
  return(list("metro_t_dist" = metro_t_dist,
              "metro_t_dist_results" = metro_t_dist_results))
}

















# Specify test date and end date
end_date <- as.Date(max(dt_sel$period_begin))
print(end_date)
test_date <- as.Date("2023-01-01")

# Initialization
metrics_rank <- paste0(metrics, "_rank")
print(metrics_rank)
month_list <- as.Date(sort(unique(dt_sel$period_begin)))

# Number of months
n <- length(month_list)
print(n)

m <- 50
set.seed(20230625)
random_metro <- sample(unique(dt_sel$region), m, replace = FALSE)
print(random_metro)

dist_mat_1 <- calMetroDist(metro_name = random_metro[1])

CausalImpactModel <- function(dist_mat, alpha = 0.05, num_query = 10){
  # metro_name <- 'San Diego, CA metro area'
  # alpha <- 0.05
  # num_query <- 10
  # i <- 5
  
  # Get the distances and ranking of control metros
  metro_t_dist <- as.data.frame(dist_mat$metro_t_dist)
  metro_t_dist_results <- dist_mat$metro_t_dist_results
  metro_t <- metro_t_dist[metro_t_dist$dtw_rank==1, 'region']
  
  causal_effect_results_list <- plot_results_list <- mape_results_list <-list()
  for (i in 1:length(metrics_rank)){
    # Get top 10 control and the treatment metro
    metro_sel <- metro_t_dist[metro_t_dist[, metrics_rank[i]]<=(num_query+1), 'region']
    metro_c <- metro_sel[metro_sel!=metro_t]
    
    # Get the target variable: median sale price
    dt_metro_t <- dt_sel[(region == metro_t) & (period_begin <= end_date), 
                         c("period_begin", "median_sale_price")]
    dt_metro_c_all <- dt_sel[(region %in% metro_c) & (period_begin <= end_date), 
                             c("region", "period_begin", "median_sale_price")]
    dt_metro_c <- dcast(dt_metro_c_all, period_begin ~ region, value.var='median_sale_price')
    
    # Final data used in CausalImpact
    dt_final <- merge(dt_metro_t[, c("period_begin", "median_sale_price")],
                      dt_metro_c, by = "period_begin")
    
    dt_final <- zoo(dt_final[,-1], month_list)
    
    # Set the observed data in the post_treatment period to NAs
    post_obs <- as.numeric(dt_final$median_sale_price[month_list >= test_date])
    dt_final$median_sale_price[month_list >= test_date] <- NA
    
    # Use BSTS package to specify custom model by adding seasonality and local linear trend
    ss <- list()
    ss <- AddSeasonal(ss, y = dt_final$median_sale_price, nseasons = 12) # Add seasonality
    ss <- AddLocalLinearTrend(ss, y = dt_final$median_sale_price) # Add linear trend (upward)
    bsts_model <- bsts(median_sale_price ~., state.specification = ss, data = as.data.frame(dt_final), niter = 2000, ping = 0)
    causal_impact_model <- CausalImpact(bsts.model = bsts_model, post.period.response = post_obs, alpha = alpha)
    
    # Get post-period predictions and compute MAPE
    post_pred <- causal_impact_model$series$point.pred[(n+1-length(post_obs)):n]
    mape <- round(mean(abs(post_obs - post_pred)/post_obs) * 100, 2)
    
    # Plot the results
    options(repr.plot.width = 16, repr.plot.height = 9)
    plot_results <- plot(causal_impact_model) +
      scale_x_continuous(breaks = seq(1, length(month_list), by = 3),
                         labels = month_list[seq(1, length(month_list), by = 3)],
                         guide = guide_axis(angle = 90)) + 
      labs(title = paste0(metro_t, ": ", metrics[i]))
    #print(plot_results)
    
    # Print the results
    #cat(paste("# -----", metrics[i], "-----\n"))
    #summary(causal_impact_model)
    
    # Save the output
    causal_effect_results_list[[i]] <- causal_impact_model
    mape_results_list[[i]] <- mape
    plot_results_list[[i]] <- plot_results
  }
  
  return(list("metro_t_dist" = metro_t_dist,
              "metro_t_dist_results" = metro_t_dist_results,
              "causal_impact_model" = causal_effect_results_list,
              "model_mape_results" = mape_results_list,
              "plot_causal_impact_results" = plot_results_list))
}


df_nquery <- data.frame(matrix(0, nrow=20, ncol=6))
colnames(df_nquery) <- c('nquery', metrics)
df_nquery[, 'nquery'] <- 1:20

for (i in 1:nrow(df_nquery)) {
  tmp <- CausalImpactModel(dist_mat = dist_mat_1, num_query = i)
  df_nquery[i, -1] <- unlist(tmp$model_mape_results)
}

df_nquery_long <- melt(as.data.table(df_nquery), id.vars = 'nquery', 
                       measure.vars = metrics, variable.name = 'metrics',
                       value.name = 'mape')

ggplot(data = df_nquery_long, aes(x = nquery, y = mape, color=metrics)) +
  geom_line(aes(linetype=metrics)) + geom_point()

df_nquery_long[, 'mape_cummean':=cumsum(mape)/nquery, by=c('metrics')]
ggplot(data = df_nquery_long, aes(x = nquery, y = mape_cummean, color=metrics)) +
  geom_line(aes(linetype=metrics)) + geom_point()
