library("RCurl")
x <-getURL("https://www.ncdc.noaa.gov/cag/time-series/us/110/00/tavg/all/01/2001-2016.csv")
weather <- read.csv(text = x)
weather<-weather[-c(1, 2, 3), ]
weather <- cbind(year=substr(weather[, 1],1,4), month=substr(weather[, 1],5,6), weather[, -1])
