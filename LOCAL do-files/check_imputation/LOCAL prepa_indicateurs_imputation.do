/* CHANGE DIRECTORY */
cd "G:"

/*
use "DTA\2018_11_19 cross-validation qu100.dta", clear
rename quantile dhi_quantiles
rename (dhi hmc hmc_medianized_predict hmc_pred_scaled hmc_scaled hmc_wor ///
	hmc_wor_pred_scaled hmc_wor_scaled inc_5* tax_eff* hmchous) =_q
*/

use ".\DTA\2020_09_21 qu100 mod10 1s4", clear
append using ".\DTA\2020_09_21 qu100 mod10 2s4.dta"
append using ".\DTA\2020_09_21 qu100 mod10 3s4.dta"
append using ".\DTA\2020_09_21 qu100 mod10 4s4.dta"
	
merge m:1 ccyy using ".\DTA\LOCAL_datasets\jblasc\18-09-09 availability matrix.dta", ///
	keep(master match) nogenerate

cd "N:/Réponse"
	
sort cname year dhi_quantiles
drop if substr(ccyy, 1, 2) == "cn"

egen hmc_mediane = median(hmc_q), by(ccyy)
gen hmc_medianized_q = hmc_q/hmc_mediane

gen decile = ceil(dhi_quantiles/10)

foreach var in dhi hmc_medianized hmc_medianized_predict hmc_pred_scaled hmc_scaled ///
	inc_5_ours inc_5_ours_pred {
	egen `var'_d = mean(`var'_q), by(ccyy decile)
	egen `var'_m = mean(`var'_q), by(ccyy)
	
	egen T10_`var'_prov = sum(`var'_q) if dhi_quantiles >= 91, by(ccyy)
	egen T10_`var' = min(T10_`var'_prov), by(ccyy)
	egen B50_`var'_prov = sum(`var'_d) if dhi_quantiles <= 50, by(ccyy)
	egen B50_`var' = min(B50_`var'_prov), by(ccyy)
	drop T10_`var'_prov B50_`var'_prov
	gen T10_B50_`var' = T10_`var'/B50_`var'
}

gen prog1050 = (T10_hmc_medianized/T10_dhi)/(B50_hmc_medianized/B50_dhi)-1
gen prog1050_predict = (T10_hmc_medianized_predict/T10_dhi) ///
	/(B50_hmc_medianized_predict/B50_dhi)-1

foreach n in q d m {
	gen relerror_`n' = 100*(hmc_medianized_predict_`n'/hmc_medianized_`n'-1)
	gen error_`n' = hmc_medianized_predict_`n'-hmc_medianized_`n'
	gen relerror_scaled_`n' = 100*(hmc_pred_scaled_`n'/hmc_scaled_`n'-1)
	gen error_scaled_`n' = hmc_pred_scaled_`n'-hmc_scaled_`n'
}


gen error_prog = 100*(prog1050_predict/prog1050-1)

gen diff_pred = T10_B50_inc_5_ours_pred - T10_B50_dhi
gen diff = T10_B50_inc_5_ours- T10_B50_dhi

egen max_year_obs = max(year) if !mi(inc_5_ours_q), by(cname)
