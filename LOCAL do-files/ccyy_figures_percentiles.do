use "G:\DTA\LOCAL_datasets\jblasc\18-09-09 availability matrix.dta", clear
merge 1:1 ccyy using "G:\DTA\LOCAL_datasets\jblasc\18-09-09 availability matrix.dta", nogen
merge 1:1 cname year using "G:\DTA\LOCAL_datasets\jblasc\18-08-31_itrcs_scalings.dta", ///
	nogen keep(master match)

global datasets_w_hchous ///
	au89 au95 au01 au03 au08 au10 at04 at07 at10 at13 co07 cz07 cz10 cz13 dk04 ee00 ee04 ee07 ee10 ee13 ///
	fi91 fr84 fr89 fr00 fr05 fr10 de84 de89 de94 de00 de04 de07 de10 de13 gr07 gr10 gr13 gt06 gt11 gt14 ///
	hu91 hu94 hu05 hu07 hu09 hu12 is07 in04 in11 il92 il97 il01 il05 il07 il10 il12 it87 it89 it91 it93 it14 lt10 lt13 ///
	lu91 lu94 lu97 lu00 lu07 lu10 lu13 mx84 mx89 mx92 mx94 mx96 mx98 mx00 mx02 mx04 mx08 mx10 mx12 ///
	nl04 nl07 nl10 nl13 pa10 pa13 py10 py13 pe04 pe07 pe10 pe13 pl86 pl95 pl99 pl04 pl13 ro97 ru10 ru13 rs06 ///
	rs10 rs13 sk07 sk10 sk13 si97 si99 si04 si07 si10 si12 za08 za12 es80 es85 es90 es07 es10 es13 se00 ch00 ///
	ch02 ch04 ch07 ch10 ch13 tw81 tw86 tw91 tw95 tw97 tw00 tw05 tw07 tw10 tw13 ///
	 uy04 uy07 uy10 uy13 uy16

replace model2_ccyy = 0
qui foreach ccyy in $datasets_w_hchous {
	replace model2_ccyy = 1 if ccyy == "`ccyy'"
}

replace wor_ccyy = 1 if ccyy == "au10"

gen ccyy_papier = .
gen ccyy_lighter = ""
foreach ccyy in at13 au10 be97 cz13 dk13 ee13 fi13 fr10 de13 gr13 is10 ie10 ///
	mx12 nl13 pl13 si12 es13 {
	replace ccyy_papier = 1 if ccyy == "`ccyy'"
	replace ccyy_lighter = " " if ccyy == "`ccyy'"
}
foreach ccyy in br13 hu12 it10 no13 za12 se05 ch13 uk13 {
	replace ccyy_papier = 1 if ccyy == "`ccyy'"
	replace ccyy_lighter = "*" if ccyy == "`ccyy'"
}


// Figure 1
// CROSS-VALIDATION
core : au10 ee00 fr10 mx12 pl13 si12 ch04
lighter :  uk95 it10

// CORE AND LIGHTER
// Table 1
 at13 au10 be97 cz13 de13 dk13 ee13 es13 fi13 fr10 gr13 ie10 is10 mx12 nl13 no13 pl13 se05 si12 uk13 us13
 
 // Figure 3
 dk13 fr10 us13 de13

 // Figure 9, 10, Table 2
us13
  
// Figure 12
fr10 us13

// Figure D.a
fr10

// TOTAL
at13 au10 be03 be97 ch04 cz13 de13 dk13 ee00 ee13 es13 es98 fi13 ///
fi98 fr10 fr98 gr04 gr13 hu05 ie01 ie10 is10 it10 lu98 mx12 nl13 ///
nl98 no13 pl13 pt98 se05 se98 si12 sl12 uk04 uk13 uk95 us13 

