setwd("~/GitHub/linkdb/data/state/texas/tecq")
url<-"https://www.tceq.texas.gov/downloads/air-quality/point-source/2014_2020statesum.xlsx"
curl::curl_download(url,destfile="state_summary.xlsx")

