*******************
* Julien Blasco
* 01 August 2017
* modified 27 November 2017
* modified 24 December 2017
* modified 14 January 2018 to compute "kakwani of the propension"
* modified 15 January 2018 to handle missing values and rescale hmchous
* modified 07 March 2018 to add some ccyy
* modified 31 August 2018 to change paths and rationalize summaries and change poverty_line
* modified 07 September to retrieve only ours summaries and remove props
* modified 09 September to change availability matrix
* modified 28 September to rationalize computation of percentiles and add quiet
* modified 02 February to add a hmc_conditionned dhi Gini
* modified 07 July to remove gap at poverty rate in model
* modified 02 August to allow
*	- saving regression models
*	- different consumption tax rates depending on income percentile
*	- crossvalidation
*	- comparison of different models
*******************

quiet {
/********************************
* DEFINITION OF MACRO VARIABLES *
*********************************/
/****************************************************
* I. independent variables in the econometric model *
****************************************************/
global depvars 										///
		i.nhhmem_top	i.nhhmem65_top 	i.single_senior ///   
		i.nearn_top 	i.hpartner_agg 	i.own_agg

		
/*****************************************
* II. variables in the summaries dataset *
*****************************************/

* II. a) Observed variables *

// means
global summeanvars_obs 											///
	hmc	dhi	hmchous	hchous 										///
	hmc_wor_scaled		hmc_scaled 			/*					///  
	prop_scaled  		prop_wor_scaled 		*/				

// concentration indices
global sumondhivars_obs 									///
	dhi 				hmc					hmc_wor			/// 
	tax_eff_ours 		tax_eff_ours_wor 					///  
	/* inc_5_carey 		inc_5_euro 	*/		inc_5_ours 		///  
	/* inc_5_carey_wor 	inc_5_euro_wor */		inc_5_ours_wor		

// Gini indices
global sumonvarvars_obs 								///
	/* inc_5_carey 		inc_5_euro 	*/	inc_5_ours 		///  
	/* inc_5_carey_wor 	inc_5_euro_wor */	inc_5_ours_wor  


* II. b) Predicted (imputed) variables *

// means
global summeanvars_pred 													///
	hmc_wor_pred_scaled 	hmc_pred_scaled 			/*					///  
	prop_pred_scaled  		prop_wor_pred_scaled 			*/				

// concentration indices
global sumondhivars_pred 													///
	hmc_medianized_predict  	hmc_wor_pred  								///
	tax_eff_ours_pred 			tax_eff_ours_wor_pred						/// 
	/* inc_5_carey_pred 		inc_5_euro_pred 	*/	inc_5_ours_pred 		///  
	/* inc_5_carey_wor_pred 	inc_5_euro_wor_pred */	inc_5_ours_wor_pred	

// Gini indices
global sumonvarvars_pred 											///
	/* inc_5_carey_pred 		inc_5_euro_pred */	inc_5_ours_pred 	///  
	/* inc_5_carey_wor_pred 	inc_5_euro_wor_pred */ inc_5_ours_wor_pred  

		
* II. c) Variables in the summaries *
global summeanvars $summeanvars_obs $summeanvars_pred
global sumondhivars $sumondhivars_obs $sumondhivars_pred
global sumonvarvars $sumonvarvars_obs $sumonvarvars_pred
		
/******************************************
* III. variables in the quantiles dataset *
******************************************/

* III. a) Observed variables *

global quvars_obs												///
	hmc	dhi	 hmchous	/* hchous  									///
	hmc_wor_scaled 		hmc_scaled  							///    
	prop_scaled  		prop_wor_scaled 	*/					


* III. b) Predicted (imputed) variables *

global quvars_pred															///
	hmc_medianized_predict			 hmc_wor_pred_scaled 	/*							///  
	prop_pred_scaled  		prop_wor_pred_scaled 		*/					
	
* III. c) Variables in the quantiles
global quvars $quvars_obs $quvars_pred
	
	
/********************
* IV. datasets used *
********************/
{	
global ccyy_to_imput ///
	au81 au85 au89 au95 au01 au03 au08 au10 at87 at97 at00 at04 at07 at10 at13 be85 be88 be92 /// 
 	be97 br06 br09 br11 br13 ca71 ca75 ca81 ca87 ca91 ca94 ca97 ca98 ca00 ca04 ca07 ca10 ca13 /// 
 	cn02 co07 cz92 cz96 cz02 cz04 cz07 cz10 cz13 dk87 dk92 dk95 dk00 dk04 dk07 dk10 dk13 do07 /// 
 	eg12 ee00 ee04 ee07 ee10 ee13 fi87 fi91 fi95 fi00 fi04 fi07 fi10 fi13 fr78 fr84 fr89 fr94 /// 
 	fr00 fr05 fr10 ge10 ge13 de73 de78 de81 de83 de84 de89 de94 de00 de04 de07 de10 de13 gr95 /// 
 	gr00 gr04 gr07 gr10 gr13 gt06 gt11 gt14 hu91 hu94 hu05 hu07 hu09 hu12 is04 is07 is10 in04 /// 
 	in11 ie87 ie94 ie95 ie96 ie04 ie07 ie10 il79 il86 il92 il97 il01 il05 il07 il10 il12 it86 /// 
 	it87 it89 it91 it93 it95 it98 it00 it04 it08 it10 it14 lt10 lt13 lu85 lu91 lu94 lu97 lu00 /// 
 	lu04 lu07 lu10 lu13 mx84 mx89 mx92 mx94 mx96 mx98 mx00 mx02 mx04 mx08 mx10 mx12 nl83 nl87 /// 
 	nl90 nl93 nl04 nl07 nl10 nl13 no79 no86 no91 no95 no00 no04 no07 no10 no13 pa07 pa10 pa13 /// 
 	py10 py13 pe04 pe07 pe10 pe13 pl86 pl92 pl95 pl99 pl04 pl07 pl10 pl13 ro95 ro97 ru00 ru04 /// 
 	ru10 ru13 rs06 rs10 rs13 sk92 sk96 sk04 sk07 sk10 sk13 si97 si99 si04 si07 si10 si12 za08 /// 
 	za10 za12 kr06 kr08 kr10 kr12 es80 es85 es90 es95 es00 es04 es07 es10 es13 se67 se75 se81 /// 
 	se87 se92 se95 se00 se05 ch82 ch92 ch00 ch02 ch04 ch07 ch10 ch13 tw81 tw86 tw91 tw95 tw97 /// 
 	tw00 tw05 tw07 tw10 tw13 uk69 uk74 uk79 uk86 uk91 uk94 uk95 uk99 uk04 uk07 uk10 uk13 us74 /// 
 	us79 us86 us91 us94 us97 us00 us04 us07 us10 us13 uy04 uy07 uy10 uy13 uy16 

}

************************************   
*        MAIN PROGRAM              *   
************************************   

/* This program takes datasets as input   
and makes a call to csv_percentiles once for each file */   
capture program drop main_program   
program main_program   
	syntax namelist, model(integer) [ test quiet quantiles(integer 0) summaries crossvalid savemodel(string) runmodel(string) compare extreme_gap(real 0)]   


	di "************ BEGIN MAIN PROGRAM ****************"  
	di "* " c(current_time)  

	di "on a quiet == `quiet'"  
	di "on a test == `test'"  
	di "on a quantiles == `quantiles'"  
	di "on a summaries == `summaries'"  
	di "on a obs == `obs'"  
	di "on a crossvalid == `crossvalid'"
	di "on a savemodel == `savemodel'"
	di "on a runmodel == `runmodel'"
	di "on a compare == `compare'"
	di "on a extreme_gap == `extreme_gap'"

	if ("`runmodel'"!="") & ("`savemodel'"!="") {
		display as error "runmodel and savemodel cannot be both defined"
		exit
	}
	
	if ("`runmodel'"=="") & ("`compare'"!="") {
		display as error "runmodel has to be defined when compare is"
		exit
	}
	
	if ("`test'"=="test") {  
	local ccyylist au01 fr10 it14 us04
	}  
	else if ("`runmodel'"!="") {  
	local ccyylist `namelist'
	}
	else {
	local ccyylist $ccyy_to_imput 
	}

	gen ccyy = ""   
	foreach ccyy in `ccyylist' {   
		qui append using $`ccyy'h, generate(appending) nolabel nonotes ///   
		keep(cname year dhi hmc hmchous hchous nhhmem hhtype ///   
		hpartner own nhhmem65 nhhmem5 nhhmem17 nearn hwgt)
		qui replace ccyy = "`ccyy'" if appending == 1   
		qui drop appending   
	}  

	qui merge m:1 ccyy using "$mydata/jblasc/18-09-09 availability matrix.dta", ///
	keepusing(dhi_ccyy hmc_ccyy model1_ccyy model2_ccyy wor_ccyy rich_ccyy nearn)
	qui drop if _merge==2
	qui drop _merge

	qui merge m:1 cname year using $mydata/jblasc/18-08-31_itrcs_scalings.dta, ///  
	keepusing(itrc_carey itrc_euro itrc_ours oecd_prop_wor oecd_prop ///  
	itrc_carey_wor itrc_euro_wor itrc_ours_wor oecd_prop_wor_def ///
	oecd_P31CP041 oecd_P31CP042 oecd_income_S14 oecd_income_S14_S15)  
	qui drop if _merge==2  

	di "************ BEGIN PREPROCESSING ****************"  
	di "* " c(current_time)

	quiet preprocessing `ccyylist', model(`model')
	
	if ("`test'"=="test") {  
	local ccyylist au01 fr10 it14 us04
	}  
	else {  
	local ccyylist `namelist'
	}  
	
	if ("`compare'"=="compare") {  
		compare_models `runmodel'
		}
	else {
		di "----------- start regressions ------------"  
		di "- " c(current_time)  
		
		if ("`crossvalid'"=="crossvalid") {  
			foreach ccyy in `ccyylist' {
			`quiet' consumption_imputation , model(`model') crossvalid("`ccyy'") 
			}  
		}
		else {  
			`quiet' consumption_imputation , model(`model') savemodel("`savemodel'") runmodel("`runmodel'")
		}
		
		if (`quantiles'!=0) | ("`summaries'"!="") {
		di "----------- variables creation ------------"  
		di "- " c(current_time) 
		quiet variables_creation , extreme_gap(`extreme_gap')
		}
	}
	
	if (`quantiles'!=0) {  
	display_percentiles $quvars, ccyylist(`ccyylist') ///
									n_quantiles(`quantiles') `median'
	}  
	
	if ("`summaries'"=="summaries") {  
	display_summaries `ccyylist', summeanvars($summeanvars) sumondhivars($sumondhivars) sumonvarvars($sumonvarvars)
	}  

	di "************** End of program : ************"  
	di c(current_time)  

	end   
 // end main_program

 
************************************   
*        PREPROCESSING             *   
************************************  
{ 
/* This program transforms initial dataset before printing :   
 - top and bottom coding   
 - creating new variables   
 - doing some analysis   
*/   
capture program drop preprocessing   
program preprocessing     
	syntax namelist, model(integer)
  
   
	 /* trim and bottom-code:   
	 we could also drop first percentiles but we use the method in    
	 Addition to Consumption VAT program_eg.do */   
	   
	  
	 gen dhi_obs 		= dhi_ccyy 		& !mi(dhi)
	 gen hmc_obs 		= hmc_ccyy		& !mi(hmc)
	 gen model0_obs		= 1
	 gen model1_obs 	= model1_ccyy 	& !mi(dhi, nhhmem, hpartner)
	 gen model2_obs 	= model2_ccyy 	& model1_obs & !mi(hchous, own, nhhmem65)
	 gen wor_obs 		= wor_ccyy 		& !mi(hmchous)
	 
	 replace dhi_obs = 0 if dhi <= 0 
	 
	 // scope: dhi available + model variables available + same obs that in regression
	 gen scope = dhi_obs & model`model'_obs & !(hmc_ccyy & mi(hmc))
	 gen scope_regression = dhi_obs & model`model'_obs & hmc_obs & rich_ccyy
	 gen scope_hmc = scope & !mi(hmc)
	 
	 egen nb_scope 			= sum(scope)
	 egen nb_scope_regress  = sum(scope_regression)
	 
	 rename hmc hmc_old
	 gen hmc = max(1, hmc_old) if !mi(hmc_old)
	 
	 rename hchous hchous_old
	 gen hchous = max(1, hchous_old) if !mi(hchous_old)
	 
	 /* equivalise */   
	 foreach var in dhi hmc hmchous hchous {   
	 replace `var' = `var'/(nhhmem^0.5)   
	 }   
	  
	  
	 foreach var in hmc dhi hmchous hchous {   
	 gen `var'_median = .
		foreach ccyy in `namelist' {
			quiet sum `var' [w=hwgt*nhhmem] if ccyy == "`ccyy'" & scope, de 
			replace `var'_median = r(p50) if ccyy == "`ccyy'"
		} 
	 gen `var'_medianized = `var'/`var'_median   
	 gen log_`var'_medianized = log(`var'_medianized)   
	 }   
	   
	 foreach var in nhhmem {   
	 gen `var'_top = `var'   
	 replace `var'_top = 6 if `var'>6   
	 }   
	  
	 foreach var in nhhmem65 nhhmem5 nhhmem17 nearn {   
	 gen `var'_top = `var'   
	 replace `var'_top = 2 if `var'>2   
	 }   
	  
	 foreach var in hpartner own {   
	 gen `var'_agg = int(`var'/100)   
	 }   
	  
	 gen single_senior = nhhmem65*nhhmem == 1  
	   
	 gen dhipov_ind = (dhi_medianized<0.6)
	 
	 gen log_dhi_med_shifted = log_dhi_medianized -log(0.6)
  
end   
     
} // end preprocessing


**************************************
*      IMPUTATION OF CONSUMPTION     *
**************************************
{
program consumption_imputation
	syntax , model(integer) [crossvalid(string) savemodel(string) runmodel(string)]
	
	if ("`runmodel'" != "") {
		local model = `model' + 1
		estimates use "$mydata/jblasc/estimation_models/`runmodel'", number(`model')
	}
	else {
		if (`model'==0) | ("`savemodel'" != "") {
			noisily glm hmc_medianized c.log_dhi_medianized [aw=hwgt*nhhmem]  if scope_regression & substr(ccyy, 1,2) != substr("`crossvalid'", 1,2), link(log)
			if (`model'==0) {
				estimates store themodel
			}
			if ("`savemodel'" != "") {
				estimates save "$mydata/jblasc/estimation_models/`savemodel'", replace
			}
		}
		if (`model'==1) | ("`savemodel'" != "") {
			noisily glm hmc_medianized c.log_dhi_medianized ///
			c.log_dhi_med_shifted#i.dhipov_ind   ///   
			i.nhhmem_top i.hpartner_agg [aw=hwgt*nhhmem]  if scope_regression & substr(ccyy, 1,2) != substr("`crossvalid'", 1,2), link(log)  
			if (`model'==1) {
				estimates store themodel
			}
			if ("`savemodel'" != "") {
				estimates save "$mydata/jblasc/estimation_models/`savemodel'", append
			}
		}
		if (`model'==2) | ("`savemodel'" != "") {
			noisily glm hmc_medianized c.log_dhi_medianized ///
			c.log_dhi_med_shifted#i.dhipov_ind  log_hchous_medianized ///   
			$depvars [aw=hwgt*nhhmem]  if scope_regression & substr(ccyy, 1,2) != substr("`crossvalid'", 1,2), link(log)  
			if (`model'==2) {
				estimates store themodel
			}
			if ("`savemodel'" != "") {
				estimates save "$mydata/jblasc/estimation_models/`savemodel'", append
			}
		}
		
		estimates restore themodel
		
		local no_regress = e(N)
		if (nb_scope_regress != `no_regress') {
			noisily display as error "__________REGRESSION SCOPE PROBLEM__________"
			noisily display as error nb_scope_regress
			noisily display as error `no_regress'
			exit
			}
		
	}

	
	if ("`crossvalid'" != "") { 
		predict temp_pred if scope & substr(ccyy, 1,2) == substr("`crossvalid'", 1,2)
		capture confirm variable hmc_medianized_predict
		if (!_rc) {
			replace hmc_medianized_predict = temp_pred if scope & substr(ccyy, 1,2) == substr("`crossvalid'", 1,2)
		}
		else {
			gen hmc_medianized_predict = temp_pred
		}
		drop temp_pred
	}
	else {
		
		predict hmc_medianized_predict if scope
		quiet count if !mi(hmc_medianized_predict)
		local no_imput = r(N)
		
		if (nb_scope != `no_imput') {
			noisily display as error "__________IMPUTATION SCOPE PROBLEM__________"
			noisily display as error nb_scope
			noisily display as error `no_imput'
			exit
			}
	}
		 
 end
 
 } // end consumption_imputation
	
**************************************
*      CREATION OF VARIABLES         *
**************************************
{
program variables_creation
	syntax [, extreme_gap(real 0)]
	
	 // compute scaled variables, propensities, tax rates, etc.  
	   
	 egen dhi_mean = wtmean(dhi) if scope,  by(ccyy)  weight(hwgt*nhhmem) 
		
	 egen hmc_mean = wtmean(hmc) if scope, by(ccyy)  weight(hwgt*nhhmem) 
	 gen hmc_scaled = oecd_prop * (dhi_mean/hmc_mean) * hmc  
	 gen prop_scaled = hmc_scaled/dhi  
	 
	foreach def in carey euro ours {   
	 gen tax_eff_`def' = hmc_scaled * itrc_`def'
	 gen tax_rate_`def' = tax_eff_`def'/dhi  
	 gen inc_5_`def' = dhi - tax_eff_`def'
	 }  
	 
	 gen hmc_wor = hmc-hmchous  
	 egen hmc_wor_mean = wtmean(hmc_wor) if scope, by(ccyy)  weight(hwgt*nhhmem) 
	 gen hmc_wor_scaled = oecd_prop_wor * (dhi_mean/hmc_wor_mean) * hmc_wor  
	 gen prop_wor_scaled = hmc_wor_scaled/dhi  
	   
	 // define quintile of income
	egen dhi_percentile = xtile(dhi) if scope, by(ccyy) nquantiles(100) weights(hwgt*nhhmem)  
	   
	foreach def in carey euro ours { 
		replace itrc_`def' = itrc_`def' + `extreme_gap' * (dhi_percentile-50)/100
		replace itrc_`def'_wor = itrc_`def'_wor + `extreme_gap' * (dhi_percentile-50)/100
		}
		
	 foreach def in carey euro ours {   
	 gen tax_eff_`def'_wor = hmc_wor_scaled * itrc_`def'_wor  
	 gen tax_rate_`def'_wor = tax_eff_`def'_wor/dhi  
	 gen inc_5_`def'_wor = dhi - tax_eff_`def'_wor  
	 }   
	  
	 // version with rent  
	 egen hmc_medianized_predict_mean = wtmean(hmc_medianized_predict) if scope, by(ccyy)  weight(hwgt*nhhmem) 
	 gen hmc_pred_scaled = oecd_prop * (dhi_mean/hmc_medianized_predict_mean) * ///  
		hmc_medianized_predict  
	 gen prop_pred_scaled = hmc_pred_scaled/dhi  
	   
	 // compute taxes   
	 foreach def in carey euro ours {   
	 gen tax_eff_`def'_pred = hmc_pred_scaled * itrc_`def'  
	 gen tax_rate_`def'_pred = tax_eff_`def'_pred/dhi  
	 gen inc_5_`def'_pred = dhi - tax_eff_`def'_pred  
	 }  
	   
	   
	 // version without rent 
	 egen hmchous_mean = wtmean(hmchous) if scope, by(ccyy)  weight(hwgt*nhhmem)
	 gen oecd_income = 	cond(oecd_prop_wor_def == 0, oecd_income_S14-oecd_P31CP042, ///
						cond(oecd_prop_wor_def == 1, oecd_income_S14, ///
						cond(oecd_prop_wor_def == 2, oecd_income_S14_S15-oecd_P31CP042, ///
						cond(oecd_prop_wor_def == 3, oecd_income_S14_S15, .))))
	 gen hmchous_scaled = oecd_P31CP041/oecd_income * (dhi_mean/hmchous_mean) * hmchous
	 
	 gen hmc_wor_pred = hmc_pred_scaled - hmchous_scaled
	 egen hmc_wor_pred_mean = wtmean(hmc_wor_pred) if scope, by(ccyy) weight(hwgt*nhhmem)  
	 gen hmc_wor_pred_scaled = oecd_prop_wor * (dhi_mean/hmc_wor_pred_mean) * ///  
	   hmc_wor_pred  
	 gen prop_wor_pred_scaled = hmc_wor_pred_scaled/dhi  
	  
	 // compute taxes   
	 foreach def in carey euro ours {   
	 gen tax_eff_`def'_wor_pred = hmc_wor_pred_scaled * itrc_`def'_wor  
	 gen tax_rate_`def'_wor_pred = tax_eff_`def'_wor_pred/dhi  
	 gen inc_5_`def'_wor_pred = dhi - tax_eff_`def'_wor_pred  
	 }  
	   
 end
 
 } // end variables_creation

************************************   
*        DISPLAY_PERCENTILES       *   
************************************   
{ 
/* This program computes quantiles of income and outputs a CSV */   
capture program drop display_percentiles   
program display_percentiles   
 syntax varlist, ccyylist(namelist) [ n_quantiles(integer 0) ]   
  
preserve

 di "************ BEGIN DISPLAY_PERCENTILES ****************"  
 di "* " c(current_time)  

 quiet {
 egen dhi_quantiles = xtile(dhi) if scope, by(ccyy) nquantiles(`n_quantiles') weights(hwgt*nhhmem)  
   
 foreach variable of local varlist {
	local varlist_q `varlist_q' `variable'_q
	egen `variable'_q = wtmean(`variable') if scope, by(ccyy dhi_quantiles) weight(hwgt*nhhmem)
 }
  
 keep dhi_quantiles ccyy `varlist_q'
 duplicates drop
 drop if dhi_quantiles == .
 
 sort ccyy dhi_quantiles
 
 gen to_output = 0
 
 foreach ccyy in `ccyylist' {
	replace to_output = 1 if ccyy=="`ccyy'"
 }
 
 drop if to_output == 0
 
 }
 
  /* display header */   
 di "quantile,ccyy" _continue   
 foreach variable of local varlist {   
 di ",`variable'" _continue   
 }  
 di  
 
 local nrow = _N
  
 forvalues x = 1(1)`nrow' {   
	 di dhi_quantiles[`x'] "," ccyy[`x']  _continue   
	 foreach variable_q of local varlist_q {   
		di "," `variable_q'[`x'] _continue   
	 }  
	 di   
 }  
    
end   
} // end display_percentiles
   
***************************************   
*          DISPLAY_SUMMARIES          *   
***************************************   
{ 
/* This program computes summaries and outputs a CSV */   
capture program drop display_summaries   
program display_summaries   
 syntax namelist, [summeanvars(namelist) sumondhivars(namelist) sumonvarvars(namelist)]

preserve

 di "************ BEGIN DISPLAY_SUMMARIES ****************"  
 di "* " c(current_time)  

 
 /* display header */   
 di "ccyy" _continue   
  
 foreach variable in `summeanvars' {   
	 di ",`variable'_mean" _continue   
 }   
   
 foreach variable in `sumondhivars' {   
	 di ",`variable'_conc_dhi" _continue   
 }   
  
 foreach variable in `sumonvarvars' {   
	 di ",`variable'_conc_`variable'" _continue   
 }
 
 di ",gini_dhi_scope_hmc" _continue
 
 di   
   
 foreach ccyy of local namelist {  
	 di "`ccyy'" _continue   
	  
	 foreach variable in `summeanvars' {   
		 quiet sum `variable' [aw=hwgt*nhhmem] if ccyy=="`ccyy'" & scope, meanonly  
		 di "," r(mean) _continue   
	 }   
	  
	 foreach variable in `sumondhivars' {  
		 capture qui sgini `variable' [aw=hwgt*nhhmem] if ccyy=="`ccyy'" & scope, sortvar(dhi)   
		 di "," r(coeff) _continue   
	 }   
	  
	 foreach variable in `sumonvarvars' {   
		 capture qui sgini `variable' [aw=hwgt*nhhmem] if ccyy=="`ccyy'" & scope, sortvar(`variable')   
		 di "," r(coeff) _continue   
	 }    
	 
	 capture qui sgini dhi [aw=hwgt*nhhmem] if ccyy=="`ccyy'" & scope_hmc, sortvar(dhi)   
	 di "," r(coeff) _continue 
	 
	 di
 }  
end   
} // end display_summaries

***************************************   
*          COMPARE_MODELS             *   
***************************************   
{ 
/* This program computes summaries and outputs a CSV */   
capture program drop compare_models   
program compare_models   
 syntax anything(name=runmodel)

 di "************ BEGIN COMPARE_MODELS ****************"  
 di "* " c(current_time)  

global summeanvars 		///
	error0 error1 error2 	///
	corr0 corr1 corr2 		///
	R2_0 R2_1 R2_2 
	
global sumondhivars

global sumonvarvars
	
global quvars_obs hmc dhi hmc_medianized					

global quvars_pred			///
	hmc_medianized_predict0 hmc_medianized_predict1 hmc_medianized_predict2			
	
global quvars $quvars_obs $quvars_pred
  
forvalues i = 0(1)2 {
	local model = `i' + 1
	estimates use "$mydata/jblasc/estimation_models/`runmodel'", number(`model')
	predict hmc_medianized_predict`i' if scope
}
  
sort ccyy
 
 forvalues i = 0(1)2 {
	gen error`i' = (hmc_medianized - hmc_medianized_predict`i')^2
	egen corr`i' = corr(hmc_medianized hmc_medianized_predict`i'), by(ccyy)
	gen R2_`i' = corr`i'^2
 }

end   
} // end compare_models
}

/***************************************   
* Call function on desired datasets    
***************************************/   
   
main_program $ccyy_to_imput, model(2) test quantiles(10) summaries