use ".\DTA\2021_11_22_par_age_mod2.dta", clear
keep ccyy ccyy_f rich_ccyy hmc_a hmc_medianized_predict_a L_obs agecat
rename (hmc_a hmc_medianized_predict_a) (hmc_a1 hmc_medianized_predict_a1)

merge 1:1 ccyy agecat using ".\DTA\2020_09_21_par_age_mod2.dta", ///
 keepusing(hmc_a hmc_medianized_predict_a)
 
egen tot_hmc_medianized_predict = total(hmc_medianized_predict_a), by(ccyy)
egen tot_hmc_medianized_predict1 = total(hmc_medianized_predict_a1), by(ccyy)
egen tot_hmc = total(hmc_a), by(ccyy)
gen hmc_age = hmc_a/tot_hmc
gen hmc_pred_age = hmc_medianized_predict_a/tot_hmc_medianized_predict
gen hmc_pred_age1 = hmc_medianized_predict_a1/tot_hmc_medianized_predict1
graph bar (first) hmc_age hmc_pred_age hmc_pred_age1 if L_obs, ///
	by(ccyy_f rich_ccyy, rescale) over(agecat) ///
	legend(order(1 "Observed consumption" 2 "Imputed consumption (old model)" ///
	3 "Imputed consumption (new model)"))

gen diff_new = (hmc_pred_age1 - hmc_age)^2
gen diff_old = (hmc_pred_age - hmc_age)^2

twoway line diff_old diff_new agecat if L_obs, by(ccyy_f rich_ccyy)
graph bar (first) diff_old diff_new if L_obs, ///
	by(ccyy_f rich_ccyy) over(agecat) ///
	legend(order(1 "Imputed consumption (old model)" ///
	2 "Imputed consumption (new model)"))
	
egen error_new = total(diff_new), by(ccyy)
egen error_old = total(diff_old), by(ccyy)

graph dot (first) error_old error_new if L_obs, ///
	over(ccyy_f, sort(error_old)) ///
	legend(order(1 "Imputed consumption (old model)" ///
	2 "Imputed consumption (new model)"))