cd "E:\Notes\2021-03 Resubmit JPubEc\Comparaison ITRC Microsim\Odonoghue_2004"
import excel ".\ODonogue_2004.xlsx", sheet("VAT over Exp") firstrow clear
rename * vat_exp=
rename vat_expDecile Decile
reshape long vat_exp, i(Decile) j(cc, string)
save ".\ODonogue_2004_vat_exp.dta", replace

import excel ".\ODonogue_2004.xlsx", sheet("VAT over DHI") firstrow clear
drop if Decile == ""
rename * vat_dhi=
rename vat_dhiDecile Decile
reshape long vat_dhi, i(Decile) j(cc, string)
save ".\ODonogue_2004_vat_dhi.dta", replace

import excel ".\ODonogue_2004.xlsx", sheet("Excise over Exp") firstrow clear
drop if Decile == ""
rename * exc_exp=
rename exc_expDecile Decile
reshape long exc_exp, i(Decile) j(cc, string)
save ".\ODonogue_2004_exc_exp.dta", replace

import excel ".\ODonogue_2004.xlsx", sheet("Excise over dhi") firstrow clear
drop if Decile == ""
rename * exc_dhi=
rename exc_dhiDecile Decile
reshape long exc_dhi, i(Decile) j(cc, string)
save ".\ODonogue_2004_exc_dhi.dta", replace

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
cd "E:\Notes\2021-03 Resubmit JPubEc\Comparaison ITRC Microsim\Odonoghue_2004"
clear
use ".\ODonogue_2004_vat_exp.dta", clear
merge 1:1 Decile cc using ".\ODonogue_2004_vat_dhi.dta", nogenerate
merge 1:1 Decile cc using ".\ODonogue_2004_exc_exp.dta", nogenerate
merge 1:1 Decile cc using ".\ODonogue_2004_exc_dhi.dta", nogenerate

replace cc = lower(cc)
gen yy = 98
egen ccyy = concat(cc yy)
gen year = 1998

gen decile_num = Decile if Decile != "Total"
replace decile_num = "11" if Decile == "Total"
destring decile_num, replace
label define deciles 11 "Total" 
label values decile_num deciles  

gen cname = "Belgium" if cc == "be"
replace cname = "Finland" if cc == "fi"
replace cname = "France" if cc == "fr"
replace cname = "Greece" if cc == "gr"
replace cname = "Ireland" if cc == "ir"
replace cname = "Italia" if cc == "ir"
replace cname = "Luxembourg" if cc == "lu"
replace cname = "Netherlands" if cc == "nl"
replace cname = "Portugal" if cc == "pt"
replace cname = "Spain" if cc == "sp"
replace cname = "Sweden" if cc == "sw"
replace cname = "United Kingdom" if cc == "uk"

sort cname decile_num

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

merge m:1 cname year using ///
"E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\Itrcs scalings\18-08-31_itrcs_scalings.dta", ///
keep(match) keepusing(itrc_ours oecd_5110 oecd_5121 oecd_P3 oecd_D1CG oecd_P31CP042) nogenerate

gen prop = vat_dhi/vat_exp
gen effective_taxrate_odonoghue = (vat_exp+exc_exp)/100
gen effective_taxrate_ours = itrc_ours/(1+itrc_ours)
gen tax_prop_odonoghue = (vat_dhi + exc_dhi)/100
gen tax_prop_ours = prop * effective_taxrate_ours

gen ecart_tax_prop = tax_prop_ours-tax_prop_odonoghue

*--- graphes ---*

twoway line effective_taxrate_odonoghue effective_taxrate_ours decile_num if Decile != "Total", by(cname) yscale(range(0 0.1))
twoway line tax_prop* decile_num if Decile != "Total" & tax_prop_ours < 0.4, by(ccyy_f) yscale(range(0 0.1))

graph bar (asis) ecart_tax_prop, over(decile_num) by(ccyy_f)

preserve
keep cname year decile_num tax_prop_odonoghue tax_prop_ours
drop if decile_num == 11
reshape wide tax_prop_odonoghue tax_prop_ours, i(cname year) j(decile_num)
gen ecart_odonoghue = tax_prop_odonoghue10/tax_prop_odonoghue1
gen ecart_ours = tax_prop_ours10/tax_prop_ours1

gen ecart_odonoghue2 = tax_prop_odonoghue9/tax_prop_odonoghue2
gen ecart_ours2 = tax_prop_ours9/tax_prop_ours2

graph dot (asis) ecart*, over(cname, sort(ecart_ours))






