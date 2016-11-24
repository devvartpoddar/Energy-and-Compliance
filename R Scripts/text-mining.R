# File to read in pdf text and identify words such as renewable

# Functions
# To find the word
find.words <- function(text, words) {
  text <- as.character(text)

  # Sapply words over text
  word.freq <- sapply(words, function(x) {
    temp.freq <- stri_count_regex(text, x)
    return(temp.freq)
    }) %>%
    sum()

  return(word.freq)
}

# To clean the text - Should I look at lemmatising of text?
text.clean <- function(text) {
  text <- as.character(text)

  # Defining extra words
  extra.words <- c("united", "states", "america", "pdf", "ferc")

  # Removing stop words, punctation, numbers, special charcters and whitespace
  text %<>%
    stri_replace_all_regex("[[:punct:]]|\\$", "") %>%
    stri_replace_all_regex("\\s+", " ") %>%
    VectorSource() %>%
    VCorpus() %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removeNumbers) %>%
    tm_map(removeWords, stopwords()) %>%
    tm_map(removeWords, extra.words) %>%
    # sapply(`[`, "content") %>%
    sapply(as.character)

  return(text)
}

# Lemmatising text to convert to tokens
text.lemma <- function(text) {
  text <- as.character(text) %>%
    tolower()

  # Create a lemma dataframe of the text
  ## Creating a temporary file
  file.con <- file("temp.txt")
  writeLines(text, file.con)
  close(file.con)

  # Creating temporary dataframe with lemma
  temp.data <- treetag("temp.txt",
    treetagger = "manual",
    lang = "en",
    TT.options = list(
      path = "/home/devvart/Treetagger",
      preset = "en"
      ))

  temp.data <- temp.data@TT.res %>%
    select(token, lemma) %>%
    mutate(
      lemma = ifelse(lemma == "<unknown>", token, lemma)
      )

  file.remove("temp.txt")

  # Replacing words with their lemma
  for (x in 1:nrow(temp.data)) {
    # Values
    token <- paste0("\\b", temp.data$token[x], "\\b")
    # token <- temp.data$token[x]
    lemma <- temp.data$lemma[x]

    # Replacing
    text %<>% stri_replace_all_regex(token, lemma)
  }

  # Removing text spaces
  text %<>% stri_replace_all_regex("\\s+", " ")

  return(text)
}

## List of words
list.words <- list(
  renewable = c("green", "renewable", "hydro", "sustainable", "sustain", "environment"),
  pollution = c("pollute", "pollution", "climate", "global warming", "warming"),
  order = c("order", "revoke", "comply")
  )

# Processing text
text.data <- import("Output/processed data/pdf-text.json")

rows <- nrow(text.data)
# rows <- 10

final.data <- data.frame(
  year = rep(NA, rows),
  renewable.freq = rep(NA, rows),
  pollution.freq = rep(NA, rows),
  order.freq = rep(NA, rows),
  clean.text = rep(NA, rows)
  )

for (x in 1:rows) {
  # Data cleaning
  final.data$year[x] <- text.data$year[x]

  temp.text <- text.data$text[x] %>%
    text.clean() %>%
    text.lemma()

  # Note that the order of the list is as same as the order
  # of colums ofset by one.
  for (y in 1:length(list.words)) {
    words.to.find <- list.words[[y]]
    final.data[x, 1 + y] <- find.words(temp.text, words.to.find)
  }

  # Adding text
  final.data$clean.text[x] <- temp.text

  # Message text
  if (x %% 10 == 0) {
    message.text <- paste("Finished", round(x / rows * 100) , "% of cleaning")
    message(message.text)

    temp.gc <- gc()
    rm(temp.gc)
  }

  rm(temp.text, words.to.find)
}

export(final.data, "Output/processed data/text-clean.json")
