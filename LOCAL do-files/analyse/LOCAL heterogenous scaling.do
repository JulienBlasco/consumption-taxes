/* CHANGE DIRECTORY */
cd "G:"
set varabbrev off, permanent

import delimited "./CSV/2022_09_22_qu10_mod10_fr10.csv", clear delimiter(space, collapse)
drop v1 v14
rename (hmc_q hmc_scaled_unif_q) (scaled_heter scaled_unif)
save ".\DTA\2022_09_22_qu10_mod10_fr10.dta", replace

import delimited "./CSV/2021_11_22_qu10_mod10_us10.csv", clear delimiter(space, collapse)
drop v1 
rename (hmc_pred_heter_scaled_q hmc_pred_scaled_q) (scaled_heter scaled_unif)
save ".\DTA\2022_09_22_qu10_mod10_us10.dta", replace

use ".\DTA\2022_09_22_qu10_mod10_fr10", clear
append using ".\DTA\2022_09_22_qu10_mod10_us10"

set scheme plotplaincolor

label variable hmc_unscaled_q "Unscaled (micro data)"
label variable scaled_unif "Uniform scaling (present paper)"
label variable scaled_heter "Heterogenous scaling"
label variable dhi_q "Equivalized disposable income in euros (left) and dollars (right)"
label variable dhi_quantiles "Decile of equivalized disposable income"

gen ccyy_f = "France 2010 (observed consumption data)"  if ccyy == "fr10"
replace ccyy_f = "United States 2010 (imputed consumption data)"  if ccyy == "us10"

label define deciles 1 "Decile: 1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10"
label values dhi_quantiles deciles

gen zero = 1000 if ccyy == "fr10"
replace zero = 1500 if ccyy == "us10"

twoway (connected hmc_unscaled_q scaled_unif scaled_heter dhi_q) || ///
	(scatter zero dhi_q, mlabel(dhi_quantiles) msymbol(none) mlabposition(9) mlabcolor(black) mlabgap(-2)),  by(ccyy_f, rescale note("")) ///
	legend(order(1 2 3) rows(1) position(5) ring(0) title(Consumption data, size(medium) position(11))) ///
	 xtitle(, size(small))

graph export "N:\images\2022-10_heterogenous_deciles.eps", as(eps) preview(on) replace