library(data.table)
f = fread("cohorts_debit.csv")
f = t(f) #dcast should be able to do this to and not convert everything to char
fwrite(f, "cohorts_debit.csv")