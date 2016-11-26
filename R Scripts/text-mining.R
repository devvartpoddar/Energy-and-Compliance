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

nrow(text.data)

# sstr(text.data)

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

final.data <- text.data %>%
  mutate(renewable.mean = renewable / total,
      order.mean = order / total,
      pollution.mean = pollution / total)

final.data %>%
  filter(renewable.mean > 0 & renewable.mean < 0.0025) %>%
  ggplot() +
  geom_point(aes(x = renewable.mean, y = order.mean)) +
  geom_smooth(aes(x = renewable.mean, y = order.mean))

lm(order ~ renewable  + year + pollution, data = final.data) %>% summary()

hist(final.data$order.mean)

str(final.data)

cor(final.data[, c(1, 6:8)])
