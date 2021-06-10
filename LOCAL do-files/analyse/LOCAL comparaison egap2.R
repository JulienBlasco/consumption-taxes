library(tidyverse)
library(haven)

sumegap2 <- read_dta("~/Pro/BLASCOLIEPP/Code/21-03 Datasets V7 (JPubEc Resubmit)/DTA/2021_06_07_centralccyy_summaries_egap2.dta")
sumcentral <- read_dta("~/Pro/BLASCOLIEPP/Code/21-03 Datasets V7 (JPubEc Resubmit)/DTA/2020_09_21 summaries mod10v2.dta")

données <- bind_rows(sumegap2, sumcentral)
attach(données)

