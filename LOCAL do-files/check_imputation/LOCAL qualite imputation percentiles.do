// GRAPHS

keep if year == max_year_obs & model2_ccyy & rich_ccyy

// error by percentile

twoway (connected relerror_d decile) || (line relerror_m decile, lpattern(dash)) ///
	, by(ccyy_f)
twoway (connected relerror_scaled_d decile) || (line relerror_scaled_m decile, lpattern(dash)) ///
	, by(ccyy_f)
	
graph export images/deciles_impute_obs.eps, as(eps) preview (off) replace

// absolute error
twoway (connected error_d decile) || (line error_m decile, lpattern(dash)), by(ccyy_f)


twoway (line hmc_medianized_predict_d hmc_medianized_d decile) || ///
	(bar error_d decile), by(ccyy_f, legend(position(3))) ///
	legend(order(1 "Predict" 2 "Observed" 3 "Difference") cols(1))

twoway (line hmc_pred_scaled_d hmc_scaled_d decile) || ///
	(bar error_scaled_d decile), by(ccyy_f, rescale legend(position(3))) ///
	legend(order(1 "Predict" 2 "Observed" 3 "Difference") cols(1))


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

graph dot (first) T10_B50_inc_5_ours T10_B50_inc_5_ours_pred T10_B50_dhi, ///
	over(ccyy_f, sort(T10_B50_inc_5_ours)) ///
	marker(1, msize(small) msymbol(T)) marker(2, msize(small) msymbol(T)) ///
	legend(title(T10/B50 ratios) cols(1) order(3 "Disposable Income" ///
	1 "Inc5 (observed consumption data)" ///
	2 "Inc5 (imputed consumption data)"))
	

graph dot (last) T10_B50_inc_5_ours T10_B50_inc_5_ours_pred T10_B50_dhi ///
	if !mi(hmc_medianized_q) & !mi(diff) & T10_B50_dhi < 1.5, ///
	over(cname, sort(T10_B50_inc_5_ours)) ///
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

graph hbar (first) diff diff_pred ///
	if !mi(hmc_medianized_q) & year == max_year_obs & diff < 0.5, ///
	over(ccyy_f, sort(diff)) ///
	legend(title("Effect of cons taxes on T10/B50") cols(1) ///
	order(1 "Observed consumption data" 2 "Imputed consumption data"))
