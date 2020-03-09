/* CHANGE DIRECTORY */
cd "E:"

use "\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\18-11-19 cross-validation qu100.dta", clear

append using "\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\18-09-29 qu100 V5 mod2 za12.dta"

sort ccyy quantile


*saut du a dhipov
twoway scatter  global_prop_pred quantile if ccyy=="fr10"
twoway line  hmc_pred_scaled dhi_med if year==2010&!mi(global_prop_pred ), by(cname, rescale)

*peu de correlation en dessous du C5
twoway (scatter hmc quantile || lfit hmc quantile ) if quantile <6&!mi(hmc), by(ccyy, yrescale)

*resultat similaire en prenant la grande pauvrete, mais grande heterogeneite
twoway (scatter hmc quantile || lfit hmc quantile ) if quantile <6&!mi(hmc), by(ccyy, yrescale)

*plot propensities
twoway (line global_prop_pred  quantile) || (scatter global_prop quantile, msize(small)) if !mi(global_prop_wor_pred  )&year==2010&inlist(cname,"France", "Germany", "Spain", "Poland")&global_prop_pred <2, by(cname)

gen log_dhi = log(dhi)
twoway (line hmc_pred_scaled  log_dhi) || (scatter hmc_scaled log_dhi, msize(vsmall)) if !mi(global_prop  )&the_year_obs&global_prop_pred <2&global_prop <2&!inlist(cname,"South Africa"), by(ccyy_f, rescale)


* compare actual and estimated propensities
twoway (line global_prop_pred  quantile) || (scatter global_prop quantile, msize(vsmall)) if !mi(global_prop  )&global_prop_pred <2&global_prop<2, by(ccyy_f, rescale) 


* effort rate
keep if the_year
keep ccyy quantile global_rate_ours_pred

twoway scatter global_rate_ours_pred quantile if global_rate_ours_pred<0.5&the_year&year>2008 , ylabel(#5) msize(small) by(ccyy_f )
	
twoway (line global_rate_ours_predau10 quantile if global_rate_ours_predau10<0.4) ///
(line global_rate_ours_predde13 quantile if global_rate_ours_predde13<0.4) ///
(line global_rate_ours_preddk04 quantile if global_rate_ours_preddk04<0.4) ///
(line global_rate_ours_predfr10 quantile if global_rate_ours_predfr10<0.4) ///
(line global_rate_ours_preduk13 quantile if global_rate_ours_preduk13<0.4) ///
(line global_rate_ours_predus13 quantile if global_rate_ours_predus13<0.4)

* impact of rents
twoway line global_prop_pred global_prop global_prop_wor_pred quantile if ccyy=="fr10"
twoway line global_prop global_prop_wor quantile if ccyy=="fr10"
twoway line global_prop global_prop_wor quantile if ccyy=="fr10"&global_prop<2

gen vingt = ceil(quantile/5)
egen global_prop_vingt = mean(global_prop), by(ccyy vingt)
egen global_prop_wor_vingt = mean(global_prop_wor), by(ccyy vingt)
twoway line global_prop_vingt global_prop_wor_vingt vingt if ccyy=="fr10"

gen dec = ceil(quantile/10)
egen global_prop_dec = mean(global_prop), by(ccyy dec)
egen global_prop_wor_dec = mean(global_prop_wor), by(ccyy dec)
twoway line global_prop_dec global_prop_wor_dec dec if ccyy=="fr10"

preserve
* graphe effort rate US DK FR DE
keep if inlist(cname,"France", "United States", "Germany", "Denmark") & the_year
keep global_rate_ours_pred ccyy  quantile
reshape wide global_rate_ours_pred , i(quantile) j(ccyy ) string

twoway (line global_rate_ours_predde13 quantile if global_rate_ours_predde13<0.4) ///
(line global_rate_ours_predfr10 quantile if global_rate_ours_predfr10<0.4) ///
(line global_rate_ours_predus13 quantile if global_rate_ours_predus13<0.4) ///
(line global_rate_ours_preddk04 quantile if global_rate_ours_preddk04<0.4)
restore

* compare actual and estimated propensities
twoway (line global_prop_pred  quantile) || ///
	(scatter global_prop quantile, msize(vsmall)) ///
	if !mi(global_prop  )&global_prop_pred <2&global_prop<2, by(ccyy_f) 

* compare actual and estimated propensities
twoway (line global_rate_ours_pred  quantile) || ///
	(scatter global_rate_ours quantile, msize(vsmall)) ///
	if !mi(global_prop  )&global_rate_ours_pred <0.4&global_rate_ours<0.4, by(ccyy_f) 

* compare actual and estimated propensities for South Africa 2012
twoway (line global_rate_ours_pred  quantile) || ///
	(scatter global_rate_ours quantile, msize(vsmall)) ///
	if ccyy=="za12"&global_rate_ours_pred <0.4&global_rate_ours<0.4, by(ccyy_f) 
