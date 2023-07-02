rm(list = ls())
source("loadConfig.R")
source("forecastUtility.R")

# Read in data
dt <- fread("data_sfh_zip.csv")
dt$region <- substr(dt$region, 2, nchar(dt$region))

# Select metros without NAs
dt[, ':='(id_NA = max(is.na(median_sale_price)|is.na(median_ppsf)), n_month = .N), by='region']
dt_nonNA <- dt[id_NA == FALSE]
metro_list_all <- unique(dt$region)
metro_list_nonNA <- unique(dt_nonNA$region)
cat(paste0("Number of All Regions: ", length(metro_list_all),
           "\nNumber of Regions w/o NAs: ", length(metro_list_nonNA)))

# Specify start date and end date, and subset the data
start_date <- as.Date("2014-01-01")
end_date <- as.Date(max(dt_nonNA$period_begin))

# Number of months
n <- (year(end_date) - year(start_date)) * 12 + (month(end_date) - month(start_date)) + 1
dt_sel <- dt_nonNA[period_begin >= start_date][
  , sel := max(sum(period_begin >= start_date) == n)
  , by = "region"][sel == 1]
month_list <- as.Date(sort(unique(dt_nonNA$period_begin)))

# Get the list of metro
metro_list_sel <- unique(dt_sel$region)
print(paste("Number of regions is", length(metro_list_sel)))
print(paste("Number of observations is", nrow(dt_sel)))

############################## DTW ##############################
# Initialization
steppattern <- matrix(c(1, 1, 2.0, 0, 1, 1.0, 1, 0, 1.0), ncol = 3, byrow = TRUE)
metrics <- c("dtw", "wdtw", "td_wdtw", "shapedtw", "td_shapedtw")
metrics_rank <- paste0(metrics, "_rank")

# Normalize the target variables
var_sel <- c("median_sale_price", "median_ppsf")
dt_sel[, (paste0(var_sel, "_normalized")) := lapply(.SD, zNormalizeTS)
       , .SDcols = var_sel, by = "region"]

# Generate forecast
set.seed(20230625)
m <- 50
random_metro <- sample(unique(dt_sel$region), m, replace = FALSE)
test_date <- as.Date("2023-01-01") # Specify test date
output_list <- list()
for (k in 1:m){
  output_list[[k]] <- CausalImpactModel(metro_name = random_metro[k], test_date = test_date)
  print(paste("# -----", random_metro[k], "-----\n"))
}

# Calculate MAPE
mapeCalc <- function(output, metro_name){
  mape <- as.data.frame(cbind(
    rep(metro_name, 5),
    metrics, 
    output$model_mape_results
  ))
  colnames(mape) <- c("region", "matching_algorithm", "mape")
  return(mape)
}

output_df <- mapeCalc(output = output_list[[1]], metro_name = random_metro[1])
for (k in 2:m){
  output_df <- rbind(output_df, mapeCalc(output_list[[k]], random_metro[k]))
}
fwrite(output_df, file = "zip_output_50.csv", row.names = FALSE)
