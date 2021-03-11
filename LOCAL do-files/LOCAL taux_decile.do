preserve
keep if ccyy=="fr10"
gen decile = ceil(percentile/10)
collapse tax, by(decile)
twoway scatter tax decile
clist

preserve
keep if ccyy=="fr10"
gen decile = ceil(percentile/10)
collapse tax tcons, by(decile)
gen taux_apparent = tax/tcons
twoway scatter taux_apparent decile
clist
