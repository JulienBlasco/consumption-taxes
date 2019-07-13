* updated 06/07/2017 to add actual rents
* updated 31/07/2017 to harmonize with scaling
* updated 19/07/2018 to add some country-years

/* CHANGE DIRECTORY */
cd "G:"

cd ".\Code\18-07-27 Datasets V5\Implicit tax rates"

/* import final consumption expenditure and merge other datasets */
use ".\DTA\18-07-27 OECD_consumption.dta", clear

merge 1:1 cname year using ".\DTA\18-07-27 OECD_government_expenditure.dta", nogenerate
merge 1:1 cname year using ".\DTA\18-07-27 OECD_taxes.dta", nogenerate
merge 1:1 cname year using ".\DTA\18-07-27 OECD_imprent.dta", nogenerate

gen oecd_rents = cond( !mi(oecd_P31CP041) & !mi(oecd_P31CP042), ///
					  oecd_P31CP041 + oecd_P31CP042, ///
					  oecd_P31CP040)
gen oecd_rents_def = cond(!mi(oecd_P31CP041) & !mi(oecd_P31CP042), 0, ///
					 cond(!mi(oecd_P31CP040), 1, .))
label define oecd_rents_def 0 "P31CP041 + P31CP042" 1 "P31CP040"
label values oecd_rents_def oecd_rents_def

gen oecd_private_expenditure = cond( !mi(oecd_P31S14_S15), oecd_P31S14_S15, oecd_P31S14)
gen oecd_private_expenditure_def = mi(oecd_P31S14_S15)
label define oecd_private_expenditure_def 0 "P31S14_S15" 1 "P31S14"
label values oecd_private_expenditure_def oecd_private_expenditure_def

										 
/* generate implicit tax rates as defined in the literature */
// First definition: we remove all rents from consumption
gen itrc_carey_wor_obs = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_P3-oecd_rents)
gen itrc_euro_wor_obs = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_private_expenditure-oecd_rents)
gen itrc_ours_wor_obs = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_P3-oecd_D1CG-oecd_rents)

// Second definition: we only remove imputed rents
gen itrc_carey_obs = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_P3-oecd_P31CP042)
gen itrc_euro_obs = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_private_expenditure-oecd_P31CP042)
gen itrc_ours_obs = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_P3-oecd_D1CG-oecd_P31CP042)

// Third definition: we take whole consumption
gen itrc_carey_whole = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_P3)
gen itrc_euro_whole = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/ ///
	(oecd_private_expenditure)

	
label define itrc_def 0 "actual" 1 "predicted"

// Predict itrcs based on the whole version
foreach type in carey euro {
	reg itrc_`type'_wor_obs itrc_`type'_whole
	predict itrc_`type'_wor_pred
	
	gen itrc_`type'_wor = cond(!mi(itrc_`type'_wor_obs), itrc_`type'_wor_obs, itrc_`type'_wor_pred)
	gen itrc_`type'_wor_def = cond(!mi(itrc_`type'_wor_obs), 0, ///
							  cond(!mi(itrc_`type'_wor_pred), 1, . ))
	label values itrc_`type'_wor_def itrc_def
}

foreach type in carey euro {
	reg itrc_`type'_obs itrc_`type'_whole
	predict itrc_`type'_pred
	
	gen itrc_`type' = cond(!mi(itrc_`type'_obs), itrc_`type'_obs, itrc_`type'_pred)
	gen itrc_`type'_def = cond(!mi(itrc_`type'_obs), 0, ///
						  cond(!mi(itrc_`type'_pred), 1, . ))
	label values itrc_`type'_def itrc_def
}
*

// Predict itrc_ours from carey
reg itrc_ours_wor_obs itrc_carey_wor
predict itrc_ours_wor_pred
gen itrc_ours_wor = cond(!mi(itrc_ours_wor_obs), itrc_ours_wor_obs, itrc_ours_wor_pred)
gen itrc_ours_wor_def = cond(!mi(itrc_ours_wor_obs), 0, ///
						cond(!mi(itrc_ours_wor_pred), 1, .))
label values itrc_ours_wor_def itrc_def
						
reg itrc_ours_obs itrc_carey
predict itrc_ours_pred
gen itrc_ours = cond(!mi(itrc_ours_obs), itrc_ours_obs, itrc_ours_pred)
gen itrc_ours_def = cond(!mi(itrc_ours_obs), 0, ///
						cond(!mi(itrc_ours_pred), 1, .))
label values itrc_ours_def itrc_def


save ".\DTA\18-07-27 OECD_itrcs.dta", replace
