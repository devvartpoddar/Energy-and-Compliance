# Regressing outputs on electricity prices

# Import dataset
prices.data <- import("Output/processed data/mergeddata.csv") %>%
  mutate(time = ymd(paste0(year, "-", month, "-01")),
    log.prices = log(Prices),
    order.ave = 100 * order.ave,
    renewable.ave = 100 * renewable.ave) %>%
    arrange(State, year, month) %>%
    group_by(State) %>%
    mutate(lag.log.prices = lag(log.prices),
      lag.prices = lag(Prices)) %>%
    ungroup()

months <- unique(prices.data$month)

# Generating monthly dummy variables
for (x in months) {
    if (x == 1) {next}
    colname <- paste0("dmonth_", x)
    prices.data[[colname]] <-  ifelse(prices.data$month == x, 1, 0)
}

# head(prices.data, 100)

# Modeling regressions
# Defining the variables to be used
col.names <- colnames(prices.data)
var.names <- paste(c("RPS", "renewable.ave", "year",
  grep("dmonth", col.names, value = T)), collapse = " + ")

formula.call <- as.formula(paste("log.prices ~", var.names))

# ols.reg <- lm(formula.call, data = prices.data)
# table(prices.data$context_30)

fe.reg <- plm(formula.call, data = prices.data,
    index = c("State", "time"), model = "within")

summary(fe.reg)

png("Output/figures/lag-prices.png", width = 4000, height = 4000)
prices.data %>%
  ggplot() +
  geom_point(aes(x = lag.log.prices, y = log.prices)) +
  facet_wrap(~ State) +
  theme_bw()
dev.off()

t.data <- prices.data %>%
  group_by(time) %>%
  dplyr::summarise(Prices = mean(Prices))

prices <- zoo(t.data$Prices, order.by = t.data$time)

t <- ts(t.data$Prices, freq = 12)

x <- stl(t, "periodic")
plot(x)
