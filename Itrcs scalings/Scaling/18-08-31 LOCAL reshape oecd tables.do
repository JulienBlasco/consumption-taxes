* updated 31/08/2018 to change paths

/* CHANGE DIRECTORY */
cd "G:"

cd ".\Code\18-07-27 Datasets V5\Scaling"

/* import OECD data for income and expenditure */
import delimited ".\CSV\OECD_expenditure_disp_income_S14-15.csv", clear 
replace value = value*10^(powercodecode)

keep country year transact sector value unitcode
rename value oecd_
reshape wide oecd_, i(country year sector) j(transact) string
reshape wide oecd_*, i(country year) j(sector) string
rename country cname
rename unitcode currency_oecd1
save ".\DTA\18-07-27 OECD_expenditure_disp_income_S14-15.dta", replace


/* import OECD data for imputed rent and expenditure */
import delimited ".\CSV\OECD_expenditure_imputed rent.csv", clear 
replace value = value*10^(powercodecode)
keep country year transact value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(transact) string
rename country cname
rename unitcode currency_oecd2
save ".\DTA\18-07-27 OECD_expenditure_imputed rent.dta", replace
