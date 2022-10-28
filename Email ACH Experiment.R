library(dplyr)

pmt <- read.csv("PMT_Email_Portal_Activation_Test_Data.csv")

#1343 vhosts - 671 for the test

hist(pmt$NEW_OCC_EMAIL_ACTIVATED)
hist(pmt$AVG_OCC_AP_EMAIL)
sum(pmt$NEW_OCC_AP_EMAIL) #80314
#40157 per variation

#set.seed(1)
#sample<-sample_n(pmt,671,replace = FALSE)
#sum(sample$NEW_OCC_AP_EMAIL) #40488
#write.csv(sample,"email_ach_sample.csv")
###this .csv was delivered as the 'remove free' email variation to Lauren
###need to uplaod the A/B group list to cuploa to build tracking dash

hist(sample$NEW_OCC_EMAIL_ACTIVATED)
hist(sample$AVG_OCC_AP_EMAIL)


###not used - yet

hist(sample$TOTAL_UNITS)
hist(sample$TENURE)
table(sample$KEY_ACCOUNT_FLAG)
table(sample$CUSTOMER_VERSION)
write.csv(sample,"screening_sample_v2.csv")

sample_comp <- read.csv("IV_freetrial/screening_sample.csv")

anti_join(sample,sample_comp, by = "VHOST")

IV_final = read.csv("IV_final_050222.csv")

test = left_join(screeningexperiment,IV_final, by = "VHOST")

test %>% filter(IV_CUSTOMERS.y == "YES") #24 customers on this list who actual have IV

screeningexperiment = test %>% filter(is.na(IV_CUSTOMERS) == TRUE)
