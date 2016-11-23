# download and use revelant package
library("RCurl")

# scrape the data from the NCDC website
x <-getURL("https://www.ncdc.noaa.gov/cag/time-series/us/110/00/tavg/all/01/2001-2016.csv")
weather <- read.csv(text = x)

#delete the first first columns
weather<-weather[-c(1, 2, 3), ]

#separate the first column into "Year" and "Month" to make merging with other datasets easier.
weather <- cbind(year=substr(weather[, 1],1,4), month=substr(weather[, 1],5,6), weather[, -1])

#export dataset
write.csv(weather, "weather.csv")
