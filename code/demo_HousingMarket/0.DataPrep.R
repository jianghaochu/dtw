rm(list = ls())

library(data.table)

# download housing market data from https://www.redfin.com/news/data-center/
# url = 'https://redfin-public-data.s3.us-west-2.amazonaws.com/redfin_market_tracker/zip_code_market_tracker.tsv000.gz'
# df = pd.read_csv(url, compression='gzip', sep='\t', on_bad_lines='skip')

# load data
data_raw_path <- file.path("~/Documents/Research/dtw-main/code/demo_HousingMarket",
                           "zip_code_market_tracker.tsv000")
#"redfin_metro_market_tracker.tsv000",
#"redfin_metro_market_tracker.tsv000")
data_raw <- fread(data_raw_path)
str(data_raw)

# check data granularity
unique(data_raw$region_type)
length(unique(data_raw$region))

# check data last update date
unique(data_raw$last_updated)

# select data for single family house
unique(data_raw$property_type)
unique(data_raw$is_seasonally_adjusted)

col_sel <- grep("_type*|id$|seasonally|city|state$|yoy|mom|updated$", 
                colnames(data_raw), value=TRUE, invert=TRUE)
data_sfh <- data_raw[property_type=="Single Family Residential", col_sel, 
                     with=FALSE][order(region, period_begin)]
data_sfh[, region:=gsub('Zip Code: ', 'Z', region)]

# export data
fwrite(data_sfh, file='demo_HousingMarket/data_sfh_zip.csv')
