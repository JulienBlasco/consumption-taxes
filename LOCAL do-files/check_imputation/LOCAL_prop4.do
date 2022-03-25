cd "G:/"

use "G:\DTA\2021_11_22_qu100_mod2wprop4_1s4.dta", clear
append using "G:\DTA\2021_11_22_qu100_mod2wprop4_2s4.dta"
append using "G:\DTA\2021_11_22_qu100_mod2wprop4_3s4.dta"
append using "G:\DTA\2021_11_22_qu100_mod2wprop4_4s4.dta"

egen max_year = max(year) if !mi(hmc_pred_scaled_q), by(cname)

twoway scatter prop4_pred_scaled_q dhi_quantiles if year == max_year & dhi_quantiles <= 10, by(ccyy_f, ///
	title(Proportion of propensity to consume > 4 by percentile for percentiles P1-P10) ///
	subtitle("Imputed and scaled data, last year available"))
