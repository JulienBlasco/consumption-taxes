use "G:\DTA\comparaison_euromod\comparaison_euromod.dta", clear
cd "N:\Réponse"

gen effet_taxes = T10_B50_inc5 - T10_B50
gen effet_taxes_ours_rescaled = T10_B50_inc5ours_rescaled - T10_B50
gen effet_taxes_ours = T10_B50_inc5ours - T10_B50

// taux d'effort par décile
twoway line tax_prop tax_prop_ours decile_num ///
	if decile_num != 11 & tax_prop_ours < 0.4 & central, ///
	graphregion(fcolor(white)) legend(order(1 "BUA approach" 2 "ITRC (our method)")) ///
	by(ccyy_f etude) yscale(range(0 0.1))
		
graph export images/taux_effort_central.eps, as(eps) preview (off) replace

twoway (line tax_prop rescaled_tax_prop_ours decile_num) || (scatteri 0 5, msymbol(none)) ///
	if decile_num != 11 & tax_prop_ours < 0.4 & central, ///
	by(ccyy_f etude, rescale) legend(order(1 "BUA approach" 2 "ITRC (our method)"))
		
graph export images/taux_effort_central_rescaled.eps, as(eps) preview (off) replace

// différences de niveau
graph dot (asis) effective_tax* if central & decile_num == 11, ///
	over(ccyy_f, sort(effective_taxrate_ours)) nofill	///
	legend(order(1 "BUA approach" 2 "ITRC (our method)"))
	
graph export images/eff_taxrate_central.eps, as(eps) preview (off) replace

	
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

	frmttable using tables/interdeciles2.tex, statmat(interdeciles) ///
		sdec(2) varlabels tex fragment nocenter replace ///
		ctitles("" "D5/D1" "" "D10/D5" "" "D10/D1" "" \ ///
		"" "Euromod" "ITRC" "Euromod" "ITRC" "Euromod" "ITRC") ///
		multicol(1,2,2; 1,4,2; 1,6,2) vlines(000{10}0)
	filefilter tables/interdeciles2.tex tables/interdeciles.tex, ///
		from("\BS_") to(" ") replace

		
	graph dot (asis) ecart_D10_D1 ecart_ours_D10_D1 ecart_D9_D2 ecart_ours2_D9_D2 ///
		if central, over(ccyy_f, sort(ecart_D9_D2)) ///
		marker(1, msymbol(T) mcolor(navy)) marker(2, msymbol(T) mcolor(maroon)) ///
		marker(3, msymbol(O) mcolor(navy)) marker(4, msymbol(O) mcolor(maroon))
		
	graph export images/interdecile_effort_central.eps, as(eps) preview (off) replace
restore

 
// T10 et B50
graph dot (first) T10_B50 T10_B50_inc5 T10_B50_inc5ours if central ///
	, over(ccyy_f) nofill ///
	marker(1, msymbol(x)) marker(2, msymbol(x)) marker(3, msymbol(x))
graph export images/t10_b50.eps, as(eps) preview (off) replace

mkmat T10_B50 T10_B50_inc5 T10_B50_inc5ours ///
	if decile_num == 1 & !mi(T10_B50_inc5) & central & (etude != 3 | percentile==1), ///
	matrix(T10_B50) rownames(ccyy_f)

frmttable using tables/T10_B50_brut.tex, statmat(T10_B50) ///
	sdec(3) varlabels tex fragment nocenter replace ///
	ctitles("" "Disposable income" "Post-Tax (bottom-up approach)" ///
	"Post-Tax (ITRC)")
filefilter tables/T10_B50_brut.tex tables/T10_B50.tex, from("\BS_") to(" ") replace

graph bar (first) effet_taxes_ours effet_taxes  effet_taxes_ours_rescaled ///
	if central, nofill ///
	over(ccyy_f, label(angle(forty_five))) legend(order( ///
	1 "Constant ITRC (our methodology)" ///
	2 "Bottom-up approach without bundle effect (constant effective tax rate)" ///
	3 "Bottom-up approach (including bundle effect)") cols(1))
graph export images/decompo_level_bundle.eps, as(eps) preview(off) replace
