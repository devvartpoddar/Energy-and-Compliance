#download the data
x<-getURL("http://www.electoral-vote.com/evp2016/Info/elections-1900-to-2012.csv")
pres<-read.csv(text=x)

#remove the column from before our period of analysis
pres<-pres[,-c(16:89)]
pres<-pres[,-c(2:3)]
pres<-pres[,-c(4,7,10,13)]

#remove the first row and all empty rows
pres=pres[-(1),]
pres=pres[-(53:4290),]

library(plyr)

#rename the column headers
pres<-rename(pres, c("X2012"="dem2012", "X.1"="rep2012","X2008"="dem2008", "X.3"="rep2008", "X2004"="dem2004","X.5"="rep2004","X2000"="dem2000","X.7"="rep2000"))
library("reshape2")

#move the column header values into values associated with rows
pres<-melt(pres,id.vars=(1))

#rename the new columns
pres<-rename(pres, c("variable"="dyear","value"="%"))

#separate the name of the party from the year for easier matching to other datasets
library(RCurl)
pres <- cbind(party=substr(pres[,2],1,3), year=substr(pres[,2],4,7), pres[, -2])

#export the data
write.csv(pres, "president.csv")
