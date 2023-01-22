/* CHANGE DIRECTORY */
cd "G:"

set varabbrev off, permanent

// choose file
local filename "2023-01-21_22_11_2021_mod1_summaries"
import delimited "./CSV/`filename'.csv", clear delimiter(space, collapse)
drop v1 v48

/*
// pour régler le pb du summaries mod2
{
	keep if mean_scope > 0
	rename (gini_inc1   gini_inc2   gini_inc3   gini_inc4   gini_inc_5_ours   ///
	gini_inc_5_ours_pred   gini_inc_5_ours_wor   gini_inc_5_ours_wor_pred   ///
	mean_dhi   mean_hchous   mean_hitp   mean_hmc   mean_hmc_pred_scaled   ///
	mean_hmc_scaled   mean_hmc_wor_pred_scaled   mean_hmc_wor_scaled   ///
	mean_hmchous   mean_inc1   mean_inc2   mean_inc3   mean_inc4   mean_scope v38) ///
	(gini_dhi_scope_hmc gini_inc1   gini_inc2   gini_inc3   gini_inc4   ///
	gini_inc_5_ours   gini_inc_5_ours_pred   gini_inc_5_ours_wor   gini_inc_5_ours_wor_pred   ///
	mean_dhi   mean_hchous   mean_hitp   mean_hmc   mean_hmc_pred_scaled   ///
	mean_hmc_scaled   mean_hmc_wor_pred_scaled   mean_hmc_wor_scaled   mean_hmchous   ///
	mean_inc1   mean_inc2   mean_inc3   mean_inc4   mean_scope)
}
*/

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

// replace 0 with .
ds mean_*
local varlist = r(varlist)
foreach var of local varlist {
	replace `var' = . if `var' == 0
}

// change order of variables
order ccyy cname year, first

local _pred
forvalues i = 1(1)2 {
	local _wor
	forvalues j = 1(1)2 {
		foreach def in  carey euro ours {
			gen tax_eff_`def'`_wor'`_pred'_mean = itrc_`def'`_wor' * mean_hmc`_wor'`_pred'_scaled
			gen inc_5_`def'`_wor'`_pred'_mean = mean_dhi - tax_eff_`def'`_wor'`_pred'_mean
		}
		local _wor _wor
	}
	local _pred _pred
}

local _wor
forvalues j = 1(1)2 {
	foreach def in /* carey euro */ ours {
		gen G_diff_`def'`_wor' = gini_inc_5_`def'`_wor' - gini_dhi_scope_hmc
		gen RS_`def'`_wor' = conc_dhi_inc_5_`def'`_wor' - gini_dhi_scope_hmc
	}
	gen kak`_wor' = conc_dhi_hmc`_wor' - gini_dhi_scope_hmc
	local _wor _wor
}

local _wor
forvalues j = 1(1)2 {
	foreach def in /* carey euro */ ours {
		gen G_diff_`def'`_wor'_pred = gini_inc_5_`def'`_wor'_pred - conc_dhi_dhi
		gen RS_`def'`_wor'_pred =conc_dhi_inc_5_`def'`_wor'_pred - conc_dhi_dhi
	}
	local _wor _wor
}


gen kak_pred 	= conc_dhi_hmc_medianized_predict - conc_dhi_dhi
gen kak_wor_pred = conc_dhi_hmc_wor_pred - conc_dhi_dhi

// drop intermediary variables
capture drop prop_scaled_mean prop_wor_scaled_mean ///
tax_eff_carey_conc_dhi tax_eff_euro_conc_dhi tax_eff_ours_conc_dhi ///
tax_eff_carey_wor_conc_dhi tax_eff_euro_wor_conc_dhi tax_eff_ours_wor_conc_dhi ///
hmc_wor_pred_scaled_mean hmc_pred_scaled_mean prop_pred_scaled_mean ///
prop_wor_pred_scaled_mean tax_eff_carey_pred_conc_dhi tax_eff_euro_pred_conc_dhi ///
tax_eff_ours_pred_conc_dhi tax_eff_carey_wor_pred_conc_dhi ///
tax_eff_euro_wor_pred_conc_dhi tax_eff_ours_wor_pred_conc_dhi

// rename Gini indices

gen Gini_pre = conc_dhi_dhi

local _pred
forvalues i = 1(1)2 {
	local _wor
	forvalues j = 1(1)2 {
		foreach def in /* carey euro */ ours {
			rename gini_inc_5_`def'`_wor'`_pred' Gini_`def'`_wor'`_pred'
		}
		local _wor _wor
	}
	local _pred _pred
}

forvalues i = 1(1)3 {  
	rename gini_inc`i' Gini_inc`i'
}

// generate apc
gen apc_lis_wor = mean_hmc_wor_scaled/mean_dhi
gen apc_lis = mean_hmc_scaled/mean_dhi

egen last_year_m = max(year)  if !mi(mean_hmc_pred_scaled ), by(cname)
egen last_year = max(last_year_m), by(cname)
drop last_year_m
gen the_year = (year==last_year)

egen last_year_obs_m = max(year)  if !mi(mean_hmc_scaled), by(cname)
egen last_year_obs = max(last_year_obs_m), by(cname)
drop last_year_obs_m
gen the_year_obs = (!mi(last_year_obs) & year==last_year_obs) | (mi(last_year_obs) & year==last_year)

// macro global rates should be the same as global rates
gen global_tax_rate_ours_pred = tax_eff_ours_pred_mean / mean_dhi
gen global_tax_rate_ours = tax_eff_ours_mean/mean_dhi
gen macro_global_tax_rate_ours_pred = oecd_prop * itrc_ours
gen macro_global_tax_rate_ours = oecd_prop * itrc_ours

tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

save "./DTA/`filename'.dta", replace
