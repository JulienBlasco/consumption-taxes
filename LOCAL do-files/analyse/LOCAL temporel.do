use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear
merge 1:1 year cname using ///
	"E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\Itrcs scalings\18-08-31_itrcs_scalings.dta" ///
	, keepusing(year cname itrc_ours)

sort cname year

preserve
keep if cname == "United Kingdom"
twoway (connected Gini_diff_pred year, mlabel(year)) ///
	(connected itrc_ours year, yaxis(2) ) (line Gini_pre year, yaxis(3)) ///
	if cname=="United Kingdom" & year >=1990

preserve
keep itrc_ours year cname
reshape wide itrc_ours, i(year) j(cname, string)
twoway line itrc_ours* year

preserve
keep Gini_diff_pred year cname
reshape wide Gini_diff_pred, i(year) j(cname, string)
twoway line Gini_diff* year
