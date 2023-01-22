/*
import delimited "G:/CSV/2021_11_22_summarise_uk_itrcbloque.csv", clear delimiter(space, collapse)
gen Gini_diff_bloque = gini_inc_5_ours_pred - conc_dhi_dhi
save "G:/DTA/2021_11_22_summarise_uk_itrcbloque", replace
*/


use "G:\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear

merge 1:1 year cname using ///
	"G:\Itrcs scalings\18-08-31_itrcs_scalings.dta" ///
	, keepusing(year cname itrc_ours oecd_*)
merge 1:1 year cname using ///
	"G:\LOCAL do-files\temporel\SNA_TABLE1_22032022121247604" ///
	, keepusing(year cname GDP) nogenerate

gen cc = substr(ccyy, 1, 2)
tostring year, generate(year_s)
gen yy = substr(year_s, 3,2)
gsort cname -cc, mfirst
replace cc = cc[_n-1] if missing(cc) & cname == cname[_n-1]
egen ccyy2 = concat(cc yy)
replace ccyy = ccyy2 if missing(ccyy)
keep if ccyy != yy
drop cc yy ccyy2

merge 1:1 ccyy using ///
	"G:\LOCAL do-files\temporel\consumption_data", ///
	keepusing(ccyy standard_vat_rate) generate(merge2) keep(matched master)
merge 1:1 cname year using ///
	"G:\LOCAL do-files\temporel\consumption_data", ///
	keepusing(cname year standard_vat_rate) generate(merge3) update

sort cname year
replace standard_vat_rate = standard_vat_rate/100

set scheme plotplaincolor

preserve
keep if cname == "United Kingdom"
keep year Gini_diff_pred itrc_ours Gini_pre standard_vat_rate oecd_prop
rename (standard_vat_rate itrc_ours Gini_pre Gini_diff_pred) (valeur#), addnumber
reshape long valeur, i(year) j(indicateur)
label define label_indicateur ///
	4 "Impact of consumption taxes on inequality" ///
	2 "Effective tax rate (ITRC)" ///
	3 "Inequality of disposable income" ///
	1 "Standard VAT rate" // 5 "propension agrégée" = oecd_prop à ajouter si on veut
label values indicateur label_indicateur
twoway connected valeur* year if year >= 1995 & year <= 2015, ///
	 yscale(range(0 0.1)) by(indicateur, note("") yrescale title(Evolution of some VAT-related indicators in United Kingdom)) ///
	ytitle(, size(zero))
restore

graph export "N:\images\23-01_tab_tva_UK.eps", as(eps) preview(on) replace
