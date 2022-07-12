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

ap =   matrix(c(3795, 9617, 4279, 10242),
              nrow = 2,
              dimnames = list(conversions = c("debit", "total_payments"),
                              no_conversions = c("disabled", "enabled")))
fisher.test(ap, alternative = "less")
#99% confident that users with apple pay enabled use debit more

power.fisher.test(0.3946, 0.4177, 9617, 10242,alpha=0.05, nsim=100, alternative = "less")

#given the large sample size maybe a different test would be better

prop.test(c(597,671),c(9617,10242), alternative = "less")
#83% confident

prop.test(c(5225,5292),c(9617,10242), alternative = "less")
#no difference

prop.test(c(3795,4279),c(9617,10242), alternative = "less")
#also 99% confident

#to do: compare debit usage rates to historic debit rates for larger population

#how large is the uncertainty around the actual increase in debit usage?
binconf(4279,10242, alpha=0.05, method = "all")

#lower = 0.408, upper 0.427

binconf(3795,9617, alpha=0.05, method = "all")

#lower = 0.385, 0.404

(0.408 - 0.404)/0.408

#1% relative lift

(0.427 - 0.385)/0.427

#10% relative lift


