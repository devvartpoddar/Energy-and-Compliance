# EIA data

states.abb <- c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA", "IL", "IN", "MI", "OH", "WI", "IA",
  "MN", "MO", "KS", "NE", "ND", "SD", "DE", "DC", "FL", "GA", "MD", "NC", "SC", "VA", "WV", "AL", "KY", "MS",
  "TN", "AR", "LA", "OK", "TX", "AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "CA", "OR", "WA", "AK")

states <- c("Conneticut", "Maine", "Massachusets", "New Hampshire", "Rhode Island", "Vermont",
  "New Jersey", "New York", "Pennsylvania", "Illinois", "Indiana", "Michigan", "Ohio", "Wisconsin",
  "Iowa", "Minnesota", "Missouri", "Kansas", "Nebraska", "North Dakota", "South Dakota",
  "Delaware", "Washington DC", "Florida", "Georgia", "Maryland", "North Carolina", "South Carolina",
  "Virginia", "West Virginia", "Alabama", "Kentucky", "Mississippi", "Tennessee", "Arkansas", "Louisiana",
  "Oklahoma", "Texas", "Arizona", "Colorado", "Idaho", "Montana", "Nevada", "New Mexico",
  "Utah", "Wyoming", "California", "Oregon", "Washington", "Alaska")

key = "E5E6C12447188F1A664D64EEC5411A69"

EIA.data <- NULL

for (x in 1:length(states.abb)) {
  EIA.request <- paste0("ELEC.PRICE.", states.abb[x], "-RES.M")

  temp.data <- getEIA(EIA.request, key) %>%
    as.data.frame() %>%
    mutate(rowname = rownames(.),
      year = year(rowname),
      month = month(rowname),
      State = states[x]) %>%
    select(-rowname)

  colnames(temp.data)[1] <- "Prices"

  EIA.data <- rbind(temp.data, EIA.data)
}

# Merge with RPS dataset
rps.data <- import("Input/processed/RPS.csv")

final.data <- merge(EIA.data, rps.data) %>%
  group_by(State) %>%
  mutate(RPS = ifelse(year < `1stEnactmentYear`, 0, 1)) %>%
  ungroup()

# Merge with Weather dataset
final.data1<-merge(EIA, weather, by=c("year", "month"))

# Merge with Deregulation Dataset
merged.data<-merge(final.data1, der, by="state")

#Merge with President dataset
merged.data1 <- merge(merged.data, pres, by=c("state", "year"))

export(merged.data1, "Output/processed data/mergeddata.csv")
