set seed 339487731

use "D:\19-08-21 Datasets V6\DTA\LOCAL datasets\it04ih.dta", clear

preserve

replace dname = "fr10"
replace cname = "France"
replace iso2 = "fr"
replace year = 2010

egen dhi_med = median(dhi)
egen dhi_stdded = sd(dhi)
gen epsilon = 1 + 0.1 * rnormal()
replace hmc = exp(0.1) * 0.9 * dhi_med^0.43 * dhi^0.57 * epsilon

save "D:\19-08-21 Datasets V6\DTA\LOCAL datasets\fr10ih.dta", replace
restore

preserve

replace dname = "au10"
replace cname = "Australia"
replace iso2 = "au"
replace year = 2010

egen dhi_med = median(dhi)
egen dhi_stdded = sd(dhi)
gen epsilon = 1 + 0.12 * rnormal()
replace hmc = exp(0.1) * 0.92 * dhi_med^0.43 * dhi^0.57 * epsilon

save "D:\19-08-21 Datasets V6\DTA\LOCAL datasets\au10ih.dta", replace
restore


use "D:\19-08-21 Datasets V6\DTA\LOCAL datasets\it04ip.dta", clear

preserve

replace dname = "fr10"
replace cname = "France"
replace iso2 = "fr"
replace year = 2010

save "D:\19-08-21 Datasets V6\DTA\LOCAL datasets\fr10ip.dta", replace
restore

preserve

replace dname = "au10"
replace cname = "Australia"
replace iso2 = "au"
replace year = 2010

save "D:\19-08-21 Datasets V6\DTA\LOCAL datasets\au10ip.dta", replace
restore
