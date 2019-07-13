* updated 31/08/2018 to change paths

/* CHANGE DIRECTORY */
cd "G:"

cd ".\Code\18-07-27 Datasets V5\Itrcs scalings"

use ".\Scaling\DTA\18-08-31 oecd_scalings.dta", clear
merge 1:1 cname year using ".\Implicit tax rates\DTA\18-07-27 OECD_itrcs.dta", nogenerate

save "./18-08-31_itrcs_scalings.dta", replace
