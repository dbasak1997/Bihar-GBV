/*==============================================================================
File Name: FIR Data - Cleaning do file
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	25/03/2024
Created by: Dibyajyoti Basak
Updated on: 27/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to perform the cleaning and appending operations for the PS level FIR data 

==============================================================================*/

//SET-UP: Basic Definitions

/*CLEAR*/
drop _all       /*all variables and obs are dropped*/
label drop _all /*all defined labels are dropped*/
clear           /*drop _all + label drop _all*/ 
clear mata      /*Mata is a matrix programming language that can be used by those who want to perform matrix calculations interactively and by those who want to add new features to Stata.*/
clear matrix    /*clear all matrices*/

clear all /*or "clear *". Remove all data, value labels, matrices
    scalars, constraints, clusters, stored results, sersets, and Mata functions and objects
    from memory.  They also close all open files and postfiles, clear the class system,
    close any open Graph windows and dialog boxes, drop all programs from memory, and reset
    all timers to zero.*/

/*SETTINGS*/
set more off     /*avoids that stata stops*/ 
set memory 300m  /*sets memory size*/
set matsize 1000 /*sets the maximum number of variables in a model*/
set maxvar 32767 /*maximum number of variables in your dataset*/
set seed 12435   /*initial value of a random number*/

* We will log in
capture log close 

log using "$fir_data_log_files\psfir_cleaning.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$fir_data_clean_dta\ps_fir_clean.dta", clear


****dropping data before 2020
drop if year < 2020

****dropping by training date
drop if year < 2023 & ps_dist == 1001 //Bagaha
drop if year == 2023 & month < 7 & ps_dist == 1001 //Bagaha
*drop if year == 2023 & month > 11 & ps_dist == 1001 //Bagaha
*drop if year > 2023 & ps_dist == 1001 //Bagaha

drop if year < 2023 & ps_dist == 1002 //Bettiah
drop if year == 2023 & month < 5 & ps_dist == 1002 //Bettiah
*drop if year == 2023 & month > 9 & ps_dist == 1002 //Bettiah
*drop if year > 2023 & ps_dist == 1002 //Bettiah

drop if year < 2023 & ps_dist == 1003 //Bhojpur
drop if year == 2023 & month < 3 & ps_dist == 1003 //Bhojpur
*drop if year == 2023 & month > 7 & ps_dist == 1003 //Bhojpur
*drop if year > 2023 & ps_dist == 1003 //Bhojpur

drop if year < 2023 & ps_dist == 1004 //Gopalganj
drop if year == 2023 & month < 9 & ps_dist == 1004 //Gopalganj


drop if year < 2023 & ps_dist == 1005 //Motihari
drop if year == 2023 & month < 5 & ps_dist == 1005 //Motihari
*drop if year == 2023 & month > 9 & ps_dist == 1005 //Motihari
*drop if year > 2023 & ps_dist == 1005 //Motihari

drop if year < 2023 & ps_dist == 1006 //Muzaffarpur
drop if year == 2023 & month < 3 & ps_dist == 1006 //Muzaffarpur
*drop if year == 2023 & month > 7 & ps_dist == 1006 //Muzaffarpur
*drop if year > 2023 & ps_dist == 1006 //Muzaffarpur

drop if year < 2023 & ps_dist == 1007 //Nalanda
drop if year == 2023 & month < 6 & ps_dist == 1007 //Nalanda
**drop if year == 2023 & month > 10 & ps_dist == 1007 //Nalanda
drop if year > 2023 & ps_dist == 1007 //Nalanda

drop if year < 2023 & ps_dist == 1008 //Patna
drop if year == 2023 & month < 2 & ps_dist == 1008 //Patna
*drop if year == 2023 & month > 6 & ps_dist == 1008 //Patna
*drop if year > 2023 & ps_dist == 1008 //Patna

drop if year < 2023 & ps_dist == 1009 //Saran
drop if year == 2023 & month < 9 & ps_dist == 1009 //Saran

drop if year < 2022 & ps_dist == 1010 //Sitamarhi
drop if year == 2022 & month < 11 & ps_dist == 1010 //Sitamarhi
*drop if year == 2023 & month > 3 & ps_dist == 1010 //Sitamarhi
*drop if year > 2023 & ps_dist == 1010 //Sitamarhi

drop if year < 2023 & ps_dist == 1011 //Siwan
drop if year == 2023 & month < 8 & ps_dist == 1011 //Siwan
*drop if year == 2023 & month > 12 & ps_dist == 1011 //Siwan
*drop if year > 2023 & ps_dist == 1011 //Siwan

drop if year < 2023 & ps_dist == 1012 //Vaishali
drop if year == 2023 & month < 9 & ps_dist == 1012 //Vaishali


****generating dummies for male complainants
gen dum_malecomplainant = 0
replace dum_malecomplainant = 1 if dum_femalecomplainant == 0
gen dum_male_gbv = 0
replace dum_male_gbv = 1 if dum_malecomplainant == 1 & dum_gbv == 1

*****collapsing data to station-month level
collapse (sum) dum_femalecomplainant dum_gbv dum_female_gbv dum_malecomplainant dum_male_gbv count_cases dum_375-dum_petty, by(ps_dist_id year month)

****generating composite variable - year-month
gen modate=ym(year,month)
format modate %tm

gen pct_gbv = dum_gbv/count_cases

****generating percentage variables for female complainants
gen pct_femalecomplainant = dum_femalecomplainant/count_cases
gen pct_female_gbv = dum_female_gbv/count_cases
gen pct_female_gbv_subset = dum_female_gbv/dum_gbv

****generating percentage variables for male complainants
gen pct_malecomplainant = dum_malecomplainant/count_cases
gen pct_male_gbv = dum_male_gbv/count_cases
gen pct_male_gbv_subset = dum_male_gbv/dum_gbv

************

replace pct_female_gbv_subset = 0 if pct_female_gbv_subset ==.
foreach var of varlist pct_femalecomplainant pct_gbv pct_female_gbv pct_female_gbv_subset{
	egen std_`var' = std(`var')
}

replace pct_male_gbv_subset = 0 if pct_male_gbv_subset ==.
foreach var of varlist pct_malecomplainant pct_male_gbv pct_male_gbv_subset{
	egen std_`var' = std(`var')
}
                                
***Labelling
label variable dum_femalecomplainant "No. of female complainants" 
label variable dum_gbv "No. of GBV cases" 
label variable dum_female_gbv "No. of female complainants in GBV cases" 
label variable count_cases "Total no. of cases" 
label variable dum_375 "No. of cases filed under Sec.375" 
label variable dum_376 "No. of cases filed under Sec.376" 
label variable dum_511 "No. of cases filed under Sec.511" 
label variable dum_rape_attempt "No. of cases filed under attempt to rape" 
label variable dum_unnatural "No. of cases filed under forcing unnatural intercourse" 
label variable dum_362 "No. of cases filed under Sec.362" 
label variable dum_363 "No. of cases filed under Sec.363" 
label variable dum_kidnapping "No. of cases filed under kidnapping" 
label variable dum_302 "No. of cases filed under Sec.302" 
label variable dum_304b "No. of cases filed under Sec.304b" 
label variable dum_306 "No. of cases filed under Sec.306" 
label variable dum_murder "No. of cases filed under murder" 
label variable dum_cruelty "No. of cases filed under cruelty" 
label variable dum_354 "No. of cases filed under Sec.354" 
label variable dum_298 "No. of cases filed under Sec.298" 
label variable dum_harassment "No. of cases filed under harassment" 
label variable dum_modesty "No. of cases filed under outraging modesty" 
label variable dum_418 "No. of cases filed under Sec.418" 
label variable dum_420 "No. of cases filed under Sec.420" 
label variable dum_cheating "No. of cases filed under cheating" 
label variable dum_503 "No. of cases filed under Sec.503" 
label variable dum_506 "No. of cases filed under Sec.506" 
label variable dum_intimidation "No. of cases filed under intimidation" 
label variable dum_66 "No. of cases filed under Sec.66" 
label variable dum_67 "No. of cases filed under Sec.67" 
label variable dum_292 "No. of cases filed under Sec.292" 
label variable dum_onlineharassment "No. of cases filed under online harassment"    
label variable pct_femalecomplainant "Percentage of female complainants (of total cases)" 
label variable pct_gbv "Percentage of GBV cases (of total cases)"

rename pct_female_gbv pct_female_gbv_totalcases
label variable pct_female_gbv_totalcases "Percentage of female complainants of GBV (of total cases)"

rename pct_female_gbv_subset pct_female_gbv_totalgbv
label variable pct_female_gbv_totalgbv "Percentage of female complainants of GBV (of total GBV cases)"  

label variable std_pct_femalecomplainant "Standardized values of percentage of female complainants (of total cases)"  
label variable std_pct_gbv "Standardized values of percentage of GBV cases (of total cases)"  

rename std_pct_female_gbv std_pct_female_gbv_totalcases
label variable std_pct_female_gbv_totalcases "Standardized values of percentage of female complainants of GBV (of total cases)"

rename std_pct_female_gbv_subset std_pct_female_gbv_totalgbv
label variable std_pct_female_gbv_totalgbv "Standardized values of percentage of female complainants of GBV (of total GBV cases)"  

rename pct_male_gbv pct_male_gbv_totalcases    
label variable pct_male_gbv_totalcases "Percentage of male complainants of GBV (of total cases)"   

rename pct_male_gbv_subset pct_male_gbv_totalgbv
label variable pct_male_gbv_totalgbv "Percentage of male complainants of GBV (of total GBV cases)" 
 

label variable pct_malecomplainant "Percentage of male complainants (of total cases)"  
label variable dum_male_gbv "No. of male complainants in GBV cases"  
label variable dum_malecomplainant "No. of male complainants"
 
rename std_pct_male_gbv std_pct_male_gbv_totalcases
label variable std_pct_male_gbv_totalcases "Standardized values of percentage of male complainants of GBV (of total cases)"

rename std_pct_male_gbv_subset std_pct_male_gbv_totalgbv
label variable std_pct_male_gbv_totalgbv "Standardized values of percentage of male complainants of GBV (of total GBV cases)"

label variable std_pct_malecomplainant "Standardized values of percentage of male complainants (of total cases)"   
  
merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta"
drop if _m != 3
drop _m


*****saving the station-month level dataset
save "$fir_data_clean_dta\ps_fir_stationmonth.dta", replace

preserve
drop if treatment == 0
foreach var of varlist dum_femalecomplainant-std_pct_male_gbv_totalgbv /*empathy_Reg_decoy VB_Reg_decoy Ext_Reg_decoy swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy*/ {
	rename `var' `var'_t
}
drop treatment
order modate
collapse (mean) count_cases pct_gbv_t pct_femalecomplainant_t pct_female_gbv_totalcases_t pct_female_gbv_totalgbv_t std_pct_femalecomplainant_t std_pct_female_gbv_totalcases_t std_pct_female_gbv_totalgbv_t, by(modate)
save "$decoy_intermediate_dta\ps_fir_treatment.dta", replace
restore

preserve
keep if treatment == 0
foreach var of varlist dum_femalecomplainant-std_pct_male_gbv_totalgbv /*empathy_Reg_decoy VB_Reg_decoy Ext_Reg_decoy swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy*/ {
	rename `var' `var'_c
}
drop treatment
order modate

****collapsing to year-month level
collapse (mean) count_cases pct_gbv_c pct_femalecomplainant_c pct_female_gbv_totalcases_c pct_female_gbv_totalgbv_c std_pct_femalecomplainant_c std_pct_female_gbv_totalcases_c std_pct_female_gbv_totalgbv_c, by(modate)
rename modate_c modate
save "$decoy_intermediate_dta\ps_fir_control.dta", replace
restore

use "$decoy_intermediate_dta\ps_fir_treatment.dta", clear
rename modate_t modate 
merge 1:1 modate using "$decoy_intermediate_dta\ps_fir_control.dta"
drop _m


****declaring as panel dataset
tsset modate

*****generating graphs

******Total cases
tsline count_cases_t count_cases_c, ttick(754, tpos(in)) ///
ttext(42 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Number of cases filed") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\01 Number of cases.gph", replace

******Female Complainants
tsline pct_femalecomplainant_t pct_femalecomplainant_c, ttick(754, tpos(in)) ///
ttext(0.21 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Percentage of female complainants") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\02 PCT_Female Complainants.gph", replace

tsline std_pct_femalecomplainant_t std_pct_femalecomplainant_c, ttick(754, tpos(in)) ///
ttext(-0.3 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Standardised percentage of female complainants") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\03 PCT_Standardised_Female Complainants.gph", replace

******GBV complaints
tsline pct_gbv_t pct_gbv_c, ttick(754, tpos(in)) ///
ttext(0.27 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Percentage of GBV cases") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\04 PCT_GBV Cases.gph", replace

******Female complainants of GBV (as a percentage of total cases)
tsline pct_female_gbv_totalcases_t pct_female_gbv_totalcases_c, ttick(754, tpos(in)) ///
ttext(0.24 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Percentage of female complainants filing GBV cases") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\05 PCT_Female Complainants_GBV Cases.gph", replace

tsline std_pct_female_gbv_totalcases_t std_pct_female_gbv_totalcases_c, ttick(754, tpos(in)) ///
ttext(-0.4 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Standardised percentage of female complainants filing GBV cases") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\06 PCT_Standardised_Female Complainants_GBV Cases.gph", replace

******Female complainants of GBV (as a percentage of GBV cases)
tsline pct_female_gbv_totalgbv_t pct_female_gbv_totalgbv_c, ttick(754, tpos(in)) ///
ttext(0.32 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Percentage of female complainants filing GBV cases ONLY") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\07 PCT_Female Complainants_GBV Cases Only.gph", replace

tsline std_pct_female_gbv_totalgbv_t std_pct_female_gbv_totalgbv_c, ttick(754, tpos(in)) ///
ttext(-0.2 755 "Training Begins", orient(horiz) size(0.23cm)) ///
tline(2022m11) ///
xtitle("Timeline") ///
xlabel(#3, format(%tmMon_CCYY) labsize(small)) ///
title("Standardised percentage of female complainants filing GBV cases ONLY") /// 
legend(order(1 "Treatment" 2 "Control"))
graph save "Graph" "$fir_data_graphs\08 PCT_Standardised_Female Complainants_GBV Cases Only.gph", replace


save "$decoy_clean_dta\ps_fir_collapsed.dta", replace

