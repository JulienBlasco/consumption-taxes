use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\ConsumptionTaxes_percentiles_xtnddmodel.dta", clear

egen T10_ind = sum(dhi) if percentile >= 91, by(ccyy_f)
egen B50_ind = sum(dhi) if percentile <= 50, by(ccyy_f)
egen T10 = max(T10_ind), by(ccyy_f)
egen B50 = max(B50_ind), by(ccyy_f)
gen T10_B50 = T10/B50

gsort cname -year percentile

graph dot (first) T10_B50, over(cname, sort(T10_B50))
