cd "G:\DTA\comparaison_euromod"

* Déciles de revenu
import delimited using "..\..\CSV\ilc_di01_1_Data.csv", clear
replace value = "" if value == ":"
destring value, replace
rename value dhi
gen cc = lower(geo)
gen Decile = substr(quantile, 2,2)
keep Decile cc dhi

replace cc = "gr" if cc == "el"
replace cc = "sp" if cc == "es"
replace cc = "ir" if cc == "ie"
drop if cc == "it"
replace cc = "sw" if cc == "se"
save ODonogue_2004_dhi, replace

* O'Donoghue
use ".\ODonogue_2004_vat_exp.dta", clear
merge 1:1 Decile cc using ".\ODonogue_2004_vat_dhi.dta", nogenerate
merge 1:1 Decile cc using ".\ODonogue_2004_exc_exp.dta", nogenerate
merge 1:1 Decile cc using ".\ODonogue_2004_exc_dhi.dta", nogenerate

gen yy = 98
egen ccyy = concat(cc yy)
gen year = 1998
replace cc = strlower(cc)

merge 1:1 Decile cc using ODonogue_2004_dhi, nogenerate


* Decoster et Figari
append using "2021_05_31_decoster.dta" "figari.dta", generate(etude)
label define etudes 0 "Odonoghue" 1 "Decoster" 2 "Figari" 3 "ITEP"
label values etude etudes  

replace cc = cn if cn != ""

replace prop = vat_dhi/vat_exp if etude == 0
replace prop = (100-ep)/100 if etude == 1
replace prop = tax_prop_figari/taux_figari if etude == 2

gen effective_taxrate = (vat_exp+exc_exp)/100 if etude == 0
replace effective_taxrate = taux_decoster/100 if etude == 1
replace effective_taxrate = taux_figari/100 if etude == 2

gen tax_prop = prop * effective_taxrate

gen decile_num = Decile if Decile != "Total"
replace decile_num = "11" if Decile == "Total"
destring decile_num, replace
replace decile_num = decile if decile != .
label define deciles 11 "Total" 
label values decile_num deciles  

keep cc year decile_num prop effective_taxrate tax_prop dhi etude

replace year = 2003 if cc == "be" & etude != 0
replace year = 2004 if cc == "gr" & etude != 0
replace year = 2001 if cc == "ie" & etude != 0
replace year = 2005 if cc == "hu" & etude != 0
replace year = 2004 if cc == "uk" & etude != 0

gen cname = "Belgium" if cc == "be"
replace cname = "Finland" if cc == "fi"
replace cname = "France" if cc == "fr"
replace cname = "Greece" if cc == "gr"
replace cname = "Ireland" if cc == "ir" | cc == "ie"
replace cname = "Italia" if cc == "it"
replace cname = "Luxembourg" if cc == "lu"
replace cname = "Netherlands" if cc == "nl"
replace cname = "Portugal" if cc == "pt"
replace cname = "Spain" if cc == "sp"
replace cname = "Sweden" if cc == "sw"
replace cname = "United Kingdom" if cc == "uk"
replace cname = "Hungary" if cc == "hu"

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

merge m:1 cname year using ///
"G:\Itrcs scalings\18-08-31_itrcs_scalings.dta", ///
keep(match) keepusing(itrc_ours oecd_5110 oecd_5121 oecd_P3 oecd_D1CG oecd_P31CP042) nogenerate

sort etude cname decile_num

gen effective_taxrate_ours = itrc_ours/(1+itrc_ours)
gen tax_prop_ours = prop * effective_taxrate_ours

// propensions recalées
gen D5_tax_prop_t = tax_prop if decile_num == 5
gen D5_tax_prop_ours_t = tax_prop_ours if decile_num == 5
egen D5_tax_prop = max(D5_tax_prop_t), by(ccyy_f etude)
egen D5_tax_prop_ours = max(D5_tax_prop_ours_t), by(ccyy_f etude)
drop D5_tax_prop_t D5_tax_prop_ours_t

gen rescaled_tax_prop_ours = tax_prop_ours/D5_tax_prop_ours*D5_tax_prop

* ajout des revenus
foreach cc in be hu ie uk gr {
	merge m:1 etude cc decile_num using "indirect_taxes_`cc'.dta", ///
		keep(master match match_update) keepusing(cc decile_num dhi) ///
		nogenerate update
}

gen tax_eff = tax_prop * dhi
gen tax_eff_ours = tax_prop_ours * dhi
gen tax_eff_ours_rescaled = rescaled_tax_prop_ours * dhi

// rapport T10/B50
egen T10 = max(dhi), by(ccyy_f)
egen B50 = sum(dhi) if inlist(decile_num, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50 = T10/B50

gen inc5 = dhi - tax_eff
gen inc5_ours = dhi - tax_eff_ours
gen inc5_ours_rescaled = dhi - tax_eff_ours_rescaled

egen T10_5 = max(inc5), by(ccyy_f)
egen B50_5 = sum(inc5) if inlist(decile_num, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50_inc5 = T10_5/B50_5

egen T10_5ours = max(inc5_ours), by(ccyy_f)
egen B50_5ours = sum(inc5_ours) if inlist(decile_num, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50_inc5ours = T10_5ours/B50_5ours

egen T10_5ours_rescaled = max(inc5_ours_rescaled), by(ccyy_f)
egen B50_5ours_rescaled = sum(inc5_ours_rescaled) ///
	if inlist(decile_num, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50_inc5ours_rescaled = T10_5ours_rescaled/B50_5ours_rescaled

// ITEP
append using US_ITEP, generate(etude_itep)
replace etude = 3 if etude_itep
drop etude_itep

// coverage incluant les années les plus récentes de odonoghue, decoster, figari
egen max_year = max(year), by(cname)
egen max_etude = max(etude) if year == max_year, by(cname)
gen central = year == max_year & etude == max_etude

notes: Created TS

save "./comparaison_euromod.dta", replace

