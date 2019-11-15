use "D:\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\19-08-23 V6 fr10 summaries egap 0-1-2.dta", clear
keep extreme_gap Gini_pre Gini_ours Gini_ours_wor
replace extreme_gap = "1" in 2
replace extreme_gap = "2" in 3
reshape wide Gini_ours_wor , i( Gini_pre Gini_ours ) j(extreme_gap ) string

label variable Gini_pre "Disposable income"
label variable Gini_ours "Post-tax with constant rate on whole consumption"
label variable Gini_ours_wor0 "Post-tax with constant rate on non-rent consumption"
label variable Gini_ours_wor1 "Post-tax with progressive rate (medium scenario)"
label variable Gini_ours_wor2 "Post-tax with progressive rate (extreme scenario)"

graph dot (asis) Gini_ours Gini_ours_wor0 Gini_ours_wor1 Gini_ours_wor2 Gini_pre, ///
exclude0 marker(1, msize(large)) marker(2, msize(large) msymbol(square)) ///
marker(3, msize(large) msymbol(triangle)) marker(4, msize(large) msymbol(diamond)) ///
marker(5, msize(large) msymbol(lgx)) legend(cols(1)) graphregion(fcolor(white))

import delimited "D:\BLASCOLIEPP\Code\19-08-21 Datasets V6\CSV\19-08-23 V6 fr10 qu20 egap 0-1-2.csv", clear 
keep extremegap quantile dhi tax_eff_ours tax_eff_ours_wor
reshape wide tax_eff_ours_wor , i(quantile dhi tax_eff_ours ) j(extremegap )
twoway line tax_eff* quantile
reshape long
gen global_rate = tax_eff_ours/dhi
gen global_rate_wor = tax_eff_ours_wor /dhi
reshape wide tax_eff_ours_wor global_rate_wor , i(quantile dhi tax_eff_ours global_rate ) j(extremegap )

label variable global_rate "Constant rate on whole consumption"
label variable global_rate_wor0 "Constant rate on non-rent consumption"
label variable global_rate_wor1 "Progressive rate (medium scenario)"
label variable global_rate_wor2 "Progressive rate (extreme scenario)"

twoway (line global_rate quantile) (line global_rate_wor0 quantile) ///
(line global_rate_wor1 quantile) (line global_rate_wor2 quantile), ///
yscale(range(0 0.3)) xtitle(Income vingtile) ytitle(Tax-to-income ratio) ///
graphregion(fcolor(white)) legend(cols(1)) xsize(5.5) ysize(5.5) scale(0.8) yla(0(0.05)0.35) 

// version by decile of income
gen decile = ceil(quantile/2)
collapse dhi tax_eff_ours tax_eff_ours_wor0 tax_eff_ours_wor1 tax_eff_ours_wor2, by(decile)
reshape long tax_eff, i(decile dhi) j(def, string)
gen global_rate = tax_eff/dhi
reshape wide
reshape wide tax_eff global_rate, i(decile dhi) j(def, string)

label variable global_rate_ours "Constant rate on whole consumption"
label variable global_rate_ours_wor0 "Constant rate on non-rent consumption"
label variable global_rate_ours_wor1 "Progressive rate (1 % point between ends)"
label variable global_rate_ours_wor2 "Progressive rate (2 % points between ends)"

twoway (line global_rate_ours decile) (line global_rate_ours_wor0 decile) ///
(line global_rate_ours_wor1 decile) (line global_rate_ours_wor2 decile), ///
yscale(range(0 0.3)) xtitle(Income vingtile) graphregion(fcolor(white)) ///
legend(cols(1)) xsize(5.5) ysize(5.5) scale(0.8) 

