// percentiles

gen er_int = round(error_prog)
twoway (connected relerror_d decile) || (line relerror_m decile, lpattern(dash)) ///
	if L_obs & cname != "Peru" & cname != "South Africa", by(ccyy_f er_int)
	
egen tot_hmc_medianized_predict = total(hmc_medianized_predict_d), by(ccyy)
egen tot_hmc = total(hmc_medianized_d), by(ccyy)
gen hmc_d = hmc_medianized_d/tot_hmc
gen hmc_pred_d = hmc_medianized_predict_d/tot_hmc_medianized_predict
graph bar (first) hmc_d hmc_pred_d if L_obs, ///
	by(ccyy_f rich_ccyy, rescale) over(decile) ///
	legend(order(1 "Observed consumption" 2 "Imputed consumption"))

graph dot (first) error_prog ///
	if L_obs, ///
	over(ccyy_f, sort(error_prog)) nofill
	
// summaries	

twoway (scatter G_diff_ours RS_ours, mlabel(ccyy)) || ///
	(scatter G_diff_ours_pred RS_ours_pred, mlabel(ccyy)), ///
	ytitle("Effet antiredistributif (points de Gini)") ///
	xtitle("Régressivité (kakwani)") ///
	legend(order(1 "Observé" 2 "Imputé"))
	
gen delta = kak_pred - kak
gen delta_RS = RS_ours_pred - RS_ours
gen rerank = G_diff_ours - RS_ours
gen rerank_pred = G_diff_ours_pred - RS_ours_pred
gen delta_rerank =  rerank - rerank_pred

twoway scatter G_diff_ours_pred G_diff_ours , mlabel(ccyy) || function y = x, range(G_diff_ours)

twoway scatter rerank_pred rerank , mlabel(ccyy) || function y = x, range(rerank)

graph dot (asis) delta if !mi(delta), over(ccyy_f, sort(delta))

graph dot (asis) delta if ccyy=="fr10", over(noisy, sort(delta))

graph dot (asis) delta_rerank if ccyy=="fr10", over(noisy, sort(delta))

twoway scatter delta_RS  delta_rerank