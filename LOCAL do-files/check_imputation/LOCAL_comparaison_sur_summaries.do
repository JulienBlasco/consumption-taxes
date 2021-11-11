cd "G:"
use "G:\DTA\2021_10_29_summaries_mod10.dta", clear

merge m:1 ccyy using ".\DTA\LOCAL_datasets\jblasc\18-09-09 availability matrix.dta", ///
	keep(master match) nogenerate

egen max_year_obs = max(year) if !mi(kak), by(cname)

keep if !mi(kak) & model2_ccyy & rich_ccyy //& year == max_year_obs

gen error_prog = 100*(kak_pred/kak-1)
gen error_effect = 100*(G_diff_ours_pred/G_diff_ours-1)

graph dot (asis) error_prog, over(ccyy_f, sort(error_prog))
graph dot (asis) error_effect, over(ccyy_f, sort(error_effect))

twoway (scatter G_diff_ours kak, mlabel(ccyy)) || ///
	(scatter G_diff_ours_pred kak_pred, mlabel(ccyy))

graph dot kak, over(ccyy_f, sort(kak))

graph dot (asis)  Gini_ours Gini_ours_pred  gini_inc4, ///
	over(ccyy_f, sort(Gini_ours)) ///
	marker(1, msize(small) msymbol(T)) marker(2, msize(small) msymbol(T)) ///
	legend(title(Gini coefficients) cols(1) order(3 "Disposable Income" ///
	1 "Inc5 (observed consumption data)" ///
	2 "Inc5 (imputed consumption data)"))
