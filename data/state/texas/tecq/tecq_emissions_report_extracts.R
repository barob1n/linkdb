setwd("~/GitHub/linkdb/data/state/texas/tecq")
library(readxl)

fin<-"state_summary.xlsx"
s<-readxl::excel_sheets(fin)
statesum <- read_excel(fin, sheet=s[NROW(s)])

base_url<-"https://www.tceq.texas.gov/assets/public/implementation/air/ie/extracts/" # RN_NUMBER_EXTRACT.txt.gz
for(RN in statesum$RN){
  fh<-gzcon(curl::curl(url=paste0(base_url,RN,'_EXTRACT.txt.gz')))
  d<-readLines(fh)
}

d_n<-unlist(lapply(d,function(x){
  NROW(strsplit(x,'\\|')[[1]])
}))

d_2<-unlist(lapply(d,function(x){
  strsplit(x,'\\|')[[1]][2]
}))

d_split<-split(d,d_2)

lapply(d_split$`ACCOUNT-SITE`,function(x){
  
})

paste0(d_split$ACTIVITY[grepl('FROM DATE',d_split$ACTIVITY)],
       d_split$ACTIVITY[grepl('TO DATE',d_split$ACTIVITY)])

lapply(d_split$ACTIVITY,function(x){
  
})

lapply(d_split,function(x){
  x<-strsplit(x,'\\|')[[1]]
  x<-x[-1]
  x<-x[-NROW(x)]
  
  
})


d_4<-unlist(lapply(d,function(x){
  strsplit(x,'\\|')[[1]][4]
}))

