# Scraping pdfs from Commisioner websites

# Intialisation
rm(list = ls())
pkgs <- c("dplyr", "magrittr", "methods", "rvest", "stringi", "rio", "ggplot2")

load <- sapply(pkgs, function(x) {
    suppressPackageStartupMessages(
      require(x, character.only = TRUE)
    )
  }
)
rm(load, pkgs)

# Function for scraping single website calls (sans appellate-briefs)
single.scrape <- function(URL) {

  if (missing(URL)) stop("No URL provided. Website cannot be scraped")
  URL <- as.character(URL)

  list.cases <- read_html(URL) %>%
    html_nodes(".indent a") %>%
    html_attr("href")

  # Searching  and keeping links with fileIDs
  keep.cases <- stri_detect_fixed(list.cases, "fileID")
  list.cases %<>%  .[keep.cases] %>% .[!is.na(.)]

  return(list.cases)
}

# Changing URL for opinion articles (opinion articles)
change.URL <- function(URL, year) {

  if (missing(URL)) stop("No URL provided. Website cannot be scraped")
  URL <- as.character(URL)
  if (missing(year)) year <- 2016

  # Look for opinion in URL
  is.opinion <- stri_detect_fixed(URL, "opinions")

  # If URL does not have opinion, returning original URL
  if (!is.opinion) return(URL)

  # Creating new url from old
  if (year < 2016) {
    url.first <- stri_split_fixed(URL, ".asp") %>% unlist() %>% .[1]
    URL <- paste0(url.first, "/", year, ".asp")
  }

  return(URL)
}

# List of websites to scrape
web.scrape.list <- list(
  "https://www.ferc.gov/legal/court-cases/opinions.asp",
  "https://www.ferc.gov/legal/court-cases/pend-case.asp",
  "https://www.ferc.gov/legal/court-cases/new-petitions.asp"
  )

# Scraping the websites
list.pdfs <- NULL

for (x in web.scrape.list) {
  URL <- x
  # Look for opinion in URL
  is.opinion <- stri_detect_fixed(URL, "opinions")

  if (is.opinion) {
    years <- 2001:2016
    for (y in years) {
      list.links <- change.URL(URL, y) %>%
        single.scrape()

      list.pdfs <- c(list.pdfs, list.links)
    }
  } else {
    list.links <- change.URL(URL) %>%
      single.scrape()

    list.pdfs <- c(list.pdfs, list.links)
  }
}

# Downloading all pdf files to Input/raw data
