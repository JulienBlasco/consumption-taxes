cd "C:\users\julien\Favorites\21-03 Datasets V7 (JPubEc Resubmit)\DTA\"
use "2021_05_31_decoster.dta", replace

*********
gen cname = "Belgium" if cn == "be"
replace cname = "Greece" if cn == "gr"
replace cname = "Ireland" if cn == "ie"
replace cname = "Hungary" if cn == "hu"
replace cname = "United Kingdom" if cn == "uk"

gen year = 2003 if cn == "be"
replace year = 2004 if cn == "gr"
replace year = 2001 if cn == "ie"
replace year = 2005 if cn == "hu"
replace year = 2004 if cn == "uk"

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

merge m:1 cname year using "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\Itrcs scalings\18-08-31_itrcs_scalings.dta", ///
	keep(match) keepusing(itrc_ours oecd_5110 oecd_5121 oecd_P3 oecd_D1CG oecd_P31CP042) nogenerate
sort cname decile

gen itrc_ours_decoster = (oecd_5110+oecd_5121)/ ///
	(oecd_P3-oecd_D1CG-oecd_P31CP042)
	
gen taux_effectif = itrc_ours/(1+itrc_ours)*100

gen tax_prop_decoster = (100-ep) * taux_decoster/10000
gen tax_prop_ours = (100-ep) * taux_effectif/10000


* comparaison brute taux ITRC et taux decoster
twoway line  taux_decoster taux_effectif average_decoster decile, lpattern(solid solid dash) by(cname)

twoway line  tax_prop* decile,  by(ccyy_f) yscale(range(0 0.1))


preserve
keep cname year decile tax_prop_decoster tax_prop_ours
reshape wide tax_prop_decoster tax_prop_ours, i(cname year) j(decile)
gen ecart_decoster = tax_prop_decoster10/tax_prop_decoster1
gen ecart_ours = tax_prop_ours10/tax_prop_ours1

gen ecart_decoster2 = tax_prop_decoster9/tax_prop_decoster2
gen ecart_ours2 = tax_prop_ours9/tax_prop_ours2

graph dot (asis) ecart*, over(cname, sort(ecart_ours))


******* COMPARAISON DES DIFFERENCES DE GINI **********
use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear
gen Gini_disp_figari = 0.228 if cname == "Belgium"
replace Gini_disp_figari = 0.320 if cname == "Greece"
replace Gini_disp_figari = 0.318 if cname == "United Kingdom"

gen Gini_inc5_figari = 0.234 if cname == "Belgium"
replace Gini_inc5_figari = 0.352 if cname == "Greece"
replace Gini_inc5_figari = 0.332 if cname == "United Kingdom"

