cd "C:\Users\julien.blasco\Documents\Perso\Recherche\consumption-taxes\"
cd "G:"

import delimited "CSV\kak.csv", clear 
merge 1:1 ccyy using "DTA\match cname year.dta", keep(match) nogenerate
merge 1:1 cname year using "Itrcs scalings\18-08-31_itrcs_scalings.dta", keep(match) keepusing(itrc_ours)
gen kak = hmc_conc_dhi - gini

twoway (scatter kak itrc_ours), yscale(range(0 -0.3)) xscale(range(0 0.3))

keep if !mi(itrc_ours)

sum kak, de
sum itrc_ours, de
gen kak_norm = kak/(-0.1224386)
gen itrc_ours_norm = itrc_ours/(0.1746376)
sum itrc_ours_norm , de
sum kak_norm, de
gen tau = itrc_ours/(1-itrc_ours)
sum tau, de
gen tau_norm = tau/0.2152341
sum tau_norm, de

twoway (scatter kak_norm itrc_ours_norm, mlabel(ccyy)), yscale(range(0 1.5)) xscale(range(0 1.5))
twoway (scatter kak_norm tau_norm,), yscale(range(0 1.5)) xscale(range(0 1.5))


gen rs = -kak*tau
twoway scatter rs tau

gen kak_pondere = kak * 
