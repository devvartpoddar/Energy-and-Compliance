# Merging datasets
# Importing RPS data
rps.data <- import("Input/processed/RPS.csv") %>%
  select(-`1stBindingYear`, -`1stEffectiveYear`)

colnames(rps.data) <- c("State", "rps.year")

# Importing EIA data
EIA.data <- import("Input/processed/EIA-data.csv")

# Changing name of two states
EIA.data$State[EIA.data$State == "Massachusets"] <- "Massachusetts"
EIA.data$State[EIA.data$State == "Conneticut"] <- "Connecticut"

# Importing president data
presidents.data <- import("Input/processed/president.csv") %>%
  select(-V1)

colnames(presidents.data)[4] <- "PercentageofVote"

# Changing name of one state
presidents.data$State[presidents.data$State == "D.C."] <- "Washington DC"

# Grouping by state and keeping the maximum value of dem / rep
presidents.data %<>%
  transform(
    year = as.numeric(year),
    PercentageofVote = as.numeric(PercentageofVote)
    ) %>%
  group_by(State, year) %>%
  filter(PercentageofVote == max(PercentageofVote)) %>%
  ungroup() %>%
  # Removing State of Hawai
  filter(State != "Hawaii")

# Importing weather data
weather.data <- import("Input/processed/weather.csv") %>%
  select(-V1) %>%
  mutate_each(funs(as.numeric))

# Importing deregulation data
deregulation.data <- import("Input/processed/dereg.csv") %>%
  select(-V1) %>%
  transform(eyear = as.numeric(eyear)) %>%
  # Removing Hawaii
  filter(State != "Hawaii")

# Giving NA values an exceedingly high value that is not possible
deregulation.data$eyear[is.na(deregulation.data$eyear)] <- 9999

# Importing text data
text.data <- import("Input/processed/text-words.csv")

# Merging EIA and RPS
final.data <- merge(EIA.data, rps.data, by = "State", all = T) %>%
  group_by(State) %>%
  mutate(RPS = ifelse(year < rps.year, 0, 1)) %>%
  ungroup() %>%
  mutate(RPS = ifelse(is.na(RPS), 0, RPS)) %>%
  select(-rps.year)

# Merging data with presidents data
final.data %<>%
  merge(presidents.data, by = c("State", "year"), all = T) %>%
  arrange(State, year, month) %>%
  group_by(State) %>%
  mutate(
    party = na.locf(party),
    PercentageofVote = na.locf(PercentageofVote)
    ) %>%
  ungroup()

# Merge with Weather dataset
final.data  %<>%
  merge(weather.data, by=c("year", "month")) %>%
  select(State, everything()) %>%
  arrange(State, year, month)

# Merging with deregulation dataset
final.data %<>%
  merge(deregulation.data, all = T) %>%
  mutate(Electric = ifelse(year < eyear, 0, 1)) %>%
  select(-eyear)

# Merging with text data
final.data %<>%
  merge(text.data, all = T) %>%
  arrange(State, year, month)

export(final.data, "Output/processed data/mergeddata.csv")
