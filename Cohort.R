rm(list=ls()) #remove all variables from workspace
graphics.off() #close open graphics windows

library(tidyverse)
sales = as_tibble(read.csv("PMT - Payments KPI Dashboard 3.25.csv"))

mylogit <- glm(OUTCOME ~ SEG + STRUCT + geo, data = sales, family = "binomial")