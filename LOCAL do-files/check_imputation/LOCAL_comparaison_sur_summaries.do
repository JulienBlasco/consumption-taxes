cd "G:"
use "G:\DTA\2021_10_29_summaries_mod2.dta", clear

// préparation des données

merge m:1 ccyy using ".\DTA\LOCAL_datasets\jblasc\18-09-09 availability matrix.dta", ///
	keep(master match) nogenerate

gen obs = !mi(kak) & model2_ccyy
gen obs_inc5 = !mi(inc_5_ours_mean)
gen obs_R = obs & rich_ccyy
gen obs_inc5_R = obs_inc5 & rich_ccyy

foreach indic in obs obs_inc5 obs_R obs_inc5_R {
	egen M_`indic' = max(year) if `indic', by(cname)
	gen L_`indic' = year == M_`indic'
}

gen error_prog = 100*(kak_pred/kak-1)
gen error_effect = 100*(G_diff_ours_pred/G_diff_ours-1)

keep if obs

cd "E:\Notes\2021-03 Resubmit JPubEc\Réponse"
// graphes

graph dot (asis) error_prog, over(ccyy_f, sort(error_prog))
graph dot (asis) error_prog if L_obs, over(ccyy_f, sort(error_prog))
graph dot (asis) error_effect if L_obs_inc5_R, over(ccyy_f, sort(error_effect))

twoway (scatter G_diff_ours kak, mlabel(ccyy)) || ///
	(scatter G_diff_ours_pred kak_pred, mlabel(ccyy)), ///
	ytitle("Effet antiredistributif (points de Gini)") ///
	xtitle("Régressivité (kakwani)") ///
	legend(order(1 "Observé" 2 "Imputé"))

graph dot kak, over(ccyy_f, sort(kak))

graph dot (asis)  Gini_ours Gini_ours_pred  Gini_pre if L_obs_inc5, ///
	over(rich_ccyy, relabel(1 "*" 2 " ")) over(ccyy_f, sort(Gini_ours)) nofill ///
	marker(1, msize(small) msymbol(T)) marker(2, msize(small) msymbol(T)) ///
	legend(title(Gini coefficients) cols(1) order(3 "Disposable Income" ///
	1 "Inc5 (observed consumption data)" 2 "Inc5 (imputed consumption data)")) ///
	note("* High inequality countries not used in the calibration of the model")
graph export images/gini_obs_imp.eps, as(eps) preview (off) replace
	
preserve
sort Gini_ours
mkmat rich_ccyy Gini_pre Gini_ours Gini_ours_pred if L_obs_inc5, ///
	matrix(gini_obs_imp) rownames(ccyy_f) nchar(25)
frmttable using tables/gini_obs_imp_brut.tex, statmat(gini_obs_imp) ///
	sdec(3) varlabels tex fragment nocenter replace
filefilter tables/gini_obs_imp_brut.tex tables/gini_obs_imp.tex, ///
	from("\BS_") to(" ") replace
restore
