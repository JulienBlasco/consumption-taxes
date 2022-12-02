/* CHANGE DIRECTORY */
cd "G:"
use ".\DTA\20_11_2022 mod10 summaries", clear

global redineq_datasets ///
	at04 at07 at13 au03 au08 au10 ca04 ca07 ca10 ca13 ch00 ch02 ch04 ch07 ch10 ch13 cz02 cz04 ///
	cz07 cz10 cz13 de00 de04 de07 de10 de13 de15 dk00 dk04 dk07 dk10 dk13 ee10 ee13 es07 es10 ///
	es13 fi00 fi04 fi07 fi10 fi13 fr00 fr05 fr10 gr07 gr10 gr13 ie04 ie07 ie10 il10 is04 is07 is10 it04 it08 it10 ///
	it14 jp08 kr06 kr08 kr10 kr12 lu04 lu07 lu10 lu13 nl99 nl04 nl07 nl10 nl13 no00 no04 no07 no10 no13 ///
	pl04 pl07 pl10 pl13 pl16 pl99 se00 se05 sk04 sk07 sk10 sk13 uk99 uk04 uk07 uk10 uk13 us00 us04 ///
	us07 us10 us13 us16 at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 ///
	mx10 mx12 mx98 si10  /* it00 il12 si12*/ 
	
global red_net_datasets ///
	at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10 ///
	/*it00*/ // Removed es00 and it98 in this version since they contain dupicates and missing values respectively in pil.

drop conc_dhi_dhi conc_dhi_hmc_wor conc_dhi_hmc_wor_pred conc_dhi_inc_5_ours_wor ///
	conc_dhi_inc_5_ours_wor_pred conc_dhi_tax_eff_ours_wor conc_dhi_tax_eff_ours_wor_pred ///
	gini_dhi_scope_hmc gini_inc4 Gini_ours_wor Gini_ours_wor_pred mean_hchous ///
	mean_hitp mean_hmc mean_hmc_wor_pred_scaled mean_hmc_wor_scaled mean_hmchous ///
	mean_inc4 oecd_prop_wor oecd_prop itrc_carey* itrc_euro* itrc_ours_wor ///
	tax_eff_ours_wor_mean inc_5_ours_wor_mean  ///
	tax_eff_ours_wor_pred_mean inc_5_ours_wor_pred_mean G_diff_ours_wor RS_ours_wor ///
	kak_wor G_diff_ours_wor_pred RS_ours_wor_pred kak_wor_pred apc_lis_wor apc_lis ///
	global_tax_rate_ours_pred global_tax_rate_ours ///
	macro_global_tax_rate_ours_pred macro_global_tax_rate_ours year_s ///
	last_year the_year last_year_obs the_year_obs ///
	tax_eff_carey_* tax_eff_euro_*  inc_5_carey_* inc_5_euro_*
	
 order ccyy ccyy_f cname year ///
	mean_* itrc_* tax_* inc_5_* Gini_* G_* ///
	kak* RS_* conc_*, first

gen fourlevers = 0
foreach ccyy of global redineq_datasets {
	qui replace fourlevers = 1 if ccyy == "`ccyy'"
}
replace fourlevers = 0 if inlist(ccyy, "at00", "be00", "gr00", "hu05", "hu07", "hu09", "hu12", "hu99", "ie00") ///
	| inlist(ccyy, "lu00", "mx00", "mx02", "mx04", "mx08", "mx10", "mx12", "mx98", "si10")
replace fourlevers = 0 if inlist(ccyy, "kr06", "jp08", "is04") | inlist(cname, "Poland", "Switzerland")

foreach var4L in mean_inc1 mean_inc2 mean_inc3 Gini_inc1 Gini_inc2 Gini_inc3 {
	replace `var4L' = . if fourlevers != 1
}

/*
preserve
import delimited ".\CSV\2020_09_21 availability mod1.csv", clear delimiter(space, collapse)
drop v1 v17
capture noisily save ".\DTA\2020_09_21 availability mod1.dta"
restore

merge 1:1 ccyy using ".\DTA\2020_09_21 availability mod1.dta", ///
	keep(master match) keepusing(av_inc_5_ours_pred av_inc_5_ours) nogenerate	
	
drop if (mi(mean_hmc_pred_scaled) & mi(mean_hmc_scaled)) | (av_inc_5_ours_pred < 0.9 & av_inc_5_ours < 0.9)
drop av_inc_5_ours*
*/

drop if (mi(inc_5_ours_mean) & mi(inc_5_ours_pred_mean))
drop mean_scope

rename (mean_dhi mean_hmc_pred_scaled mean_hmc_scaled ///
	mean_inc1 mean_inc2 mean_inc3) ///
	(M_dhi M_tcons_pred M_tcons M_inc1 M_inc2 M_inc3)
	
rename itrc_ours effective_taxrate

rename (tax_eff_ours_mean  tax_eff_ours_pred_mean) ///
	(M_tax M_tax_pred)
	
rename (inc_5_ours_mean inc_5_ours_pred_mean) ///
	(M_inc5 M_inc5_pred)
	
rename (Gini_ours Gini_ours_pred) ///
	(Gini_inc5 Gini_inc5_pred)
	
rename (G_diff_ours G_diff_ours_pred) ///
	(Gini_diff Gini_diff_pred)
	
rename (kak kak_pred) ///
	(Kak Kak_pred)
	
rename (RS_ours RS_ours_pred) ///
	(RS RS_pred)
	
rename (conc_dhi_hmc conc_dhi_hmc_medianized_predict ///
	conc_dhi_inc_5_ours conc_dhi_inc_5_ours_pred ///
	conc_dhi_tax_eff_ours conc_dhi_tax_eff_ours_pred) ///
	(Conc_tcons Conc_tcons_pred Conc_inc5 ///
	Conc_inc5_pred Conc_tax Conc_tax_pred)

label variable ccyy "Country-year code"
label variable ccyy_f "Country-year name"
label variable cname "Country name"
label variable year "Year"
label variable M_dhi "Mean of Disposable Income"
label variable M_tcons_pred "Mean of imputed taxable consumption"
label variable M_tcons "Mean of observed taxable consumption"
label variable M_inc1 "Mean of Factor Income"
label variable M_inc2 "Mean of Market Income"
label variable M_inc3 "Mean of Gross Income"
label variable effective_taxrate "Implicit effective tax rate on consumption"
label variable M_tax "Mean of consumption tax paid"
label variable M_tax_pred "Mean of consumption tax paid (imputed consumption)"
label variable M_tax "Mean of consumption tax paid (observed consumption)"
label variable M_inc5_pred "Mean of Post-Tax Income (imputed consumption)"
label variable M_inc5 "Mean of Post-Tax income (observed consumption)"
label variable Gini_pre "Gini of Disposable Income"
label variable Gini_inc1 "Gini of Factor Income"
label variable Gini_inc2 "Gini of Market Income"
label variable Gini_inc3 "Gini of Gross Income"
label variable Gini_inc5 "Gini of Post-Tax Income (observed consumption)"
label variable Gini_inc5_pred "Gini of Post-Tax Income (imputed consumption)"
label variable Gini_diff "Redistributive impact of consumption taxes (observed consumption)"
label variable Gini_diff_pred "Redistributive impact of consumption taxes (imputed consumption)"
label variable Kak "Regressivity index of consumption taxes (observed consumption)"
label variable Kak_pred "Regressivity index of consumption taxes (imputed consumption)"
label variable RS "Vertical redistribution index of consumption taxes (observed consumption)"
label variable RS_pred "Vertical redistribution index of consumption taxes (imputed consumption)"
label variable Conc_tcons "Concentration index of observed taxable consumption over disposable income"
label variable Conc_tcons_pred "Concentration index of imputed taxable consumption over disposable income"
label variable Conc_inc5 "Concentration index of Post-Tax Income (observed consumption) over DI"
label variable Conc_inc5_pred "Concentration index of Post-Tax Income (imputed consumption) over DI"
label variable Conc_tax "Concentration index of consumption tax paid (observed consumption) over DI"
label variable Conc_tax_pred "Concentration index of consumption tax paid (imputed consumption) over DI"

label data "Aggregated indicators, extended model. Credits Blasco-Guillaud-Zemmour 2020"

note: This data contains aggregated indicators from the extended model: ///
rents are NOT removed from taxable consumption, and the imputation model DOES NOT use ///
the value of housing as an independant variable. Hence, the imputed consumption is a bit less ///
accurate whereas the regressivity of consumption taxes are slightly overestimated

note: Version of the model: 2022.11.20

note: Version of the dataset: TS

note: Credits: Julien Blasco, Elvire Guillaud, Michael Zemmour, ///
"How regressive are consumptions taxes? An international perspective with microsimulation", ///
February 2020

save ".\DTA\ConsumptionTaxes_indicators_xtnddmodel", replace
