/* CHANGE DIRECTORY */
cd "D:"
use "\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\24_04_2022 summaries model 0.dta", clear
append using ///
	"\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\24_04_2022 summaries model 1.dta" ///
	"\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\24_04_2022 summaries model 2.dta" ///
	, generate(model)

gen G_error = abs(Gini_ours_pred - Gini_ours)
	
preserve
keep ccyy* cname year G* model
reshape wide G*, i(ccyy) j(model)

list ccyy G_error* if G_error0 <.

graph dot (asis) G_error?  if (G_error1 < G_error2 & G_error2<.), over(ccyy, sort(G_error2))
