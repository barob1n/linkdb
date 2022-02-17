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

## parse type of information (second column)
d_2<-unlist(lapply(d,function(x){
  strsplit(x,'\\|')[[1]][2]
}))

## split along type
d_split<-split(d,d_2)

## parse site information
get_site<-function(x){
  str<-'(E\\|ACCOUNT-SITE\\|RN.*?\\|)(.*?)(\\|)(.*?)(\\|)'
  tmp<-data.frame(as.list(c(RN,gsub(str,'\\4',x))),stringsAsFactors = F)
  names(tmp)<-c('RN',gsub(str,'\\2',x))
  tmp
}
d_split$`ACCOUNT-SITE`<-get_site(d_split$`ACCOUNT-SITE`)


tmp<-lapply(d_split$`ACCOUNT-SITE`,function(x){
  strsplit(x,'\\|')[[1]][5]
})
data.frame(tmp,stringsAsFactors=F)

## Parse Activity
d_split$ACTIVITY<-paste0(
  d_split$ACTIVITY[grepl('FROM DATE',d_split$ACTIVITY)],
  d_split$ACTIVITY[grepl('TO DATE',d_split$ACTIVITY)])


d_split$ACTIVITY<-lapply(d_split$ACTIVITY,function(x){
  x<-strsplit(x,'\\|')[[1]]
  data.frame(RN=RN,ACTIVITY=x[3],FROM_DATE=x[5],TO_DATE=x[10],stringsAsFactors = F)
})

d_split$ACTIVITY<-do.call(rbind,d_split$ACTIVITY)

lapply(d_split,function(x){
  x<-strsplit(x,'\\|')[[1]]
  x<-x[-1]
  x<-x[-NROW(x)]
  
  
})


d_4<-unlist(lapply(d,function(x){
  strsplit(x,'\\|')[[1]][4]
}))

