# Source file for Energy and Compliance

# Intialisation
rm(list = ls())
pkgs <- c("dplyr", "magrittr", "methods", "rvest", "stringi", "rio", "ggplot2",
  "tm", "wordcloud", "viridis", "pdftools", "xml2")

load <- sapply(pkgs, function(x) {
    suppressPackageStartupMessages(
      require(x, character.only = TRUE)
    )
  }
)
rm(load, pkgs)

# Settng working directory
try(setwd("/home/devvart/Desktop/Energy-and-Compliance"))

# Downloading files from the websites
source("R Scripts/file-scrape.R")

# Read PDFs and basic frequency plots
source("R Scripts/pdf-clean.R")

# Creating wordclouds
source("R Scripts/word-cloud.R")
