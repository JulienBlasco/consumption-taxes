use "G:\DTA\ConsumptionTaxes_percentiles_xtnddmodel_ccyypapier.dta", clear
keep if ccyy == "us13"
sort percentile

gen group = 10 if percentile <= 20
replace group = 30 if percentile > 20 & percentile <= 40
replace group = 50 if percentile > 40 & percentile <= 60
replace group = 70 if percentile > 60 & percentile <= 80
replace group = 88 if percentile > 80 & percentile <= 95
replace group = 97 if percentile > 95 & percentile <= 99
replace group = 100 if percentile == 100

label define groupes 10 "P1-20" 30 "P21-40" 50 "P41-60" 70 "P61-80" 88 "P81-95" 97 "P96-99" 100 "P100"
label values group groupes  

gen taxrate_group_ITEP = 0.071202 if group == 10
replace taxrate_group_ITEP = 0.059358 if group == 30
replace taxrate_group_ITEP = 0.047539 if group == 50
replace taxrate_group_ITEP = 0.037639 if group == 70
replace taxrate_group_ITEP = 0.027392 if group == 88
replace taxrate_group_ITEP = 0.016966 if group == 97
replace taxrate_group_ITEP = 0.008738 if group == 100

merge m:1 cname year using "G:\Itrcs scalings\18-08-31_itrcs_scalings.dta", ///
keep(match) keepusing(oecd_5110 oecd_5121 oecd_P3 oecd_D1CG oecd_P31CP042 oecd_rents itrc_ours)

gen itrc_ours_salesexc = (oecd_5110+oecd_5121)/ ///
	(oecd_P3-oecd_D1CG-oecd_P31CP042)

gen tax_ours_salesexc = itrc_ours_salesexc * tcons_pred
gen tax_ours = itrc_ours * tcons_pred

egen tax_group_ours = mean(tax_ours), by(group)
egen tax_group_salesexc = mean(tax_ours_salesexc), by(group)

egen dhi_group = mean(dhi), by(group)
gen taxrate_group_ours = tax_group_ours/dhi_group
gen taxrate_group_salesexc = tax_group_salesexc/dhi_group

// tax_eff et inc5
gen tax_eff = dhi * taxrate_group_ITEP
gen tax_eff_ours = dhi * taxrate_group_ours
gen tax_eff_salesexc = dhi * taxrate_group_salesexc
drop inc5
gen inc5 = dhi - tax_eff
gen inc5_ours = dhi - tax_eff_ours
gen inc5_salesexc = dhi - tax_eff_salesexc

gen decile_num = group/10

rename taxrate_group_ours tax_prop_ours 
rename taxrate_group_salesexc rescaled_tax_prop_ours
rename taxrate_group_ITEP tax_prop

twoway line *tax_prop* decile_num

// rapport T10/B50
sum dhi if percentile >= 91
local T10 = r(sum)
sum dhi if percentile <= 50
local B50 = r(sum)
gen T10_B50 = `T10'/`B50'

sum inc5 if percentile >= 91
local T10_inc5 = r(sum)
sum inc5 if percentile <= 50
local B50_inc5 = r(sum)
gen T10_B50_inc5ITEP = `T10_inc5'/`B50_inc5'

sum inc5_ours if percentile >= 91
local T10_inc5ours = r(sum)
sum inc5_ours if percentile <= 50
local B50_inc5ours = r(sum)
gen T10_B50_inc5ours = `T10_inc5ours'/`B50_inc5ours'

sum inc5_salesexc if percentile >= 91
local T10_inc5salesexc = r(sum)
sum inc5_salesexc if percentile <= 50
local B50_inc5salesexc = r(sum)
gen T10_B50_inc5salesexc = `T10_inc5salesexc'/`B50_inc5salesexc'

graph dot (asis) T10_B50 T10_B50_inc5ITEP T10_B50_inc5ours T10_B50_inc5salesexc ///
	if percentile == 1, over(ccyy_f)

list T10_B50 T10_B50_inc5ITEP T10_B50_inc5ours T10_B50_inc5salesexc ///
	if percentile == 1, ab(20)

rename T10_B50_inc5ITEP T10_B50_inc5
rename T10_B50_inc5salesexc T10_B50_inc5ours_rescaled
	
notes: Created TS
save "G:\DTA\comparaison_euromod\US_ITEP.dta", replace
