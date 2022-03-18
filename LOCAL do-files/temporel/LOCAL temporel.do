use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear
merge 1:1 year cname using ///
	"E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\Itrcs scalings\18-08-31_itrcs_scalings.dta" ///
	, keepusing(year cname itrc_ours)
keep if ccyy != ""
merge 1:1 ccyy using ///
	"G:\LOCAL do-files\temporel\consumption_data", ///
	keepusing(ccyy standard_vat_rate) generate(merge2) keep(matched master)
merge 1:1 cname year using ///
	"G:\LOCAL do-files\temporel\consumption_data", ///
	keepusing(cname year standard_vat_rate) generate(merge3)
	
sort cname year
replace standard_vat_rate = standard_vat_rate/100

preserve
keep if cname == "United Kingdom"
keep year Gini_diff_pred itrc_ours Gini_pre standard_vat_rate
rename (standard_vat_rate itrc_ours Gini_pre Gini_diff_pred) (valeur#), addnumber
reshape long valeur, i(year) j(indicateur)
label define label_indicateur ///
	4 "Impact of consumption taxes on inequality" ///
	2 "Effective tax rate (ITRC)" ///
	3 "Inequality of disposable income" ///
	1 "Standard VAT rate"
label values indicateur label_indicateur
twoway connected valeur year if year >= 1990, ///
	by(indicateur, yrescale title(Evolution of some VAT-related indicators in the UK)) ///
	ytitle(, size(zero))
restore
	
// give and idea of the variation over time of ITRCS

*preserve
*keep itrc_ours year cname
*reshape wide itrc_ours, i(year) j(cname, string)
*twoway line itrc_ours* year if year >= 1995 & year <= 2013
*restore

preserve
keep itrc_ours year cname
keep if year >= 1995 & year <= 2013
reshape wide itrc_ours, i(cname) j(year)
graph dot (asis) itrc_ours*, ///
	over(cname, sort(itrc_ours2010) descending) nofill cw legend(off) linetype(line)
restore

graph hbox itrc_ours if year >= 1995 & year <= 2013, ///
	over(cname, sort(itrc_ours) descending) nofill cw

// give and idea of the variation over time of ITRCS
	
*preserve
*keep Gini_diff_pred year cname
*reshape wide Gini_diff_pred, i(year) j(cname, string)
*twoway line Gini_diff* year
*restore

graph hbox Gini_diff_pred if year >= 1995 & year <= 2013, ///
	over(cname, sort(Gini_diff_pred) descending) nofill cw
