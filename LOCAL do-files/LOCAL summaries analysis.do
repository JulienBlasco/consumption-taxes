/* CHANGE DIRECTORY */
cd "G:"

use ".\Code\18-07-27 Datasets V5\DTA\18-09-14 summaries V5 mod1 ours.dta", clear

// see if scaling is effective
twoway (scatter apc_lis oecd_prop, mlabel(ccyy)) || (function y=x, range(oecd_prop))

// compare average taxation in LIS and macro
gen global_tax_rate_ours_pred = tax_eff_ours_pred_mean / dhi_mean
gen global_tax_rate_ours = tax_eff_ours_mean/dhi_mean
gen macro_global_tax_rate_ours_pred = oecd_prop * itrc_ours
gen macro_global_tax_rate_ours = oecd_prop * itrc_ours

twoway (scatter global_tax_rate_ours macro_global_tax_rate_ours, ///
mlabel(ccyy)) || (function y=x, range(macro_global_tax_rate_ours ))

rename RS_ours_pred RS_ours_pred1 
rename G_diff_ours_pred G_diff_ours_pred1
gen kak_pred = hmc_pred_scaled_conc_dhi -Gini_pre
rename kak_pred kak_pred1
keep ccyy RS_ours_pred1 G_diff_ours_pred1 kak_pred1 

graph dot (asis) kak_pred kak_pred1 kak_ours if year>2000&!mi(kak_ours), ///
			over(ccyy, sort(kak_ours))

// plot indicators of redistribution and progressivity
graph dot (asis) RS_ours_pred RS_ours_pred1 RS_ours if year>2000&!mi(RS_ours), ///
			over(ccyy, sort(RS_ours))

graph dot (mean) G_diff_ours_pred G_diff_ours_pred1 G_diff_ours if cname=="United Kingdom", ///
			over(year, sort(RS_ours))
			
graph dot (mean) G_diff_ours_pred G_diff_ours_pred1 G_diff_ours if !mi(G_diff_ours), ///
			over(cname, sort(G_diff_ours))
			
gen diff1 = abs(G_diff_ours_pred1 - G_diff_ours)
gen diff2 = abs(G_diff_ours_pred - G_diff_ours)

graph dot (mean) diff1 diff2 if !mi(G_diff_ours), ///
			over(cname, sort(G_diff_ours))

graph dot (mean) G_diff_ours_pred G_diff_ours if !mi(G_diff_ours), ///
			over(cname, sort(G_diff_ours))
			
graph dot (asis) G_diff_ours_pred G_diff_ours_pred1 G_diff_ours if year>2000&!mi(G_diff_ours), ///
			over(ccyy, sort(RS_ours))
			
// plot indicators of redistribution and progressivity
graph dot (asis) G_diff_ours_pred if year==2010&!mi(RS_ours_pred), ///
			over(cname, sort(G_diff_ours_pred))
			
graph export ".\Code\18-03-07 Datasets V4\18-03-18 Réponse conf Science Po\18-03-18 gini diff 2010.png", ///
	as(png) replace

// plot indicators of redistribution and progressivity
graph dot (asis) RS_ours_pred G_diff_ours_pred if year==2000&!mi(RS_ours_pred), ///
			over(cname, sort(G_diff_ours_pred))
			
twoway 	(scatter kak_pred G_diff_ours_pred, msize(small) mlabel(cname)) ///
			if !mi(G_diff_ours_pred)&year==2004&ccyy!="uk04"
			
// plot progressivity VS redistribution
twoway 	(scatter kak_ours G_diff_ours, msize(small) mlabel(ccyy)) ///
		|| (scatter kak_pred G_diff_ours_pred, msize(small) mlabel(ccyy)) ///
	//	|| (lfit kak_ours_pred G_diff_ours_pred) ///
			if !mi(G_diff_ours)

// plot average tax rate VS redistribution
twoway 	(scatter global_tax_rate_ours_pred G_diff_ours_pred, msize(small) mlabel(ccyy)) ///
		|| (lfit global_tax_rate_ours_pred G_diff_ours_pred) ///
			if year==2004&!mi(RS_ours_pred)

// plot average tax rate VS progressivity
twoway 	(scatter global_tax_rate_ours_pred kak_ours_pred, msize(small) mlabel(ccyy)) ///
		|| (lfit global_tax_rate_ours_pred kak_ours_pred) ///
			if year==2004&!mi(RS_ours_pred)&ccyy!="uk04"

**** lets find the corrupted hmchous and hchous ****
gen effort_rate = hchous_mean /dhi_mean
gen meffort_rate = hmchous_mean /dhi_mean

graph dot (asis) effort_rate meffort_rate if year==2004, over(cname, sort(effort_rate))

graph dot (asis) effort_rate meffort_rate, ///
over(ccyy, sort(effort_rate) label(labsize(minuscule))) ///
marker(1, msize(vsmall)) marker(2, msize(vsmall)) linetype(line) lines(lwidth(vvvthin))

graph export ".\Code\12-24 Datasets V2\01-09 effort rates.pdf", as(pdf) replace

graph dot (asis) effort_rate meffort_rate if inlist(cname,"United Kingdom", ///
									"United States", "Estonia", "Denmark"), ///
over(ccyy, sort(effort_rate) label(labsize(tiny))) ///
marker(1, msize(small)) marker(2, msize(small)) linetype(line) lines(lwidth(vvvthin))

graph dot (asis) effort_rate meffort_rate if inlist(cname,"United Kingdom", "Uruguay", ///
"United States", "Spain", "Italy", "Ireland"), ///
over(ccyy, sort(meffort_rate) label(labsize(tiny))) ///
marker(1, msize(small)) marker(2, msize(small)) linetype(line) lines(lwidth(vvvthin))

// 09/01/2018 check de la formule de lencadre REDINEQ
gen RS_calcule_ours_pred = -global_tax_rate_ours_pred /(1-global_tax_rate_ours_pred ) * kak_pred
twoway (scatter RS_calcule_ours_pred RS_ours_pred) (function y=x, range(RS_ours_pred )) if !mi(RS_calcule_ours_pred )

gen RS_calcule_ours = -global_tax_rate_ours /(1-global_tax_rate_ours ) * kak
twoway (scatter RS_calcule_ours RS_ours, mlabel(ccyy)) (function y=x, range(RS_ours )) if !mi(RS_calcule_ours )

// 25/01/2019 pays sur la map des RS et itrc
gen pos_kak = -kak
twoway scatter RS_ours pos_kak  if !mi(kak)&!mi(RS_ours)&the_year_obs, mlabel(ccyy ) ///
|| function vat_10 = 0.1/0.9*x, range(0 0.2) ///
|| function vat_15 = 0.15/0.85*x, range(0 0.2) ///
|| function vat_20 = 0.20/0.8*x, range(0 0.2) ///
|| function vat_25 = 0.25/0.75*x, range(0 0.2) ///
|| function vat_30 = 0.3/0.7*x, range(0 0.2)

* dot graph redistribution
graph dot (asis) G_diff_ours_pred if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), over(cname, sort(G_diff_ours_pred) descending)

*twoway graph redis itrc
twoway (scatter G_diff_ours_pred itrc_ours if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), mlabel("cname")) || (lfit G_diff_ours_pred itrc_ours)


* dot graph redistribution
graph dot (asis) Gini_pre Gini_ours_pred if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), over(cname, sort(Gini_pre) descending)

* difference reranking rs
twoway scatter RS_ours G_diff_ours if !mi(G_diff_ours)&the_year_obs, mlabel(ccyy_f) ///
|| function y=x, range(G_diff_ours)

* prediction error 
graph dot (asis) Gini_pre Gini_ours_pred Gini_ours if !mi(G_diff_ours)&the_year_obs ///
& !mi(G_diff_ours_pred), over(ccyy_f, sort(Gini_pre) descending)

*GRAPH CENTRAL REDISTRIBUTION
keep if (year==2010|ccyy=="dk04"|ccyy=="uk13")&!mi(G_diff_ours_pred)

/*
values factor income
ccyy	dhi_conc_dhi	factor_conc_factor
au10	0.3308726	0.49322543
at10	0.27921017	0.49851322
cz10	0.25633	0.45915372
dk04	0.22843617	0.45373421
ee10	0.31902081	0.49148449
fr10	0.28593346	0.49853509
de10	0.28489652	0.52044401
gr10	0.32188235	0.52248123
is10	0.23873578	0.38577343
mx10	0.46167822	0.52897743
nl10	0.25440429	0.46586909
pl10	0.32059359	0.5348356
si10	0.25149046	0.41814879
za10	0.67411852	0.74102713
es10	0.32772442	0.5073143
ch10	0.29780398	0.42432502
uk13	0.32130608	0.54051956
us10	0.34185302	0.48930527
*/

graph dot (asis) factor Gini_pre Gini_ours_pred if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), over(cname, sort(Gini_pre) descending) ///
marker(1, msymbol(triangle)) marker(3, msymbol(lgx))

gen redistrib1 = factor - Gini_pre
gen redistrib2 = factor - Gini_ours_pred

*twoway graph redis itrc
twoway (scatter redistrib1 itrc_ours if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), mlabel("cname") yscale(range(0 0.25)))

twoway (scatter redistrib1 itrc_ours if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), mlabel("cname")) || (scatter redistrib2 itrc_ours if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), mlabel("cname"))

twoway (scatter redistrib1 redistrib2 itrc_ours if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred))

twoway (scatter redistrib2 itrc_ours if (year==2010|ccyy=="dk04"|ccyy=="uk13") ///
& !mi(G_diff_ours_pred), mlabel("cname"))