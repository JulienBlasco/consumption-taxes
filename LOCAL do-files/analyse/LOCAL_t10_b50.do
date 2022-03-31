cd "G:"
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

gen itrc = tax_central/tcons_central
gen itrc_redresse = itrc + 0.02*(percentile-50)/100
gen tax_central_redresse = tcons_central*itrc_redresse
gen tax_ratio_central_redresse = tax_central_redresse/dhi
gen inc5_central_redresse = dhi - tax_central_redresse

gen decile = ceil(percentile/10)

foreach var in tax_central tcons_central tax_central_redresse dhi inc5_central inc5_central_redresse {
	egen `var'_dec = sum(`var'), by(ccyy decile)
}

keep ccyy* central decile *_dec
duplicates drop

// rapport T10/B50
egen T10 = max(dhi_dec), by(ccyy_f)
egen B50 = sum(dhi_dec) if inlist(decile, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50 = T10/B50

egen T10_5_redresse = max(inc5_central_redresse_dec), by(ccyy_f)
egen B50_5_redresse = sum(inc5_central_redresse_dec) if inlist(decile, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50_inc5_redresse = T10_5_redresse/B50_5_redresse

egen T10_5 = max(inc5_central_dec), by(ccyy_f)
egen B50_5 = sum(inc5_central_dec) if inlist(decile, 1, 2, 3, 4, 5), by(ccyy_f)
gen T10_B50_inc5 = T10_5/B50_5

duplicates drop ccyy T10_B50 T10_B50_inc5 T10_B50_inc5_redresse, force
drop if mi(T10_B50)
// stockage latex
cd "N:\Article"
mkmat T10_B50 T10_B50_inc5 T10_B50_inc5_redresse if central, matrix(t10_b50) rownames(ccyy_f)

frmttable using tables/t10_b50_brut.tex, statmat(t10_b50) ///
	sdec(2) varlabels tex fragment nocenter replace ///
	ctitles("" "Disposable Income" "Post-tax" "Post-tax (redresse)") // vlines(000{10}0)
filefilter tables/t10_b50_brut.tex tables/t10_b50.tex, ///
	from("\BS_") to(" ") replace



