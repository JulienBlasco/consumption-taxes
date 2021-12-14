clear
set obs 10000
gen log_dhi = rnormal()
gen dhi = exp(log_dhi)
gen error = 2*rnormal()
gen hmc = dhi^0.5 + error
gen w = 1.2 if _n <= 5000
replace w = 2 if _n >= 5000
sort dhi

glm hmc log_dhi [aw=w], link(log) 
gen hmc_pred_var = `e(deviance)'/`e(N)'

predict hmc_pred
predict hmc_pred_stdp, stdp
gen hmc_pred_noise = hmc_pred + (hmc_pred_var)^(1/2)*rnormal()

gen residual = hmc_pred - hmc
gen residual2 = residual^2


//

twoway scatter hmc dhi || line hmc_pred dhi, xscale(log)
twoway scatter hmc_pred_noise dhi || line hmc_pred dhi, xscale(log)
twoway line hmc_pred dhi

twoway scatter residual log_dhi

twoway scatter hmc_pred hmc
twoway scatter hmc_pred_noise hmc

twoway line hmc_pred_stdp log_dhi
twoway line hmc_pred_var log_dhi

/*
gen sigma = 1/(.4870066*log_dhi)
gen error_variance = exp(sigma^2-1)*exp(2+sigma^2)

twoway scatter hmc_pred_var error_variance
*/