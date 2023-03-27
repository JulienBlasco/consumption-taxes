/************************************************/
/* FIGURES WITH SUMMARIES DATASET */
/************************************************/

cd "G:"
use ".\DTA\ConsumptionTaxes_indicators_coremodel.dta", clear
append using ".\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", generate(model)

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

gen ccyy_papier = .
gen ccyy_lighter = " "
replace ccyy_lighter = "*" if model == 1

foreach ccyy in at13 be97 cz13 dk13 ee13 fi13 fr10 de13 gr13 is10 ie10 ///
	mx12 nl13 pl13 si12 es13 uk13 {
	replace ccyy_papier = 1 if ccyy == "`ccyy'"
	*replace ccyy_lighter = " " if ccyy == "`ccyy'"
}
foreach ccyy in au10  hu12 it10 no13  se05 ch13 us13 { // br13 za12
	replace ccyy_papier = 1 if ccyy == "`ccyy'"
	*replace ccyy_lighter = "*" if ccyy == "`ccyy'"
}

*label define lab_lighter 0 "*" 1 ""
*label values ccyy_lighter lab_lighter

gen M_tcons_central = M_tcons
replace M_tcons_central = M_tcons_pred if mi(M_tcons_central)
gen M_tax_central = M_tax
replace M_tax_central = M_tax_pred if mi(M_tax_central)
gen M_inc5_central = M_inc5
replace M_inc5_central = M_inc5_pred if mi(M_inc5_central)
gen Gini_inc5_central = Gini_inc5
replace Gini_inc5_central = Gini_inc5_pred if mi(Gini_inc5_central)
gen observe = !mi(Gini_inc5)
gen Gini_diff_central = Gini_diff
replace Gini_diff_central = Gini_diff_pred if mi(Gini_diff_central)
gen Kak_central = Kak
replace Kak_central = Kak_pred if mi(Kak_central)
gen RS_central = RS
replace RS_central = RS_pred if mi(RS_central)
gen Conc_tcons_central = Conc_tcons
replace Conc_tcons_central = Conc_tcons_pred if mi(Conc_tcons_central)
gen Conc_inc5_central = Conc_inc5
replace Conc_inc5_central = Conc_inc5_pred if mi(Conc_inc5_central)
gen Conc_tax_central = Conc_tax
replace Conc_tax_central = Conc_tax_pred if mi(Conc_tax_central)

set scheme plotplaincolor

// Figure 2: actual and predicted Gini coefficients
capture {
	gen clock2 = 4
	replace clock2 = 10 if Gini_inc5_pred > Gini_inc5 | ccyy == "fr84"
	replace clock2 = 12 if inlist(ccyy, "pl13","au10")
	replace clock2 = 9 if inlist(ccyy, "fr89", "fr94")
	replace clock2 = 3 if inlist(ccyy, "si12", "hu07", "it95", "it08")
}
twoway (scatter Gini_inc5_pred Gini_inc5 if Gini_inc5<0.4, mlabel(ccyy) mlabvpos(clock2)) ///
	(function y = x, range(0.25 0.4)), ///
	ytitle(Imputed consumption) xtitle(Observed consumption) ///
	legend(position(6) order(2 "45-degree line: no prediction error") title(Gini index of Post-Tax Income))
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-02_prediction_gini_posttax.eps", ///
	as(eps) preview(on) replace

// Figure 4: estimated rise in Gini index due to consumption taxes
graph hbar (asis) Gini_diff_central if ccyy_papier == 1, over(ccyy_lighter) nofill over(ccyy_f, sort(Gini_diff_central) descending) ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ylabel(0(0.01)0.05) graphregion(fcolor(white))
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-02_regressive_impact.eps", as(eps) preview(on) replace

// Figure 5: Gini of market, gross, disposable and post tax income
graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_central if ccyy_papier == 1 & !mi(Gini_inc2), ///
	over(ccyy_lighter) nofill over(ccyy_f, sort(Gini_inc5_central) descending) ytitle(Gini index of income inequality) ///
	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income")) exclude0 ///
	yscale(range(0.2 0.2))
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-02_market_gross_di_posttax.eps", ///
	as(eps) preview(on) replace

// Figure 6: redistributive impact vs effective tax	 rate
capture {
	gen clock6 = 9
	replace clock6 = 12 if inlist(cname, "Czech Republic", "United States")
	replace clock6 = 3 if inlist(cname, "Belgium", "Ireland", "Mexico")
}
twoway (scatter Gini_diff_central effective_taxrate if ccyy_papier != 1, mcolor(*0.3)) ///
	(scatter Gini_diff_central effective_taxrate if ccyy_papier == 1, mlabel(cname) mlabcolor(navy) mcolor(navy) msymbol(circle) mlabvpos(clock6)), ///
	ytitle(Redistribution effect of consumption taxes (increase in Gini points), size(small)) ///
	xtitle(Implicit tax rate on consumption) graphregion(fcolor(white)) legend(off)
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-02_regrimpact_itrc.eps", as(eps) preview(on) replace

// Figure 7: Kakwani, global TIR and RS
capture {
	gen mean_rate = M_tax_central/M_dhi
	gen pos_kak = -Kak_central
}

gen pos_kak_core = pos_kak if ccyy_lighter == " "
gen pos_kak_lighter = pos_kak if ccyy_lighter == "*"
label variable pos_kak_core "Core model"
label variable pos_kak_lighter "Lighter model"

gen clock7 = 3
replace clock7 = 9 if inlist(cname, "Netherlands", "South Africa", "Sweden")
replace clock7 = 6 if inlist(cname, "Czech Republic")

twoway (scatter pos_kak_core mean_rate if ccyy_papier == 1, mlabvpos(clock7) mlabel(cname)  ///
	yaxis(1 2) ylab(.02333333 "RS = 0.01" .04666667 "RS = 0.02" ///
	0.07 "RS = 0.03" 0.093333 "RS = 0.04" 0.11666667 "RS = 0.05" ///
	0.14 "RS = 0.06", noticks labstyle(size(small)) axis(2) angle(h))) ///
	(scatter pos_kak_lighter mean_rate if ccyy_papier == 1, mlabvpos(clock7) mlabel(cname))  ///
	(function RS1 = (0.01*(1-x)/x)/(1-(.01*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS3 = (0.02*(1-x)/x)/(1-(.02*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS5 = (0.03*(1-x)/x)/(1-(.03*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS7 = (0.04*(1-x)/x)/(1-(.04*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function (0.05*(1-x)/x)/(1-(.05*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function (0.06*(1-x)/x)/(1-(.06*(1-x)/x > 0.2)), range(0.05 0.3)), ///
	xtitle("Global tax-to-income ratio") ///
	ytitle("Kakwani index of regressivity", axis(1)) ///
	legend(order(1 2))
graph export "E:\Notes\2022-08_Reresubmit_JPubEc\images\23-02_kakwani_globalTIR.eps", as(eps) preview(on) replace

// Figure 14 : gross, market and disposable with heterogeneous
preserve
use "DTA\2023-01-28_20_11_2022_heter mod2 summaries ccyy_fig13.dta" , clear
append using "DTA\2023-01-28_20_11_2022_heter mod1 summaries ccyy_fig13.dta", generate(model)
save "DTA\20_11_2022_heter mod12 summaries ccyy_fig13.dta", replace
restore

preserve
keep ccyy_f Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_central model observe
merge 1:1 ccyy_f model using "DTA\20_11_2022_heter mod12 summaries ccyy_fig13.dta", keepusing(model Gini_ours*)
keep if _merge == 3
gen Gini_inc5_central_h = Gini_ours if observe
replace Gini_inc5_central_h = Gini_ours_pred if !observe
drop Gini_ours*

graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_central Gini_inc5_central_h, ///
	over(ccyy_f, sort(Gini_inc5_central) descending) ytitle(Gini index of income inequality)	///
	marker(4, msize(medsmall) msymbol(plus)) marker(5, msymbol(lgx)) exclude0 ///
	yscale(range(0.2 0.2)) ///
	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income (uniform)" 5 "Post-Tax Income (heterogeneous)"))
graph export "N:\images\23-02_heterogenous_gini.eps", as(eps) preview(on) replace
restore

// Fgure Appendix G.a : temporel
preserve
egen max_year = max(year), by(cname)
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
		gen clock_`pays' = 3
		if (inlist("`pays'", "Denmark", "Austria")) {
			replace clock_`pays' = 2
			}
		if (inlist("`pays'", "Spain","UnitedKingdom")) {
			replace clock_`pays' = 4
		}
}

keep if year >= 1995 & year <= 2013 & pays_central == 1
gen G_ = Gini_diff_pred if year == max_year
keep G_ Gini_diff_pred year cname lab_* clock_*
replace cname = subinstr(cname, " ", "", 1)
reshape wide Gini_diff_pred G_, i(year) j(cname, string)
local plotlist_line (line Gini_diff_predIceland year) 
local plotlist_scatter (scatter G_Iceland year, mlabel(lab_Iceland))
foreach pays in Denmark Greece Netherlands ///
	Austria CzechRepublic Spain Germany Poland UnitedKingdom France ///
	Australia Switzerland Mexico UnitedStates {
		local plotlist_line `plotlist_line' || (line Gini_diff_pred`pays' year, lpattern(solid)) 
		local plotlist_scatter `plotlist_scatter' || (scatter G_`pays' year, ///
		mlabel(lab_`pays') mlabvpos(clock_`pays') msymbol(circle))
}

twoway `plotlist_line' || `plotlist_scatter', legend(off)
	
graph export "N:\images\23-02_g_diff_temporel.eps", replace
restore

// Figure Appendix F : vertical vs horizontal redistribution
gen rerank = Gini_diff - RS 
preserve
label variable rerank "Reranking index"
label variable RS "Reynolds-Smolensky vertical redistribution index"
tostring year, gen(year_s)
keep if !mi(rerank)
egen max_year = max(year), by(cname)
keep if year == max_year
graph bar (asis) RS rerank , over(ccyy_f, sort(Gini_diff) descending label(alternate)) ///
	stack legend(position(6))
graph export "N:\images\23-02_decomposition_effective_redistribution.eps", replace


/************************************************/
/* FIGURES IN APPENDIX WITH MOD 1     */
/************************************************/
cd "G:"
use ".\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", clear

egen max_year = max(year), by(cname)
egen max_year_obs = max(year) if !mi(M_inc5), by(cname)

gen M_tcons_central = M_tcons
replace M_tcons_central = M_tcons_pred if mi(M_tcons_central)
gen M_tax_central = M_tax
replace M_tax_central = M_tax_pred if mi(M_tax_central)
gen M_inc5_central = M_inc5
replace M_inc5_central = M_inc5_pred if mi(M_inc5_central)
gen Gini_inc5_central = Gini_inc5
replace Gini_inc5_central = Gini_inc5_pred if mi(Gini_inc5_central)
gen Gini_diff_central = Gini_diff
replace Gini_diff_central = Gini_diff_pred if mi(Gini_diff_central)
gen Kak_central = Kak
replace Kak_central = Kak_pred if mi(Kak_central)
gen RS_central = RS
replace RS_central = RS_pred if mi(RS_central)
gen Conc_tcons_central = Conc_tcons
replace Conc_tcons_central = Conc_tcons_pred if mi(Conc_tcons_central)
gen Conc_inc5_central = Conc_inc5
replace Conc_inc5_central = Conc_inc5_pred if mi(Conc_inc5_central)
gen Conc_tax_central = Conc_tax
replace Conc_tax_central = Conc_tax_pred if mi(Conc_tax_central)

// Figure 2: actual and predicted Gini coefficients
// graph dot (asis) Gini_inc5_pred Gini_pre Gini_inc5 if year == max_year_obs, ///
// 	over(model, relabel(1 " " 2 "*")) over(ccyy_f, sort(Gini_pre) descending) nofill exclude0 ///
// 	marker(1, msymbol(lgx)) yscale(range(0.2 0.2)) ytitle(Gini index of income) ///
// 	legend(caption(* imputation done with extended model) rows(3) ///
// 		order(2 "Disposable Income" 3 "Post-tax Income (observed consumption)" ///
// 		1 "Post-Tax Income (imputed consumption)"))

capture {
	gen clockB2 = 4
	replace clockB2 = 10 if Gini_inc5_pred > Gini_inc5 | ccyy == "fr84"
	replace clockB2 = 12 if inlist(ccyy, "pl13","au10")
	replace clockB2 = 9 if inlist(ccyy, "fr89", "fr94")
	replace clockB2 = 3 if inlist(ccyy, "si12", "hu07", "it95", "it08")
}
twoway (scatter Gini_inc5_pred Gini_inc5 if Gini_inc5<0.4, mlabel(ccyy) mlabvpos(clockB2)) ///
	(function y = x, range(0.25 0.4)), ///
	ytitle(Imputed consumption (Lighter model)) xtitle(Observed consumption) ///
	legend(position(6) order(2 "45-degree line: no prediction error") title(Gini index of Post-Tax Income))
graph export "N:\images\23-02_prediction_gini_posttax_mod1.eps", ///
	as(eps) preview(on) replace


// Gini pre et post tax
graph dot (asis) Gini_inc5_central Gini_pre if year == max_year, ///
	over(ccyy_f, sort(Gini_pre) descending) ytitle(Gini index of income inequality) ///
	legend(order(2 "Disposable Income" 1 "Post-consumption-tax"))
graph export "N:\images\23-02_gini_prepost_mod1.eps", as(eps) preview(on) replace

// Figure 6: redistributive impact vs effective tax rate
capture {
	reg Gini_diff_central effective_taxrate
	predict lfit_Gdiff
}
capture {
	gen clockB6 = 12 if Gini_diff_central > lfit_Gdiff
	replace clockB6 = 6 if Gini_diff_central <= lfit_Gdiff
	replace clockB6 = 9 if inlist(cname, "Estonia", "United Kingdom")
	// replace clockB6 = 3 if inlist(cname, "Belgium", "Ireland", "Mexico")
}
twoway (scatter Gini_diff_central effective_taxrate if year != max_year, mcolor(*0.3)) ///
	(scatter Gini_diff_central effective_taxrate if year == max_year, mlabel(cname) mlabcolor(navy) mcolor(navy) msymbol(circle)  mlabvpos(clockB6)), ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ///
	xtitle(Effective tax rate on consumption) legend(off)
graph export "N:\images\23-02_regrimpact_itrc_mod1.eps", as(eps) preview(on) replace
