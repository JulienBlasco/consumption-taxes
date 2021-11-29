/* CHANGE DIRECTORY */
cd "G:"

set varabbrev off, permanent

// choose file
local filename "2021_11_22_par_age_mod2"
local mod "mod2"
//

import delimited "./CSV/`filename'.csv", clear delimiter(space, collapse)
drop v1 v9

// get cnames and years
merge m:1 ccyy using ".\DTA\match cname year.dta"
drop if _merge == 2
drop _merge

// merge with itrcs
merge m:1 cname year using ".\Itrcs scalings\18-08-31_itrcs_scalings.dta", ///
		keepusing(itrc_carey itrc_euro itrc_ours oecd_prop_wor oecd_prop ///
				  itrc_carey_wor itrc_euro_wor itrc_ours_wor)
drop if _merge == 2
drop _merge

// merge with summaries
merge m:1 ccyy using ".\DTA\2021_10_29_summaries_`mod'.dta", ///
			keepusing(mean_hmc mean_dhi mean_hmchous mean_hmc_scaled ///
			mean_hmc_wor_scaled mean_hmc_pred_scaled)
drop if _merge == 2
drop _merge
			
// change order of variables
order ccyy cname year, first
 
preserve
use 			".\DTA\2021_11_22_qu100_`mod'_1s4", clear
append using 	".\DTA\2021_11_22_qu100_`mod'_2s4"
append using 	".\DTA\2021_11_22_qu100_`mod'_3s4"
append using 	".\DTA\2021_11_22_qu100_`mod'_4s4"
keep ccyy hmc_medianized_predict_q
egen mean_hmc_med_pred = mean(hmc_medianized_predict_q), by(ccyy)
keep ccyy mean_hmc_med_pred
duplicates drop
mkmat mean_hmc_med_pred, mat(mean_pred) rownames(ccyy)
restore

svmat mean_pred, names( col )

gen scaling_hmc = oecd_prop / (mean_hmc/mean_dhi)
gen scaling_hmc_wor = oecd_prop_wor / ((mean_hmc-mean_hmchous)/mean_dhi)
gen scaling_hmc_pred = oecd_prop / (mean_hmc_med_pred/mean_dhi)

gen hmc_wor_q 			= hmc_q - hmchous_q
gen hmc_scaled_q 		= hmc_q * scaling_hmc
gen hmc_wor_scaled_q 	= hmc_wor_q * scaling_hmc_wor
gen hmc_pred_scaled_q = hmc_medianized_predict_q * scaling_hmc_pred

local _pred
forvalues i = 1(1)2 {
	gen global_prop`_pred'_q = hmc`_pred'_scaled_q/dhi_q
	gen global_prop_wor`_pred'_q = hmc_wor`_pred'_scaled_q/dhi_q
		foreach def in carey euro ours {
			gen tax_eff_`def'`_pred'_q = itrc_`def' * hmc`_pred'_scaled_q
			gen inc_5_`def'`_pred'_q = dhi_q - tax_eff_`def'`_pred'_q
			gen global_rate_`def'`_pred'_q= tax_eff_`def'`_pred'_q/dhi_q
			
			gen tax_eff_`def'_wor`_pred'_q = itrc_`def'_wor * hmc_wor`_pred'_scaled_q
			gen inc_5_`def'_wor`_pred'_q = dhi_q - tax_eff_`def'_wor`_pred'_q
			gen global_rate_`def'_wor`_pred'_q = tax_eff_`def'_wor`_pred'_q/dhi_q
			
			/*
			gen tax_eff_`def'`_pred'_V3_q = itrc_`def'_V3 * hmc_wor`_pred'_scaled_q
			gen inc_5_`def'`_pred'_V3 = dhi_q - tax_eff_`def'`_pred'_V3
			gen global_rate_`def'`_pred'_V3 = tax_eff_`def'`_pred'_V3/dhi_q
			*/
	}
	local _pred _pred
}

/*
egen last_year_m = max(year)  if !mi(hmc_pred_scaled_q), by(cname)
egen last_year = max(last_year_m), by(cname)
drop last_year_m
gen the_year = (year==last_year)

egen last_year_obs_m = max(year)  if !mi(hmc_scaled_q), by(cname)
egen last_year_obs = max(last_year_obs_m), by(cname)
drop last_year_obs_m
gen the_year_obs = (!mi(last_year_obs) & year==last_year_obs) | (mi(last_year_obs) & year==last_year)
*/

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

rename *_q *_a

save "./DTA/`filename'.dta", replace
