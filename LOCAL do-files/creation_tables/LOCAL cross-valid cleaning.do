/* CHANGE DIRECTORY */
cd "G:"

set varabbrev off, permanent

// choose file
local filename "20_11_2022_mod2_qu100_crossvalid_ccyypap"
local mod "mod2"
//

import delimited "./CSV/`filename'.csv", clear delimiter(space, collapse)
drop v1 v12

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
merge m:1 ccyy using ".\DTA\20_11_2022 `mod' summaries.dta", ///
			keepusing(mean_hmc_scaled mean_hmc_wor_scaled mean_hmc_pred_scaled)
drop if _merge == 2
drop _merge
			
// change order of variables
order ccyy cname year, first

egen hmc_mmean 			= mean(hmc_q), by(ccyy)
egen hmc_med_pred_mmean = mean(hmc_medianized_predict_q), by(ccyy)
gen hmc_wor_q 			= hmc_q - hmchous_q
egen hmc_wor_mmean		= mean(hmc_wor_q), by(ccyy)

gen hmc_scaled_q 		= hmc_q * mean_hmc_scaled/hmc_mmean
gen hmc_wor_scaled_q 	= hmc_wor_q * mean_hmc_wor_scaled/hmc_wor_mmean
gen hmc_pred_scaled_q = hmc_medianized_predict_q * mean_hmc_pred_scaled/hmc_med_pred_mmean

local _pred
forvalues i = 1(1)2 {
	local _wor
	forvalues j = 1(1)2 {
	gen global_prop`_wor'`_pred'_q = hmc`_wor'`_pred'_scaled_q/dhi_q
		foreach def in carey euro ours {
			gen tax_eff_`def'`_wor'`_pred'_q = itrc_`def'`_wor' * hmc`_wor'`_pred'_scaled_q
			gen inc_5_`def'`_wor'`_pred'_q = dhi_q - tax_eff_`def'`_wor'`_pred'_q
			gen global_rate_`def'`_wor'`_pred'_q = tax_eff_`def'`_wor'`_pred'_q/dhi_q
		}
		local _wor _wor
	}
	local _pred _pred
}


tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

save "./DTA/`filename'.dta", replace

