cd "G:"
*cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"
use ".\DTA\ConsumptionTaxes_percentiles_coremodel.dta", clear
append using ".\DTA\ConsumptionTaxes_percentiles_xtnddmodel.dta", generate(model)

sort ccyy percentile

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

label define model 0 "Core" 1 "Extended"
label values model model

egen max_year = max(year), by(cname)
egen max_year_obs = max(year) if !mi(inc5), by(cname)
egen max_year_core = max(year) if model == 0, by(cname)
egen max_year_central = max(year) if (model == 0) | ///
	inlist(cname, "United States", "Norway", "Sweden", "Australia"), by(cname)
gen central = year == max_year_central

gen tcons_central = tcons
replace tcons_central = tcons_pred if mi(tcons_central)
gen tax_central = tax
replace tax_central = tax_pred if mi(tax_central)
gen inc5_central = inc5
replace inc5_central = inc5_pred if mi(inc5_central)
gen propensity_central = propensity
replace propensity_central = propensity_pred if mi(propensity_central)
gen tax_ratio_central = tax_ratio
replace tax_ratio_central = tax_ratio_pred if mi(tax_ratio_central)


egen T10_ind = sum(dhi) if percentile >= 91, by(ccyy_f)
egen B50_ind = sum(dhi) if percentile <= 50, by(ccyy_f)
egen T10 = max(T10_ind), by(ccyy_f)
egen B50 = max(B50_ind), by(ccyy_f)
gen T10_B50 = T10/B50

egen T10_inc5_ind = sum(inc5_central) if percentile >= 91, by(ccyy_f)
egen B50_inc5_ind = sum(inc5_central) if percentile <= 50, by(ccyy_f)
egen T10_inc5 = max(T10_inc5_ind), by(ccyy_f)
egen B50_inc5 = max(B50_inc5_ind), by(ccyy_f)
gen T10_B50_inc5= T10_inc5/B50_inc5

gen T10_diff = T10_B50_inc5 - T10_B50

graph dot (first)  T10_B50 T10_B50_inc5 if central & !mi(T10_B50_inc5), over(ccyy_f)

graph hbar (first) T10_diff  if central & !mi(T10_B50_inc5), over(ccyy_f, sort(T10_diff) descending)
