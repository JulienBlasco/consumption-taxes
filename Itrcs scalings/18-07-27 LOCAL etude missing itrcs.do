/* CHANGE DIRECTORY */
cd "G:"

doedit ".\Code\18-03-07 Datasets V4\18-03-15 LOCAL summaries analysis.do" 
use ".\Code\18-03-07 Datasets V4\18-03-15 summaries V4 mod1.dta", clear
merge 1:1 cname year using ".\Code\06-12 Actual consumption taxes\07-31_itrcs_scalings.dta"
table cname if _merge ==1
table cname year if _merge ==1
