use "G:\DTA\2021_11_22_par_age_mod2.dta", clear
cd "N:/Réponse"

capture drop year_temp
egen year_temp = max(year) if !mi(hmc_scaled_a) & !mi(hmc_pred_scaled_a), by(cname)

egen tot_hmc_medianized_predict = total(hmc_medianized_predict_a), by(ccyy)
egen tot_hmc = total(hmc_a), by(ccyy)
gen hmc_age = hmc_a/tot_hmc
gen hmc_pred_age = hmc_medianized_predict_a/tot_hmc_medianized_predict
graph bar (first) hmc_age hmc_pred_age if L_obs, ///
	by(ccyy_f rich_ccyy, rescale) over(agecat) ///
	legend(order(1 "Observed consumption" 2 "Imputed consumption"))
graph export images/observed_imputed_age.eps, as(eps) preview(off) replace

* comparaison avec l'ancien modèle ;
use "G:\DTA\2020_09_21_par_age_mod2.dta", clear

capture drop year_temp
egen year_temp = max(year) if !mi(hmc_scaled_a) & !mi(hmc_pred_scaled_a), by(cname)

egen tot_hmc_medianized_predict = total(hmc_medianized_predict_a), by(ccyy)
egen tot_hmc = total(hmc_a), by(ccyy)
gen hmc_age = hmc_a/tot_hmc
gen hmc_pred_age = hmc_medianized_predict_a/tot_hmc_medianized_predict
graph bar (first) hmc_age hmc_pred_age if L_obs, ///
	by(ccyy_f rich_ccyy, rescale) over(agecat) ///
	legend(order(1 "Observed consumption" 2 "Imputed consumption"))

