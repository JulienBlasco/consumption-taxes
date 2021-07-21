cd "D:"
capture noisily cd "D:\BLASCOLIEPP\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA"

use "2020_09_21 qu100 mod1 1s4", clear
append using "2020_09_21 qu100 mod1 2s4" "2020_09_21 qu100 mod1 3s4" ///
	"2020_09_21 qu100 mod1 4s4"
	
// merge with summaries
merge m:1 ccyy using "2020_09_21 summaries mod1v2.dta", ///
			keepusing(mean_hmc_scaled mean_hmc_wor_scaled mean_dhi mean_hmc_pred_scaled)
drop if _merge == 2
drop _merge	

gen coeff = mean_hmc_scaled/hmc_mmean
gen micro_prop = hmc_mmean/mean_dhi

egen max_year = max(year) if !mi(hmc_q), by(cname)
gen prop_q = hmc_q/dhi_q

sort cname year dhi_quantiles

cd "E:\Notes\2021-03 Resubmit JPubEc\Imputation conso\Réponse\images"
	
// propensions à consommer brutes
preserve 
keep if global_prop_q < 3 & year == max_year & global_prop_q < .
twoway line prop_q global_prop_q dhi_quantiles, by(cname) ///
	legend(order(1 "Unscaled" 2 "Scaled with NA"))
restore

graph export prop_brutes.eps, as(eps) preview (off) replace

// coefficients de recalage compta nat
preserve
gen cc = substr(ccyy, 1, 2)
keep cc year coeff oecd_prop micro_prop
duplicates drop
keep if coeff != .
rename (coeff oecd_prop micro_prop) (val_rescaling val_oecd_prop val_micro_prop)
reshape long val_, i(cc year) j(stat, string)
reshape wide val_, i(year stat) j(cc, string)
twoway (connected val_* year, msize(small ..)), ///
	by(stat, yrescale legend(span position(3))) legend(cols(1))
restore
	
graph export coefficients_recalage.eps, as(eps) preview (off) replace

// nombre de centiles en dessous de 1
preserve
keep if !mi(prop_q) & year == max_year
gen prop_regular = prop_q < 1
gen global_prop_regular = global_prop_q < 1
table ccyy_f prop_regular

egen share_regular = sum(prop_regular), by(ccyy_f)
egen global_share_regular = sum(global_prop_regular ), by(ccyy_f)
replace global_share_regular = . if global_share_regular == 0

keep ccyy_f share_regular global_share_regular
duplicates drop

mkmat share_regular global_share_regular, ///
	matrix(share_regular) rownames(ccyy_f) nchar(25)
frmttable using propensity_lower_one_brut.tex, statmat(share_regular) ///
	sdec(0) varlabels tex fragment nocenter replace ///
	ctitles("" "Unscaled" "Scaled with NA\textsuperscript{1}")
filefilter propensity_lower_one_brut.tex propensity_lower_one.tex, ///
	from("\BS_") to(" ") replace
restore

