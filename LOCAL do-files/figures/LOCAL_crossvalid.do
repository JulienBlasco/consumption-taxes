cd "G:"

set scheme plotplaincolor

use "./DTA/crossvalid au10 ee00 fr10 mx12 pl13 si12 ch04 mod2 qu100.dta", clear
keep ccyy_f global_prop_q global_prop_wor_q global_prop_pred_q global_prop_wor_pred_q dhi_quantiles
merge 1:1 ccyy_f dhi_quantiles using "DTA/20_11_2022_crossvalid uk95 it10 mod1 qu100", ///
	keepusing(ccyy_f dhi_quantiles global_prop_q global_prop_pred_q) update

sort ccyy_f dhi_quantiles

gen prop = global_prop_wor_q
gen prop_pred = global_prop_wor_pred_q
replace prop = global_prop_q if mi(global_prop_wor_q) | mi(global_prop_wor_pred_q)
replace prop_pred = global_prop_pred_q if mi(global_prop_wor_q) | mi(global_prop_wor_pred_q)
replace ccyy_f = ccyy_f + "*" if mi(global_prop_wor_q) | mi(global_prop_wor_pred_q)

label variable prop "Observed consumption"
label variable prop_pred "Imputed consumption"

twoway (line prop_pred dhi_quantiles,  lpattern(solid)) ///
	(scatter prop dhi_quantiles, msize(tiny) msymbol(circle)) ///
	if prop <= 2 & prop_pred <= 2,  yscale(range(0 2)) ///
	by(ccyy_f, legend(position(3)) note("")) ///
	xtitle(Income percentile)
	
graph export "N:/images/23-02_cross-validation.eps", as(eps) preview(on) replace
