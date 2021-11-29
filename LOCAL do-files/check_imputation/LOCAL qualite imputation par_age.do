use "G:\DTA\2021_10_29_par_age_mod2.dta", clear

capture drop year_temp
egen year_temp = max(year) if !mi(hmc_scaled_a) & !mi(hmc_pred_scaled_a), by(cname)

graph bar (asis) hmc_scaled_a hmc_pred_scaled_a if year==year_temp, over(agecat) by(ccyy_f)
