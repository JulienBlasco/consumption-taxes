/* CHANGE DIRECTORY */
cd "D:"
capture noisily cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"

use ".\DTA\2020_09_21 qu100 mod1 1s4", clear
append using ".\DTA\2020_09_21 qu100 mod1 2s4.dta"
append using ".\DTA\2020_09_21 qu100 mod1 3s4.dta"
append using ".\DTA\2020_09_21 qu100 mod1 4s4.dta"

keep ccyy ccyy_f cname year dhi_quantiles ///
	dhi_q hmc_scaled_q hmc_pred_scaled_q ///
	global_prop_q global_prop_pred_q ///
	itrc_ours tax_eff_ours_q tax_eff_ours_pred_q ///
	global_rate_ours_q global_rate_ours_pred_q ///
	inc_5_ours_q inc_5_ours_pred_q

order ccyy ccyy_f cname year dhi_quantiles ///
	dhi_q hmc_scaled_q hmc_pred_scaled_q ///
	global_prop_q global_prop_pred_q ///
	itrc_ours tax_eff_ours_q tax_eff_ours_pred_q ///
	global_rate_ours_q global_rate_ours_pred_q ///
	inc_5_ours_q inc_5_ours_pred_q
	
preserve
import delimited ".\CSV\2020_09_21 availability mod1.csv", clear delimiter(space, collapse)
drop v1 v17
capture noisily save ".\DTA\2020_09_21 availability mod1.dta"
restore

merge m:1 ccyy using ".\DTA\2020_09_21 availability mod1.dta", ///
	keep(master match) keepusing(av_inc_5_ours_pred av_inc_5_ours) nogenerate

drop if (mi(hmc_scaled_q) & mi(hmc_pred_scaled_q)) | (av_inc_5_ours_pred < 0.9 & av_inc_5_ours < 0.9)
drop av_inc_5_ours*

rename *_q *
rename dhi_quantiles percentile
rename (hmc_scaled hmc_pred_scaled) (tcons tcons_pred)
rename (global_prop global_prop_pred) (propensity propensity_pred)
rename itrc_ours effective_taxrate
rename (tax_eff_ours tax_eff_ours_pred) (tax tax_pred)
rename (global_rate_ours global_rate_ours_pred) (tax_ratio tax_ratio_pred)
rename (inc_5_ours inc_5_ours_pred) (inc5 inc5_pred)

label variable ccyy "Country-year code"
label variable ccyy_f "Country-year name"
label variable cname "Country name"
label variable year "Year"
label variable percentile "Percentile of Disposable Income"
label variable  dhi "Disposable Income"
label variable  tcons "Taxable consumption (observed)"
label variable  tcons_pred "Taxable consumption (imputed)"
label variable  propensity "Propensity to consume (observed consumption)"
label variable  propensity_pred "Propensity to consume (imputed consumption)"
label variable effective_taxrate "Implicit effective tax rate on consumption"
label variable  tax "Consumption tax paid (observed consumption)"
label variable  tax_pred "Consumption tax paid (imputed consumption)"
label variable  tax_ratio "Tax-to-income ratio (observed consumption)"
label variable  tax_ratio_pred "Tax-to-income ratio (imputed consumption)"
label variable  inc5 "Post-Tax Income (observed consumption)"
label variable  inc5_pred "Post-Tax Income (imputed consumption)"


label data "Variable percentiles, extended model. Credits Blasco-Guillaud-Zemmour 2020"

note: This data contains variable percentiles from the extended model: ///
rents are NOT removed from taxable consumption, and the imputation model DOES NOT use ///
the value of housing as an independant variable. Hence, the imputed consumption is a bit less ///
accurate whereas the regressivity of consumption taxes are slightly overestimated.

note: Version of the model: 2020.09.21

note: Use carefully: very high propensities to consume observed at the first percentiles ///
may not be reliable.

note percentile: Warning: first percentiles might not be reliable.

note: Credits: Julien Blasco, Elvire Guillaud, Michael Zemmour, ///
"How regressive are consumptions taxes? An international perspective with microsimulation", ///
February 2020

save ".\DTA\ConsumptionTaxes_percentiles_xtnddmodel", replace
