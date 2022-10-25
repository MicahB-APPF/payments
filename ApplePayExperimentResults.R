#Apple Pay Experiment Results - data from 24 Oct 2022

library(statmod)
library(Hmisc)

###final results###
###new users###

prop.test(c(47703,45585),c(106491,107986), alternative = "greater") #99% confident that card usage % is higher in b group

prop.test(c(5868,5586),c(106491,107986), alternative = "greater") #99% confident that credit is greater in B group

prop.test(c(41835,39999),c(106491,107986), alternative = "greater") #99% confident that debit % is higher

prop.test(c(58788,62401),c(106491,107986), alternative = "less") #99% confident that ach % is lower

##what is the range of uncertainty?

#how large is the uncertainty around credit?
binconf(5868,106491, alpha=0.01, method = "all")
binconf(5586,107986, alpha=0.01, method = "all")

#how large is the uncertainty around debit?
binconf(41835,106491, alpha=0.01, method = "all")
binconf(39999,107986, alpha=0.01, method = "all")

#how large is the uncertainty around ach?
binconf(58788,106491, alpha=0.01, method = "all")
binconf(62401,107986, alpha=0.01, method = "all")

####
#credit/debit split (margin)
prop.test(c(41835,39999),c(47703,45585), alternative = "greater") #99% confident that debit usage % is higher in b group

prop.test(c(5868,5586),c(47703,45585), alternative = "greater") #cannot say conclusively that credit is greater in B group


#Now look at all transactions

##read in all transactions from users in experiment + relevant attributes for deep dive

library(tidyverse)
ns = read_csv("PMT_Apple_Pay_All_Transactions_2022_10_14.csv")

ns %>% filter(VARIATION_NAME == 'enabled' & IS_APPLE_PAY == TRUE) %>% count(PAYMENT_METHOD)
#1100 credit, 6507 debit

#100 random samples to check credit/debit split for enabled group who chose AP vs those who did not
results = tibble(credit = numeric(),debit = numeric())
n = 1

for (n in 1:100) {

z = ns %>% filter(VARIATION_NAME == 'enabled' & IS_APPLE_PAY == FALSE) %>% slice_sample(n = 20000) %>% count(PAYMENT_METHOD)
results[n,1] = z %>% filter(PAYMENT_METHOD == 'credit') %>% select(n) %>% as.numeric()
results[n,2] = z %>% filter(PAYMENT_METHOD == 'debit') %>% select(n) %>% as.numeric()
}

mean(results$credit) #988
mean(results$debit)  #6540



##NOT USED


IVpage <-
  matrix(c(8, 145, 17, 135),
         nrow = 2,
         dimnames = list(conversions = c("conversions", "no_conversion"),
                         no_conversions = c("off_exp", "on_exp")))
fisher.test(IVpage, alternative = "less")
##Odds of new page conversion significantly greater than old page conversion
#We are confident we can expect this to be true if the test were run again
#>95% probability that new page performing better was not due to random chance 
#(p-value =0.045)

#power
power.fisher.test(0.0523, 0.1118, 153, 152,alpha=0.05, nsim=100, alternative = "less")

#Due to low volumes (=low statistical power) we are less confident in the exact lift we can expect moving forward from implementing the new page

#Use Fisher test for Apple Pay Experiment

ap =   matrix(c(6030, 15223, 6642, 16379),
              nrow = 2,
              dimnames = list(conversions = c("debit", "total_payments"),
                              no_conversions = c("disabled", "enabled")))
fisher.test(ap, alternative = "less")
#86% confident that users with apple pay enabled use debit more -- this is not the best method now that sample size is bigger -- see prop test below

power.fisher.test(0.3946, 0.4177, 9617, 10242,alpha=0.05, nsim=100, alternative = "less")

#given the large sample size maybe a different test would be better

prop.test(c(5886,6036),c(101053,106371), alternative = "less") #credit
#93% confident 

prop.test(c(8147,8594),c(15223,16379), alternative = "greater") #ach
#97% confident

prop.test(c(6030,6642),c(15223,16379), alternative = "less") #debit
# 95% confident

#to do: compare debit usage rates to historic debit rates for larger population

#how large is the uncertainty around the actual increase in debit usage?
binconf(6642,16379, alpha=0.05, method = "all")

#lower = 0.406, upper 0.413

binconf(6030,15223, alpha=0.05, method = "all")

#lower = 0.396, 0.404

(0.406 - 0.404)/0.406

#0.5% relative lift

(0.413 - 0.396)/0.413

#4% relative lift

#next steps:  

#break out results into apple pay enabled -> used apple pay vs apple pay enabled -> didn't use apple pay -- is there a diff in credit/debit usage?

#look at switching behavior for population -> do ach users switch to apple pay in month 2?  how sticky is apple pay?  one-off for first month or continued use?

#also look at %online payments vs offline -- do more users pay online because they have acces to apple pay?  or, is the UI so cluttered that they just get out the checkbook?


#is the apple pay experiment impacting autopayments significantly?  how many samples do we need to detect a 1% difference?

prop.test(c(1168,1398),c(18281,19791), alternative = "less") #pct autopay
#99% confident

#sample estimates:
  #prop 1     prop 2 
#0.06389147 0.07063817

#how large is the uncertainty around the actual increase in debit usage?
binconf(1168,18281, alpha=0.05, method = "all") #prop 1 confidence intervals

#lower = 0.0603, upper 0.0675

binconf(1398,19791, alpha=0.05, method = "all") #prop 2 confidence intervals

#lower = 0.0671, 0.0742

(0.0675 - 0.0671)

#prop 1 is higher so no increase 

abs((0.0603 - 0.0742))/0.0742

#18.7% relative increase in prop 2



prop.test(c(157,229),c(7084,7886), alternative = "less") #debit
#99% confident

#sample estimates:
#prop 1     prop 2 
#0.02216262 0.02903880

#how large is the uncertainty around the actual increase in debit usage?
binconf(157,7084, alpha=0.05, method = "all") #prop 1 confidence intervals

#lower = 0.0188, upper 0.0258

binconf(229,7886, alpha=0.05, method = "all") #prop 2 confidence intervals

#lower = 0.0254, upper 0.0329

(0.0258 - 0.0254)

#prop 1 is higher so no increase 

abs((0.0188 - 0.0329))/0.0329

#42.8% relative increase in prop 2

