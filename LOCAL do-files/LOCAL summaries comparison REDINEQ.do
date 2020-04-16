import excel "C:\users\julien\Mes documents\BLASCOLIEPP\Code\19-08-21 Datasets V6\CSV\02_08_2019_V6 mod0 summarise inc123.xlsx", ///
	sheet("02_08_2019_V6 mod0 summarise inc123") firstrow clear
	
keep ccyy inc1_conc_inc1 inc2_conc_inc2 inc3_conc_inc3 inc4_conc_inc4 

merge 1:1 ccyy using "Z:\home\julien\Documents\BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\redistribution_data.dta", ///
	keep(match) keepusing(*_gini) nogenerate
	
order inc*, after(ccyy) alphabetic

