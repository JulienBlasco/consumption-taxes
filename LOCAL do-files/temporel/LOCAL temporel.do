use "G:\DTA\ConsumptionTaxes_indicators_coremodel.dta", clear
append using "G:\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", generate(model)

drop if (ccyy =="uk04" | ccyy == "uk99") & model == 0
keep if year >= 1995

gen mod0 = model == 0
egen nb_mod0 = sum(mod0), by(cname)
gen mod1 = model == 1
egen nb_mod1 = sum(mod1), by(cname)
drop if nb_mod0 != nb_mod1 & model == 0
drop if nb_mod0 == nb_mod1 & model == 1
drop mod0 nb_mod0 mod1 nb_mod1

label define model 0 "Core" 1 "Extended"
label values model model
table cname model

gen obs = !mi(M_inc5)
table cname obs
egen nb_obs = sum(obs), by(cname)

egen max_year = max(year), by(cname)

twoway connected Gini_diff Gini_diff_pred year if nb_obs > 0, by(cname)

foreach var in M_tcons M_tax M_inc5 Gini_inc5 Gini_diff Kak RS Conc_tcons Conc_inc5 Conc_tax {
	gen `var'_central = `var'
	replace `var'_central = `var'_pred if mi(`var')
}

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

capture program drop tableau_tva
program define tableau_tva
	syntax namelist(name=pays)
	
	preserve
	keep if cname == "`pays'"
	keep year Gini_diff_pred itrc_ours Gini_pre standard_vat_rate
	rename (standard_vat_rate itrc_ours Gini_pre Gini_diff_pred) (valeur#), addnumber
	reshape long valeur, i(year) j(indicateur)
	label define label_indicateur ///
		4 "Impact of consumption taxes on inequality" ///
		2 "Effective tax rate (ITRC)" ///
		3 "Inequality of disposable income" ///
		1 "Standard VAT rate"
	label values indicateur label_indicateur
	twoway connected valeur year if year >= 1995 & year <= 2015, ///
		by(indicateur, yrescale title(Evolution of some VAT-related indicators in `pays')) ///
		ytitle(, size(zero))
	restore
end

tableau_tva United Kingdom

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
	
preserve
gen pays_central = .
foreach pays in Iceland Denmark Greece Netherlands ///
	Austria "Czech Republic" Spain Germany Poland "United Kingdom" France ///
	Australia Switzerland Mexico "United States" {
		replace pays_central = 1 if cname == "`pays'"
}
foreach pays in Iceland Denmark Greece Netherlands ///
	Austria "CzechRepublic" Spain Germany Poland "UnitedKingdom" France ///
	Australia Switzerland Mexico "UnitedStates" {
		gen lab_`pays' = "`pays'"
}
keep if year >= 1995 & year <= 2013 & pays_central == 1
gen G_ = Gini_diff_pred if year == max_year
keep G_ Gini_diff_pred year cname lab_*
replace cname = subinstr(cname, " ", "", 1)
reshape wide Gini_diff_pred G_, i(year) j(cname, string)
local plotlist_line (line Gini_diff_predIceland year) 
local plotlist_scatter (scatter G_Iceland year, mlabel(lab_Iceland))
foreach pays in Denmark Greece Netherlands ///
	Austria CzechRepublic Spain Germany Poland UnitedKingdom France ///
	Australia Switzerland Mexico UnitedStates {
		local plotlist_line `plotlist_line' || (line Gini_diff_pred`pays' year) 
		local plotlist_scatter `plotlist_scatter' || (scatter G_`pays' year, ///
		mlabel(lab_`pays'))
}
twoway `plotlist_line' || `plotlist_scatter', legend(off)
restore

graph hbox Gini_diff_pred if year >= 1995 & year <= 2013, ///
	over(cname, sort(Gini_diff_pred) descending) nofill cw

