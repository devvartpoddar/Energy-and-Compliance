# Reading PDF files and cleaning it into years

## Functions
# Function to read doc files
read.doc <- function(link, dir.path = "Input/raw data/Text/temp") {
  # create and empty directory to unzip doc files
  if (!dir.exists(dir.path)) {
    dir.create(dir.path)
  }
  # Unziping doc files
  unzip(link, exdir = dir.path)

  # Reading xml document
  xml.path <- paste0(dir.path, "/word/document.xml")

  text <- try(read_xml(xml.path) %>%
    xml_text())

  if (inherits(text, "try-error")) {
    return("No text available")
  }

  unlink(dir.path, recursive= TRUE)

  return(text)
}

# Function to try and read pdfs files
read.pdf <- function(link) {
  # Function to try and read pdfs files
  text <- suppressMessages(
    try(pdf_text(link))
    )

  # Returning Null if not a pdf
  if (inherits(text, "try-error")) {

    message(paste0(link, " not a PDF file. Force reading as .doc"))
    # Renaming files as doc in system
    if (grepl(link, ".pdf")) {
      filename <- stri_split_fixed(link, ".pdf") %>%
        unlist() %>% .[1] %>%
        paste0(".doc")
    } else {
      filename <- link
    }
    suppressMessages(
    try(file.rename(link, filename))
    )
    suppressMessages(
    text <-  read.doc(filename)
    )
    return(text)
  }

  # Cleaning text whitespace and returning as string
  text %<>% stri_split_fixed(" ") %>%
    unlist() %>% trimws() %>%
    paste(collapse = " ")

  return(text)
}

# Function to find the minimum position of year variables
find.year <- function(text) {
  # Function finds the position of years in text
  # and returns the first year refered to. If no year,
  # returns NA

  years <- as.character(2001:2016 )

  # Checking if text is NULL. returning NA if yes.
  if (is.na(text)) return(NA)

  # Matching the list of years to text
  text %<>% stri_split_regex(" |\\.|\\,") %>%
    unlist()

  pos.year <- sapply(years, function(x) {
    # Forcing word boundry to identify only whole years
    temp.pat <- paste0("\\b", x, "\\b")
    grep(temp.pat, text)
    })

  # Finding minimum of the years found
  first.year <-  suppressWarnings(
    sapply(pos.year, min) %>%
    {which(. == min(.))} %>%
    names() %>%
    as.numeric()
    )

  return(first.year)
}

## Looping over all files in Text to create a dataframe
# List of files
list.pdfs <- list.files("Input/raw data/Text", pattern = ".pdf")

# Blank Dataset
text.data <- data.frame(
  text = rep("NA", length(list.pdfs)),
  year = rep(NA, length(list.pdfs)),
  stringsAsFactors = FALSE
  )

# Loop
for (x in 1:length(list.pdfs)) {
  pdf.path <- paste0("Input/raw data/Text/", list.pdfs[x])

  pdf.text <- read.pdf(pdf.path)

  text.data$text[x] <- as.character(pdf.text)
  text.data$year[x] <- find.year(pdf.text)

  rm(pdf.text)

  if (x %% 10 == 0) {
    message(paste("Finished extracting ",
      round(x / length(list.pdfs)*100, 2), "% of data"))
  }
}

text.data %<>%
  filter(!is.na(year))

# Exporting data to Output/processed data
export(text.data, "Output/processed data/pdf-text.json")

# Message and source
message("Starting lemmatising. This might take some time ----------------- ")
source("R Scripts/text-cleaning.R")
