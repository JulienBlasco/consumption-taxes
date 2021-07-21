cd "E:\Notes\2021-03 Resubmit JPubEc\Comparaison ITRC Microsim\Decoster_2010"

foreach cc in be hu ie uk {
	import delimited using "indirect_taxes_`cc'.txt", delimiters(" ", collapse) clear
	
	gen dhi = taxessilc * tax_ratiosilc
	gen cc = "`cc'"
	gen etude = 1
	rename decile decile_num
	
	save "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\comparaison_euromod\indirect_taxes_`cc'.dta", ///
		replace
}

use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\ConsumptionTaxes_percentiles_coremodel.dta", clear
keep if ccyy == "gr04"
gen decile_num = ceil(percentile/10)
gen cc = substr(ccyy, 1, 2)
gen etude = 1
egen dhi_mean = mean(dhi), by(ccyy decile_num)
keep cc etude decile_num dhi_mean
rename dhi_mean dhi
duplicates drop
save "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\comparaison_euromod\indirect_taxes_gr.dta", replace
