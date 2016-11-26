# Source file for Energy and Compliance

# Intialisation
rm(list = ls())
pkgs <- c("dplyr", "magrittr", "methods", "rvest", "stringi", "rio", "ggplot2",
  "tm", "wordcloud", "viridis", "pdftools", "xml2", "EIAdata", "lubridate", "RCurl",
  "plyr", "reshape2", "XML", "koRpus")

load <- sapply(pkgs, function(x) {
    suppressPackageStartupMessages(
      require(x, character.only = TRUE)
    )
  }
)
rm(load, pkgs)

# Settng working directory
try(setwd("/home/devvart/Desktop/Energy-and-Compliance"))

## Text
# Downloading files from the websites
# source("R Scripts/file-scrape.R")

# Read PDFs and cleaning
# source("R Scripts/pdf-clean.R")

#Reading words
source("R Scripts/text-mining.R")

# Creating wordclouds
# source("R Scripts/word-cloud.R")

## Downloading and merging datasets
# Voted for president
# source("R Scripts/president.R")
## Weather
# source("R Scripts/weather.R")
## Deregulation
# source("R Scripts/deregulation.R")
## EIA data and Merging
# source("R Scripts/EIA-data.R")
