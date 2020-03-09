/* CHANGE DIRECTORY */
cd "D:"
cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6\"


// choose file
local filename "02_08_2019_V6 mod2 qu100"
local mod "mod2"
//

import delimited "./CSV/`filename'.csv", clear 

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
merge m:1 ccyy using ".\DTA\18-09-14 summaries V5 `mod'.dta", ///
			keepusing(hmc_scaled_mean hmc_wor_scaled_mean hmc_pred_scaled_mean)
drop if _merge == 2
drop _merge
			
// change order of variables
order ccyy cname year, first

egen hmc_mmean 			= mean(hmc), by(ccyy)
egen hmc_med_pred_mmean = mean(hmc_medianized_predict), by(ccyy)
gen hmc_wor 			= hmc - hmchous
egen hmc_wor_mmean		= mean(hmc_wor), by(ccyy)

gen hmc_scaled 		= hmc * hmc_scaled_mean/hmc_mmean
gen hmc_wor_scaled 	= hmc_wor * hmc_wor_scaled_mean/hmc_wor_mmean
gen hmc_pred_scaled = hmc_medianized_predict * hmc_pred_scaled_mean/hmc_med_pred_mmean


local _pred
forvalues i = 1(1)2 {
	local _wor
	forvalues j = 1(1)2 {
	gen global_prop`_wor'`_pred' = hmc`_wor'`_pred'_scaled/dhi
		foreach def in carey euro ours {
			gen tax_eff_`def'`_wor'`_pred' = itrc_`def'`_wor' * hmc`_wor'`_pred'_scaled
			gen inc_5_`def'`_wor'`_pred' = dhi - tax_eff_`def'`_wor'`_pred'
			gen global_rate_`def'`_wor'`_pred' = tax_eff_`def'`_wor'`_pred'/dhi
		}
		local _wor _wor
	}
	local _pred _pred
}



egen last_year_m = max(year)  if !mi(hmc_pred_scaled ), by(cname)
egen last_year = max(last_year_m), by(cname)
drop last_year_m
gen the_year = (year==last_year)

egen last_year_obs_m = max(year)  if !mi(hmc_scaled), by(cname)
egen last_year_obs = max(last_year_obs_m), by(cname)
drop last_year_obs_m
gen the_year_obs = (!mi(last_year_obs) & year==last_year_obs) | (mi(last_year_obs) & year==last_year)

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

save "./DTA/`filename'.dta", replace
