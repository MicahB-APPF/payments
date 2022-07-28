rm(list=ls()) #remove all variables from workspace
graphics.off() #close open graphics windows

library(tidyverse)
library(dygraphs)
library(xts)
library(readxl)

sales = read_excel("Rent_Data.xlsx", sheet = "clean_counts")
dat = as_tibble(t(sales[,3:42]))
dat$month = seq(as.Date('2019-01-01'), by = "month", length.out = 40)

z1 = dat  %>% select(month,V1) %>% rename(ds = 1, y = 2)

z4 = xts(x = z1, order.by = z1$ds)

dygraph(z4) %>% dySeries("y", label = "Actual") %>% dyOptions(colors = RColorBrewer::brewer.pal(3, "Set1")) %>% dyLegend(show = "onmouseover") %>% dyRangeSelector() %>% dyEvent("2022-06-22", "Landing Page and Marketplace Launch Date", labelLoc = "bottom")

dat = xts(x = dat, order.by = date)

dat = dat %>% select(date,V19) %>% rename(ds = 1, y = 2)
