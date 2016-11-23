library("XML")
url<-"http://www.electricchoice.com/map-deregulated-energy-markets/"
tbls<-readHTMLTable(url)
sapply(tbls,nrow)
der <- readHTMLTable("http://www.electricchoice.com/map-deregulated-energy-markets/", which = 1, header = TRUE, stringsAsFactors = FALSE)
