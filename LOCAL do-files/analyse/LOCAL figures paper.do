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
	 
gen M_tcons_central = M_tcons
replace M_tcons_central = M_tcons_pred if mi(M_tcons_central)
gen M_tax_central = M_tax
replace M_tax_central = M_tax_pred if mi(M_tax_central)
gen M_inc5_central = M_inc5
replace M_inc5_central = M_inc5_pred if mi(M_inc5_central)
gen Gini_inc5_central = Gini_inc5
replace Gini_inc5_central = Gini_inc5_pred if mi(Gini_inc5_central)
gen Gini_diff_central = Gini_diff
replace Gini_diff_central = Gini_diff_pred if mi(Gini_diff_central)
gen Kak_central = Kak
replace Kak_central = Kak_pred if mi(Kak_central)
gen RS_central = RS
replace RS_central = RS_pred if mi(RS_central)
gen Conc_tcons_central = Conc_tcons
replace Conc_tcons_central = Conc_tcons_pred if mi(Conc_tcons_central)
gen Conc_inc5_central = Conc_inc5
replace Conc_inc5_central = Conc_inc5_pred if mi(Conc_inc5_central)
gen Conc_tax_central = Conc_tax
replace Conc_tax_central = Conc_tax_pred if mi(Conc_tax_central)


* set scheme s1mono
* set scheme s1color
set scheme plotplaincolor

// Figure 2: actual and predicted Gini coefficients
// graph dot (asis) Gini_inc5_pred Gini_pre Gini_inc5 if year == max_year_obs, ///
// 	over(model, relabel(1 " " 2 "*")) over(ccyy_f, sort(Gini_pre) descending) nofill exclude0 ///
// 	marker(1, msymbol(lgx)) yscale(range(0.2 0.2)) ytitle(Gini index of income) ///
// 	legend(caption(* imputation done with extended model) rows(3) ///
// 		order(2 "Disposable Income" 3 "Post-tax Income (observed consumption)" ///
// 		1 "Post-Tax Income (imputed consumption)"))

capture {
	gen clock2 = 4
	replace clock2 = 10 if Gini_inc5_pred > Gini_inc5 | ccyy == "fr84"
	replace clock2 = 12 if inlist(ccyy, "pl13","au10")
	replace clock2 = 9 if inlist(ccyy, "fr89", "fr94")
	replace clock2 = 3 if inlist(ccyy, "si12", "hu07", "it95", "it08")
}
twoway (scatter Gini_inc5_pred Gini_inc5 if Gini_inc5<0.4, mlabel(ccyy) mlabvpos(clock2)) ///
	(function y = x, range(0.25 0.4)), ///
	ytitle(Imputed consumption) xtitle(Observed consumption) ///
	legend(position(6) order(2 "45-degree line: no prediction error") title(Gini index of Post-Tax Income))
graph export "E:\Notes\2020-10 Article\images\20-10_prediction_gini_posttax.eps", ///
	as(eps) preview(on) replace
	
	
// Figure 4: Gini of market, gross, disposable and post tax income
graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_central if central & !mi(Gini_inc2), ///
	over(cname, sort(Gini_inc5_central) descending) ytitle(Gini index of income inequality) ///
	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income"))
graph export "E:\Notes\2020-10 Article\images\2020-10_market_gross_di_posttax.eps", ///
	as(eps) preview(on) replace
	

// Figure 5: estimated rise in Gini index due to consumption taxes
graph hbar (asis) Gini_diff_central if central, over(cname, sort(Gini_diff_central) descending) ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ylabel(0(0.01)0.05) graphregion(fcolor(white))
graph export "E:\Notes\2020-10 Article\images\2020-10_regressive_impact.eps", as(eps) preview(on) replace

// Figure 6: redistributive impact vs effective tax rate
capture {
	gen clock6 = 9
	replace clock6 = 12 if inlist(cname, "Czech Republic", "United States")
	replace clock6 = 3 if inlist(cname, "Belgium", "Ireland", "Mexico")
}
twoway (scatter Gini_diff_central effective_taxrate if model==0 & !central, mcolor(*0.3)) ///
	(scatter Gini_diff_central effective_taxrate if central, mlabel(cname) mlabcolor(navy) mcolor(navy) msymbol(circle) mlabvpos(clock6)), ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ///
	xtitle(Effective tax rate on consumption) graphregion(fcolor(white)) legend(off)
graph export "E:\Notes\2020-10 Article\images\2020-10_regrimpact_itrc.eps", as(eps) preview(on) replace
	
// Figure 7: Kakwani, global TIR and RS
capture {
	gen mean_rate = M_tax_central/M_dhi
	gen pos_kak = -Kak_central
}
twoway (scatter pos_kak mean_rate if central, mlabel(cname)  ///
	yaxis(1 2) ylab(.02333333 "RS = 0.01" .04666667 "RS = 0.02" ///
	0.07 "RS = 0.03" 0.093333 "RS = 0.04" 0.11666667 "RS = 0.05" ///
	0.14 "RS = 0.06", noticks labstyle(size(small)) axis(2) angle(h))) ///
	(function RS1 = (0.01*(1-x)/x)/(1-(.01*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS3 = (0.02*(1-x)/x)/(1-(.02*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS5 = (0.03*(1-x)/x)/(1-(.03*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS7 = (0.04*(1-x)/x)/(1-(.04*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function (0.05*(1-x)/x)/(1-(.05*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function (0.06*(1-x)/x)/(1-(.06*(1-x)/x > 0.2)), range(0.05 0.3)), ///
	xtitle("Global tax-to-income ratio") ///
	ytitle("Kakwani index of regressivity", axis(1)) ///
	legend(off)
graph export "E:\Notes\2020-10 Article\images\2020-10_kakwani_globalTIR.eps", as(eps) preview(on) replace
	
	
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

gen tcons_central = tcons
replace tcons_central = tcons_pred if mi(tcons_central)
gen tax_central = tax
replace tax_central = tax_pred if mi(tax_central)
gen inc5_central = inc5
replace inc5_central = inc5_pred if mi(inc5_central)
gen propensity_central = propensity
replace propensity_central = propensity_pred if mi(propensity_central)
gen tax_ratio_central = tax_ratio
replace tax_ratio_central = tax_ratio_pred if mi(tax_ratio_central)

// Figure 4: TIR for FR, US, DE, DK
preserve
keep if inlist(cname,"France", "United States", "Germany", "Denmark") & central
keep ccyy tax_ratio_central percentile
drop if tax_ratio_central > 0.4
reshape wide tax_ratio_central , i(percentile) j(ccyy) string
twoway line tax_ratio_central???? percentile, ytitle(Tax-to-income ratio) ///
	legend(order(2 "Denmark" 3 "France" 1 "Germany" 4 "United States")) ///
	graphregion(fcolor(white)) lpattern(solid dash vshortdash longdash_dot)
graph export "E:\Notes\2020-10 Article\images\2020-10_TIR_qu100_dedkfrus.eps", ///
	as(eps) preview(on) replace
restore

********************
* ITRC DATASET
********************

// Figure B.1.a : ITRC
use "./Itrcs scalings/18-08-31_itrcs_scalings.dta", replace
tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

graph dot (mean) itrc_carey itrc_ours itrc_euro if !mi(itrc_ours), ///
	over(cname, sort(itrc_ours) label(angle(45))) vertical ///
	ylabel(, angle(horizontal)) ///
	legend(title(Average implicit tax rate for each definition, size(medium)) ///
	order(1 "Carey et al. 2000" 2 "Present paper" 3 "Eurostat 2016") position(6) rows(1))
graph export "E:\Notes\2020-10 Article\images\2020-11_averageITRCS.eps", as(eps) preview(on) replace


/************************************************/
/* FIGURES IN APPENDIX WITH MOD 1     */
/************************************************/
cd "D:"
cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"
use ".\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear

egen max_year = max(year), by(cname)
egen max_year_obs = max(year) if !mi(M_inc5), by(cname)

gen M_tcons_central = M_tcons
replace M_tcons_central = M_tcons_pred if mi(M_tcons_central)
gen M_tax_central = M_tax
replace M_tax_central = M_tax_pred if mi(M_tax_central)
gen M_inc5_central = M_inc5
replace M_inc5_central = M_inc5_pred if mi(M_inc5_central)
gen Gini_inc5_central = Gini_inc5
replace Gini_inc5_central = Gini_inc5_pred if mi(Gini_inc5_central)
gen Gini_diff_central = Gini_diff
replace Gini_diff_central = Gini_diff_pred if mi(Gini_diff_central)
gen Kak_central = Kak
replace Kak_central = Kak_pred if mi(Kak_central)
gen RS_central = RS
replace RS_central = RS_pred if mi(RS_central)
gen Conc_tcons_central = Conc_tcons
replace Conc_tcons_central = Conc_tcons_pred if mi(Conc_tcons_central)
gen Conc_inc5_central = Conc_inc5
replace Conc_inc5_central = Conc_inc5_pred if mi(Conc_inc5_central)
gen Conc_tax_central = Conc_tax
replace Conc_tax_central = Conc_tax_pred if mi(Conc_tax_central)

// Figure 2: actual and predicted Gini coefficients
// graph dot (asis) Gini_inc5_pred Gini_pre Gini_inc5 if year == max_year_obs, ///
// 	over(model, relabel(1 " " 2 "*")) over(ccyy_f, sort(Gini_pre) descending) nofill exclude0 ///
// 	marker(1, msymbol(lgx)) yscale(range(0.2 0.2)) ytitle(Gini index of income) ///
// 	legend(caption(* imputation done with extended model) rows(3) ///
// 		order(2 "Disposable Income" 3 "Post-tax Income (observed consumption)" ///
// 		1 "Post-Tax Income (imputed consumption)"))

capture {
	gen clockB2 = 4
	replace clockB2 = 10 if Gini_inc5_pred > Gini_inc5 | ccyy == "fr84"
	replace clockB2 = 12 if inlist(ccyy, "pl13","au10")
	replace clockB2 = 9 if inlist(ccyy, "fr89", "fr94")
	replace clockB2 = 3 if inlist(ccyy, "si12", "hu07", "it95", "it08")
}
twoway (scatter Gini_inc5_pred Gini_inc5 if Gini_inc5<0.4, mlabel(ccyy) mlabvpos(clockB2)) ///
	(function y = x, range(0.25 0.4)), ///
	ytitle(Imputed consumption (Lighter model)) xtitle(Observed consumption) ///
	legend(position(6) order(2 "45-degree line: no prediction error") title(Gini index of Post-Tax Income))
graph export "E:\Notes\2020-10 Article\images\2020-11_prediction_gini_posttax_mod1.eps", ///
	as(eps) preview(on) replace


// Gini pre et post tax
graph dot (asis) Gini_inc5_central Gini_pre if year == max_year, ///
	over(cname, sort(Gini_pre) descending) ytitle(Gini index of income inequality) ///
	legend(order(2 "Disposable Income" 1 "Post-consumption-tax"))
graph export "E:\Notes\2020-10 Article\images\2020-11_gini_prepost_mod1.eps", as(eps) preview(on) replace

// Figure 6: redistributive impact vs effective tax rate
capture {
	reg Gini_diff_central effective_taxrate
	predict lfit_Gdiff
}
capture {
	gen clockB6 = 12 if Gini_diff_central > lfit_Gdiff
	replace clockB6 = 6 if Gini_diff_central <= lfit_Gdiff
	replace clockB6 = 9 if inlist(cname, "Estonia", "United Kingdom")
	// replace clockB6 = 3 if inlist(cname, "Belgium", "Ireland", "Mexico")
}
twoway (scatter Gini_diff_central effective_taxrate if year != max_year, mcolor(*0.3)) ///
	(scatter Gini_diff_central effective_taxrate if year == max_year, mlabel(cname) mlabcolor(navy) mcolor(navy) msymbol(circle)  mlabvpos(clockB6)), ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ///
	xtitle(Effective tax rate on consumption) legend(off)
graph export "E:\Notes\2020-10 Article\images\2020-11_regrimpact_itrc_mod1.eps", as(eps) preview(on) replace

/************************************************/
/* FIGURES IN APPENDIX WITH EGAP     */
/************************************************/

import delimited "D:\BLASCOLIEPP\Code\19-08-21 Datasets V6\CSV\19-08-23 V6 fr10 qu20 egap 0-1-2.csv", clear 
keep extremegap quantile dhi tax_eff_ours tax_eff_ours_wor
gen global_rate = tax_eff_ours/dhi
gen global_rate_wor = tax_eff_ours_wor /dhi
reshape wide tax_eff_ours_wor global_rate_wor , i(quantile dhi tax_eff_ours global_rate ) j(extremegap )

label variable global_rate `""Constant tax rate" "on whole consumption""'
label variable global_rate_wor0 `""Constant tax rate" "on non-housing consumption" "(present paper)""'
label variable global_rate_wor1 `""Progressive tax rate" "(medium scenario)""'
label variable global_rate_wor2 `""Progressive tax rate" "(extreme scenario)""'

twoway line global_rate global_rate_wor0  ///
 global_rate_wor1 global_rate_wor2 quantile, ///
 xtitle(Income vingtile) ytitle(Tax-to-income ratio) ///
 legend(position(6) cols(2)) lpattern(dash solid vshortdash longdash_dot) 

graph export "E:\Notes\2020-10 Article\images\20-01_diff_rates.eps", as(eps) preview(on) replace
