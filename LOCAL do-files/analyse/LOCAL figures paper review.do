/************************************************/
/* FIGURES WITH SUMMARIES DATASET */
/************************************************/

cd "G:"
use ".\DTA\ConsumptionTaxes_indicators_coremodel.dta", clear
append using ".\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", generate(model)
append using ".\DTA\no13_ConsumptionTaxes_indicators_xtnddmodel.dta"

egen min_model = min(model), by(ccyy)
drop if min_model == 0 & model == 1
drop min_model

gen ccyy_papier = .
gen ccyy_lighter = ""
foreach ccyy in at13 be97 cz13 dk13 ee13 fi13 fr10 de13 gr13 is10 ie10 ///
	mx12 nl13 pl13 si12 es13 uk13 {
	replace ccyy_papier = 1 if ccyy == "`ccyy'"
	replace ccyy_lighter = " " if ccyy == "`ccyy'"
}
foreach ccyy in au10 br13 hu12 it10 no13 za12 se05 ch13 us13 {
	replace ccyy_papier = 1 if ccyy == "`ccyy'"
	replace ccyy_lighter = "*" if ccyy == "`ccyy'"
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
graph export "E:\Notes\2021-03 Resubmit JPubEc\Article\images\20-10_prediction_gini_posttax.eps", ///
	as(eps) preview(on) replace

// Figure 4: estimated rise in Gini index due to consumption taxes
graph hbar (asis) Gini_diff_central if ccyy_papier == 1, over(ccyy_lighter) nofill over(ccyy_f, sort(Gini_diff_central) descending) ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ylabel(0(0.01)0.05) graphregion(fcolor(white))
graph export "E:\Notes\2021-03 Resubmit JPubEc\Article\images\2020-10_regressive_impact.eps", as(eps) preview(on) replace

// Figure 5: Gini of market, gross, disposable and post tax income
graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_central if ccyy_papier == 1 & !mi(Gini_inc2), ///
	over(ccyy_lighter) nofill over(ccyy_f, sort(Gini_inc5_central) descending) ytitle(Gini index of income inequality) ///
	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income"))
graph export "E:\Notes\2021-03 Resubmit JPubEc\Article\images\2020-10_market_gross_di_posttax.eps", ///
	as(eps) preview(on) replace

// Figure 6: redistributive impact vs effective tax rate
capture {
	gen clock6 = 9
	replace clock6 = 12 if inlist(cname, "Czech Republic", "United States")
	replace clock6 = 3 if inlist(cname, "Belgium", "Ireland", "Mexico")
}
twoway (scatter Gini_diff_central effective_taxrate if ccyy_papier != 1, mcolor(*0.3)) ///
	(scatter Gini_diff_central effective_taxrate if ccyy_papier == 1, mlabel(cname) mlabcolor(navy) mcolor(navy) msymbol(circle) mlabvpos(clock6)), ///
	ytitle(Regressive impact of consumption taxes (Gini points)) ///
	xtitle(Implicit tax rate on consumption) graphregion(fcolor(white)) legend(off)
graph export "E:\Notes\2021-03 Resubmit JPubEc\Article\images\2020-10_regrimpact_itrc.eps", as(eps) preview(on) replace

// Figure 7: Kakwani, global TIR and RS
capture {
	gen mean_rate = M_tax_central/M_dhi
	gen pos_kak = -Kak_central
}
twoway (scatter pos_kak mean_rate if ccyy_papier == 1, mlabel(cname)  ///
	yaxis(1 2) ylab(.02333333 "RS = 0.01" .04666667 "RS = 0.02" ///
	0.07 "RS = 0.03" 0.093333 "RS = 0.04" 0.11666667 "RS = 0.05" ///
	0.14 "RS = 0.06", noticks labstyle(size(small)) axis(2) angle(h))) ///
	(function RS1 = (0.01*(1-x)/x)/(1-(.01*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS3 = (0.02*(1-x)/x)/(1-(.02*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS5 = (0.03*(1-x)/x)/(1-(.03*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function RS7 = (0.04*(1-x)/x)/(1-(.04*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function (0.05*(1-x)/x)/(1-(.05*(1-x)/x > 0.2)), range(0.05 0.3)) ///
	(function (0.06*(1-x)/x)/(1-(.06*(1-x)/x > 0.2)), range(0.05 0.3)), ///
	xtitle("Global tax-to-income ratio") ///
	ytitle("Kakwani index of regressivity", axis(1)) ///
	legend(off)
graph export "E:\Notes\2021-03 Resubmit JPubEc\Article\images\2020-10_kakwani_globalTIR.eps", as(eps) preview(on) replace

