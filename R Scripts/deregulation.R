# scrape the data from the electric choice URL
url<-"http://www.electricchoice.com/map-deregulated-energy-markets/"
tbls<-readHTMLTable(url)
sapply(tbls,nrow)
der <- readHTMLTable("http://www.electricchoice.com/map-deregulated-energy-markets/", which = 1, header = TRUE, stringsAsFactors = FALSE)

# change the "Electricity Regulation" variable into a binary 0/1 variable
der$Electric<-ifelse(der$Electric=='Yes', 1,0)

#remove the gas related variables
der$year <- NULL
der$Gas <- NULL

#Export the dataset
write.csv(der, "dereg.csv")
