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
* modified 24 February 2020 to add count of hmc imputed in compare
* modifier 03 April 2020 to add computation of REDINEQ income styles	
*******************

quiet {
/********************************
* DEFINITION OF MACRO VARIABLES *
*********************************/
{
/****************************************************
* I. independent variables in the econometric model *
****************************************************/
global depvars 										///
		i.nhhmem_top	i.hpartner_agg 	i.own_agg /// 
		i.single_senior i.agecat /* i.nearn_top */

		
/*****************************************
* II. variables in the summaries dataset *
*****************************************/

* II. a) Observed variables *

// means
global summeanvars_obs 											///
	hmc	dhi	hmchous	hchous 	hitp									///
	hmc_wor_scaled		hmc_scaled			///
	inc1 inc2 inc3 inc4

// concentration indices
global sumondhivars_obs 									///
	dhi 				hmc					hmc_wor			/// 
	tax_eff_ours 		tax_eff_ours_wor 					///  
	/* inc_5_carey 		inc_5_euro 	*/		inc_5_ours 		///  
	/* inc_5_carey_wor 	inc_5_euro_wor */		inc_5_ours_wor		

// Gini indices
global sumonvarvars_obs 								///
	/* inc_5_carey 		inc_5_euro 	*/	inc_5_ours 		///  
	/* inc_5_carey_wor 	inc_5_euro_wor */	inc_5_ours_wor  ///
	inc1 inc2 inc3 inc4


* II. b) Predicted (imputed) variables *

// means
global summeanvars_pred 													///
	hmc_wor_pred_scaled 	hmc_pred_scaled

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
		
		
/*****************************************
* IIbis. variables to check availability *
*****************************************/
global availvars ///
	hmc 	hmc_wor 	hmc_wor_scaled 	hmc_scaled ///
	hchous hmchous ///
	tax_eff_ours	tax_eff_ours_wor	inc_5_ours	inc_5_ours_wor ///
	inc1 inc2 inc3 inc4 inc_5_ours_pred inc_5_ours_wor_pred ///
	nhhmem_top	hpartner_agg 	own_agg  /// 
	nhhmem65_top 	single_senior nearn_top ///
	nhhmem5_top nhhmem17_top 
	
		
/******************************************
* III. variables in the quantiles dataset *
******************************************/

* III. a) Observed variables *
global quvars_obs hmc dhi hmchous prop4 prop4_scaled ///
			hmc_unscaled hmc_scaled_unif

* III. b) Predicted (imputed) variables *
global quvars_pred	hmc_medianized_predict hmc_wor_pred_scaled	prop4_pred_scaled			

* III. c) Variables in the quantiles
global quvars $quvars_obs $quvars_pred
	
	
/********************
* IV. datasets used *
********************/
{	
global ccyy_to_imput1 ///
	au81 au85 au89 au95 au01 au03 au08 au10 at87 at97 at00 at04 at07 at10 at13 be85 be88 be92 /// 
 	be97 br06 br09 br11 br13 ca71 ca75 ca81 ca87 ca91 ca94 ca97 ca98 ca00 ca04 ca07 ca10 ca13 /// 
 	cn02 co07 cz92 cz96 cz02 cz04 cz07 cz10 cz13 dk87 dk92 dk95 dk00 dk04 dk07 dk10 dk13 do07 /// 
 	eg12 ee00 ee04 ee07 ee10 ee13 fi87 fi91 fi95 fi00 fi04 fi07 fi10 fi13 fr78 fr84 fr89 fr94
global ccyy_to_imput2 ///
 	fr00 fr05 fr10 ge10 ge13 de73 de78 de81 de83 de84 de89 de94 de00 de04 de07 de10 de13 gr95 /// 
 	gr00 gr04 gr07 gr10 gr13 gt06 gt11 gt14 hu91 hu94 hu05 hu07 hu09 hu12 is04 is07 is10 in04 /// 
 	in11 ie87 ie94 ie95 ie96 ie04 ie07 ie10 il79 il86 il92 il97 il01 il05 il07 il10 il12 it86 /// 
 	it87 it89 it91 it93 it95 it98 it00 it04 it08 it10 it14 lt10 lt13 lu85 lu91 lu94 lu97 lu00
global ccyy_to_imput3 ///
 	lu04 lu07 lu10 lu13 mx84 mx89 mx92 mx94 mx96 mx98 mx00 mx02 mx04 mx08 mx10 mx12 nl83 nl87 /// 
 	nl90 nl93 nl04 nl07 nl10 nl13 no79 no86 no91 no95 no00 no04 no07 no10 no13 pa07 pa10 pa13 /// 
 	py10 py13 pe04 pe07 pe10 pe13 pl86 pl92 pl95 pl99 pl04 pl07 pl10 pl13 ro95 ro97 ru00 ru04 ///
 	ru10 ru13 rs06 rs10 rs13 sk92 sk96 sk04 sk07 sk10 sk13 si97 si99 si04 si07 si10 si12 za08
global ccyy_to_imput4 ///
 	za10 za12 kr06 kr08 kr10 kr12 es80 es85 es90 es95 es00 es04 es07 es10 es13 se67 se75 se81 /// 
 	se87 se92 se95 se00 se05 ch82 ch92 ch00 ch02 ch04 ch07 ch10 ch13 tw81 tw86 tw91 tw95 tw97 /// 
 	tw00 tw05 tw07 tw10 tw13 uk69 uk74 uk79 uk86 uk91 uk94 uk95 uk99 uk04 uk07 uk10 uk13 us74 /// 
 	us79 us86 us91 us94 us97 us00 us04 us07 us10 us13 uy04 uy07 uy10 uy13 uy16 

global ccyy_to_imput $ccyy_to_imput1 $ccyy_to_imput2 $ccyy_to_imput3 $ccyy_to_imput4

global redineq_datasets ///
	at04 at07 at13 au03 au08 au10 ca04 ca07 ca10 ca13 ch00 ch02 ch04 ch07 ch10 ch13 cz02 cz04 ///
	cz07 cz10 cz13 de00 de04 de07 de10 de13 de15 dk00 dk04 dk07 dk10 dk13 ee10 ee13 es07 es10 ///
	es13 fi00 fi04 fi07 fi10 fi13 fr00 fr05 fr10 gr07 gr10 gr13 ie04 ie07 ie10 il10 is04 is07 is10 it04 it08 it10 ///
	it14 jp08 kr06 kr08 kr10 kr12 lu04 lu07 lu10 lu13 nl99 nl04 nl07 nl10 nl13 no00 no04 no07 no10 no13 ///
	pl04 pl07 pl10 pl13 pl16 pl99 se00 se05 sk04 sk07 sk10 sk13 uk99 uk04 uk07 uk10 uk13 us00 us04 ///
	us07 us10 us13 us16 at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 ///
	mx10 mx12 mx98 si10  /* it00 il12 si12*/ 
	
global red_net_datasets ///
	at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10 ///
	/*it00*/ // Removed es00 and it98 in this version since they contain dupicates and missing values respectively in pil.

global fixpension_datasets3 ///
	ie04 ie07 ie10 uk99 uk04 uk07 uk10 uk13
}

global datasets_w_hchous ///
	au89 au95 au01 au03 au08 at04 at07 at10 at13 co07 cz07 cz10 cz13 dk04 ee00 ee04 ee07 ee10 ee13 ///
	fi91 fr84 fr89 fr00 fr05 fr10 de84 de89 de94 de00 de04 de07 de10 de13 gr07 gr10 gr13 gt06 gt11 gt14 ///
	hu91 hu94 hu05 hu07 hu09 hu12 is07 in04 in11 il92 il97 il01 il05 il07 il10 il12 it87 it89 it91 it93 it14 lt10 lt13 ///
	lu91 lu94 lu97 lu00 lu07 lu10 lu13 mx84 mx89 mx92 mx94 mx96 mx98 mx00 mx02 mx04 mx08 mx10 mx12 ///
	nl04 nl07 nl10 nl13 pa10 pa13 py10 py13 pe04 pe07 pe10 pe13 pl86 pl95 pl99 pl04 pl13 ro97 ru10 ru13 rs06 ///
	rs10 rs13 sk07 sk10 sk13 si97 si99 si04 si07 si10 si12 za08 za12 es80 es85 es90 es07 es10 es13 se00 ch00 ///
	ch02 ch04 ch07 ch10 ch13 tw81 tw86 tw91 tw95 tw97 tw00 tw05 tw07 tw10 tw13 uk86 uk91 uk94 uk95 uk99 ///
	uk04 uy04 uy07 uy10 uy13 uy16

/*********************
* V. Variables for REDINEQ income *
**********************/

global pvars "pid hid dname pil pxit pxiti pxits age emp relation"
global hvars "hid dname nhhmem dhi nhhmem17 nhhmem65 hwgt"
global hvarsflow ///
	dhi hc hic hicvip hil hits hitsap hitsil hitsilep hitsilepd hitsilepo hitsileps hitsilmip hitsilo hitsilwi hitsisma ///
	hitsissi hitsisun hitsiswi hitsup hxit hxiti hxits pension  hicid hicidd hicidi hicren hicrenl hicrenm hicrenr ///
	hicroy hitsa hitsaed hitsafa hitsafo hitsagen hitsahe hitsaho hitsame hitsapd hitsapo hitsaps hitsaun ///
	hitsi hitsis hitsu hitsudi hitsued hitsufa hitsufaam hitsufaca hitsufacc hitsupd hitsupo hitsups hitsuun hitp // Local currency, given in the datasets
global hvarsnew "hsscer hsscee" // Local currency, imputed
global hvarsinc "inc1 inc2 inc3 inc3_SSER inc3_SSEE inc4 tax transfer allpension pubpension pripension hssc" // Summation / imputed after PPP conversion
global incconcept "inc1 inc2 inc3 inc3_SSER inc3_SSEE inc4" /*Concept of income: for the loops*/
}

************************************   
*        MAIN PROGRAM              *   
************************************   

/* This program takes datasets as input   
and makes a call to csv_percentiles once for each file */   
capture program drop main_program   
program main_program   
	syntax namelist, model(integer) ///
		[ test quiet quantiles(integer 0) summaries availability par_age crossvalid ///
		savemodel(string) runmodel(string) compare extreme_gap(real 0)]   

	clear
	set varabbrev off, permanent
	
	di "************ BEGIN MAIN PROGRAM ****************"  
	di "* " c(current_time)  

	di "on a quiet == `quiet'"  
	di "on a test == `test'"  
	di "on a quantiles == `quantiles'"  
	di "on a summaries == `summaries'"  
	di "on a availability == `availability'"
	di "on a par_age == `par_age'"  
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
	local ccyylist au10 fr10 it14 us04
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
		keep(dname hid cname year dhi hmc hmchous hchous nhhmem hhtype ///   
		hpartner own nhhmem65 nhhmem5 nhhmem17 nearn hwgt ///
		$hvars $hvarsflow)
		qui replace ccyy = "`ccyy'" if appending == 1   
		qui drop appending   
	}

	qui merge m:1 ccyy using "${mydata}jblasc/18-09-09 availability matrix.dta", ///
	keepusing(dhi_ccyy hmc_ccyy model1_ccyy model2_ccyy wor_ccyy rich_ccyy)
	qui drop if _merge==2
	qui drop _merge

	
	qui foreach ccyy in $datasets_w_hchous {
		replace model2_ccyy = 1 if ccyy == "`ccyy'"
	}
	
	
	qui merge m:1 cname year using "${mydata}jblasc/18-08-31_itrcs_scalings.dta", ///  
	keepusing(itrc_carey itrc_euro itrc_ours oecd_prop_wor oecd_prop ///  
	itrc_carey_wor itrc_euro_wor itrc_ours_wor oecd_prop_wor_def ///
	oecd_P31CP041 oecd_P31CP042 oecd_income_S14 oecd_income_S14_S15)  
	qui drop if _merge==2  
	
	di "************ BEGIN SSC COMPUTATION ****************"  
	di "* " c(current_time)

	`quiet' ssc_impute `ccyylist'
	
	
	di "************ BEGIN PREPROCESSING ****************"  
	di "* " c(current_time)

	quiet preprocessing `ccyylist', model(`model')
	
	if ("`test'"=="test") {  
	local ccyylist au10 fr10 it14 us04
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
		
		if (`quantiles'!=0) | ("`summaries'"!="") | ("`availability'" == "availability") | ("`par_age'" == "par_age") {
		di "----------- variables creation ------------"  
		di "- " c(current_time) 
		quiet variables_creation , extreme_gap(`extreme_gap')
		}
	}
	
	if (`quantiles'!=0) {  
	display_percentiles $quvars, ccyylist(`ccyylist') ///
									n_quantiles(`quantiles') `median'
	}  
	
	if ("`par_age'"=="par_age") {
	stat_par_age $quvars, ccyylist(`ccyylist')
	}
	
	if ("`summaries'"=="summaries") {  
	display_summaries `ccyylist', summeanvars($summeanvars) sumondhivars($sumondhivars) sumonvarvars($sumonvarvars)
	}  

	if ("`availability'" == "availability") {
	display_availability
	}
	
	if (`model'==10) {
		table ccyy prediction_indicator
	}
	
	if ("`runmodel'"=="") {
		table ccyy scope_regression0
		table ccyy scope_regression1
		table ccyy scope_regression2
	}
	
	di "************** End of program : ************"  
	di c(current_time)  

	end   
 // end main_program

***********************************
*       SSC COMPUTATION      *
***********************************
capture program drop ssc_impute
program ssc_impute 
	syntax namelist
	local redineq_inlist
   	foreach ccyy in $redineq_datasets {   
		if strpos("`namelist'", "`ccyy'" ) {
			local redineq_inlist `redineq_inlist' `ccyy'
			}
		}
	
	foreach ccyy in `namelist' {
		qui merge m:m dname hid using $`ccyy'p, ///
		update keepusing($pvars) nogenerate ///
		assert(master match match_update) ///
		keep(master match match_update)
	}
	
	gen incometype = "gross"
	replace incometype = "France" if substr(ccyy,1,2) =="fr"
	replace incometype = "Italy" if substr(ccyy,1,2) =="it"
	replace incometype = "net" if strpos("$red_net_datasets",ccyy) > 0
	
	*************
	* Generate social security variables from person level dataset
	*************
	merge_ssc
	gen_employee_ssc
	manual_corrections_employee_ssc
	gen_employer_ssc
	manual_corrections_employer_ssc
	convert_ssc_to_household_level
	missing_values
end
	
capture program drop merge_ssc
program define merge_ssc
	di "* Merge labour income variables for gross and mixed datasets"
	quiet merge m:1 dname using "${mydata}vamour/SSC_20180621.dta", keep(match master) nogenerate
	 * Impute taxes for net datasets THIS IS NOT SUPPORTED YET
	* nearmrg dname pil using "$mydata/molcke/net_20161101.dta", `option1'`option2'("m:m") nearvar(pil) lower keep(match master) nogenerate
end

capture program drop gen_employee_ssc
program define gen_employee_ssc
	di "* Generate Employee Social Security Contributions"
	{
	**IMPORTANT**Convert Italian datasets from net to gross
	replace pil=pil+pxit if incometype == "Italy"

	capture confirm variable psscer
	if _rc { 
		gen psscee=.
	}
	replace psscee = pil*ee_r1 if inlist(incometype, "gross", "Italy")
	replace psscee = (pil-ee_c1)*ee_r2 + ee_r1*ee_c1  if pil>ee_c1 & ee_c1!=. & inlist(incometype, "gross", "Italy")
	replace psscee = (pil-ee_c2)*ee_r3 + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c2 & ee_c2!=. & inlist(incometype, "gross", "Italy")
	replace psscee = (pil-ee_c3)*ee_r4 + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c3 & ee_c3!=. & inlist(incometype, "gross", "Italy")
	replace psscee = (pil-ee_c4)*ee_r5 + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) ///
		+ ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c4 & ee_c4!=. & inlist(incometype, "gross", "Italy")
	replace psscee = (pil-ee_c5)*ee_r6 + ee_r5*(ee_c5 - ee_c4) + ee_r4*(ee_c4 - ee_c3) ///
		+ ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1  if pil>ee_c5 & ee_c5!=.  & inlist(incometype, "gross", "Italy")
	
	**IMPORTANT**Convert French datasets from net to gross
	* Impute Employee Social Security Contributions then sum with pil
	/*We assume that the original INSEE survey provides information about actual "net" wages in the sense 
	"net of all contributions" and not in the sense of "declared income", which contains non deductible CSG. If not, one should 
	remove this rate in the excel file and add it manually after we have the gross income*/
	replace psscee = pil*ee_r1/(1-ee_r1) if pil>0 & pil<=(ee_c1 - ee_r1*ee_c1) & incometype == "France"
	replace psscee = 1/(1-ee_r2)*(ee_r2*(pil - ee_c1) + ee_r1*ee_c1) ///
		if pil>(ee_c1 - ee_r1*ee_c1) & pil<=(ee_c2 - ee_r1*ee_c1 - ee_r2*(ee_c2-ee_c1)) & incometype == "France"
	replace psscee = 1/(1-ee_r3)*(ee_r3*(pil - ee_c2) + ee_r1*ee_c1 + ee_r2*(ee_c2-ee_c1)) ///
		if pil>(ee_c2 - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & pil<=(ee_c3 - ee_r3*(ee_c3-ee_c2) - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & incometype == "France"
	replace psscee = 1/(1-ee_r4)*(ee_r4*(pil - ee_c3) + ee_r1*ee_c1 + ee_r2*(ee_c2-ee_c1) + ee_r3*(ee_c3 - ee_c2)) ///
		if pil>(ee_c3 - ee_r3*(ee_c3-ee_c2) - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & incometype == "France"
	
	replace pil=pil+psscee if incometype == "France"
	}
end

capture program drop manual_corrections_employee_ssc
program define manual_corrections_employee_ssc
	di "* Manual corrections for certain datasets (Employee Social Security Contributions)"
	quiet {
	*Belgium 2000 BE00
	replace psscee=psscee-2600 if pil>34000 & pil<=42500 & dname=="be00"
	replace psscee=psscee-(2600-0.4*(pil-42500)) if pil>42500 & pil<=4900 & dname=="be00"
	replace psscee=psscee+0.09*hil if hil>750000 & hil<=850000 & dname=="be00"
	replace psscee=psscee+9000+0.013*hil if hil>850000 & hil<=2426924 & dname=="be00"
	replace psscee=psscee+29500 if hil>2426924 & dname=="be00"
	*Denmark 2007 DK07
	replace psscee=psscee+8052+975.6 if pil>0 & dname=="dk07"
	*Denmark 2010 DK10
	replace psscee=psscee+10244 if pil>0 & dname=="dk10"
	*Greece 2000 GR00
	replace psscee=0.159*6783000 if pil>6783000 & age>29 & dname=="gr00" //it would be betzter if I used year of birth
	*Greece 2004 GR04
	replace psscee=0.16*24699 if pil>24699 & age>33 & dname=="gr04"
	*Greece 2007 GR07
	replace psscee=0.16*27780 if pil>27780  & age>36 & dname=="gr07"
	*Greece 2010 GR10
	replace psscee=0.16*29187 if pil>29187  & age>39 & dname=="gr10"
	*Iceland 2007 IS07
	replace psscee=6314 if pil>ee_c1 & dname=="is07" //Should there also be an age restriction like in 2010?
	*Iceland 2010 IS10
	replace psscee=8400+17200 if pil>ee_c1 & age>=16 & age<=70 & dname=="is10"
	}
end


capture program drop gen_employer_ssc
program define gen_employer_ssc
  di "* Generate Employer Social Security Contributions"
	quiet {
	capture confirm variable psscer
	if _rc { 
		gen psscer=.
	}
	replace psscer = pil*er_r1 if inlist(incometype, "gross", "Italy", "France")
	replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=. & inlist(incometype, "gross", "Italy", "France")
	replace psscer = (pil-er_c2)*er_r3 + er_r2*(er_c2 - er_c1) + er_r1*er_c1 ///
		if pil>er_c2 & er_c2!=. & inlist(incometype, "gross", "Italy", "France")
	replace psscer = (pil-er_c3)*er_r4 + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 ///
		if pil>er_c3 & er_c3!=. & inlist(incometype, "gross", "Italy", "France")
	replace psscer = (pil-er_c4)*er_r5 + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 ///
		if pil>er_c4 & er_c4!=. & inlist(incometype, "gross", "Italy", "France")
	replace psscer = (pil-er_c5)*er_r6 + er_r5*(er_c5 - er_c4) + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1  ///
		if pil>er_c5 & er_c5!=.  & inlist(incometype, "gross", "Italy", "France")
	}
end

capture program drop manual_corrections_employer_ssc
program define manual_corrections_employer_ssc
	di "* Manual corrections for certain datasets (Employer Social Security Contributions)"
	quiet {
	*Germany 2004 de04
	replace psscer = 0.25*pil if pil<4800 & dname=="de04"
	replace psscer = 0.25*pil if pil<4800 & dname=="de07"
	*Germany 2010 de10 
	replace psscer = 0.30*pil if pil<4800 & dname=="de10" 
	*Germany 2013 de13 *Seems to be now 450/month : http://www.bmas.de/EN/Our-Topics/Social-Security/450-euro-mini-jobs-marginal-employment.html
	replace psscer = 0.30*pil if pil<5400 & dname=="de13" 
	*Germany 2015 de15 (VA)
	replace psscer = 0.30*pil if pil<5400 & dname=="de15"
	*Denmark dk
	replace psscer = psscer +  1789 if pil>0 & dname=="dk00" 
	replace psscer = psscer +  1789 if pil>0 & dname=="dk04"
	replace psscer = psscer +  1951.2 if pil>0 & dname=="dk07"
	replace psscer = psscer + 2160 if pil>0 & dname=="dk10"
	replace psscer = psscer + 2160 if pil>0 & dname=="dk13"
	*Estonia 2010 ee10
	replace psscer = psscer + 17832 if pil>0 & dname=="ee10"
	*Hungary 2005 hu05
	replace psscer = psscer + 3450*10 + 1950*2 if pil>0 & dname=="hu05"
	*Hungary 2007 2009 hu07 hu09 
	replace psscer = psscer + 1950*12 if pil>0 & dname=="hu07"
	replace psscer = psscer + 1950*12 if pil>0 & dname=="hu09"
	*Ireland 2000 ie00
	replace psscer=pil*.085 if  pil<14560 & dname=="ie00" // I could have easily included these changes for Ireland in the rates and ceilings.
	*Ireland 2004 ie04
	replace psscer=pil*.085 if  pil<18512 & dname=="ie04"
	*Ireland 2007 ie07
	replace psscer=pil*.085 if  pil<18512 & dname=="ie07"
	*Ireland 2010 ie10
	replace psscer=pil*.085 if  pil<18512 & dname=="ie10"
	*Korea 2012 kr12
	replace psscer=0.045*240000*12+0.0308995*280000*12+(0.008+0.0177)*pil if pil>0 & pil<240000*12 & dname=="kr12"
	replace psscer=0.0308995*280000*12+(0.045+0.008+0.0177)*pil if pil>240000*12 & pil<280000*12 & dname=="kr12"
	*France 2000 fr00 (measured in Francs, not Euros)
	replace psscer=psscer-(0.182*pil) if pil<=83898 & dname=="fr00"
	replace psscer=psscer-(0.55*(111584.34-pil)) if pil>83898 & pil<=111584.34 & dname=="fr00" 
	*France 2005 fr05
	replace psscer=psscer-((0.26/0.6)*((24692.8/pil)-1)*pil) if pil>15433 & pil<24692.8 & dname=="fr05" //I am not sure I have this adjustment correct.
	*France 2010 fr10
	replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10"
	*Mexico 2000 mx00
	replace psscer=psscer + 0.152*35.12*365 if pil>0 & dname=="mx00"
	replace psscer=psscer + 0.0502*(pil-3*35.12*365) if pil>3*35.12*365 & dname=="mx00"
	*Mexico 2002 mx02
	replace psscer=psscer + 0.165*39.74*365 if pil>0 & dname=="mx02"
	replace psscer=psscer + 0.0404*(pil-3*39.74*365) if pil>3*39.74*365 & dname=="mx02"
	*Mexico 2004 mx04
	replace psscer=psscer + 0.178*45.24*365 if pil>0 & dname=="mx04"
	replace psscer=psscer + 0.0306*(pil-3*45.24*365) if pil>3*45.24*365 & dname=="mx04"
	*Mexico 2008 mx08
	replace psscer=psscer + 0.204*52.59*365 if pil>0 & dname=="mx08"
	replace psscer=psscer + 0.011*(pil-3*52.59*365) if pil>3*52.59*365 & dname=="mx08"
	*Mexico 2010 mx10
	replace psscer=psscer + 0.204*57.46*365 if pil>0 & dname=="mx10"
	replace psscer=psscer + 0.011*(pil-3*57.46*365) if pil>3*57.46*365 & pil<25*57.46*365 & dname=="mx10"
	replace psscer=psscer + 0.011*((25-3)*57.46*365)	 if pil>25*57.46*365 & dname=="mx10"
	*Mexico 2012 mx12 VA
	replace psscer=psscer + 0.204*62.33*365 if pil>0 & dname=="mx10"
	replace psscer=psscer + 0.011*(pil-3*62.33*365) if pil>3*62.33*365 & pil<25*62.33*365 & dname=="mx10"
	replace psscer=psscer + 0.011*((25-3)*62.33*365)	 if pil>25*62.33*365 & dname=="mx10"
	*Netherlands 1999 nl99
	replace psscer=psscer + 0.0585*pil  if pil>0 & pil<54810 & dname=="nl99"
	replace psscer=psscer + 0.0585*54810  if pil>0 & pil<64300 & dname=="nl99"
	*Netherlands 2004 nl04
	replace psscer=psscer + 0.0675*pil  if pil>0 & pil<29493 & dname=="nl04"
	replace psscer=psscer + 0.0675*29493  if pil>0 & pil<32600 & dname=="nl04"
	}
end

capture program drop convert_ssc_to_household_level
program define convert_ssc_to_household_level
  di "* Convert variables to household level"
  {
  bysort ccyy hid: egen hsscee=total(psscee)
  bysort ccyy hid: egen hsscer=total(psscer)
  // bysort ccyy hid: egen hxiti_temp=total(pinctax) if incometype == "net" NOT SUPPORTED
  // replace hxiti = hxiti_temp if incometype == "net"
  // drop hxiti_temp
  
  *create a dummy variable taking 1 if head of household btw 25 and 59
  gen headactivage=1 if age>24 & age<60 & relation==1000
  replace headactivage=0 if headactivage!=1
  bys ccyy hid: egen hhactivage=total(headactivage)
  
  /* ajout de l'age du head en variable numerique */
  gen age_head = age if relation == 1000
  replace age_head = 0 if age_head == .
  bys ccyy hid: egen headagenum=total(age_head)
  egen agecat = cut(headagenum), at(1, 30, 50, 65, 1000)
  
  * Keep only household level SSC and household id and activage dummy
  drop pid pil pxit pxiti pxits age emp relation headactivage psscee psscer age_head // pinctax NOT SUPPORTED
  drop if hid==.
  duplicates drop
  }
end

capture program drop missing_values
program define missing_values
	di "*Here we replace missing values of aggregates by the sum of values of the subvariables if it brings extra information"
	quiet {
	egen hitsilep2=rowtotal(hitsilepo hitsilepd hitsileps)
	replace hitsilep=hitsilep2 if hitsilep==. & hitsilep2 !=0

	egen hitsil2=rowtotal(hitsilmip hitsilo hitsilep hitsilwi)  
	replace hitsil=hitsil2 if hitsil==. & hitsil2 !=0

	egen hitsis2=rowtotal(hitsissi hitsisma hitsiswi hitsisun) 
	replace hitsis=hitsis2 if hitsis==. &	 hitsis !=0

	egen hitsup2=rowtotal(hitsupo hitsupd hitsups)
	replace hitsup=hitsup2 if hitsup==. & hitsup2 !=0

	egen hitsufa2=rowtotal(hitsufaca hitsufaam hitsufacc)
	replace hitsufa = hitsufa2 if hitsufa==. & hitsufa !=0

	egen hitsu2=rowtotal(hitsup hitsuun hitsudi hitsufa hitsued)
	replace hitsu=hitsu2 if hitsu==. & hitsu2 !=0

	egen hitsap2=rowtotal(hitsapo hitsapd hitsaps) 
	replace hitsap=hitsap2 if hitsap==. & hitsap2 !=0

	egen hitsa2=rowtotal(hitsagen hitsap hitsaun hitsafa hitsaed hitsaho hitsahe hitsafo hitsame)
	replace hitsa=hitsa2 if hitsa==. & hitsa2 !=0

	egen hits2=rowtotal(hitsi hitsil hitsis hitsu hitsa)
	replace hits=hits2 if hits==. & hits2 !=0

	egen pension2=rowtotal(hitsil hitsup hitsap hicvip)
	replace pension=pension2 if pension==. & pension2 !=0 /*A priori pension is always defined so this should have no impact...*/

	egen hicid2=rowtotal(hicidi hicidd)
	replace hicid=hicid2 if hicid==.

	egen hicren2=rowtotal(hicrenr hicrenl hicrenm)
	replace hicren=hicren2 if hicren==.

	egen hic2=rowtotal(hicid hicren hicroy)
	replace hic=hic2 if hic==.  
	}
end

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

	foreach ccyy in de83 tw81 tw86 tw91 uk69 {
		replace model2_ccyy = 0 if ccyy == "`ccyy'"
	 }

	 gen dhi_obs 		= dhi_ccyy 		& !mi(dhi)
	 gen hmc_obs 		= hmc_ccyy		& !mi(hmc) & !mi(oecd_prop)
	 gen model0_obs		= 1
	 gen model1_obs 	= model1_ccyy 	& !mi(dhi, nhhmem, hpartner)
	 gen model2_obs 	= model2_ccyy 	& model1_obs & !mi(hchous, own, agecat)
	 gen wor_obs 		= wor_ccyy 		& !mi(hmchous)
	 
	 replace dhi_obs = 0 if dhi <= 0 
	 
	 // scope: dhi available + model variables available + same obs that in regression
	 foreach m in 0 1 2 {
		 gen scope`m' = dhi_obs & model`m'_obs & !(hmc_ccyy & mi(hmc))
		 gen scope_regression`m' = dhi_obs & model`m'_obs & hmc_obs & rich_ccyy
		 gen scope_hmc`m' = scope`m' & !mi(hmc)
		 
		 egen nb_scope`m' 			= sum(scope`m')
		 egen nb_scope_regress`m'  = sum(scope_regression`m')
	 }
	 
	 if (`model' == 10)  {
			gen scope = scope0
			gen scope_regression = scope_regression0
			gen scope_hmc = scope_hmc0
	 }
	 else {
	 	gen scope = scope`model'
		gen scope_regression = scope_regression`model'
		gen scope_hmc = scope_hmc`model'
	 }
		 
	gen modelfinal = `model'
		 
	 rename hmc hmc_old
	 gen hmc = max(1, hmc_old) if !mi(hmc_old)
	 
	 /* scalings : means of households income and consumption */
     egen dhi_mean = wtmean(dhi) if scope,  by(ccyy)  weight(hwgt)
		
	 rename hmc hmc_unscaled
	 egen hmc_unscaled_mean = wtmean(hmc_unscaled) if scope, by(ccyy)  weight(hwgt) 
	 gen hmc_unscaled_squared = hmc_unscaled ^ 2
	 egen hmc_unscaled_squared_mean = wtmean(hmc_unscaled_squared) if scope, by(ccyy) weight(hwgt)
	 
	 gen beta = (oecd_prop * dhi_mean - hmc_unscaled_mean)/hmc_unscaled_squared_mean
	 
	 gen hmc = hmc_unscaled * (1+beta*hmc_unscaled)
	 gen hmc_scaled_unif = hmc_unscaled * oecd_prop * (dhi_mean/hmc_unscaled_mean)
	 
	 /* without rent */
	 gen hmc_wor = hmc_unscaled-hmchous  
	 egen hmc_wor_mean = wtmean(hmc_wor) if scope, by(ccyy)  weight(hwgt) 
	 gen hmc_wor_squared = hmc_wor^2
	 egen hmc_wor_squared_mean = wtmean(hmc_wor_squared) if scope, by(ccyy)  weight(hwgt) 
	 
	 gen beta_wor = (oecd_prop_wor * dhi_mean - hmc_wor_mean)/hmc_wor_squared_mean
	 
	 replace hmc_wor = hmc_wor * (1+beta_wor*hmc_wor)
	 
	 rename hchous hchous_old
	 gen hchous = max(1, hchous_old) if !mi(hchous_old)
	 
    replace hsscer=0 if hsscer<0 // Employer
    replace hsscee=0 if hsscee<0 // Employee
	 
	 egen hmchous_mean = wtmean(hmchous) if scope, by(ccyy)  weight(hwgt*nhhmem)
	 gen oecd_income = 	cond(oecd_prop_wor_def == 0, oecd_income_S14-oecd_P31CP042, ///
						cond(oecd_prop_wor_def == 1, oecd_income_S14, ///
						cond(oecd_prop_wor_def == 2, oecd_income_S14_S15-oecd_P31CP042, ///
						cond(oecd_prop_wor_def == 3, oecd_income_S14_S15, .))))
	 gen hmchous_scaled = oecd_P31CP041/oecd_income * (dhi_mean/hmchous_mean) * hmchous
	 
	 /* equivalise */   
	 foreach var in dhi hmc hmc_unscaled hmc_scaled_unif hmchous hmc_wor hchous $hvarsflow $hvarsnew {   
	 capture gen `var'_equiv = `var'/(nhhmem^0.5)   
	 }   
	 foreach var in dhi hmc hmc_unscaled hmc_scaled_unif hmchous hmc_wor hchous $hvarsflow $hvarsnew {   
	 replace `var' = `var'_equiv
	 }   
	 
	  
	  /* variables for regression model */
	 foreach var in hmc dhi hmchous hchous {   
	 gen `var'_median = .
		foreach ccyy in `namelist' {
			quiet sum `var' [w=hwgt*nhhmem] if ccyy == "`ccyy'", de 
			replace `var'_median = r(p50) if ccyy == "`ccyy'"
		} 
	 gen `var'_medianized = `var'/`var'_median   
	 gen log_`var'_medianized = log(`var'_medianized)   
	 }   
	   
	 foreach var in nhhmem {   
	 gen `var'_top = `var'   
	 replace `var'_top = 6 if `var'>6 & !mi(`var')
	 }   
	  
	 foreach var in nhhmem65 nhhmem5 nhhmem17 nearn {   
	 gen `var'_top = `var'   
	 replace `var'_top = 2 if `var'>2 & !mi(`var')
	 }   
	  
	 foreach var in hpartner {   
	 gen `var'_agg = int(`var'/100)   
	 }   
	  
	 gen own_agg = own
	 replace own_agg = 1 if own != 210 & own != 212
	 
	 regress hmchous c.hchous#i.own_agg, noconstant
	 predict hmchous_pred
	 
	 replace hmchous = hmchous_pred if mi(hmchous)
	 * US exception: hmchous nonmissing but always equal to zero ;
	 replace hmchous = hmchous_pred if cname == "United States"
	  
	 gen single_senior = nhhmem65*nhhmem == 1  
	 gen dhipov_ind = (dhi_medianized<0.6)
	 gen log_dhi_med_shifted = log_dhi_medianized -log(0.6)
	 
	 *********************************** 
	 * Define the different stages of income
	 * we'll see if this has to go inside preprocessing
	 * or creation of variables	
	 ***********************************
	quietly def_tax_and_transfer
  
end   
     
} // end preprocessing


**************************************************
* Program: Define taxes and transfer variables
**************************************************

capture program drop def_tax_and_transfer
program define def_tax_and_transfer
  gen pubpension = hitsil + hitsup /*Use conventional definition: hitsil + hitsup if nothing missing. 
				Recall that hitsil or hitsup may have been "enriched" by their components but there are still missing values left */
  * if hitsil or hitsup is missing (=> previous formula generates a missing value), use the negative definition of pubpension*/
 
  replace pubpension= pension - hicvip - hitsap if pubpension==. /*Recall: pension = hitsil + hitsup + hicvip + hitsap: 
																					if hicvip and hitsap are defined, hitsil + hitsup can be defined by the residual*/
  replace pubpension = pension - hicvip if pubpension==.  /*use pension - hicvip if only hitsap missing*/
  replace pubpension = pension - hitsap if pubpension==.  /*use pension - hitsap if only hicvip missing*/
  replace pubpension = pension if pubpension==. /*if pension is the only variable not missing, use this as pubpension*/
  
  replace pubpension = hitsil + hitsup + hitsap if inlist(cname, "United Kingdom", "Ireland")
  
   *Now we define transfers and pensions. We set to 0 the remaining missing values
  replace pubpension=0 if pubpension==.
  replace hits=0 if hits==.
  replace hicvip=0 if hicvip==.
  replace hitsil=0 if hitsil==.
  replace hitsap=0 if hitsap==.
  replace hitsup=0 if hitsup==.
  replace pension=0 if pension==.

  gen transfer = hits - pubpension
  gen pripension = hicvip
  gen allpension = pension - hitsap
 
 replace allpension = pension if inlist(cname, "United Kingdom", "Ireland")
 
 
  *Finally define PIT and social security contribution. Rather use hxit in the income definitions
   * Use the imputed data if employee social security contributions is not available
  replace hxits=hsscee if hxits==.
  replace hxiti=hxit - hxits if hxiti==.
  replace hxit = hxiti + hxits if hxit==.

  gen tax = hxit + hsscer
  gen hssc = hxits + hsscer
  gen marketincome = hil + (hic-hicvip) + hsscer
  
  * Italy is reported net of both SSC contributions and income tax while the gross datasets 
  * are net of employer contributions but gross of employee SSC and income tax.
  replace marketincome = hil + (hic-hicvip) + tax if dname=="it04" | dname=="it08" | dname=="it10" | dname=="it14"

   * Impute the taxes CSG and CRDS
   * Labour income
  // CSG and CRDS on labour income is imputed within Employee SSC
  * Capital income
  gen hic_csg_crds = hic * 0.08 if dname =="fr00"
  replace hic_csg_crds = hic * 0.087 if dname =="fr05"
  replace hic_csg_crds = hic * 0.087  if dname =="fr10"
  * Pensions
    *Family share
    gen N = (nhhmem - nhhmem17)
    replace N = 2 + ((nhhmem - nhhmem17)-2) / 2 if (nhhmem - nhhmem17)>2
    gen C = nhhmem17 / 2
    replace C = 1 + (nhhmem17 - 2) if nhhmem17>2
    gen familyshare = N + C
    drop N C
     *Imputation
    gen pension_csg_crds = 0
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) /// 2002 figures deflated to 2000 prices using WDI CPI
		if ((hil/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (6584+2*(familyshare - 1)*1759) & hxit<=0 & dname=="fr00"
    replace pension_csg_crds = 0.067/(1-0.067)*(hitsil + hitsup) /// 2002 figures deflated to 2000 prices using WDI CPI
		if ((hil/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (6584+2*(familyshare - 1)*1759) & hxit>0 & dname=="fr00" 
	
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) ///
		if ((hil/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (7165+2*(familyshare - 1)*1914) & hxit<=0 & dname=="fr05"
    replace pension_csg_crds = 0.071/(1-0.071)*(hitsil + hitsup) ///
		if ((hil/(1-0.024*0.97)+ hitsil + hitsup)*0.9 + hic) >  (7165+2*(familyshare - 1)*1914) & hxit>0 & dname=="fr05"
	
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) ///
		if ((hil/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (9876+2*(familyshare - 1)*2637) & hxit<=0 & dname=="fr10"
    replace pension_csg_crds = 0.071/(1-0.071)*(hitsil + hitsup) ///
		if ((hil/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (9876+2*(familyshare - 1)*2637) & hxit>0& dname=="fr10"
  
  * Define the components of the income stages
  replace tax = hxiti + hxits + hsscer + hic_csg_crds + pension_csg_crds if incometype == "France"
  * For France, incomes are reported net of ssc, but gross of income tax
  replace marketincome = hil + (hic-hicvip) + hsscer + hic_csg_crds + hxits + pension_csg_crds if incometype == "France"
  
  replace hitp = 0 if mi(hitp)
  gen inc1 = marketincome
  gen inc2 = marketincome + allpension + hitp // added 07/05/2020 --> private transfers included from inc2
  gen inc3 = marketincome + allpension + hitp + transfer
  gen inc3_SSER = marketincome + allpension + hitp + transfer - hsscer /*Inc3 minus Employer (ER) social security contributions (SSER)*/
  gen inc3_SSEE = marketincome + allpension + hitp + transfer - hsscer - hxits /*Inc3 minus ER and EE SSC*/
  gen inc4 = marketincome + allpension + hitp + transfer - tax


end



**************************************
*      IMPUTATION OF CONSUMPTION     *
**************************************
{
capture program drop consumption_imputation
program consumption_imputation
	syntax , model(integer) [crossvalid(string) savemodel(string) runmodel(string)]
	
	if ("`runmodel'" != "") {
		if (`model' == 10) {
			estimates use "${mydata}jblasc/estimation_models/`runmodel'", number(1)
			estimates store themodel0
			
			estimates use "${mydata}jblasc/estimation_models/`runmodel'", number(2)
			estimates store themodel1
			
			estimates use "${mydata}jblasc/estimation_models/`runmodel'", number(3)
			estimates store themodel2
		}
		else {
			local number = `model' + 1
			estimates use "${mydata}jblasc/estimation_models/`runmodel'", number(`number')
			estimates store themodel`model'
			}
	}
	else {
		if (`model'==0) | ("`savemodel'" != "") | (`model' == 10) {
			noisily glm hmc_medianized c.log_dhi_medianized c.log_dhi_med_shifted#i.dhipov_ind [aw=hwgt*nhhmem] ///
				if scope_regression0 & substr(ccyy, 1,2) != substr("`crossvalid'", 1,2), link(log)
			estimates store themodel0
			
			if ("`savemodel'" != "") {
				estimates save "${mydata}jblasc/estimation_models/`savemodel'", replace
			}
			
			local no_regress = e(N)
			if (nb_scope_regress0 != `no_regress') {
				noisily display as error "__________REGRESSION SCOPE PROBLEM__________"
				noisily display as error nb_scope_regress0
				noisily display as error `no_regress'
				exit
				}
			
		}
		if (`model'==1) | ("`savemodel'" != "") | (`model' == 10) {
			noisily glm hmc_medianized c.log_dhi_medianized ///
				c.log_dhi_med_shifted#i.dhipov_ind i.nhhmem_top i.hpartner_agg [aw=hwgt*nhhmem]  ///
				if scope_regression1 & substr(ccyy, 1,2) != substr("`crossvalid'", 1,2), link(log)  
			estimates store themodel1
			
			if ("`savemodel'" != "") {
				estimates save "${mydata}jblasc/estimation_models/`savemodel'", append
			}
			
			local no_regress = e(N)
			if (nb_scope_regress1 != `no_regress') {
				noisily display as error "__________REGRESSION SCOPE PROBLEM__________"
				noisily display as error nb_scope_regress1
				noisily display as error `no_regress'
				exit
				}
			
		}
		if (`model'==2) | ("`savemodel'" != "") | (`model' == 10) {
			noisily glm hmc_medianized c.log_dhi_medianized ///
				c.log_dhi_med_shifted#i.dhipov_ind  log_hchous_medianized ///   
				$depvars [aw=hwgt*nhhmem]  if scope_regression2 & substr(ccyy, 1,2) != substr("`crossvalid'", 1,2), link(log)  
			estimates store themodel2
			
			if ("`savemodel'" != "") {
				estimates save "${mydata}jblasc/estimation_models/`savemodel'", append
			}
			
			local no_regress = e(N)
			if (nb_scope_regress2 != `no_regress') {
				noisily display as error "__________REGRESSION SCOPE PROBLEM__________"
				noisily display as error nb_scope_regress2
				noisily display as error `no_regress'
				exit
				}
			
		}
		
	}

	
	if ("`crossvalid'" != "") { 
		estimates restore themodel`model'
	
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
		if (`model' != 10) {
		estimates restore themodel`model'
		gen var_p = `e(deviance)'/`e(N)'
		
			predict hmc_medianized_predict if scope
			replace hmc_medianized_predict = hmc_medianized_predict+sqrt(var_p/2)*rnormal()
			
			quiet count if !mi(hmc_medianized_predict)
			local no_imput = r(N)
			
			if (nb_scope`model' != `no_imput') {
				noisily display as error "__________IMPUTATION SCOPE PROBLEM__________"
				noisily display as error nb_scope`model'
				noisily display as error `no_imput'
				exit
				}
			}
		else {
			 forvalues j = 0(1)2 {   
				estimates restore themodel`j'
				gen var_p`j' = `e(deviance)'/`e(N)'
				
				predict hmc_medianized_predict`j' if scope`j'
				replace hmc_medianized_predict`j' = hmc_medianized_predict`j'+sqrt(var_p`j'/2)*rnormal()
				
				quiet count if !mi(hmc_medianized_predict`j')
				local no_imput = r(N)
				
				if (nb_scope`j' != `no_imput') {
					noisily display as error "__________IMPUTATION SCOPE PROBLEM__________"
					noisily display as error nb_scope`j'
					noisily display as error `no_imput'
					exit
					}
				 }
				 gen hmc_medianized_predict = hmc_medianized_predict2
				 gen prediction_indicator = 2
				 replace hmc_medianized_predict = hmc_medianized_predict1 if !(scope2)
				 replace prediction_indicator = 1 if !(scope2)
				 replace hmc_medianized_predict = hmc_medianized_predict0 if !(scope1)
				 replace prediction_indicator = 0 if !(scope1)
			}
	}
		 
 end
 
 } // end consumption_imputation
	
**************************************
*      CREATION OF VARIABLES         *
**************************************
{
capture program drop variables_creation
program variables_creation
	syntax [, extreme_gap(real 0)]
	
	 // define quintile of income
	egen dhi_percentile = xtile(dhi) if scope, by(ccyy) nquantiles(100) weights(hwgt*nhhmem)  
	   
	foreach def in carey euro ours { 
		replace itrc_`def' = itrc_`def' + `extreme_gap' * (dhi_percentile-50)/100
		replace itrc_`def'_wor = itrc_`def'_wor + `extreme_gap' * (dhi_percentile-50)/100
		}
	
	 // compute scaled variables, propensities, tax rates, etc.  
		
	 gen hmc_scaled = hmc  
	 gen prop_scaled = hmc_scaled/dhi  
	 gen hmc_wor_scaled = hmc_wor
	 gen prop_wor_scaled = hmc_wor_scaled/dhi  
	 
	foreach def in carey euro ours {   
	 gen tax_eff_`def' = hmc_scaled * itrc_`def'
	 gen tax_rate_`def' = tax_eff_`def'/dhi  
	 gen inc_5_`def' = dhi - tax_eff_`def'
	 }  

	 foreach def in carey euro ours {   
	 gen tax_eff_`def'_wor = hmc_wor_scaled * itrc_`def'_wor  
	 gen tax_rate_`def'_wor = tax_eff_`def'_wor/dhi  
	 gen inc_5_`def'_wor = dhi - tax_eff_`def'_wor  
	 }   
	  
	 // version with rent  
	 gen hmc_medianized_predict_unequiv = hmc_medianized_predict*(nhhmem^0.5)   
	 egen hmc_medianized_predict_mean = wtmean(hmc_medianized_predict_unequiv) if scope, by(ccyy)  weight(hwgt) 
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
	 
	 // compute proportion of individuals with propensity > 4
	 gen prop4 = hmc/dhi > 4
	 gen prop4_scaled = prop_scaled > 4
	 gen prop4_pred_scaled = prop_pred_scaled > 4
	   
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
 drop to_output
 
 }
 
 l, compress abbreviate(32) noobs table clean
 
 /*
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
 
 */
    
end   
} // end display_percentiles


*****************************   
*        STAT_PAR_AGE       *   
*****************************   
{ 
/* This program computes quantiles of income and outputs a CSV */   
capture program drop stat_par_age   
program stat_par_age   
 syntax varlist, ccyylist(namelist)  
  
preserve

 di "************ BEGIN STAT_PAR_AGE ****************"  
 di "* " c(current_time)  

 quiet {
 
 foreach variable of local varlist {
	local varlist_q `varlist_q' `variable'_q
	egen `variable'_q = wtmean(`variable') if scope, by(ccyy agecat) weight(hwgt*nhhmem)
 }
  
 drop if agecat == . | !scope
 keep agecat ccyy `varlist_q'
 duplicates drop
 
 sort ccyy agecat
 
 gen to_output = 0
 
 foreach ccyy in `ccyylist' {
	replace to_output = 1 if ccyy=="`ccyy'"
 }
 
 drop if to_output == 0
 drop to_output
 
 }
 
 l, compress abbreviate(32) noobs table clean
    
end   
} // end stat_par_age


***************************************   
*          DISPLAY_SUMMARIES          *   
***************************************   
{ 
capture program drop oneccyy_summary   
program oneccyy_summary   
	egen mean_scope = wtmean(scope),  weight(hwgt*nhhmem) 
	
	foreach variable in $summeanvars {   
		egen mean_`variable'= wtmean(`variable') if scope,  weight(hwgt*nhhmem) 
	 }

	qui sum scope, de
	if (r(max) > 0) {
		capture qui sgini $sumondhivars [aw=hwgt*nhhmem] if scope, sortvar(dhi)  
		mat conc_dhi_ = r(coeffs)
		svmat conc_dhi_, names( matcol )

		capture confirm variable conc_dhi_c1
		if !_rc {
				noisily display as error "__________PB CALCUL CONC_DHI__________"
				noisily display as error ccyy
				exit
		}
		
		capture qui sgini $sumonvarvars [aw=hwgt*nhhmem] if scope,
		mat gini_ = r(coeffs)
		svmat gini_, names( matcol)

		capture confirm variable gini_c1
		if !_rc {
				noisily display as error "__________PB CALCUL SGINI__________"
				noisily display as error ccyy
				exit
		}
		
		capture qui sgini dhi [aw=hwgt*nhhmem] if scope_hmc, sortvar(dhi) 
		gen gini_dhi_scope_hmc = r(coeff)
	}
	
	capture confirm variable gini_dhi_scope_hmc
	if _rc { 
		gen gini_dhi_scope_hmc=.
	}

	foreach variable in $sumondhivars {
		capture confirm variable conc_dhi_`variable'
		if _rc { 
			gen conc_dhi_`variable'=.
		}
	}
		
	foreach variable in $sumonvarvars {
		capture confirm variable gini_`variable'
		if _rc { 
			gen gini_`variable'=.
		}
	}
	
	// variance du log income
	foreach variable in dhi inc_5_ours inc_5_ours_wor inc_5_ours_pred inc_5_ours_wor_pred inc1 inc2 inc3 inc4 {
		qui gen log_`variable' = log(`variable')
		qui sum log_`variable' [aw=hwgt*nhhmem] if scope, de
		qui gen varlog_`variable' = r(Var)
		drop log_`variable'
	}
	
	keep if _n == 1
	keep ccyy mean_* conc_dhi_* gini_* varlog_*

	order _all, alphabetic
	order ccyy
	
 end
 
/* This program computes summaries and outputs a CSV */   
capture program drop display_summaries   
program display_summaries   
 syntax namelist, [summeanvars(namelist) sumondhivars(namelist) sumonvarvars(namelist)]

 di "************ BEGIN DISPLAY_SUMMARIES ****************"  
 di "* " c(current_time)  

preserve

  qui local first = 1
  foreach ccyy of local namelist {
	  qui drop if ccyy != "`ccyy'"
	  
	  qui gen fourlevers = 0
		qui foreach ccyy of global redineq_datasets {
			replace fourlevers = 1 if ccyy == "`ccyy'"
		}
		qui replace fourlevers = 0 if inlist(ccyy, "at00", "be00", "gr00", "hu05", "hu07", "hu09", "hu12", "hu99", "ie00") ///
			| inlist(ccyy, "lu00", "mx00", "mx02", "mx04", "mx08", "mx10", "mx12", "mx98", "si10")
		qui replace fourlevers = 0 if inlist(ccyy, "kr06", "jp08", "is04") | inlist(cname, "Poland", "Switzerland")

		qui foreach var4L in inc1 inc2 inc3 {
			replace `var4L' = . if fourlevers != 1
		}
		
		qui replace scope = scope & !mi(inc1, inc2, inc3) if fourlevers==1
	  
	  if modelfinal == 2 | modelfinal == 10 {
		qui replace scope = scope & !mi(hmchous) if wor_ccyy
	  }
	  
	  
	  // NETTOYAGE DU SCOPE
	  qui foreach var in $summeanvars $sumondhivars $sumonvarvars {
		count if mi(`var') & scope
		if r(N) > 0 {
			replace `var' = 0
		}
	  }
	  
	  keep $summeanvars $sumondhivars $sumonvarvars hwgt nhhmem scope scope_hmc dhi ccyy ///
	  dhi inc_5_ours inc_5_ours_wor inc_5_ours_pred inc_5_ours_wor_pred inc1 inc2 inc3 inc4
	  
	  qui oneccyy_summary
	  if (`first' == 1) {
		l, compress abbreviate(32) noobs table clean
	  }
	  else {
		l, compress abbreviate(32) noobs table clean noheader
	  }
	  qui local first = 0
	  qui restore
	  qui preserve
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
	R2_0 R2_1 R2_2 ///
	non_missing_hmc ///
	non_missing_hmc_pred0 non_missing_hmc_pred1 non_missing_hmc_pred2
	
global sumondhivars

global sumonvarvars
	
global quvars_obs hmc dhi hmc_medianized					

global quvars_pred			///
	hmc_medianized_predict0 hmc_medianized_predict1 hmc_medianized_predict2			
	
global quvars $quvars_obs $quvars_pred
  
forvalues i = 0(1)2 {
	local model = `i' + 1
	estimates use "${mydata}jblasc/estimation_models/`runmodel'", number(`model')
	predict hmc_medianized_predict`i'
}
  
sort ccyy
 
 gen non_missing_hmc = !mi(hmc_medianized)
 forvalues i = 0(1)2 {
	gen error`i' = (hmc_medianized - hmc_medianized_predict`i')^2
	egen corr`i' = corr(hmc_medianized hmc_medianized_predict`i') if scope, by(ccyy)
	gen R2_`i' = corr`i'^2
	gen non_missing_hmc_pred`i' = !mi(hmc_medianized_predict`i')
 }

end   
} // end compare_models
}

***************************************   
*          DISPLAY_AVAILABILITY          *   
***************************************   
{ 

/* This program computes summaries and outputs a CSV */   
capture program drop display_availability   
program display_availability   
	qui preserve

 di "************ BEGIN DISPLAY_AVAILABILITY ****************"  
 di "* " c(current_time)  

	foreach variable of global availvars {
		gen av_`variable' = !mi(`variable')
	}
	
	qui collapse av_* if scope, by(ccyy)
	
	l, compress abbreviate(32) noobs table clean
 
	qui restore
 end
 
 }

/***************************************   
* Call function on desired datasets    
***************************************/   

main_program $ccyy_to_imput, savemodel(21_09_2022) model(10) quantiles(10)
