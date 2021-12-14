use "DTA\2021_11_22_summaries_mod2.dta", clear
append using "DTA\2021_11_22_summaries_mod2wnoises2.dta", generate(noise)


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

//

egen max_noise = max(noise), by(ccyy)

keep if max_noise == 1

preserve
keep ccyy kak kak_pred noise
reshape wide kak kak_pred, i(ccyy) j(noise)
graph dot (asis) kak1 kak_pred* , over(ccyy, sort(kak1, descending))

preserve
gen rerank = G_diff_ours - RS_ours
gen rerank_pred = G_diff_ours_pred - RS_ours_pred
keep ccyy rerank rerank_pred noise
reshape wide rerank rerank_pred, i(ccyy) j(noise)
graph dot (asis) rerank1 rerank_pred* if !mi(rerank1), over(ccyy, sort(rerank1, descending))

preserve
keep ccyy G_diff_ours G_diff_ours_pred noise
reshape wide G_diff_ours G_diff_ours_pred, i(ccyy) j(noise)
graph dot (asis) G_diff_ours1 G_diff_ours_pred* if !mi(G_diff_ours1), over(ccyy, sort(G_diff_ours1, descending))