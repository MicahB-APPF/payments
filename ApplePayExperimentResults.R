#example of using the fisher test for small sample sizes
#IV landing page experiment results

library(statmod)
library(Hmisc)

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

prop.test(c(1046,1143),c(15223,16379), alternative = "less") #credit
#64% confident

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

