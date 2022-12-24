cd "G:"

/*
foreach filename in 20_11_2022_mod1_qu10_us10  ///
	20_11_2022_mod2_qu10_fr10 20_11_2022_heter_mod2_qu10_fr10 ///
	20_11_2022_heter_mod1_qu10_us10 {
		
		import delimited "./CSV/`filename'.csv", clear delimiter(space, collapse)
		save "./DTA/`filename'"
}

*/

use "DTA/20_11_2022_mod1_qu10_us10", clear
append using "DTA/20_11_2022_mod2_qu10_fr10"
keep ccyy dhi_quantiles hmc_q hmc_scaled_q hmc_pred_scaled_q
rename (hmc_scaled_q hmc_pred_scaled_q) =_homog

merge 1:1 ccyy dhi_quantiles using "DTA/20_11_2022_heter_mod1_qu10_us10", ///
	keepusing(hmc_pred_scaled_q) nogen
merge 1:1 ccyy dhi_quantiles using "DTA/20_11_2022_heter_mod2_qu10_fr10", ///
	keepusing(hmc_scaled_q) nogen
rename (hmc_scaled_q hmc_pred_scaled_q) =_heter

twoway connected hmc* dhi_quantiles, by(ccyy)

gen diff_homog = hmc_scaled_q_homog - hmc_q
gen diff_heter = hmc_scaled_q_heter - hmc_q

graph bar (asis) diff_homog diff_heter if ccyy=="fr10", over(dhi_quantiles)

bys ccyy: sum diff_homog diff_heter

egen diff_heter_total = total(diff_heter), by(ccyy)
gen diff_heter_T10 = diff_heter/diff_heter_total if dhi_quantiles == 10
egen diff_heter_B50 = total(diff_heter) if dhi_quantiles <= 5, by(ccyy)
replace diff_heter_B50 = diff_heter_B50/diff_heter_total

egen diff_homog_total = total(diff_homog), by(ccyy)
gen diff_homog_T10 = diff_homog/diff_homog_total if dhi_quantiles == 10
egen diff_homog_B50 = total(diff_homog) if dhi_quantiles <= 5, by(ccyy)
replace diff_homog_B50 = diff_homog_B50/diff_homog_total

keep if ccyy=="fr10"

replace diff_heter_T10 = diff_heter_T10[_N] if mi(diff_heter_T10)
replace diff_homog_T10 = diff_homog_T10[_N] if mi(diff_homog_T10)

list diff_heter_T10 diff_heter_B50 diff_homog_T10 diff_homog_B50 if _n==1, noobs ab(20)


