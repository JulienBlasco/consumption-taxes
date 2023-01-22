cd "G:"

set scheme plotplaincolor

use ".\DTA\20_11_2022_heter mod2 summaries ccyy_fig13.dta", clear
keep ccyy_f Gini_ours_pred Gini_ours
rename (Gini_ours_pred Gini_ours) =_mod2_h

merge 1:1 ccyy_f using ".\DTA\20_11_2022_heter mod1 summaries ccyy_fig13.dta", keepusing(Gini_ours_pred Gini_ours)
rename (Gini_ours_pred Gini_ours) =_mod1_h
keep if _merge == 3
drop _merge

merge 1:1 ccyy_f using ".\DTA\20_11_2022 mod2 summaries.dta", keepusing(Gini*)
rename (Gini_ours_pred Gini_ours) =_mod2
keep if _merge == 3
drop _merge

merge 1:1 ccyy_f using ".\DTA\20_11_2022 mod1 summaries.dta", keepusing(Gini_ours Gini_ours_pred)
rename (Gini_ours_pred Gini_ours) =_mod1
keep if _merge == 3

gen Gini_ours = Gini_ours_mod2
replace Gini_ours = Gini_ours_mod1 if mi(Gini_ours)
gen Gini_ours_h = Gini_ours_mod2_h
replace Gini_ours_h = Gini_ours_mod1_h if mi(Gini_ours_h)
gen Gini_ours_pred = Gini_ours_pred_mod2
replace Gini_ours_pred = Gini_ours_pred_mod1 if mi(Gini_ours_pred)
gen Gini_ours_pred_h = Gini_ours_pred_mod2_h
replace Gini_ours_pred_h = Gini_ours_pred_mod1_h if mi(Gini_ours_pred_h)

gen Gini_inc5 = Gini_ours
replace Gini_inc5 = Gini_ours_pred if mi(Gini_ours)
gen Gini_inc5_h = Gini_ours_h
replace Gini_inc5_h = Gini_ours_pred_h if mi(Gini_ours_h)

// Figure 4: Gini of market, gross, disposable and post tax income
graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5 Gini_inc5_h, ///
	over(ccyy_f, sort(Gini_inc5) descending) ytitle(Gini index of income inequality)	///
	marker(4, msize(medsmall) msymbol(plus)) marker(5, msymbol(lgx)) exclude0 
	
	///
	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income (uniform)" 5 "Post-Tax Income (heterogenous)"))

list ccyy_f Gini_inc2 Gini_inc3 Gini_pre Gini_inc5 Gini_inc5_h

list ccyy_f Gini_ours_mod1 Gini_ours_h


graph dot (asis) Gini_ours_pred_mod1 Gini_ours_pred_mod1_h, ///
	over(ccyy_f, sort(Gini_inc5) descending) ytitle(Gini index of income inequality)	///
	marker(4, msize(medsmall) msymbol(plus)) marker(5, msymbol(lgx)) exclude0 
	
graph dot (asis) Gini_ours_pred_mod2 Gini_ours_pred_mod2_h, ///
	over(ccyy_f, sort(Gini_inc5) descending) ytitle(Gini index of income inequality)	///
	marker(4, msize(medsmall) msymbol(plus)) marker(5, msymbol(lgx)) exclude0 
