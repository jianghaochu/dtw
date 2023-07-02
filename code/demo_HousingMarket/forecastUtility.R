# Create list of global functions used in foreach and doParallel
list_gfuncs <- c()
for (obj in ls(.GlobalEnv)) {
  text_cond <- paste0("class(", obj, ")[1]=='function'")
  if (eval(parse(text=text_cond))) {
    list_gfuncs <- c(list_gfuncs, obj)
  }
}

# Calculate varying distance
comb <- function(x, ...) {
  lapply(seq_along(x),
         function(i) c(x[[i]], lapply(list(...), function(y) y[[i]])))
}

calMetroDist <- function(metro_name, data, steppattern, cores=6, return_match_results = FALSE){
  
  metro_list <- unique(data$region) 
  
  # Treatment metro sequence, ie, query sequence
  metro_t <- grep(metro_name, metro_list, value = TRUE)
  seq_q <- as.matrix(data[region == metro_t]$median_sale_price_normalized, ncol = 1)
  
  # parallel
  cl <- makeCluster(cores)
  clusterExport(cl, varlist = list_gfuncs)
  registerDoParallel(cl)
  
  # https://stackoverflow.com/questions/25062383/cant-run-rcpp-function-in-foreach-null-value-passed-as-symbol-address
  tik <- Sys.time()
  res <- foreach(i = 1:length(metro_list), .packages = c("data.table"), 
                 .noexport = c("dpcore"), .combine='comb', .multicombine=TRUE,
                 .init=list(list(), list())) %dopar% {
                   
                   # Reference sequences
                   seq_ref <- as.matrix(data[region == metro_list[i]]$median_sale_price_normalized, ncol = 1)
                   
                   if (i <= cores) {
                     Rcpp::sourceCpp("shapeDTW_translate/dpcore.cpp")
                   }
                   
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
                   
                   # Output
                   if(return_match_results == TRUE){
                     list("dist" = c("region" = metro_list[i],
                                     "dtw" = sum(align_DTW$sc),
                                     "wdtw" = sum(align_WDTW$sc),
                                     "td_wdtw" = sum(align_td_WDTW$sc),
                                     "shapedtw" = align_shapeDTW$distDescriptor,
                                     "td_shapedtw" = align_td_shapeDTW$distDescriptor),
                          "full" = list("region" = metro_list[i],
                                        "align_DTW" = align_DTW,
                                        "align_WDTW" = align_WDTW,
                                        "align_td_WDTW" = align_td_WDTW,
                                        "align_shapeDTW" = align_shapeDTW,
                                        "align_td_shapeDTW" = align_td_shapeDTW))
                   } else {
                     list("dist" = c("region" = metro_list[i],
                                     "dtw" = sum(align_DTW$sc),
                                     "wdtw" = sum(align_WDTW$sc),
                                     "td_wdtw" = sum(align_td_WDTW$sc),
                                     "shapedtw" = align_shapeDTW$distDescriptor,
                                     "td_shapedtw" = align_td_shapeDTW$distDescriptor),
                          "full" = list()
                     )
                   }
                 }
  print(Sys.time()-tik)
  stopCluster(cl)
  
  # Get ranking of varying distances
  metro_t_dist <- rbindlist(lapply(res[[1]], as.data.frame.list))
  metro_t_dist[, (paste0(metrics, "_rank")) := lapply(.SD, function(x) frank(x, ties.method = "min"))
               , .SDcols=metrics]
  
  # Output
  if(return_match_results == TRUE){
    # Process the matching results
    aligned_res <- res[[2]]
    metro_t_dist_results <- list()
    for (i in 1:length(aligned_res)){
      region_i <- aligned_res[[i]]$region
      metro_t_dist_results[region_i] <- list(
        list("align_DTW" = aligned_res[[i]]$align_DTW,
             "align_WDTW" = aligned_res[[i]]$align_WDTW,
             "align_td_WDTW" = aligned_res[[i]]$align_td_WDTW,
             "align_shapeDTW" = aligned_res[[i]]$align_shapeDTW,
             "align_td_shapeDTW" = aligned_res[[i]]$align_td_shapeDTW)
      )
    }
    return(list("metro_t_dist" = metro_t_dist,
                "metro_t_dist_results" = metro_t_dist_results))
  } else{
    return(metro_t_dist)
  }
}

# Run causal impact model
CausalImpactModel <- function(metro_name, test_date, alpha = 0.05, num_query = 10){
  
  # Get the distances and ranking of control metros
  output <- calMetroDist(metro_name = metro_name, data = dt_sel, cores = 8, steppattern = steppattern)
  metro_t_dist <- as.data.frame(output)
  
  causal_effect_results_list <- plot_results_list <- mape_results_list <-list()
  for (i in 1:length(metrics_rank)){
    
    # Get top 10 control and the treatment metro
    metro_t <- metro_name
    metro_sel <- metro_t_dist[metro_t_dist[, metrics_rank[i]]<=(num_query+1), 'region']
    metro_c <- metro_sel[metro_sel!=metro_t]
    
    # Get the target variable: median sale price
    dt_metro_t <- dt_sel[(region == metro_t) & (period_begin <= end_date), 
                         c("period_begin", "median_sale_price")]
    dt_metro_c_all <- dt_sel[(region %in% metro_c) & (period_begin <= end_date), 
                             c("region", "period_begin", "median_sale_price")]
    dt_metro_c <- dcast(dt_metro_c_all, period_begin ~ region, value.var = "median_sale_price")
    
    # Final data used in CausalImpact
    dt_final <- as.data.frame(merge(dt_metro_t[, c("period_begin", "median_sale_price")], 
                                    dt_metro_c, 
                                    by = "period_begin"))
    dt_final <- zoo(dt_final[,2:3], month_list)
    
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
              "causal_impact_model" = causal_effect_results_list,
              "model_mape_results" = mape_results_list,
              "plot_causal_impact_results" = plot_results_list))
}