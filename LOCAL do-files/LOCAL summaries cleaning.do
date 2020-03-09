* updated 31/08/2018 to change paths
* updated 29/10/2018 to add indicators
* updated 01/02/2019 to add gini_dhi_scope_hmc

/* CHANGE DIRECTORY */
cd "D:"
cd "/BLASCOLIEPP\Code\19-08-21 Datasets V6\"

// choose file
local filename "02_08_2019_V6 mod2 summaries"

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

// rename variables


// change order of variables
order ccyy cname year, first

local _pred
forvalues i = 1(1)2 {
	local _wor
	forvalues j = 1(1)2 {
		foreach def in carey euro ours {
			gen tax_eff_`def'`_wor'`_pred'_mean = itrc_`def'`_wor' * hmc`_wor'`_pred'_scaled_mean
			gen inc_5_`def'`_wor'`_pred'_mean = dhi_mean - tax_eff_`def'`_wor'`_pred'_mean
		}
		local _wor _wor
	}
	local _pred _pred
}

local _wor
forvalues j = 1(1)2 {
	foreach def in /* carey euro */ ours {
		gen G_diff_`def'`_wor' = inc_5_`def'`_wor'_conc_inc_5 - gini_dhi_scope_hmc
		gen RS_`def'`_wor' = inc_5_`def'`_wor'_conc_dhi - gini_dhi_scope_hmc
	}
	gen kak`_wor' = hmc`_wor'_conc_dhi - gini_dhi_scope_hmc
	local _wor _wor
}

local _wor
forvalues j = 1(1)2 {
	foreach def in /* carey euro */ ours {
		gen G_diff_`def'`_wor'_pred = inc_5_`def'`_wor'_pred_conc_inc_5 - dhi_conc_dhi
		gen RS_`def'`_wor'`_pred' = inc_5_`def'`_wor'_pred_conc_dhi - dhi_conc_dhi
	}
	local _wor _wor
}


gen kak_pred 	= hmc_medianized_predict_conc_dhi - dhi_conc_dhi
gen kak_wor_pred = hmc_wor_pred_conc_dhi - dhi_conc_dhi

// drop intermediary variables
capture drop prop_scaled_mean prop_wor_scaled_mean ///
tax_eff_carey_conc_dhi tax_eff_euro_conc_dhi tax_eff_ours_conc_dhi ///
tax_eff_carey_wor_conc_dhi tax_eff_euro_wor_conc_dhi tax_eff_ours_wor_conc_dhi ///
hmc_wor_pred_scaled_mean hmc_pred_scaled_mean prop_pred_scaled_mean ///
prop_wor_pred_scaled_mean tax_eff_carey_pred_conc_dhi tax_eff_euro_pred_conc_dhi ///
tax_eff_ours_pred_conc_dhi tax_eff_carey_wor_pred_conc_dhi ///
tax_eff_euro_wor_pred_conc_dhi tax_eff_ours_wor_pred_conc_dhi

// rename Gini indices
rename dhi_conc_dhi Gini_pre
local _pred
forvalues i = 1(1)2 {
	local _wor
	forvalues j = 1(1)2 {
		foreach def in /* carey euro */ ours {
			rename inc_5_`def'`_wor'`_pred'_conc_i Gini_`def'`_wor'`_pred'
		}
		local _wor _wor
	}
	local _pred _pred
}


// generate apc
gen apc_lis_wor = hmc_wor_scaled_mean/dhi_mean
gen apc_lis = hmc_scaled_mean/dhi_mean

egen last_year_m = max(year)  if !mi(hmc_pred_scaled_mean ), by(cname)
egen last_year = max(last_year_m), by(cname)
drop last_year_m
gen the_year = (year==last_year)

egen last_year_obs_m = max(year)  if !mi(hmc_scaled_mean), by(cname)
egen last_year_obs = max(last_year_obs_m), by(cname)
drop last_year_obs_m
gen the_year_obs = (!mi(last_year_obs) & year==last_year_obs) | (mi(last_year_obs) & year==last_year)

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

save "./DTA/`filename'.dta", replace
