/* CHANGE DIRECTORY */
cd "G:"

use "./DTA/20_11_2022_mod2_qu100_ccyypapier", clear

drop year_s hmc_q hmchous_q hmc_medianized_predict_q oecd_prop_wor ///
oecd_prop itrc_carey_wor itrc_euro_wor itrc_carey itrc_euro itrc_ours ///
mean_hmc_pred_scaled mean_hmc_scaled mean_hmc_wor_scaled ///
hmc_mmean hmc_med_pred_mmean hmc_wor_q hmc_wor_mmean ///
hmc_scaled_q hmc_pred_scaled_q global_prop_q tax_eff_carey_q ///
inc_5_carey_q global_rate_carey_q tax_eff_carey_wor_q inc_5_carey_wor_q ///
global_rate_carey_wor_q tax_eff_euro_q inc_5_euro_q global_rate_euro_q ///
tax_eff_euro_wor_q inc_5_euro_wor_q global_rate_euro_wor_q tax_eff_ours_q ///
inc_5_ours_q global_rate_ours_q global_prop_pred_q tax_eff_carey_pred_q ///
inc_5_carey_pred_q global_rate_carey_pred_q tax_eff_carey_wor_pred_q ///
inc_5_carey_wor_pred_q global_rate_carey_wor_pred_q tax_eff_euro_pred_q ///
inc_5_euro_pred_q global_rate_euro_pred_q tax_eff_euro_wor_pred_q ///
inc_5_euro_wor_pred_q global_rate_euro_wor_pred_q tax_eff_ours_pred_q ///
inc_5_ours_pred_q global_rate_ours_pred_q

order ccyy ccyy_f cname year dhi_quantiles ///
	dhi_q hmc_wor_scaled_q hmc_wor_pred_scaled_q ///
	global_prop_wor_q global_prop_wor_pred_q ///
	itrc_ours_wor tax_eff_ours_wor_q tax_eff_ours_wor_pred_q ///
	global_rate_ours_wor_q global_rate_ours_wor_pred_q ///
	inc_5_ours_wor_q inc_5_ours_wor_pred_q
	
drop if (mi(hmc_wor_scaled_q) & mi(hmc_wor_pred_scaled_q))

rename *_q *
rename dhi_quantiles percentile
rename (hmc_wor_scaled hmc_wor_pred_scaled) (tcons tcons_pred)
rename (global_prop_wor global_prop_wor_pred) (propensity propensity_pred)
rename itrc_ours_wor effective_taxrate
rename (tax_eff_ours_wor tax_eff_ours_wor_pred) (tax tax_pred)
rename (global_rate_ours_wor global_rate_ours_wor_pred) (tax_ratio tax_ratio_pred)
rename (inc_5_ours_wor inc_5_ours_wor_pred) (inc5 inc5_pred)

label variable ccyy "Country-year code"
label variable ccyy_f "Country-year name"
label variable cname "Country name"
label variable year "Year"
label variable percentile "Percentile of Disposable Income"
label variable dhi "Disposable Income"
label variable tcons "Taxable consumption (observed)"
label variable tcons_pred "Taxable consumption (imputed)"
label variable propensity "Propensity to consume (observed consumption)"
label variable propensity_pred "Propensity to consume (imputed consumption)"
label variable effective_taxrate "Implicit effective tax rate on consumption"
label variable tax "Consumption tax paid (observed consumption)"
label variable tax_pred "Consumption tax paid (imputed consumption)"
label variable tax_ratio "Tax-to-income ratio (observed consumption)"
label variable tax_ratio_pred "Tax-to-income ratio (imputed consumption)"
label variable inc5 "Post-Tax Income (observed consumption)"
label variable inc5_pred "Post-Tax Income (imputed consumption)"


label data "Variable percentiles, core model. Credits Blasco-Guillaud-Zemmour 2020"

note: This data contains variable percentiles from the core model: ///
rents are removed from taxable consumption, and the imputation model uses ///
the value of housing as an independant variable.

note: Version of the model: 2022.11.20

note: Use carefully: very high propensities to consume observed at the first percentiles ///
may not be reliable.

note percentile: Warning: first percentiles might not be reliable.

note: Credits: Julien Blasco, Elvire Guillaud, Michael Zemmour, ///
"How regressive are consumptions taxes? An international perspective with microsimulation", ///
February 2020

save ".\DTA\ConsumptionTaxes_percentiles_coremodel_ccyypapier", replace
