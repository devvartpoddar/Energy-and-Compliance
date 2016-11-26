# File to read in pdf text and identify words such as renewable

# Functions
# To clean the text - Should I look at lemmatising of text?
text.clean <- function(text) {
  text <- as.character(text)

  # Defining extra words
  extra.words <- c("united", "states", "america", "pdf", "ferc")

  # Removing stop words, punctation, numbers, special charcters and whitespace
  text %<>%
    stri_replace_all_regex("[[:punct:]]|\\$|\\+", "") %>%
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
    error <- try(text %<>% stri_replace_all_regex(token, lemma))

    if (inherits(error, "try-error")) {
      message.text <- paste0(token, " ----- ", lemma)
      message(message.text)
      stop("Stopping cleaning until error resolves")
    }
  }

  # Removing text spaces
  text %<>% stri_replace_all_regex("\\s+", " ")

  return(text)
}

# Processing text
text.data <- import("Output/processed data/pdf-text.json")

rows <- nrow(text.data)
# rows <- 270

# final.data <- data.frame(
#   year = rep(NA, rows),
#   clean.text = rep(NA, rows)
#   )
final.data <- import("Output/processed data/text-clean.json")

head(final.data[270:299, ], 30)

for (x in 270:rows) {
  # Data cleaning
  final.data$year[x] <- text.data$year[x]

  temp.text <- text.data$text[x] %>%
    text.clean() %>%
    text.lemma()

  # Adding text
  final.data$clean.text[x] <- temp.text

  # Message text
  if (x %% 10 == 0) {
    message.text <- paste("Finished", round(x / rows * 100) , "% of cleaning")
    # message.text <- paste("Finished", x  , "row of cleaning")
    message(message.text)

    export(final.data, "Output/processed data/text-clean.json")

    temp.gc <- gc()
    rm(temp.gc)
  }

  rm(temp.text, words.to.find)
}

# Exporting final clean text and removing the pdf text
message("Exporting final data and removing pdf-text.json")
export(final.data, "Output/processed data/text-clean.json")

file.remove("Output/processed data/pdf-text.json")
