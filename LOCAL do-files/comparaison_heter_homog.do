cd "G:"

// FRANCE
use ".\DTA\20_11_2022_mod2_qu100_ccyypapier.dta", clear
merge 1:1 using ".\DTA\
keep if ccyy =="fr10"

twoway scatter hmc_wor_scaled_q hmc_wor_q dhi_q
