

cd "D:"
cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"
use ".\DTA\ConsumptionTaxes_indicators_coremodel.dta", clear
append using ".\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", generate(model)

sort cname year

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

label define model 0 "Core" 1 "Extended"
label values model model

list cname year if inlist(cname, "Belgium", "Greece", "Hungary", "Ireland", "United Kingdom")

keep if inlist(ccyy, "be97", "gr04", "hu05", "ie04", "uk04")

clist itrc_ours

*********
use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\Itrcs scalings\18-08-31_itrcs_scalings.dta", clear
merge 1:1 cname year using "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\match cname year.dta", ///
	keep(master match) keepusing(ccyy) nogenerate
gen cn = substr(ccyy, 1,2)
replace cn = "ie" if cname == "Ireland"
replace cn = "be" if cname == "Belgium"
keep if cname == "Belgium" & year == 2003 | ///
	cname == "Greece" & year == 2004 | ///
	cname == "Hungary" & year == 2005 | ///
	cname == "Ireland" & year == 2001 | ///
	cname == "United Kingdom" & year == 2004
merge 1:m cn using "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\2021_05_31_decoster.dta", ///
	nogenerate
*keep if inlist(ccyy, "be97", "gr04", "hu05", "ie04", "uk04")
sort cname decile

gen itrc_ours_decoster = (oecd_5110+oecd_5121)/ ///
	(oecd_P3-oecd_D1CG-oecd_P31CP042)
	
gen taux_effectif = itrc_ours/(1+itrc_ours)*100

gen itrc_ours_decoster_wor = (oecd_5110+oecd_5121)/ ///
	(oecd_P3-oecd_D1CG-oecd_rents)
gen taux_effectif_wor = itrc_ours_decoster_wor/(1+itrc_ours_decoster_wor)*100

gen relexcise_cn = oecd_5121/oecd_5110

gen relexcise_decoster = excise/TVA
gen coef = (1+relexcise_cn)/(1+relexcise_decoster_av)
gen average_fig_ajuste1 = average_figari * coef
gen fig_ajuste1 = taux_figari * coef // *(1+relexcise_cn/relexcise_decoster_av*relexcise_decoster)/(1+relexcise_decoster) 
	
*gen average_decost_ajuste = average_decoster*vat_gap
*gen decoster_ajuste = taux_decoster*vat_gap
gen average_fig_ajuste2 = average_fig_ajuste1*vat_gap
gen fig_ajuste2 = fig_ajuste1*vat_gap

* comparaison brute taux ITRC et taux decoster
twoway line  taux_decoster taux_effectif average_decoster decile, lpattern(solid solid dash) by(cname)

* comparaison brute taux ITRC et taux figari
twoway line average_figari taux_figari taux_effectif_wor decile if inlist(cn, "be", "gr", "uk"), ///
	lpattern(dash) by(cname)

* comparaison taux ITRC et taux figari ajustés
twoway line average_fig_ajuste2 taux_figari fig_ajuste1 fig_ajuste2 taux_effectif decile if inlist(cn, "be", "gr", "uk"), ///
	by(cname)

twoway line average_fig_ajuste2 fig_ajuste2 taux_effectif decile if inlist(cn, "be", "gr", "uk"), ///
	by(cname) lpattern(dash)
	
save "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\2021_05_31_decoster_comparison.dta", replace


******* COMPARAISON DES DIFFERENCES DE GINI **********
use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear
gen Gini_disp_figari = 0.228 if cname == "Belgium"
replace Gini_disp_figari = 0.320 if cname == "Greece"
replace Gini_disp_figari = 0.318 if cname == "United Kingdom"

gen Gini_inc5_figari = 0.234 if cname == "Belgium"
replace Gini_inc5_figari = 0.352 if cname == "Greece"
replace Gini_inc5_figari = 0.332 if cname == "United Kingdom"

