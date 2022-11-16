#Code for transaction forecasting for the 'new' funnel
#end goal: automate monthly reforecasting and yearly budgeting 
#All Txns made via Tportal (eCheck + Card) forecast -- this is the best fit model, all other variables forecasted using this model may not be as accurate

library(tidyverse)
library(prophet)
library(lubridate)
library(data.table)

ns = read_csv("import.csv")

ns$DATE = as.Date(ns$MO,"%m/%d/%Y")

#All Receivable Transactions forecast -- 2023 looks even more off when I only use data through June to predict...

c = ns %>% select(DATE,ALL_TXNS) %>% filter(DATE < "2022-07-01") %>% rename(ds = 1, y = 2) 
c$rev = ns$REV_DAYS[1:42]
c$u = ns$UNITS[1:42]

#m <- prophet(daily.seasonality = 50, changepoint.prior.scale = 0.5, seasonality.prior.scale = 0.1)
m = prophet(seasonality.mode = 'multiplicative') 
m <- add_regressor(m,'rev',prior.scale = 0.1, standardize = FALSE)
m <- add_regressor(m,'u',prior.scale = 0.1, standardize = FALSE)
m <- add_seasonality(m, name='monthly', period=30.5, fourier.order=5)
m <- fit.prophet(m, c)


future <- make_future_dataframe(m, periods = 18, freq = 'month')
future$rev = ns$REV_DAYS
future$u = ns$UNITS
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
#plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

ns$ALL_TXNS_y = forecast_c$yhat

#Total Transactions: Vhosts with Payments Enabled forecast 

c = ns %>% select(DATE,ALL_VPE_TXNS) %>% filter(DATE < "2022-07-01") %>% rename(ds = 1, y = 2) 
c$rev = ns$REV_DAYS[1:46]
c$u = ns$UNITS[1:46]

#m <- prophet(daily.seasonality = 50, changepoint.prior.scale = 0.5, seasonality.prior.scale = 0.1)
m = prophet(seasonality.mode = 'multiplicative') 
m <- add_regressor(m,'rev',prior.scale = 0.1, standardize = FALSE)
m <- add_regressor(m,'u',prior.scale = 0.1, standardize = FALSE)
m <- add_seasonality(m, name='monthly', period=30.5, fourier.order=5)
m <- fit.prophet(m, c)


future <- make_future_dataframe(m, periods = 14, freq = 'month')
future$rev = ns$REV_DAYS
future$u = ns$UNITS
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
#plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

ns$ALL_VPE_TXNS_y = forecast_c$yhat

#Total Transactions: Tenants with an Active Tenant Portal forecast 

c = ns %>% select(DATE,ALL_TATP_TXNS) %>% filter(DATE < "2022-11-01") %>% rename(ds = 1, y = 2) 
c$rev = ns$REV_DAYS[1:46]
c$u = ns$UNITS[1:46]

#m <- prophet(daily.seasonality = 50, changepoint.prior.scale = 0.5, seasonality.prior.scale = 0.1)
m = prophet(seasonality.mode = 'multiplicative') 
m <- add_regressor(m,'rev',prior.scale = 0.1, standardize = FALSE)
m <- add_regressor(m,'u',prior.scale = 0.1, standardize = FALSE)
m <- add_seasonality(m, name='monthly', period=30.5, fourier.order=5)
m <- fit.prophet(m, c)


future <- make_future_dataframe(m, periods = 14, freq = 'month')
future$rev = ns$REV_DAYS
future$u = ns$UNITS
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
#plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

ns$ALL_TATP_TXNS_y = forecast_c$yhat


#All Txns made via Tportal (eCheck + Card) forecast 

c = ns %>% select(DATE,TP_TXNS) %>% filter(DATE < "2022-11-01") %>% rename(ds = 1, y = 2) 
c$rev = ns$REV_DAYS[1:46]
c$u = ns$UNITS[1:46]

#m <- prophet(daily.seasonality = 50, changepoint.prior.scale = 0.5, seasonality.prior.scale = 0.1)
m = prophet(seasonality.mode = 'multiplicative') 
m <- add_regressor(m,'rev',prior.scale = 0.1, standardize = FALSE)
m <- add_regressor(m,'u',prior.scale = 0.1, standardize = FALSE)
m <- add_seasonality(m, name='monthly', period=30.5, fourier.order=5)
m <- fit.prophet(m, c)


future <- make_future_dataframe(m, periods = 14, freq = 'month')
future$rev = ns$REV_DAYS
future$u = ns$UNITS
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)
#plot(m,forecast_c, xlabel = NULL, ylabel = NULL)

ns$TP_TXNS_y = forecast_c$yhat


fwrite(ns, "tff_fore.csv")

