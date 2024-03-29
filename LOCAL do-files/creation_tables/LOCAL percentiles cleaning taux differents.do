/* CHANGE DIRECTORY */
cd "D:"
cd "\BLASCOLIEPP\Code\19-07-13 Datasets V6"


// choose file
local filename "19-07-13 fr10 qu20 taux diff"
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

// BY VINTILE : comment out to get by percentile
egen vintile = xtile(quantile), by(ccyy) nquantiles(20)

egen dhi_vt = mean(dhi), by(ccyy vintile)
egen hmc_scaled_vt = mean(hmc_scaled), by(ccyy vintile)
egen hmc_pred_scaled_vt = mean(hmc_pred_scaled), by(ccyy vintile)
egen hmc_wor_scaled_vt = mean(hmc_wor_scaled), by(ccyy vintile)
egen hmc_wor_pred_scaled_vt = mean(hmc_wor_pred_scaled), by(ccyy vintile)

replace dhi = dhi_vt
replace hmc_scaled = hmc_scaled_vt
replace hmc_pred_scaled = hmc_pred_scaled_vt
replace hmc_wor_scaled = hmc_wor_scaled_vt
replace hmc_wor_pred_scaled = hmc_wor_pred_scaled_vt
//


egen quintile = xtile(quantile), by(ccyy) nquantiles(5)
local rategap = 0.005
   
foreach def in carey euro ours { 
	gen itrc_`def'_V3 = itrc_`def'_wor + `rategap' * (quintile-3)
}

local _pred
forvalues i = 1(1)2 {
	gen global_prop`_pred' = hmc`_pred'_scaled/dhi
	gen global_prop_wor`_pred' = hmc_wor`_pred'_scaled/dhi
		foreach def in carey euro ours {
			gen tax_eff_`def'`_pred'_V1 = itrc_`def' * hmc`_pred'_scaled
			gen inc_5_`def'`_pred'_V1 = dhi - tax_eff_`def'`_pred'_V1
			gen global_rate_`def'`_pred'_V1 = tax_eff_`def'`_pred'_V1/dhi
			
			gen tax_eff_`def'`_pred'_V2 = itrc_`def'_wor * hmc_wor`_pred'_scaled
			gen inc_5_`def'`_pred'_V2 = dhi - tax_eff_`def'`_pred'_V2
			gen global_rate_`def'`_pred'_V2 = tax_eff_`def'`_pred'_V2/dhi
			
			gen tax_eff_`def'`_pred'_V3 = itrc_`def'_V3 * hmc_wor`_pred'_scaled
			gen inc_5_`def'`_pred'_V3 = dhi - tax_eff_`def'`_pred'_V3
			gen global_rate_`def'`_pred'_V3 = tax_eff_`def'`_pred'_V3/dhi
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

save "./DTA/`filename'_differents_taux.dta", replace
