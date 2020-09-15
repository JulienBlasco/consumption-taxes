*******************
* Julien Blasco
* 20 June 2017
* modified 13 January 2018 to include variables in imputation model
* modified 14 Januray 2018 to count the number of zeros in hchous
* modifier 15 September 2020 to add hmchousa
*******************

/* The goal of this program is to check the proportion of missing observations
for each variable in each dataset */

capture program drop availability_matrix
program availability_matrix
	syntax namelist, variables(namelist)
	
	/* display header */
	di "ccyy,cname,year" _continue
	foreach variable of local variables {
		di ",`variable',`variable'_zeros" _continue
	}
	di
	/* load each dataset and apply check_availability */
	foreach ccyy of local namelist {
		quiet use $`ccyy'h, clear
		di "`ccyy'" "," cname "," year _continue
		check_availability `variables'
		di
	}
end

capture program drop check_availability
program check_availability
	syntax namelist
	
	qui count
	local nobs = r(N)
	
	foreach variable of local namelist {
		capture confirm variable `variable'
		if !_rc {
			qui sum `variable'
			di "," r(N)/`nobs' _continue
			local nnonmissing = r(N)
			
			qui count if `variable' == 0
			di "," r(N)/`nnonmissing' _continue
		}
		else {
			di ",." _continue
		}
	}
end

/* Call function on desired datasets */
availability_matrix au89 /*au95 au01 au03 au08 au10 at94 at95 at97 at00 at04 	///   
 at07 at10 at13 be92 be95 be97 be00 br06 br09 br11 br13 co07 co10 co13 		///   
 cz04 cz07 cz10 cz13 dk87 dk92 dk00 dk04 dk07 dk10 dk13 do07 ee00 ee04 ee07 ///   
 ee10 ee13 fi87 fi91 fi95 fi00 fi04 fi07 fi10 fi13 fr84 fr89 fr94 fr00 fr05 ///   
 fr10 de84 de89 de94 de00 de04 de07 de10 de13 gr04 gr07 gr10 				///   
 gr13 gt06 gt11 gt14 hu91 hu94 hu99 hu05 hu07 hu09 hu12 is04 is07 is10 in04 ///   
 in11 ie94 ie95 ie96 ie00 ie04 ie07 ie10 il79 il01 il05 il07 il10 			///   
 il12 it86 it87 it89 it91 it93 it95 it98 it00 it04 it08 it10 it14 jp08 lu91 ///   
 lu94 lu97 lu00 lu07 lu10 lu13 mx84 mx89 mx92 mx94 mx96 mx98 mx00 mx02 mx04 ///   
 mx08 mx10 mx12 nl83 nl87 nl04 nl07 nl10 nl13 no79 pa10 pa13 py10 py13 pe04 ///   
 pe07 pe10 pe13 pl86 pl95 pl99 pl04 pl07 pl10 pl13 ru00 ru04 ru07 ru10 ru13 ///   
 rs06 rs10 rs13 sk04 sk07 sk10 sk13 si97 si99 si04 si07 si10 si12 			///   
 es80 es90 es95 es00 es04 es07 es10 es13 se00 se05 ch82 ch92 ch07 ch10 		///   
 ch13 tw81 tw86 tw91 tw95 tw97 tw00 tw05 tw07 tw10 tw13 uk86 uk91 uk94 uk95 ///   
 uk99 uk04 uk07 uk10 uk13 us79 us86 us91 us94 us97 us00 us04 us07 us10 us13 ///   
 uy04 uy07 uy10 uy13*/, ///
variables(dhi hmc hchous hmchous hmchousa)
