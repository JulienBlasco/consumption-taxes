/************************************************/
/* FIGURES WITH SUMMARIES DATASET */
/************************************************/
cd "G:"
set scheme plotplaincolor

/************************************************/
/* FIGURES WITH PERCENTILE DATASET */
/************************************************/
cd "G:"
*cd "\BLASCOLIEPP\Code\19-08-21 Datasets V6"
use ".\DTA\ConsumptionTaxes_percentiles_coremodel_ccyypapier.dta", clear
append using ".\DTA\ConsumptionTaxes_percentiles_xtnddmodel_ccyypapier.dta", generate(model)

gsort cname -year percentile

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

gen ccyy_lighter = " "
replace ccyy_lighter = "*" if model == 1

label define model 0 "Core" 1 "Extended"
label values model model

egen max_year1 = max(year) if model == 0 & !mi(tax) & year > 2000, by(cname)
egen max_year_total1 = total(max_year1), by(cname)

egen max_year2 = max(year) if !mi(tax_pred) & model == 0 & max_year_total1 == 0 ///
	& year > 2000, by(cname)
egen max_year_total2 = total(max_year2), by(cname)

egen max_year3 = max(year) if !mi(tax) & max_year_total1 == 0 & max_year_total2 == 0 ///
	& year > 2000, by(cname)
egen max_year_total3 = total(max_year3), by(cname)

egen max_year4 = max(year) if !mi(tax_pred) & max_year_total1 == 0 ///
	& max_year_total2 == 0 & max_year_total3 == 0 & year > 2000, by(cname)
egen max_year_total4 = total(max_year4), by(cname)

egen max_year5 = max(year) if !mi(tax_pred) & max_year_total1 == 0 ///
	& max_year_total2 == 0 & max_year_total3 == 0 & max_year_total4 == 0 , by(cname)
	
gen max_year = max_year1
replace max_year = max_year2 if mi(max_year)
replace max_year = max_year3 if mi(max_year)
replace max_year = max_year4 if mi(max_year)
replace max_year = max_year5 if mi(max_year)

gen central = year == max_year

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
gen T10_B50_inc5 = T10_inc5/B50_inc5

egen T10_inc5_ind_obs = sum(inc5) if percentile >= 91, by(ccyy_f)
egen B50_inc5_ind_obs = sum(inc5) if percentile <= 50, by(ccyy_f)
egen T10_inc5_obs = max(T10_inc5_ind_obs), by(ccyy_f)
egen B50_inc5_obs = max(B50_inc5_ind_obs), by(ccyy_f)
gen T10_B50_inc5_obs = T10_inc5_obs/B50_inc5_obs

egen T10_inc5_ind_pred = sum(inc5_pred) if percentile >= 91, by(ccyy_f)
egen B50_inc5_ind_pred = sum(inc5_pred) if percentile <= 50, by(ccyy_f)
egen T10_inc5_pred = max(T10_inc5_ind_pred), by(ccyy_f)
egen B50_inc5_pred = max(B50_inc5_ind_pred), by(ccyy_f)
gen T10_B50_inc5_pred = T10_inc5_pred/B50_inc5_pred

egen T10_tax_ind = sum(tax_central) if percentile >= 91, by(ccyy_f)
egen B50_tax_ind = sum(tax_central) if percentile <= 50, by(ccyy_f)
egen T10_tax = max(T10_tax_ind), by(ccyy_f)
egen B50_tax = max(B50_tax_ind), by(ccyy_f)
gen T10_TIR = T10_tax/T10
gen B50_TIR = B50_tax/B50
gen T10_B50_taxratio = T10_TIR/B50_TIR

gen t10_diff = T10_B50_inc5 - T10_B50
gen t10_diff_obs = T10_B50_inc5_obs - T10_B50
gen t10_diff_pred = T10_B50_inc5_pred - T10_B50

cd "N:/"

// Figure 4: TIR for FR, US, DE, DK	
preserve
keep if inlist(cname,"France", "United States", "Germany", "Denmark") & central
keep ccyy tax_ratio_central percentile
drop if tax_ratio_central > 0.4
reshape wide tax_ratio_central, i(percentile) j(ccyy) string
twoway line tax_ratio_central???? percentile, ytitle(Tax-to-income ratio) ///
	legend(order(2 "Denmark (2013)" 3 "France (2010)" 1 "Germany (2013)" 4 "United States (2013)")) ///
	graphregion(fcolor(white)) lpattern(solid dash vshortdash longdash_dot)
graph export "images\23-01_TIR_qu100_dedkfrus.eps", ///
	as(eps) preview(on) replace
restore

// Figure 5: estimated rise in T10/B50 due to consumption taxes
preserve
duplicates drop ccyy_f, force
graph hbar (asis) t10_diff if central, over(ccyy_lighter) nofill over(ccyy_f, sort(t10_diff) descending) ///
	ytitle("") graphregion(fcolor(white))
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-01_diff_t10_b50.eps", as(eps) preview(on) replace
restore

// Table 1: tax-to-income ratios of T10 and B50
preserve
duplicates drop ccyy_f, force
sort T10_B50_taxratio
mkmat T10_TIR B50_TIR T10_B50_taxratio if central, matrix(t10_b50_tir) rownames(ccyy_f)
restore

frmttable using "tables/23-01_t10_b50_tir_brut.tex", statmat(t10_b50_tir) ///
	sdec(2) varlabels tex fragment nocenter replace ///
	ctitles("" "TIR of T10" "TIR of B50" "Ratio") // vlines(000{10}0)
filefilter "tables/23-01_t10_b50_tir_brut.tex" "tables/23-01_t10_b50_tir.tex", ///
	from("\BS_") to(" ") replace

// Figure A.a: estimated error in T10/B50 due to consumption taxes
preserve
duplicates drop ccyy_f, force
graph hbar (asis) t10_diff_obs t10_diff_pred if !mi(t10_diff_obs), over(ccyy_lighter) nofill ///
	over(ccyy_f, sort(t10_diff_obs)) ytitle("") graphregion(fcolor(white))
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-01_prediction_gini_posttax_mod1.eps", ///
	as(eps) preview(on) replace
restore
	
********************
* ITRC DATASET
********************

// Figure B.1.a : ITRC
use "./Itrcs scalings/18-08-31_itrcs_scalings.dta", replace
tostring year, gen(year_s)
gen ccyy_f = cname + " (" + year_s + ")"

foreach pays in Japan Turkey Colombia "Costa Rica" Peru Canada Korea ///
	Latvia "Slovak Republic" Israel Chile "Cabo Verde" Argentina {
		drop if cname == "`pays'"
	}

graph dot (mean) itrc_carey itrc_ours itrc_euro if !mi(itrc_ours), ///
	over(cname, sort(itrc_ours) label(angle(45))) vertical ///
	ylabel(, angle(horizontal)) ///
	legend(order(1 "Carey et al. 2000" 2 "Present paper" 3 "Eurostat 2016") position(6) rows(1))
graph export "N:\Article\images\2020-11_averageITRCS.eps", as(eps) preview(on) replace


