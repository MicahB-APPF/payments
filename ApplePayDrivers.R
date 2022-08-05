#Apple Pay Drivers - simple forecasting

library(tidyverse)
library(prophet)
library(lubridate)
library(data.table)

ns = as_tibble(read.csv("debit_history.csv")) #read debit history

ns$MO = as.Date(substr(ns$TXN_MONTH_RECOG,1,10))

#ns$MO = as.Date(ns$TXN_MONTH_RECOG,"%Y/%m/%d")

c = ns %>% select(MO,DEBIT) %>% rename(ds = 1, y = 2)

m <- prophet(c, seasonality.mode = 'multiplicative')
future <- make_future_dataframe(m, periods = 41, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

fwrite(forecast_c, "results1.csv")