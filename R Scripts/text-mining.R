#
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

list.words <- list(
  renewable = c("green", "renewable", "hydro", "sustainable", "sustain", "environment"),
  pollution = c("pollute", "pollution", "climate", "global warm", "warm"),
  order = c("order", "revoke", "comply")
  )

# Import Data
text.data <- import("Output/processed data/text-clean.json")

text.data %<>% filter(!is.na(year)) %>%
  mutate(renewable = NA,
      pollution = NA,
      order = NA,
      total = NA)

for (x in 1:nrow(text.data)) {
  text <- text.data$clean.text[x]

  for (y in 1:length(list.words)) {
    temp.words <- list.words[[y]]

    text.data[x, 2 + y] <- find.words(text, temp.words)
  }

  total <- stri_split_fixed(text, " ") %>%
    unlist() %>% length()

  text.data$total[x] <- total
}

text.data %<>%
  select(-clean.text)

export(text.data, "Input/processed/text-words.csv")
