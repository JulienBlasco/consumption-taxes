use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\comparaison_euromod\comparaison_euromod.dta", clear
cd "E:\Notes\2021-03 Resubmit JPubEc\Comparaison ITRC Microsim\Réponse\images"

// taux d'effort par décile
twoway line tax_prop tax_prop_ours decile_num ///
	if decile_num != 11 & tax_prop_ours < 0.4 & central, ///
	by(ccyy_f etude) yscale(range(0 0.1))
		
graph export taux_effort_central.eps, as(eps) preview (off) replace

twoway line tax_prop rescaled_tax_prop_ours decile_num ///
	if decile_num != 11 & tax_prop_ours < 0.4 & central, ///
	by(ccyy_f etude) yscale(range(0 0.1))
		
graph export taux_effort_central_rescaled.eps, as(eps) preview (off) replace

// différences de niveau
graph dot (asis) effective_tax* if central & decile_num == 11, ///
	over(ccyy_f, sort(effective_taxrate_ours)) nofill
	
graph export eff_taxrate_central.eps, as(eps) preview (off) replace

	

// rapport interdécile des taux d'effort
preserve
keep ccyy_f cname year tax_prop* decile_num etude central
drop if decile_num == 11 | !central | etude == 3
duplicates drop
reshape wide tax_prop tax_prop_ours, i(ccyy_f cname year etude) j(decile_num)
gen ecart_D10_D1 = tax_prop10/tax_prop1
gen ecart_D10_D5 = tax_prop10/tax_prop5
gen ecart_D5_D1 = tax_prop5/tax_prop1
gen ecart_D9_D2 = tax_prop9/tax_prop2

gen ecart_ours_D10_D1 = tax_prop_ours10/tax_prop_ours1
gen ecart_ours_D10_D5 = tax_prop_ours10/tax_prop_ours5
gen ecart_ours_D5_D1 = tax_prop_ours5/tax_prop_ours1
gen ecart_ours2_D9_D2 = tax_prop_ours9/tax_prop_ours2

mkmat ecart_D5_D1 ecart_ours_D5_D1 ecart_D10_D5 ecart_ours_D10_D5 ///
	ecart_D10_D1 ecart_ours_D10_D1 if central, ///
	matrix(interdeciles) rownames(ccyy_f)

frmttable using interdeciles2.tex, statmat(interdeciles) ///
	sdec(2) varlabels tex fragment nocenter replace ///
	ctitles("" "D5/D1" "D5/D1 (ITRC)" "D10/D5" "D10/D5 (ITRC)" ///
	"D10/D1" "D10/D1 (ITRC)")
filefilter interdeciles2.tex interdeciles.tex, from("\BS_") to(" ") replace

	
graph dot (asis) ecart_D10_D1 ecart_ours_D10_D1 ecart_D9_D2 ecart_ours2_D9_D2 ///
	if central, over(ccyy_f, sort(ecart_D9_D2)) ///
	marker(1, msymbol(T) mcolor(navy)) marker(2, msymbol(T) mcolor(maroon)) ///
	marker(3, msymbol(O) mcolor(navy)) marker(4, msymbol(O) mcolor(maroon))
	
graph export interdecile_effort_central.eps, as(eps) preview (off) replace
restore

 
// T10 et B50
graph dot (first) T10_B50 T10_B50_inc5 T10_B50_inc5ours if central ///
	, over(ccyy_f) nofill ///
	marker(1, msymbol(x)) marker(2, msymbol(x)) marker(3, msymbol(x))
graph export t10_b50.eps, as(eps) preview (off) replace

mkmat T10_B50 T10_B50_inc5 T10_B50_inc5ours ///
	if decile_num == 1 & !mi(T10_B50_inc5) & central & (etude != 3 | percentile==1), ///
	matrix(T10_B50) rownames(ccyy_f)

frmttable using T10_B50_brut.tex, statmat(T10_B50) ///
	sdec(3) varlabels tex fragment nocenter replace ///
	ctitles("" "Disposable income" "Post-Tax (bottom-up approach)" ///
	"Post-Tax (ITRC)")
filefilter T10_B50_brut.tex T10_B50.tex, from("\BS_") to(" ") replace

gen effet_taxes = T10_B50_inc5 - T10_B50
gen effet_taxes_ours_rescaled = T10_B50_inc5ours_rescaled - T10_B50
gen effet_taxes_ours = T10_B50_inc5ours - T10_B50

graph bar (first) effet_taxes  effet_taxes_ours_rescaled effet_taxes_ours ///
	if central, nofill ///
	over(ccyy_f, label(angle(forty_five))) legend(order(1 "Bottom-up approach" ///
	2 "Constant effective tax rate" 3 "Constant ITRC"))
graph export decompo_level_bundle.eps, as(eps) preview(off) replace
