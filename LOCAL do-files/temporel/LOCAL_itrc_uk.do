// chute de l'ITRC entre 95 et 07 alors que taux stable
tableau_tva United Kingdom

twoway line itrc_ours year if cname =="United Kingdom" & year >= 1995 & year <= 2007

// dynamiques des recettes et tax base
gen recettes = (oecd_5110+oecd_5121+oecd_5122+oecd_5123+oecd_5126+oecd_5128+oecd_5200)/GDP
gen tax_base = (oecd_P3-oecd_D1CG-oecd_P31CP042)/GDP

twoway line itrc_ours year if cname =="United Kingdom" & year >= 1995 & year <= 2007

use "G:\Itrcs scalings\Implicit tax rates\DTA\18-07-27 OECD_itrcs.dta", clear
merge 1:1 year cname using ///
	"G:\LOCAL do-files\temporel\price_index_UK"

gen cpi_base = cpi[1218]
replace cpi = cpi/cpi_base
	
gen stacked_oecd_5110 = oecd_5110/(oecd_P3-oecd_D1CG-oecd_P31CP042)
gen stacked_oecd_5121 = oecd_5121/(oecd_P3-oecd_D1CG-oecd_P31CP042) + stacked_oecd_5110
gen stacked_oecd_5122 = oecd_5122/(oecd_P3-oecd_D1CG-oecd_P31CP042) + stacked_oecd_5121
gen stacked_oecd_5123 = oecd_5123/(oecd_P3-oecd_D1CG-oecd_P31CP042) + stacked_oecd_5122
gen stacked_oecd_5126 = oecd_5126/(oecd_P3-oecd_D1CG-oecd_P31CP042) + stacked_oecd_5123
gen stacked_oecd_5128 = oecd_5128/(oecd_P3-oecd_D1CG-oecd_P31CP042) + stacked_oecd_5126
gen stacked_oecd_5200 = oecd_5200/(oecd_P3-oecd_D1CG-oecd_P31CP042) + stacked_oecd_5128

twoway area stacked_oecd_5200 stacked_oecd_5128 stacked_oecd_5126 stacked_oecd_5123 ///
	stacked_oecd_5122 stacked_oecd_5121 stacked_oecd_5110      ///
	year if cname == "United Kingdom" & year > 1995 & year <= 2007, yscale(range(0 0))

preserve
keep if cname == "United Kingdom"  & year > 1995 & year <= 2007
gen taxes_5110 = oecd_5110
gen taxes_5120 = oecd_5121 + oecd_5122 + oecd_5123 + oecd_5126 + oecd_5128
replace taxes_5120 = taxes_5120 // *cpi si on veut voir l'effet prix relatifs
gen taxes_5200 = oecd_5200
reshape long taxes_, i(year) j(tax)

label define label_conso ///
	5110 "VAT (5110)" ///
	5120 `" "Taxes on specific goods" "and services" "(5121, 5122, 5123, 5126, 5128)" "' ///
	5200 "Taxes on use of goods and perform activities"
label values tax label_conso

replace taxes_ = taxes_/(oecd_P3-oecd_D1CG-oecd_P31CP042)
twoway line taxes_ year, by(tax) ymtick(##5)
