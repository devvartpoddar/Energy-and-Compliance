# Regressing outputs on electricity prices

# Import dataset
prices.data <- import("Output/processed data/mergeddata.csv") %>%
  mutate(time = ymd(paste0(year, "-", month, "-01")),
    log.prices = log(Prices))

months <- unique(prices.data$month)

# Generating monthly dummy variables
for (x in months) {
  if (x == 1) next

  colname <- paste0("dmonth_", x)

  prices.data[[colname]] <-  ifelse(prices.data$month == x, 1, 0)
}

str(prices.data)

# Modeling regressions
# Defining the variables to be used
col.names <- colnames(prices.data)
var.names <- paste(c("RPS", "party", "order.ave", "pollution.ave", "renewable.ave", "year",
  "count", grep("dmonth", col.names, value = T)), collapse = " + ")

formula.call <- as.formula(paste("Prices ~", var.names))

ols.reg <- lm(formula.call, data = prices.data)

fe.reg <- plm(formula.call, data = prices.data,
    index = c("State", "time"), model = "within")

summary(fe.reg)

prices.data %>%
  group_by(time) %>%
  dplyr::summarise(Prices = mean(Prices)) %>%
  ggplot() +
  geom_line(aes(x = time, y = Prices, group = 1)) +
  theme_bw()


t.data <- prices.data %>%
  group_by(time) %>%
  dplyr::summarise(Prices = mean(Prices))

prices <- zoo(t.data$Prices, order.by = t.data$time)

t <- ts(t.data$Prices, freq = 12)

x <- stl(t, "periodic")
plot(x)
