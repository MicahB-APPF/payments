rm(list=ls()) #remove all variables from workspace
graphics.off() #close open graphics windows

library(tidyverse)
library(dygraphs)
library(xts)

sales = as_tibble(read.csv("Rent_clean_counts.csv"))
dat = as_tibble(t(sales[,3:42]))
dat$date = as.Date(seq(as.Date('2019-01-01'), by = "month", length.out = 40))


dat = xts(x = dat, order.by = date)

dat = dat %>% select(date,V19) %>% rename(ds = 1, y = 2)

z = pivot_longer(sales)

relig_income
relig_income %>%
  pivot_longer(!religion, names_to = "income", values_to = "count")

dat <- as.data.frame(matrix(as.numeric t(sales[,3:42])
> colnames(dat) <- LETTERS[1:4]
> dat
A B C  D
1 1 4 7 10
2 2 5 8 11
3 3 6 9 12