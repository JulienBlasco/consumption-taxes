library(tidyverse)
library(haven)
library(stargazer)

core <- read_stata("DTA/20_11_2022 mod2 summaries.dta") %>% 
  transmute(ccyy, Country=cname, year=as.character(year), observed = !is.na(Gini_ours_wor), pred = !is.na(Gini_ours_wor_pred))
extended <- read_stata("DTA/20_11_2022 mod1 summaries.dta") %>% 
  transmute(ccyy, observed_light = !is.na(Gini_ours), pred_light = !is.na(Gini_ours_pred))

core %>% 
  left_join(extended, "ccyy") %>% 
  mutate(
    any_observe = observed | observed_light,
    any_impute = !any_observe & (pred | pred_light),
    year=ifelse(observed | pred, year, paste0(year, "*"))
    ) %>% 
  filter(any_observe | any_impute) -> datasets

datasets %>% 
  summarise(
    n = n(),
    min(year),
    max(year),
    n_country = n_distinct(Country),
    n_core = sum(observed | pred),
    n_light = n-n_core,
    n_obs = sum(observed|observed_light)
  )

datasets %>% 
  group_by(Country) %>% 
  summarise(
    `Years with observed data` = paste(year[observed | observed_light], collapse=", "),
    `Years with imputed data` = paste(year[any_impute], collapse=", "),
  ) -> appendix_H


table_tex <- stargazer(appendix_H, summary=FALSE, rownames=FALSE, header=FALSE)
table_tex <- table_tex[11:length(table_tex)-3]
table_tex <- gsub("\\\\textasteriskcentered", "*", table_tex)
table_tex <- gsub("[-1.8ex]", "", table_tex, fixed=TRUE)
table_tex <- c(
  "\\begin{tabularx}{\\textwidth}{l>{\\hsize=0.75\\hsize}X>{\\hsize=1.25\\hsize}X}",
  "\\hline\\hline",
  table_tex,
  "\\hline\\hline",
  "\\end{tabularx}"
)

write(table_tex, "~/Pro/BLASCOLIEPP/Notes/2022-08_Reresubmit_JPubEc/tables/23-02_coverage.tex")
