#Receivables - simple forecasting

library(tidyverse)
library(prophet)
library(lubridate)
library(data.table)

ns = read_csv("import.csv")

ns$DATE = as.Date(ns$MO,"%m/%d/%Y")

#online transaction forecast

c = ns %>% select(DATE,'All Txns made via Tportal (eCheck + Card)...2') %>% filter(DATE < "2022-11-01") %>% rename(ds = 1, y = 2) 
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

fwrite(forecast_c, "otrns_fore.csv")

#nice fit for this and future trend looks reasonable -- strong candidate for automation

####month zero credit forecasting
ns = read_csv("mzero_cr.csv")
ns$DATE = as.Date(ns$MO,"%m/%d/%Y")
c = ns %>% select(DATE, MZERO_CR) %>% rename(ds = 1, y = 2)

#multiplicative growth
m <- prophet(c, seasonality.mode = 'multiplicative')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
#dyplot.prophet(m, forecast_c)

results = tibble(date = forecast_c$ds, mg = forecast_c$yhat)

#additive growth
m <- prophet(c, seasonality.mode = 'additive')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)

results$ag = forecast_c$yhat

#linear additive growth
m <- prophet(c, growth = 'linear')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)

results$linear = forecast_c$yhat

#logistic additive growth -- hmm not working...maybe can't do logistic for monthly data?
ns$cap = 11.3
m <- prophet(c, growth = 'logistic')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
future$cap = 10.13
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)

#flat growth
m <- prophet(c, growth = 'flat')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)


results$flat = forecast_c$yhat

fwrite(results, "mzero_cr_fore.csv")


####month zero credit forecasting v2
ns = read_csv("mzero_cr.csv")
ns$DATE = as.Date(ns$MO,"%m/%d/%Y")
c = ns %>% select(DATE, 'Month 0 online txns') %>% rename(ds = 1, y = 2)

m <- prophet(c, seasonality.mode = 'additive')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)

results = tibble(date = forecast_c$ds, mg = forecast_c$yhat)

#flat growth
m <- prophet(c, growth = 'flat')
future <- make_future_dataframe(m, periods = 16, freq = 'month')
forecast_c <- predict(m, future)
#prophet_plot_components(m, forecast_c)
dyplot.prophet(m, forecast_c)


results$flat = forecast_c$yhat

fwrite(results, "mzero_cr_fore1.csv")