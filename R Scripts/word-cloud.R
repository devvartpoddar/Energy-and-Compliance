# Creating WordClouds

# Functions
# Text subsetting and cleaning
text.clean <- function(data, year) {
  # subsetting data only for the year
  text.data <- data %>%
    filter(year == year) %>%
    select(-year) %>%
    as.matrix() %>% as.vector()

  # Creating a corpus and cleaning
  text.tdm <- VectorSource(text.data) %>%
    Corpus() %>%
    tm_map(PlainTextDocument) %>%
    tm_map(stripWhitespace) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeNumbers) %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removeWords, stopwords()) %>%
    TermDocumentMatrix() %>%
    removeSparseTerms(0.5)
}

Function to create a wordcloud
wordcloud.make <- function(tdm) {
  # RowSums of TDM
  freq <- as.matrix(tdm) %>%
    rowSums()

  wordcloud(names(freq), freq, max.words = 100, random.order = FALSE,
    colors = substr(viridis(10, 1, option = "D"), 0 , 7))
}

# Creatng word clouds
text.data <- import("Output/processed data/pdf-text.json")

temp.freq <- text.data %>%
  text.clean(year = 2014)

png("Output/figures/wordcloud2014.png",
  width = 1200, height = 1200,
  res = 200, type = "cairo-png")

  print(wordcloud.make(temp.freq))

dev.off()
