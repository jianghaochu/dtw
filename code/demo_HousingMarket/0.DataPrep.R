rm(list = ls())

library(data.table)

# download housing market data from https://www.redfin.com/news/data-center/
# https://redfin-public-data.s3.us-west-2.amazonaws.com/redfin_market_tracker/
# redfin_metro_market_tracker.tsv000.gz

# load data
data_raw_path <- file.path("C:/Users/y/Downloads",
                           "redfin_metro_market_tracker.tsv000",
                           "redfin_metro_market_tracker.tsv000")
data_raw <- fread(data_raw_path)
str(data_raw)

# check data granularity
unique(data_raw$region_type)

# check data last update date
unique(data_raw$last_updated)

# select data for single family house
unique(data_raw$property_type)
unique(data_raw$is_seasonally_adjusted)

col_sel <- grep("_type*|id$|seasonally|city|state$|yoy|mom|updated$", 
                colnames(data_raw), value=TRUE, invert=TRUE)
data_sfh <- data_raw[property_type=="Single Family Residential", col_sel, 
                     with=FALSE][order(region, period_begin)]

# export data
fwrite(data_sfh, file='data_sfh.csv')
