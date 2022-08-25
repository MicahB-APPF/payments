#Apple Pay Drivers - simple forecasting

library(tidyverse)
library(prophet)
library(lubridate)
library(data.table)

ns = read_csv("payables_actuals.csv")

ns$MO = as.Date(ns$DATE,"%m/%d/%Y")

#OVE forecast

c = ns %>% select(MO,OVE) %>% rename(ds = 1, y = 2)

m <- prophet(c, seasonality.mode = 'multiplicative')
future <- make_future_dataframe(m, periods = 17, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

fwrite(forecast_c, "ove_fore.csv")

#BP forecast

c = ns %>% select(MO,BP) %>% rename(ds = 1, y = 2) %>% filter(ds > '2017-12-01')

m <- prophet(c, seasonality.mode = 'multiplicative')
future <- make_future_dataframe(m, periods = 17, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

fwrite(forecast_c, "bp_fore.csv")