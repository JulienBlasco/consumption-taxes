*************************************************************
* Define globals
*************************************************************

global datasets "at04 at07 at13 au03 au08 au10 ca04 ca07 ca10 ca13 ch00 ch02 ch04 ch07 ch10 ch13 cz02 cz04 cz07 cz10 cz13 de00 de04 de07 de10 de13 de15 dk00 dk04 dk07 dk10 dk13 ee10 ee13 es07 es10 es13 fi00 fi04 fi07 fi10 fi13 fr00 fr05 fr10 gr07 gr10 gr13 ie04 ie07 ie10 il10 is04 is07 is10 it04 it08 it10 it14 jp08 kr06 kr08 kr10 kr12 lu04 lu07 lu10 lu13 nl99 nl04 nl07 nl10 nl13 no00 no04 no07 no10 no13 pl04 pl07 pl10 pl13 pl16 pl99 se00 se05 sk04 sk07 sk10 sk13 uk99 uk04 uk07 uk10 uk13 us00 us04 us07 us10 us13 us16 at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10"  /*it00 il12 si12*/ 
global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10" /*it00*/ // Removed es00 and it98 in this version since they contain dupicates and missing values respectively in pil.
global pvars "pid hid dname pil pxit pxiti pxits age emp relation"
global hvars "hid dname nhhmem dhi nhhmem17 nhhmem65 hwgt"
global hvarsflow "hil hic pension hits hitsil hitsup hitsap hxit hxiti hxits hc hicvip dhi hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps" // Local currency, given in the datasets
global hvarsnew "hsscer hsscee" // Local currency, imputed
global hvarsinc "inc1 inc2 inc3 inc3_SSER inc3_SSEE inc4 tax transfer allpension pubpension pripension hssc" // Summation / imputed after PPP conversion
global incconcept "inc1 inc2 inc3 inc3_SSER inc3_SSEE inc4" /*Concept of income: for the loops*/
global fixpension_datasets3 "ie04 ie07 ie10 uk99 uk04 uk07 uk10 uk13"

*************************************************************
* Program: Generate SSC variables from person level dataset
*************************************************************

program define gen_pvars
  merge_ssc
  gen_employee_ssc
  manual_corrections_employee_ssc
  gen_employer_ssc
  manual_corrections_employer_ssc
  convert_ssc_to_household_level
end


program define merge_ssc
	* Merge labour income variables for gross and mixed datasets
	merge m:1 dname using "$mydata/vamour/SSC_20180621.dta", keep(match master) nogenerate
	 * Impute taxes for net datasets
	nearmrg dname using "$mydata/molcke/net_20161101.dta", nearvar(pil) lower keep(match master) nogenerate
end


program define gen_employee_ssc
  * Generate Employee Social Security Contributions	
  {
  **IMPORTANT**Convert Italian datasets from net to gross
  replace pil=pil+pxit if income_type == "Italy"
  
  replace psscee = pil*ee_r1 if inlist(income_type, "gross", "Italy")
  replace psscee = (pil-ee_c1)*ee_r2 + ee_r1*ee_c1  if pil>ee_c1 & ee_c1!=. & inlist(income_type, "gross", "Italy")
  replace psscee = (pil-ee_c2)*ee_r3 + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c2 & ee_c2!=. & inlist(income_type, "gross", "Italy")
  replace psscee = (pil-ee_c3)*ee_r4 + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c3 & ee_c3!=. & inlist(income_type, "gross", "Italy")
  replace psscee = (pil-ee_c4)*ee_r5 + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c4 & ee_c4!=. & inlist(income_type, "gross", "Italy")
  replace psscee = (pil-ee_c5)*ee_r6 + ee_r5*(ee_c5 - ee_c4) + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1  if pil>ee_c5 & ee_c5!=.  & inlist(income_type, "gross", "Italy")
  
   **IMPORTANT**Convert French datasets from net to gross
   * Impute individual level income tax from household level income tax
  bysort ccyy hid: egen hemp = total(emp) , missing // missing option to set a total of all missing values to missing rather than zero.
  replace pxiti = hxiti/hemp if income_type == "France"
  replace pxiti =. if emp!=1 & income_type == "France"
  * Impute Employee Social Security Contributions
  /*We assume that the original INSEE survey provides information about actual "net" wages in the sense "net of all contributions" and not in the sense of "declared income", which contains non deductible CSG. If not, one should 
  remove this rate in the excel file and add it manually after we have the gross income*/
  replace psscee = pil*ee_r1/(1-ee_r1) if pil>0 & pil<=(ee_c1 - ee_r1*ee_c1) & income_type == "France"
  replace psscee = 1/(1-ee_r2)*(ee_r2*(pil - ee_c1) + ee_r1*ee_c1) if pil>(ee_c1 - ee_r1*ee_c1) & pil<=(ee_c2 - ee_r1*ee_c1 - ee_r2*(ee_c2-ee_c1)) & income_type == "France"
  replace psscee = 1/(1-ee_r3)*(ee_r3*(pil - ee_c2) + ee_r1*ee_c1 + ee_r2*(ee_c2-ee_c1)) if pil>(ee_c2 - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & pil<=(ee_c3 - ee_r3*(ee_c3-ee_c2) - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & income_type == "France"
  replace psscee = 1/(1-ee_r4)*(ee_r4*(pil - ee_c3) + ee_r1*ee_c1 + ee_r2*(ee_c2-ee_c1) + ee_r3*(ee_c3 - ee_c2)) if pil>(ee_c3 - ee_r3*(ee_c3-ee_c2) - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & income_type == "France"
**IMPORTANT**Convert French datasets from net to gross
  replace pil=pil+pxiti+psscee if income_type == "France" /* J'AI UN DOUTE SUR CETTE PARTIE : pourquoi rajouter l'IR aux salaires avant le calcul des cotisations employeur mais pas employé ? */
  }
end


program define gen_employer_ssc
  * Generate Employer Social Security Contributions
  {
  replace psscer = pil*er_r1 if inlist(income_type, "gross", "Italy", "France")
  replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=. & inlist(income_type, "gross", "Italy", "France")
  replace psscer = (pil-er_c2)*er_r3 + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c2 & er_c2!=. & inlist(income_type, "gross", "Italy", "France")
  replace psscer = (pil-er_c3)*er_r4 + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c3 & er_c3!=. & inlist(income_type, "gross", "Italy", "France")
  replace psscer = (pil-er_c4)*er_r5 + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c4 & er_c4!=. & inlist(income_type, "gross", "Italy", "France")
  replace psscer = (pil-er_c5)*er_r6 + er_r5*(er_c5 - er_c4) + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1  if pil>er_c5 & er_c5!=.  & inlist(income_type, "gross", "Italy", "France")
  }
end

program define convert_ssc_to_household_level
  * Convert variables to household level 
  {
  bysort ccyy hid: egen hsscee=total(psscee)
  bysort ccyy hid: egen hsscer=total(psscer)
  bysort ccyy hid: replace hxiti=total(pinctax) if income_type == "net"
  
  *create a dummy variable taking 1 if head of household btw 25 and 59
  gen headactivage=1 if age>24 & age<60 & relation==1000
  replace headactivage=0 if headactivage!=1
  bys ccyy hid: egen hhactivage=total(headactivage)
  
  * Keep only household level SSC and household id and activage dummy
  drop pid pil pxit pxiti pxits age emp relation headactivage /* VA PROBABLEMENT PLANTER CAR IL Y A ENCORE PINCTAX ET PTET D'AUTRES */
  drop if hid==.
  duplicates drop
  }
end


***************************************************************************
* Helper Program: Manual corrections
***************************************************************************

program define manual_corrections_employee_ssc
  * Manual corrections for certain datasets (Employee Social Security Contributions)
  {
  *Belgium 2000 BE00
  replace psscee=psscee-2600 if pil>34000 & pil<=42500 & dname=="be00"
  replace psscee=psscee-(2600-0.4*(pil-42500)) if pil>42500 & pil<=4900 & dname=="be00"
  bysort ccyy hid: egen hil=total(pil) if dname=="be00"
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

program define manual_corrections_employer_ssc
  * Manual corrections for certain datasets (Employer Social Security Contributions)
  {
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


program define missing_values
/*Here we replace missing values of aggregates by the sum of values of the subvariables if it brings extra information*/
	{
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




**************************************************
* Program: Define taxes and transfer variables
**************************************************

program define def_tax_and_transfer
  gen pubpension = hitsil + hitsup /*Use conventional definition: hitsil + hitsup if nothing missing. Recall that hitsil or hitsup may have been "enriched" by their components but there are still missing values left */
  * if hitsil or hitsup is missing (=> previous formula generates a missing value), use the negative definition of pubpension*/
 
  replace pubpension= pension - hicvip - hitsap if pubpension==. /*Recall: pension = hitsil + hitsup + hicvip + hitsap: if hicvip and hitsap are defined, hitsil + hitsup can be defined by the residual*/
  replace pubpension = pension - hicvip if pubpension==.  /*use pension - hicvip if only hitsap missing*/
  replace pubpension = pension - hitsap if pubpension==.  /*use pension - hitsap if only hicvip missing*/
  replace pubpension = pension if pubpension==. /*if pension is the only variable not missing, use this as pubpension*/
  
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

  gen inc1 = marketincome
  gen inc2 = marketincome + allpension
  gen inc3 = marketincome + allpension + transfer
  gen inc3_SSER = marketincome + allpension + transfer - hsscer /*Inc3 minus Employer (ER) social security contributions (SSER)*/
  gen inc3_SSEE = marketincome + allpension + transfer - hsscer - hxits /*Inc3 minus ER and EE SSC*/
  gen inc4 = marketincome + allpension + transfer - tax


end


***************************************************************************
* Program: Adjustments to pensions for UK and Ireland
***************************************************************************

/* In the preceding income definitions, UK and Ireland have transfers that
seem to be too high. We propose moving HITSAP (old-age, disability assistance
pensions, a subcategory of assistance benefits) out of transfers, and into
pensions.  */

program define fix_pensions_type3
  drop pubpension allpension transfer inc1 inc2 inc3 inc4 inc3_SSER inc3_SSEE decile_inc1 decile_inc2 decile_inc3 decile_inc4 decile_inc3_SSER decile_inc3_SSEE hhaa_decile_inc1 hhaa_decile_inc2 hhaa_decile_inc3 hhaa_decile_inc4 hhaa_decile_inc3_SSER hhaa_decile_inc3_SSEE
  gen pubpension = hitsil + hitsup + hitsap // Added "+hitsap"
  *gen pripension = hicvip // No change
  gen allpension = pension // Removed "-hitsap"
  gen transfer = hits - pubpension
  *gen tax = hxit + hsscer // No change
  *gen marketincome = hil + (hic-hicvip) + hsscer // No change

  gen inc1 = marketincome
  gen inc2 = marketincome + allpension
  gen inc3 = marketincome + allpension + transfer
  gen inc3_SSER = marketincome + allpension + transfer - hsscer /*Inc3 minus Employer (ER) social security contributions (SSER)*/
  gen inc3_SSEE = marketincome + allpension + transfer - hsscer - hxits /*Inc3 minus ER and EE SSC*/
  gen inc4 = marketincome + allpension + transfer - tax

end

***************************************************************************
* Program: Adjustments to tax for France
***************************************************************************

program define FR_def_tax_and_transfer
  drop tax inc1 inc2 inc3 inc4 inc3_SSER inc3_SSEE  decile_inc1 decile_inc2 decile_inc3 decile_inc4 decile_inc3_SSER decile_inc3_SSEE hhaa_decile_inc1 hhaa_decile_inc2 hhaa_decile_inc3 hhaa_decile_inc4 hhaa_decile_inc3_SSER hhaa_decile_inc3_SSEE marketincome
 * Impute the taxes CSG and CRDS
  FR_tax_CSG_CRDS
  * Define the components of the income stages
  gen tax = hxiti + hxits + hsscer + hic_csg_crds + pension_csg_crds
  * For France, incomes are reported net of ssc, but gross of income tax
  gen marketincome = hil + (hic-hicvip) + hsscer + hic_csg_crds + hxits + pension_csg_crds

end

program define FR_tax_CSG_CRDS
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
    gen hil_temp=hil-hxiti-hsscee /*On regarde bien le salaire net pour calculer le RFR*/
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (6584+2*(familyshare - 1)*1759) & hxit<=0 & dname=="fr00" // 2002 figures deflated to 2000 prices using WDI CPI
    replace pension_csg_crds = 0.067/(1-0.067)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (6584+2*(familyshare - 1)*1759) & hxit>0 & dname=="fr00" // 2002 figures deflated to 2000 prices using WDI CPI
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (7165+2*(familyshare - 1)*1914) & hxit<=0 & dname=="fr05"
    replace pension_csg_crds = 0.071/(1-0.071)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97)+ hitsil + hitsup)*0.9 + hic) >  (7165+2*(familyshare - 1)*1914) & hxit>0 & dname=="fr05"
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (9876+2*(familyshare - 1)*2637) & hxit<=0 & dname=="fr10"
    replace pension_csg_crds = 0.071/(1-0.071)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (9876+2*(familyshare - 1)*2637) & hxit>0& dname=="fr10"
    drop hil_temp
end


*********************************************************
* add income_type as a variable 
*********************************************************
gen income_type = ""
foreach ccyy in $datasets {
	local cc : di substr("`ccyy'",1,2)
	  if "`cc'" == "fr" {
		replace income_type = "France"
	  }
	  else if "`cc'" == "it" {
		replace income_type = "Italy"
	  }
	  else if strpos("$net_datasets","`ccyy'") > 0 {
		replace income_type = "net"
	  }
	  else {
		replace income_type = "gross"
	  }
	
	


**********************************************************
* Loop over datasets
**********************************************************

foreach ccyy in $datasets {
  quietly use $pvars using $`ccyy'p, clear
  
  *************
  * Generate social security variables from person level dataset
  *************
  local cc : di substr("`ccyy'",1,2)
  if "`cc'" == "fr" {
    quietly merge m:1 hid using "$`ccyy'h", keep(match) keepusing(hxiti) nogenerate
    quietly FR_gen_pvars
  }
  else if "`cc'" == "it" {
    quietly merge m:1 hid using "$`ccyy'h", keep(match) keepusing(hxiti) nogenerate
    quietly IT_gen_pvars
  }
  else if strpos("$net_datasets","`ccyy'") > 0 {
    quietly NET_gen_pvars
  }
  else {
    quietly gen_pvars
  }
  
  
  *************
  *  Merge with households variables
  *************
  quietly merge 1:1 hid using $`ccyy'h,  nogenerate // keepusing($hvars $hvarsflow)
  
  *************
  * Do some corrections and equivalization
  *************
  quietly missing_values
  
    replace hsscer=0 if hsscer<0 // Employer
    replace hsscee=0 if hsscee<0 // Employee
  
  foreach var in $hvarsflow $hvarsnew {
    replace `var' = (`var')/(nhhmem^0.5)
    }
	
 *********************************** 
 * Define the different stages of income
 ***********************************
  quietly def_tax_and_transfer
  if "`cc'" == "fr" {
    quietly FR_def_tax_and_transfer
  }
  foreach certain_ccyy in $fixpensions_datasets3 {
    quietly fix_pensions_type3 if "`ccyy'" == "`certain_ccyy'"
  }

   }
 
program drop _all
clear all
