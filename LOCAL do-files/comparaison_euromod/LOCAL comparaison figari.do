cd "E:\Notes\2021-03 Resubmit JPubEc\Comparaison ITRC Microsim\Figari_2015"
use "figari.dta", replace

*********
gen cname = "Belgium" if cn == "be"
replace cname = "Greece" if cn == "gr"
replace cname = "United Kingdom" if cn == "uk"

gen year = 2003 if cn == "be"
replace year = 2004 if cn == "gr"
replace year = 2004 if cn == "uk"

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

merge m:1 cname year using "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\Itrcs scalings\18-08-31_itrcs_scalings.dta", ///
	keep(match) keepusing(itrc_ours oecd_5110 oecd_5121 oecd_P3 oecd_D1CG oecd_P31CP042) nogenerate
sort cname decile

gen itrc_ours_restreint = (oecd_5110+oecd_5121)/ ///
	(oecd_P3-oecd_D1CG-oecd_P31CP042)
gen taux_effectif = itrc_ours/(1+itrc_ours)
gen tax_prop_ours = prop * taux_effectif

replace tax_prop_figari = tax_prop_figari/100

* comparaison brute taux ITRC et taux figari
twoway line  taux_figari taux_effectif average_figari decile, lpattern(solid solid dash) by(cname)

twoway line  tax_prop* decile,  by(ccyy_f) yscale(range(0 0.1))


preserve
keep cname year decile tax_prop_figari tax_prop_ours
reshape wide tax_prop_figari tax_prop_ours, i(cname year) j(decile)
gen ecart_figari = tax_prop_figari10/tax_prop_figari1
gen ecart_ours = tax_prop_ours10/tax_prop_ours1

gen ecart_figari2 = tax_prop_figari9/tax_prop_figari2
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

