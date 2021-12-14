use "G:\DTA\2021_11_22_par_age_mod2.dta", clear
cd "N:/Réponse"

egen tot_hmc_medianized_predict = total(hmc_medianized_predict_a), by(ccyy)
egen tot_hmc = total(hmc_a), by(ccyy)
gen hmc_age = hmc_a/tot_hmc
gen hmc_pred_age = hmc_medianized_predict_a/tot_hmc_medianized_predict
graph bar (first) hmc_age hmc_pred_age if L_obs, ///
	by(ccyy_f rich_ccyy, rescale) over(agecat) ///
	legend(order(1 "Observed consumption" 2 "Imputed consumption"))
graph export images/observed_imputed_age.eps, as(eps) preview(off) replace

gen relerror = hmc_pred_age/hmc_age
sum relerror if L_obs, de

preserve
keep ccyy_f relerror agecat
reshape wide relerror, i(ccyy_f) j(agecat)
list