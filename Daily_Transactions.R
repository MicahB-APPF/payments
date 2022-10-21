##read in all transactions from users in experiment + relevant attributes for deep dive

library(tidyverse)
ns = read_csv("2022_10_20_10_23am.csv")

ns %>% filter(PAYMENT_LINE2 == 'ACH_RENT' | PAYMENT_LINE2 == 'CARD_RENT' & PROPERTY_TYPE_BUCKET == 'Residential') 