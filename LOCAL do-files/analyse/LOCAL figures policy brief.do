/************************************************/
/* FIGURES WITH SUMMARIES DATASET */
/************************************************/
cd "D:"
cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"
use ".\DTA\ConsumptionTaxes_indicators_coremodel.dta", clear
append using ".\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", generate(model)

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

label define model 0 "Core" 1 "Extended"
label values model model

egen max_year = max(year), by(cname)
egen max_year_obs = max(year) if !mi(M_inc5), by(cname)
egen max_year_core = max(year) if model == 0, by(cname)
egen max_year_central = max(year) if (model == 0) | ///
	inlist(cname, "United States", "Norway", "Sweden", "Australia"), by(cname)
gen central = year == max_year_central
	 
gen M_tcons_central = M_tcons if central
replace M_tcons_central = M_tcons_pred if mi(M_tcons_central) & central
gen M_tax_central = M_tax if central
replace M_tax_central = M_tax_pred if mi(M_tax_central) & central
gen M_inc5_central = M_inc5 if central
replace M_inc5_central = M_inc5_pred if mi(M_inc5_central) & central
gen Gini_inc5_central = Gini_inc5 if central
replace Gini_inc5_central = Gini_inc5_pred if mi(Gini_inc5_central) & central
gen Gini_diff_central = Gini_diff if central
replace Gini_diff_central = Gini_diff_pred if mi(Gini_diff_central) & central
gen Kak_central = Kak if central
replace Kak_central = Kak_pred if mi(Kak_central) & central
gen RS_central = RS if central
replace RS_central = RS_pred if mi(RS_central) & central
gen Conc_tcons_central = Conc_tcons if central
replace Conc_tcons_central = Conc_tcons_pred if mi(Conc_tcons_central) & central
gen Conc_inc5_central = Conc_inc5 if central
replace Conc_inc5_central = Conc_inc5_pred if mi(Conc_inc5_central) & central
gen Conc_tax_central = Conc_tax if central
replace Conc_tax_central = Conc_tax_pred if mi(Conc_tax_central) & central


* set scheme s1mono
* set scheme s1color

// Figure 4: Gini of market, gross, disposable and post tax income
graph dot (asis) Gini_inc2 Gini_pre Gini_inc5_central if central & !mi(Gini_inc2), ///
	over(cname, sort(Gini_inc5_central) descending) marker(1, msymbol(square)) ///
	marker(3, msymbol(lgx)) ytitle(Inégalités de revenus (coefficient de Gini)) ///
	legend(order(1 "Revenu avant redistribution directe" 2 "Revenu disponible (après redistribution directe)" 3 "Revenu après taxes à la consommation") ///
	rows(3)) graphregion(fcolor(white))
graph export "E:\Notes\2020-11 Policy Brief\figures\graph2.png", ///
	as(png) replace width(3300)
	

// Figure 6: redistributive impact vs effective tax rate
capture {
	gen clock6 = 9
	replace clock6 = 12 if inlist(cname, "Czech Republic", "United States")
	replace clock6 = 3 if inlist(cname, "Belgium", "Ireland", "Mexico")
}
twoway (scatter Gini_diff_central effective_taxrate, mlabel(cname) mlabvpos(clock6)) if central, ///
	ytitle(Impact des taxes sur les inégalités) ///
	xtitle(Taux effectif de taxe à la consommation) graphregion(fcolor(white))
graph export "E:\Notes\2020-11 Policy Brief\figures\graph3.png", /// 
	as(png) replace width(3300)
	
	
	
/************************************************/
/* FIGURES WITH PERCENTILE DATASET */
/************************************************/
cd "D:"
cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"
use ".\DTA\ConsumptionTaxes_percentiles_coremodel.dta", clear
append using ".\DTA\ConsumptionTaxes_percentiles_xtnddmodel.dta", generate(model)

sort ccyy percentile

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

label define model 0 "Core" 1 "Extended"
label values model model

egen max_year = max(year), by(cname)
egen max_year_obs = max(year) if !mi(inc5), by(cname)
egen max_year_core = max(year) if model == 0, by(cname)
egen max_year_central = max(year) if (model == 0) | ///
	inlist(cname, "United States", "Norway", "Sweden", "Australia"), by(cname)
gen central = year == max_year_central

gen tcons_central = tcons if central
replace tcons_central = tcons_pred if mi(tcons_central) & central
gen tax_central = tax if central
replace tax_central = tax_pred if mi(tax_central) & central
gen inc5_central = inc5 if central
replace inc5_central = inc5_pred if mi(inc5_central) & central
gen propensity_central = propensity if central
replace propensity_central = propensity_pred if mi(propensity_central) & central
gen tax_ratio_central = tax_ratio if central
replace tax_ratio_central = tax_ratio_pred if mi(tax_ratio_central) & central

// Figure 4: TIR for FR, US, DE, DK
preserve
keep if inlist(cname,"France", "United States", "Germany", "Denmark") & central
keep ccyy tax_ratio_central percentile
drop if tax_ratio_central > 0.4
reshape wide tax_ratio_central , i(percentile) j(ccyy) string
twoway line tax_ratio_central???? percentile, ytitle(Tax-to-income ratio) ///
	legend(order(1 "Germany" 2 "Denmark" 3 "France" 4 "United States")) ///
	xtitle(Centile de revenu) ytitle(Taux de taxe rapportée au revenu) graphregion(fcolor(white))
graph export "E:\Notes\2020-11 Policy Brief\figures\graph1.png", ///
	as(png) replace width(3000)
restore

