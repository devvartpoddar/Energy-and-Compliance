# Script to find action words in text
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
# To return position of word in text with variable window
word.window <- function(text, word, window = 1) {
  # Converting text to vector of character strings
  temp.text <- as.character(text) %>%
    stri_split_fixed(" ") %>%
    unlist()

  # Find position of words in temp.text
  word.pos <- sapply(word, function(x) {
    pattern <- paste0("\\b", x, "\\b")
    temp.pos <- grep(pattern, temp.text)
    return(temp.pos)
    }) %>%
    unlist() %>%
    unique()

    # Going to next if no word available
    if (length(word.pos) == 0) {return(NA)}

    # Creating a loop
    text.window <- list()

    for (x in 1:length(word.pos)) {
      # Temporary position
      temp.pos <- word.pos[x]

      # Starting point of subset
      start <- temp.pos - window
      # Forcing start to be at 0
      if (start < 0) start <- 0

      # End of subset
      stop <- temp.pos + window

      # Subseting text
      text.subset <- temp.text[start:stop] %>%
      # removing all NAs
        .[!is.na(.)] %>%
        paste(collapse = " ")

      text.window[x] <- text.subset
    }

  return(text.window)
}

# List of words
list.words <- list(
  renewable = c("green", "renewable", "hydro", "sustainable", "sustain", "environment",
    "solar", "wind", "thermal", "nuclear"),
  pollution = c("pollute", "pollution", "climate", "global warm", "warm"),
  order = c("order", "revoke", "comply")
  )

# Import Data
text.data <- import("Output/processed data/text-clean.json")

text.data %<>% filter(!is.na(year)) %>%
  mutate(renewable = NA,
      pollution = NA,
      order = NA,
      context_30 = NA,
      total = NA)

for (x in 1:nrow(text.data)) {
  text <- text.data$clean.text[x]

  # Simple word search
  for (y in 1:length(list.words)) {
    temp.words <- list.words[[y]]

    text.data[x, 2 + y] <- find.words(text, temp.words)
  }

  total <- stri_split_fixed(text, " ") %>%
    unlist() %>% length()

  text.data$total[x] <- total

  # Search for context
  # Subsetting all text with words order
  list.text <- word.window(text, list.words[["order"]], 10)

  # Looping over each value of temp text
  context.ave <- c()
  for (z in 1:length(list.text)) {
    temp.text <- list.text[[z]]
    context.freq <- find.words(temp.text, list.words[["renewable"]])
    context.total <- stri_split_fixed(temp.text, " ") %>%
      unlist() %>% length()

    context.ave[z] <- context.freq / context.total
  }

  text.data$context_30[x] <- mean(context.ave)
}

# ggplot(text.data) +
#   geom_point(aes(x = renewable / total, y = context_30)) +
#   theme_bw()

text.data %<>%
  select(-clean.text) %>%
  mutate(
    renewable.ave = renewable / total,
    pollution.ave = pollution / total,
    order.ave = order / total
    ) %>%
  group_by(year) %>%
  dplyr::summarize(
    count = n(),
    context_30 = mean(context_30),
    # order = mean(order),
    # renewable = mean(renewable),
    # pollution = mean(pollution),
    order.ave = mean(order.ave),
    renewable.ave = mean(renewable.ave),
    pollution.ave = mean(pollution.ave),
    total = mean(total)
    ) %>%
  ungroup()

export(text.data, "Input/processed/text-words.csv")
