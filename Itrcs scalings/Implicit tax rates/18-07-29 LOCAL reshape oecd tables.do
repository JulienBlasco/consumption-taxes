/* CHANGE DIRECTORY */
cd "G:"

cd ".\Code\18-07-27 Datasets V5\Implicit tax rates"

/* import taxes */
import delimited ".\CSV\18-07-27 OECD_taxes_latin.csv", clear 
replace value = value*10^(powercodecode)
keep country year tax value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(tax)
rename country cname
rename unitcode oecd2_unitcode
save ".\DTA\18-07-27 OECD_taxes_latin.dta", replace

import delimited ".\CSV\18-07-27 OECD_taxes_oecd.csv", clear 
replace value = value*10^(powercodecode)
keep country year tax value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(tax)
rename country cname
rename unitcode oecd2_unitcode
save ".\DTA\18-07-27 OECD_taxes_oecd.dta", replace

import delimited ".\CSV\18-07-27 OECD_taxes_african.csv", clear 
replace value = value*10^(6)
keep country year tax value 
rename value oecd_
reshape wide oecd_, i(country year) j(tax)
rename country cname
save ".\DTA\18-07-27 OECD_taxes_african.dta", replace

import delimited ".\CSV\18-07-27 OECD_taxes_asian.csv", clear 
replace value = value*10^(powercodecode)
keep country year tax value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(tax)
rename country cname
rename unitcode oecd2_unitcode
save ".\DTA\18-07-27 OECD_taxes_asian.dta", replace

use ".\DTA\18-07-27 OECD_taxes_latin.dta", clear
append using 	".\DTA\18-07-27 OECD_taxes_oecd.dta" ///
				".\DTA\18-07-27 OECD_taxes_african.dta" ///
				".\DTA\18-07-27 OECD_taxes_asian.dta"
				
duplicates drop
save ".\DTA\18-07-27 OECD_taxes.dta", replace			
				
/* import government expenditure */
import delimited ".\CSV\18-07-27 OECD_government_expenditure.csv", clear   
replace value = value*10^(powercodecode)
keep country year transact value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(transact) string
rename country cname
rename unitcode oecd1_unitcode
save ".\DTA\18-07-27 OECD_government_expenditure.dta", replace

/* import imputed rentals */
import delimited ".\CSV\18-07-27 OECD_imprent.csv", clear 
replace value = value*10^(powercodecode)
keep country year transact value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(transact) string
rename country cname
rename unitcode oecd3_unitcode
save ".\DTA\18-07-27 OECD_imprent.dta", replace

/* import final consumption expenditure */
import delimited ".\CSV\18-07-27 OECD_consumption.csv", clear   
replace value = value*10^(powercodecode)
keep country year transact value unitcode
rename value oecd_
reshape wide oecd_, i(country year) j(transact) string
rename country cname
rename unitcode oecd_unitcode
save ".\DTA\18-07-27 OECD_consumption.dta", replace
