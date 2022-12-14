library(dplyr)
pmt <- read.csv("PMT_Email Portal Activation Test Data_v3.csv")

#check for duplicates -- we're good
pmt %>% 
  group_by(VHOST) %>% 
  filter(n()>1) %>% summarize(n=n())

#targets for samples
1348/2 #674 vhost per group

hist(pmt$NEW_OCC_AP)
hist(pmt$NEW_OCC_AP_EMAIL)

sum(pmt$NEW_OCC_AP)/2 #61485
sum(pmt$NEW_OCC_AP_EMAIL)/2 #51080

hist(pmt$NEW_OCC_EMAIL_ACTIVATED) #right skew use median

median(pmt$NEW_OCC_EMAIL_ACTIVATED) #0.882825

#set.seed(1)
#s <-sample_n(pmt,674,replace = FALSE)

sum(s$NEW_OCC_AP) #61485 target
sum(s$NEW_OCC_AP_EMAIL) #51080 target
median(s$NEW_OCC_EMAIL_ACTIVATED) #0.882825 target

write.csv(s,"sample_v1.csv")


(60792 - 61485)/61485 #1.1% difference
(50098 - 51080)/51080 #1.9% difference

(0.8816525 - 0.882825)/0.882825 #0.1% difference

par(mfrow = c(1,2))
hist(s$NEW_OCC_AP)
hist(pmt$NEW_OCC_AP)

par(mfrow = c(1,2))
hist(s$NEW_OCC_AP_EMAIL)
hist(pmt$NEW_OCC_AP_EMAIL)


par(mfrow = c(1,2))
hist(s$NEW_OCC_EMAIL_ACTIVATED)
hist(pmt$NEW_OCC_EMAIL_ACTIVATED) 


par(mfrow = c(1,2))
hist(pmt$TOTAL_ACTIVE_UNITS)
hist(s$TOTAL_ACTIVE_UNITS)

par(mfrow = c(1,2))
hist(pmt$ACTIVE_RESIDENTIAL_UNITS)
hist(s$ACTIVE_RESIDENTIAL_UNITS)

par(mfrow = c(1,2))
hist(pmt$ACTIVE_COMMERCIAL_UNITS)
hist(s$ACTIVE_COMMERCIAL_UNITS)

par(mfrow = c(1,2))
hist(pmt$ACTIVE_HOA_UNITS)
hist(s$ACTIVE_HOA_UNITS)

table(pmt$KEY_ACCOUNT_FLAG)
49/(1299+49) #3.6%
table(s$KEY_ACCOUNT_FLAG)
23/(23 + 651) #3.4%

table(pmt$STRUCTURE)
table(s$STRUCTURE)

#everything looks balanced for this sample -- we can re-run the same code if needed


samp <- read.csv("sample_v1.csv")
test = left_join(pmt,samp, by = "VHOST") %>% mutate(var = ifelse(is.na(X) == TRUE,'B','A')) 

##double check this work, then export to .csv and upload to snowflake to join out 

#old approach - per Charlottes input want to stratify the A/B groups accross more dimensions
pmt <- read.csv("PMT_Email_Portal_Activation_Test_Data.csv")

pmt2 <- read.csv("PMT_Email_Portal_Test_Activation_Data_v2.csv")

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


samp <- read.csv("email_ach_sample.csv")
test = left_join(pmt,samp, by = "VHOST")


##trobleshoot duplicates

pmt %>% 
  group_by(VHOST) %>% 
  filter(n()>1) %>% summarize(n=n())

samp %>% 
  group_by(VHOST) %>% 
  filter(n()>1) %>% summarize(n=n())


test %>% 
  group_by(VHOST) %>% 
  filter(n()>1) %>% summarize(n=n())

pmt %>% filter(VHOST == 'awmgtgrp')

###test revised data

pmt2 %>% 
  group_by(VHOST) %>% 
  filter(n()>1) %>% summarize(n=n())

test2 = left_join(pmt2,samp, by = "VHOST")


write.csv(test2,"screening_sample_v3.csv")

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
