import excel "C:\users\julien\Mes documents\BLASCOLIEPP\Code\19-08-21 Datasets V6\CSV\02_08_2019_V6 mod0 summarise inc123 wmean.xlsx", ///
	sheet("02_08_2019_V6 mod0 summarise inc123 wmean") firstrow clear
	
keep ccyy inc1_conc_inc1 inc2_conc_inc2 inc3_conc_inc3 inc4_conc_inc4 scope

merge 1:1 ccyy using "Z:\home\julien\Documents\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\redistribution_data.dta", ///
	 keepusing(inc*_gini)  keep(match) nogenerate
merge 1:1 ccyy using "Z:\home\julien\Documents\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\match cname year.dta", ///
	 keep(master match) nogenerate

order ccyy cname year
order inc*, after(year) alphabetic

rename (inc1_conc_inc1 inc2_conc_inc2 inc3_conc_inc3 inc4_conc_inc4 ) ///
	(inc1_gini_TVA inc2_gini_TVA inc3_gini_TVA inc4_gini_TVA)

gen inc1_diff = abs(inc1_gini  - inc1_gini_TVA )

// graphes

graph dot (asis) inc1_diff , over(ccyy, sort(inc1_diff ) label(labsize(tiny)))
twoway scatter scope inc1_diff, mlabel(ccyy)
 

// dataset long : une observation pour la valeur TVA et une obs pour REDINEQ
preserve
drop inc1_diff 
reshape long inc1 inc2 inc3 inc4 , i(ccyy cname year) j(dataset, string)
graph dot (asis) inc* if ccyy=="nl04" , over(dataset)

// dataset wide : valeurs TVA et REDINEQ sur la même observation 
restore

