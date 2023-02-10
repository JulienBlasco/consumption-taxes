if 0 { // ON LIS
	local ccyylist ee00 fr78 fr84 fr89 fr00 fr05 fr10 it95 it98 it00 ///
	it04 it08 it10 mx08 mx10 mx12 pl07 pl10 pl13 si97 si99 si04 si07 ///
	si10 si12 za08 za10 za12 ch00 ch02 ch04 uk95

	gen ccyy = ""
	foreach ccyy in `ccyylist' {   
		qui append using $`ccyy'h, generate(appending) nolabel nonotes ///   
		keep(cname year dhi hmc hwgt)
		qui replace ccyy = "`ccyy'" if appending == 1   
		qui drop appending   
	}

	egen dhi_mean = wtmean(dhi),  by(ccyy)  weight(hwgt) 
	egen hmc_mean = wtmean(dhi),  by(ccyy)  weight(hwgt) 

	keep ccyy cname year dhi_mean hmc_mean
	duplicates drop

	 l, compress abbreviate(32) noobs table divider separator(0)
}
 
// LOCAL
import delimited "./CSV/propensions_micro.csv", clear delimiter("|", collapse)
merge 1:1 cname year using "Itrcs scalings/18-08-31_itrcs_scalings", keep(match)

gen prop_micro = hmc_mean /dhi_mean 
gen scaling = prop_micro/oecd_prop
list oecd_prop prop_micro if !mi( oecd_prop) & !mi(prop_micro)
sum(scaling), de
list ccyy prop_micro oecd_prop scaling

sort cname year

graph bar (last) prop_micro oecd_prop, over(cname, label(alternate)) ///
legend(order(1 "Propension micro" 2 "Propension macro"))

graph bar (last) scaling, over(cname, label(alternate)) ///
ytitle("Missing consumption (%)")
