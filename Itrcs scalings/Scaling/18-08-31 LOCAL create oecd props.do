* updated 31/08/2018 to change paths

/* CHANGE DIRECTORY */
cd "G:"

cd ".\Code\18-07-27 Datasets V5\Scaling"

use ".\DTA\18-07-27 OECD_expenditure_disp_income_S14-15.dta", clear
merge 1:1 cname year using ".\DTA\18-07-27 OECD_expenditure_imputed rent.dta", nogen
merge 1:1 cname year using "..\Implicit tax rates\DTA\18-07-27 OECD_imprent.dta", nogen

// rents
gen oecd_rents = cond( !mi(oecd_P31CP041) & !mi(oecd_P31CP042), ///
					  oecd_P31CP041 + oecd_P31CP042, ///
					  oecd_P31CP040)
gen oecd_rents_def = cond(!mi(oecd_P31CP041) & !mi(oecd_P31CP042), 0, ///
					 cond(!mi(oecd_P31CP040), 1, .))
label define oecd_rents_def 0 "P31CP041 + P31CP042" 1 "P31CP040"
label values oecd_rents_def oecd_rents_def


// consumption
gen oecd_adj_cons_S14 = cond(!mi(oecd_P31DC), oecd_P31DC, ///
						cond(!mi(oecd_NFP3PS14), oecd_NFP3PS14, oecd_P31NC))
gen oecd_adj_cons_S14_def = cond(!mi(oecd_P31DC), 0, ///
							cond(!mi(oecd_NFP3PS14), 1, ///
							cond(!mi(oecd_P31NC), 2, .)))
label define oecd_adj_cons_S14_def 0 "P31DC" 1 "NFP3PS14" 2 "P31NC"
label values oecd_adj_cons_S14_def oecd_adj_cons_S14_def

gen oecd_adj_cons_S14_S15 = oecd_NFP3PS14_S15


// income
gen oecd_income_S14 = oecd_NFB6GRS14
gen oecd_income_S14_S15 = oecd_NFB6GRS14_S15


// propensities
gen oecd_real_prop_wor_S14 = (oecd_adj_cons_S14-oecd_rents)/(oecd_income_S14-oecd_P31CP042)
gen oecd_adj_prop_wor_S14 = (oecd_adj_cons_S14-oecd_P31CP041)/oecd_income_S14
gen oecd_real_prop_wor_S14_S15 = (oecd_adj_cons_S14_S15-oecd_rents)/(oecd_income_S14_S15-oecd_P31CP042)
gen oecd_adj_prop_wor_S14_S15 = (oecd_adj_cons_S14_S15-oecd_P31CP041)/oecd_income_S14_S15

gen oecd_prop_wor = cond(!mi(oecd_real_prop_wor_S14), oecd_real_prop_wor_S14, ///
					cond(!mi(oecd_adj_prop_wor_S14), oecd_adj_prop_wor_S14, ///
					cond(!mi(oecd_real_prop_wor_S14_S15), oecd_real_prop_wor_S14_S15, ///
					cond(!mi(oecd_adj_prop_wor_S14_S15), oecd_adj_prop_wor_S14_S15, .))))
gen oecd_prop_wor_def = cond(!mi(oecd_real_prop_wor_S14), 0, ///
						cond(!mi(oecd_adj_prop_wor_S14), 1, ///
						cond(!mi(oecd_real_prop_wor_S14_S15), 2, ///
						cond(!mi(oecd_adj_prop_wor_S14_S15), 3, .))))
label define oecd_prop_wor_def 0 "real S14" 1 "adjusted S14" 2 "real S14_S15" 3 "adjusted S14_S15"
label values oecd_prop_wor_def oecd_prop_wor_def


gen oecd_real_prop_S14 = (oecd_adj_cons_S14-oecd_P31CP042)/(oecd_income_S14-oecd_P31CP042)
gen oecd_adj_prop_S14 = oecd_adj_cons_S14/oecd_income_S14
gen oecd_real_prop_S14_S15 = (oecd_adj_cons_S14_S15-oecd_P31CP042)/(oecd_income_S14_S15-oecd_P31CP042)
gen oecd_adj_prop_S14_S15 = oecd_adj_cons_S14_S15/oecd_income_S14_S15

gen oecd_prop = cond(!mi(oecd_real_prop_S14), oecd_real_prop_S14, ///
				cond(!mi(oecd_adj_prop_S14), oecd_adj_prop_S14, ///
				cond(!mi(oecd_real_prop_S14_S15), oecd_real_prop_S14_S15, ///
				cond(!mi(oecd_adj_prop_S14_S15), oecd_adj_prop_S14_S15, .))))
gen oecd_prop_def = cond(!mi(oecd_real_prop_S14), 0, ///
					cond(!mi(oecd_adj_prop_S14), 1, ///
					cond(!mi(oecd_real_prop_S14_S15), 2, ///
					cond(!mi(oecd_adj_prop_S14_S15), 3, .))))
label define oecd_prop_def 0 "real S14" 1 "adjusted S14" 2 "real S14_S15" 3 "adjusted S14_S15"
label values oecd_prop_def oecd_prop_def

save ".\DTA\18-08-31 oecd_scalings.dta", replace
