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
egen max_year_obs = max(year) if !mi(hmc_q), by(cname)

gen decile = ceil(dhi_quantiles/10)

foreach var in dhi hmc_medianized hmc_medianized_predict inc_5_ours inc_5_ours_pred {
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
}

gen error_prog = 100*(prog1050_predict/prog1050-1)

gen diff_pred = T10_B50_inc_5_ours_pred - T10_B50_dhi
gen diff = T10_B50_inc_5_ours- T10_B50_dhi

// error by percentile

twoway (connected relerror_d decile) || (line relerror_m decile, lpattern(dash)) ///
	if !mi(hmc_medianized_q) & year == max_year_obs, by(ccyy_f)
graph export images/deciles_impute_obs.eps, as(eps) preview (off) replace

twoway line hmc_medianized_predict_d hmc_medianized_d decile ///
	if !mi(hmc_medianized_q) & model2_ccyy & rich_ccyy  & year == max_year_obs, by(ccyy_f)

twoway line hmc_medianized_predict_d hmc_medianized_d decile ///
	if !mi(hmc_medianized_q) & model2_ccyy & rich_ccyy  & cname=="Slovenia", by(ccyy_f)


	
table cname model2_ccyy rich_ccyy if !mi(relerror_d)
summar relerror_q if !mi(relerror_d), de
summar relerror_d if !mi(relerror_d) & model2_ccyy & !rich_ccyy, de

preserve
keep if !mi(hmc_medianized_q) & year == max_year_obs
keep ccyy_f decile hmc_medianized_predict_d hmc_medianized_d relerror_d relerror_m
duplicates drop
reshape wide hmc_medianized_predict_d hmc_medianized_d relerror_d, ///
	i(ccyy_f) j(decile)
mkmat relerror_d* relerror_m, ///
	matrix(deciles_impute_obs) rownames(ccyy_f) nchar(25)
frmttable using tables/deciles_impute_obs_brut.tex, statmat(deciles_impute_obs) ///
	sdec(1) varlabels tex fragment nocenter replace ///
	ctitles("" "D1" "D2" "D3" "D4" "D5" "D6" "D7" "D8" "D9" "D10" "Mean")
filefilter tables/deciles_impute_obs_brut.tex tables/deciles_impute_obs.tex, ///
	from("\BS_") to(" ") replace
restore


// T10 sur B50
sum error_prog if model2_ccyy & rich_ccyy, de
preserve
keep if !mi(error_prog)
duplicates drop ccyy_f error_prog, force
list ccyy_f error_prog if model2_ccyy & rich_ccyy, clean
list ccyy_f error_prog if model2_ccyy & !rich_ccyy, clean
list ccyy_f error_prog if rich_ccyy, clean
list ccyy_f error_prog if !rich_ccyy, clean


graph dot (first) error_prog ///
	if model2_ccyy & rich_ccyy  & year == max_year_obs, ///
	over(ccyy_f, sort(error_prog)) nofill
graph export images/error_prog.eps, as(eps) preview (off) replace
	
graph dot (first) prog1050* ///
	if !mi(hmc_medianized_q) & year == max_year_obs, ///
	over(ccyy_f, sort(prog1050))

graph dot (first) T10_B50_hmc* ///
	if !mi(hmc_medianized_q) & year == max_year_obs, ///
	over(ccyy_f, sort(T10_B50_hmc_medianized))

graph dot (first) T10_B50_inc_5_ours T10_B50_inc_5_ours_pred T10_B50_dhi ///
	if !mi(hmc_medianized_q) & year == max_year_obs & T10_B50_dhi < 1.5, ///
	over(ccyy_f, sort(T10_B50_inc_5_ours)) ///
	marker(1, msize(small) msymbol(T)) marker(2, msize(small) msymbol(T)) ///
	legend(title(T10/B50 ratios) cols(1) order(3 "Disposable Income" ///
	1 "Inc5 (observed consumption data)" ///
	2 "Inc5 (imputed consumption data)"))

graph hbar (first) diff diff_pred ///
	if !mi(hmc_medianized_q) & year == max_year_obs & diff < 0.5, ///
	over(ccyy_f, sort(diff)) ///
	legend(title("Effect of cons taxes on T10/B50") cols(1) ///
	order(1 "Observed consumption data" 2 "Imputed consumption data"))
graph export images/error_T10B50_diff.eps, as(eps) preview(off) replace
