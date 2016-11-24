x<-getURL("http://www.electoral-vote.com/evp2016/Info/elections-1900-to-2012.csv")
pres<-read.csv(text=x)
pres<-pres[,-c(16:89)]
pres<-pres[,-c(2:3)]
pres<-pres[,-c(4,7,10,13)]
pres=pres[-(53:4290),]
pres=pres[-(1),]
library(plyr)
pres<-rename(pres, c("X2012"="dem2012", "X.1"="rep2012","X2008"="dem2008", "X.3"="rep2008", "X2004"="dem2004","X.5"="rep2004","X2000"="dem2000","X.7"="rep2000"))
library("reshape2")
pres<-melt(pres,id.vars=(1))
pres<-rename(pres, c("variable"="dyear","value"="%"))
library(RCurl)
pres <- cbind(party=substr(pres[,2],1,3), year=substr(pres[,2],4,7), pres[, -2])
