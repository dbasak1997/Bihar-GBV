/*==============================================================================
File Name: Decoy Survey 2023 - Indices do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	24/05/2024
Created by: Dibyajyoti Basak
Updated on: 24/05/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to create indices for the Decoy Survey 2023

*	Inputs: 02.intermediate-data  "02.ren-officersurvey_intermediate"
*	Outputs: 06.clean-data  "01.officersurvey_clean_PII"

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

log using "$decoy_log_files\decoysurvey_indices.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$decoy_clean_dta\decoy_clean_WIDE.dta", clear


//Empathy Index
codebook d1a* d1b* d1c* d1d* d1e*

foreach var of varlist d1a* d1b* d1c* d1e*{
	gen `var'_dum = `var'
	recode `var'_dum 1=0 2=0 3=0 4=1 5=1
}

 **creating the Empathy index (Anderson)
drop wgt stdgroup
gen wgt=1
gen stdgroup = treatment_station_decoy == 0
qui do "$decoy_do_files\make_index_gr.do" //Execute Anderson index do file

local empathy d1a_visit1_dum-d1e_visit3_dum d1d*
make_index_gr empathy_And_decoy wgt stdgroup `empathy'
label var index_empathy_And_decoy "Empathy Index (Anderson)"
summ index_empathy_And_decoy

**creating the Empathy index (Regular)
egen index_empathy_Reg_decoy = rowmean(d1a_visit1_dum-d1e_visit3_dum d1d*)
label var index_empathy_Reg_decoy "Empathy Index (Regular)"
summ index_empathy_Reg_decoy


//Victim-blaming Index
codebook d2a* d2b* d2c* d2d*

foreach var of varlist d2a* d2d* d3a* {
	gen `var'_dum = `var'
	recode `var'_dum 1=1 2=1 3=1 4=0 5=0
}

foreach var of varlist d2b* d2c*{
	gen `var'_dum = `var'
	recode `var'_dum 0=1 1=0
}

 **creating the Victim-blaming index (Anderson)
qui do "$decoy_do_files\make_index_gr.do" //Execute Anderson index do file

local VB d2a_visit1_dum-d2d_visit3_dum d3a_visit1_dum d3a_visit2_dum d3a_visit3_dum
make_index_gr VB_And_decoy wgt stdgroup `VB'
label var index_VB_And_decoy "Victim-blaming Index (Anderson)"
summ index_VB_And_decoy

**creating the Victim-blaming index (Regular)
egen index_VB_Reg_decoy = rowmean(d2a_visit1_dum-d2d_visit3_dum d3a_visit1_dum d3a_visit2_dum d3a_visit3_dum)
label var index_VB_Reg_decoy "Victim-blaming Index (Regular)"
summ index_VB_Reg_decoy


//Externalising Responsibilites Index
codebook d4a* d4b* d4c*


foreach var of varlist d4a* d4b*{
	gen `var'_dum = `var'
	recode `var'_dum 0=1 1=0
}

foreach var of varlist d4c*{
	gen `var'_dum = `var'
	recode `var'_dum 1=1 2=1 3=1 4=0 5=0
}

foreach var of varlist d5a*{
	gen `var'_dum = `var'
	recode `var'_dum 1=0 2=0 3=0 4=1 5=1
}

foreach var of numlist 1 2 3{
	gen d5b_visit`var'_dum = 0
	replace d5b_visit`var'_dum = 1 if d5b_1_visit`var' == 1 | d5b_2_visit`var' == 1 | d5b_3_visit`var' == 1 | d5b_4_visit`var' == 1
}

/*
replace d5b_visit1_dum = 1 if key_visit1 == "uuid:9533d189-cdde-4931-a26e-d3ad73cad337"
replace d5b_visit1_dum = 1 if key_visit1 == "uuid:d9ae3097-e8bc-4814-a997-ca5657bd9f82"

replace d5b_visit2_dum = 1 if key_visit2 == "uuid:621e915f-b15d-4492-9725-c82e8aff947d"
replace d5b_visit2_dum = 1 if key_visit2 == "uuid:a1bef844-b429-4008-8f13-2177fd0bde19"
*/

local Extern d4a_visit1_dum-d4c_visit3_dum d5b_visit1_dum d5b_visit2_dum d5b_visit3_dum
make_index_gr Ext_And_decoy wgt stdgroup `Extern'
label var index_Ext_And_decoy "Externalising Responsibilites Index (Anderson)"
summ index_Ext_And_decoy

**creating the Externalising Responsibilites index (Regular)
egen index_Ext_Reg_decoy = rowmean(d4a_visit1_dum-d4c_visit3_dum d5b_visit1_dum d5b_visit2_dum d5b_visit3_dum)
label var index_Ext_Reg_decoy "Externalising Responsibilites Index (Regular)"
summ index_Ext_Reg_decoy

rename index_* *

recode treatment_station_decoy 0=1 1=0

swindex d1a_visit1_dum-d1e_visit3_dum d1d*, g(swindex_Empathy_decoy) normby(treatment_station_decoy) displayw

swindex d2a_visit1_dum-d2d_visit3_dum d3a_visit1_dum d3a_visit2_dum d3a_visit3_dum, g(swindex_VictimBlame_decoy) normby(treatment_station_decoy) displayw

swindex d4a_visit1_dum-d4c_visit3_dum d5b_visit1_dum d5b_visit2_dum d5b_visit3_dum, g(swindex_ExtPol_decoy) normby(treatment_station_decoy) displayw

***Visit 1
swindex d1a_visit1_dum-d1e_visit1_dum d1d_visit1, g(swindex_Empathy_decoy1) normby(treatment_station_decoy) displayw
swindex d2a_visit1_dum-d2c_visit1_dum, g(swindex_VictimBlame_decoy1) normby(treatment_station_decoy) displayw
swindex d4a_visit1_dum-d4c_visit1_dum, g(swindex_ExtPol_decoy1) normby(treatment_station_decoy) displayw

***Visit 2
swindex d1a_visit2_dum-d1e_visit2_dum d1d_visit2, g(swindex_Empathy_decoy2) normby(treatment_station_decoy) displayw
swindex d2a_visit2_dum-d2c_visit2_dum, g(swindex_VictimBlame_decoy2) normby(treatment_station_decoy) displayw
swindex d4a_visit2_dum-d4c_visit2_dum, g(swindex_ExtPol_decoy2) normby(treatment_station_decoy) displayw

***Visit 3
swindex d1a_visit3_dum-d1e_visit3_dum d1d_visit3, g(swindex_Empathy_decoy3) normby(treatment_station_decoy) displayw
swindex d2a_visit3_dum-d2c_visit3_dum, g(swindex_VictimBlame_decoy3) normby(treatment_station_decoy) displayw
swindex d4a_visit3_dum-d4c_visit3_dum, g(swindex_ExtPol_decoy3) normby(treatment_station_decoy) displayw

swindex ps_bathroom ps_confidential dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv, g(swindex_psfs_gen_bl) normby(treatment_station_decoy) displayw

swindex ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter, g(swindex_psfs_fem_infra_bl) normby(treatment_station_decoy) displayw

swindex dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho, g(swindex_psfs_m_f_seg_bl) normby(treatment_station_decoy) displayw

recode treatment_station_decoy 0=1 1=0
      
label variable swindex_Empathy_decoy "Empathy"
foreach var of varlist swindex_Empathy_decoy*{
	label variable `var' "Empathy"
}

label variable swindex_VictimBlame_decoy "Victim-blaming"
label variable swindex_ExtPol_decoy "Externalising police responsibilities"

save "$decoy_clean_dta\decoy_indices.dta", replace