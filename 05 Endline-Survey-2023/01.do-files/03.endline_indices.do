/*==============================================================================
File Name: Baseline Officer's Survey 2022 - Creating Endline Indices
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	07/10/2023
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to create indices on the Endline Officer's Survey 2023. 

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

log using "$MO_endline_log_files\officersurvey_endlineindices.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


use "$MO_endline_intermediate_dta\endline_clean.dta", clear
drop if consent_el == 0

**merging endline data and PS variables
rename *_el *
rename ps_dist ps_dist_el
rename po_rank po_rank_el
merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta"
drop if _m != 3
drop _m
rename * *_el
drop *_el_el

 ****************************************REDOING THE INDICES**********************************************************************
 **Rationale for recoding 0 = gender-regressive, 1 = gender-progressive (or simply regressive/progressive for indices like Flexibility, Desirability, etc.) 
/*The individual variables are first converted to dummy variables. For questions that used a 5-point Likert scale, the binary variable was coded as 1 if the respondent answered "Strongly Agree" or "Agree" with a gender-progressive statement (or "Strongly Disagree" or "Disagree" with a gender-regressive statement), and 0 otherwise. (Jayachandran, 2018)*/

 **Replacing multivariates with dummy variables
 
 gen openness_1_el_dum=openness_1_el
 recode openness_1_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_2_el_dum=openness_2_el
 recode openness_2_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_3_el_dum=openness_3_el 
 recode openness_3_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_4_el_dum=openness_4_el
 recode openness_4_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_5_el_dum=openness_5_el
 recode openness_5_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_6_el_dum=openness_6_el
 recode openness_6_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_7_el_dum=openness_7_el
 recode openness_7_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_8_el_dum=openness_8_el
 recode openness_8_el_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_9_el_dum=openness_9_el
 recode openness_9_el_dum 1=1 2=1 3=0 4=0 5=0
 
  **recoding Refused to Answer and DN values
 
 recode openness_1_el_dum -666=0    
 recode openness_2_el_dum -666=0    
 recode openness_3_el_dum -666=0    
 recode openness_4_el_dum -666=0    
 recode openness_5_el_dum -666=0    
 recode openness_6_el_dum -666=0    
 recode openness_7_el_dum -666=0    
 recode openness_8_el_dum -666=0    
 recode openness_9_el_dum -666=0   
 
 **creating the Openness index (Anderson)
gen wgt=1
gen stdgroup=1
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file
local open1 openness_1_el_dum openness_2_el_dum openness_3_el_dum openness_4_el_dum openness_5_el_dum openness_6_el_dum openness_7_el_dum openness_8_el_dum openness_9_el_dum
make_index_gr Openness_And_el wgt stdgroup `open1'
label var index_Openness_And_el "Openness Index (Anderson)"
summ index_Openness_And_el

**creating the Openness index (Regular)
egen index_Openness_Reg_el = rowmean(openness_1_el_dum openness_2_el_dum openness_3_el_dum openness_4_el_dum openness_5_el_dum openness_6_el_dum openness_7_el_dum openness_8_el_dum openness_9_el_dum)
label var index_Openness_Reg_el "Openness Index (Regular)"
summ index_Openness_Reg_el

***Victim-Blaming Index***

**codebook of variables to be used for the Victim Blaming index
codebook dv2_goes_without_informing_el dv2_neglects_children_el dv2_burns_food_el dv2_argues_el dv2_refuses_sex_el
rename prem_soc_unacceptable_el psu_el
codebook psu_el
codebook non_gbv_fem_fault_el

**recoding 0 = positive outcome, 1 = negative outcome
gen dv2_without_informing_dum_el = dv2_goes_without_informing_el
recode dv2_without_informing_dum_el 0=1 1=0 -999=0 -666=0
gen dv2_neglects_children_dum_el = dv2_neglects_children_el
recode dv2_neglects_children_dum_el 0=1 1=0 -999=0 -666=0
gen dv2_burns_food_dum_el = dv2_burns_food_el
recode dv2_burns_food_dum_el 0=1 1=0 -999=0 -666=0
gen dv2_argues_dum_el = dv2_argues_el
recode dv2_argues_dum_el 0=1 1=0 -999=0 -666=0
gen dv2_refuses_sex_dum_el = dv2_refuses_sex_el
recode dv2_refuses_sex_dum_el 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen psu_dum_el = psu_el
recode psu_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen non_gbv_fem_fault_dum_el = non_gbv_fem_fault_el
recode non_gbv_fem_fault_dum_el 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Victim-Blaming index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local VB dv2_without_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el
make_index_gr VictimBlame_And_el wgt stdgroup `VB'
label var index_VictimBlame_And_el "Victim Blaming Index (Anderson)"

summ index_VictimBlame_And_el

**creating the Victim-Blaming index (Regular)
egen index_VictimBlame_Reg_el = rowmean(dv2_without_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el)
label var index_VictimBlame_Reg_el "Victim Blaming Index (Regular)"
summ index_VictimBlame_Reg_el

*generating histogram for the Victim-Blaming indices (Anderson + Regular)
histogram index_VictimBlame_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V1)
histogram index_VictimBlame_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V2)

***Technical Skills Index***

**codebook of variables to be used for Technical Skills Index
codebook dv_complaint_relative_el sa_burden_proof_el eviction_dv_el fem_shelter_el verbal_abuse_public_el verbal_abuse_ipc_el sa_identity_leaked_el sa_identity_ipc_el

**replacing multivariates with dummy variables
gen dv_complaint_relative_dum_el = dv_complaint_relative_el 
recode dv_complaint_relative_dum_el 1=1 2=0 3=0 4=0 -999=0 -666=0
gen sa_burden_proof_dum_el = sa_burden_proof_el 
recode sa_burden_proof_dum_el 1=0 2=0 3=0 4=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eviction_dv_dum_el = eviction_dv_el
recode eviction_dv_dum_el 1=1 2=0 3=0 -999=0 -666=0
gen fem_shelter_dum_el = fem_shelter_el
recode fem_shelter_dum_el 1=1 2=0 3=0 4=0 -999=0 -666=0

**creating dummy variables for follow up questions
gen verbal_abuse_public_dum_el = 0
replace verbal_abuse_public_dum_el = 1 if verbal_abuse_public_el == 1
gen verbal_abuse_ipc_dum_el = 0
replace verbal_abuse_ipc_dum_el = 1 if verbal_abuse_ipc_el == 3 | verbal_abuse_public_el == 1
gen sa_identity_leaked_dum_el = 0
replace sa_identity_leaked_dum_el = 1 if sa_identity_leaked_el == 1
gen sa_identity_ipc_dum_el = 0
replace sa_identity_ipc_dum_el = 1 if sa_identity_ipc_el == 3 | sa_identity_leaked_el == 1

**creating the Technical Skills index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local TS dv_complaint_relative_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el
make_index_gr Techskills_And_el wgt stdgroup `TS'
label var index_Techskills_And_el "Technical Skills Index (Anderson)"
summ index_Techskills_And_el

**creating the Technical Skills index (Regular)
egen index_Techskills_Reg_el = rowmean(dv_complaint_relative_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum)
label var index_Techskills_Reg_el "Technical Skills Index (Regular)"
summ index_Techskills_Reg_el

*generating histogram for the Technical Skills indices (Anderson + Regular)
histogram index_Techskills_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T1)
histogram index_Techskills_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T2)

***Empathy Index***

**codebook of variables to be used for Empathy Index
codebook eq_1_el eq_2_el eq_3_el eq_4_el eq_5_el eq_6_el gbv_empathy_el non_gbv_empathy_el

**replacing multivariates with dummy variables
gen eq_1_dum_el = eq_1_el
recode eq_1_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eq_2_dum_el = eq_2_el
recode eq_2_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_3_dum_el = eq_3_el
recode eq_3_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_4_dum_el = eq_4_el
recode eq_4_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eq_5_dum_el = eq_5_el
recode eq_5_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_6_dum_el = eq_6_el
recode eq_6_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen gbv_empathy_dum_el = gbv_empathy_el
recode gbv_empathy_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen non_gbv_empathy_dum_el = non_gbv_empathy_el
recode non_gbv_empathy_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

**creating the Empathy index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Emp eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el
make_index_gr Empathy_And_el wgt stdgroup `Emp'
label var index_Empathy_And_el "Empathy Index (Anderson)"
summ index_Empathy_And_el

**creating the Empathy index (Regular)
egen index_Empathy_Reg_el = rowmean(eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el)
label var index_Empathy_Reg_el "Empathy Index (Regular)"
summ index_Empathy_Reg_el

*generating histogram for the Empathy indices (Anderson + Regular)
histogram index_Empathy_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M1)
histogram index_Empathy_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M2)

***Flexibility Index***
****Scale of Personal Rigidity derived by Rebisch (1958)
****Qs 8, 10, 14, 16, 17, 19, 22, 25, 26
**codebook of variables to be used for Flexibility Index
codebook pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el

gen pri_1_el_dum = pri_1_el
gen pri_2_el_dum = pri_2_el
gen pri_3_el_dum = pri_3_el
gen pri_4_el_dum = pri_4_el
gen pri_5_el_dum = pri_5_el
gen pri_6_el_dum = pri_6_el
gen pri_7_el_dum = pri_7_el
gen pri_8_el_dum = pri_8_el
gen pri_9_el_dum = pri_9_el

*recode pri_1_el 0=1 1=0 /*reversing the direction of the variable*/
*recode pri_2_el 0=1 1=0 /*reversing the direction of the variable*/
recode pri_3_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_4_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_5_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_6_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_7_el_dum 0=1 1=0 /*NOT reversing the direction of the variable*/
recode pri_8_el_dum 0=1 1=0 /*NOT reversing the direction of the variable*/
*recode pri_9_el 0=1 1=0 /*reversing the direction of the variable*/

/*
**assigning correct labels to the recoded variables
label def PRI_el 0 "TRUE" 1 "FALSE"
*label values pri_1_el PRI_el
*label values pri_2_el PRI_el
label values pri_3_el PRI_el
label values pri_4_el PRI_el
label values pri_5_el PRI_el
label values pri_6_el PRI_el
label values pri_7_el PRI_el
label values pri_8_el PRI_el
*label values pri_9_el PRI_el
*/

**creating the Flexibility index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Flex pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum

make_index_gr Flexibility_And_el wgt stdgroup `Flex'
cap egen Flexibility_And_el = std(index_Flexibility_And_el)
label var index_Flexibility_And_el "Flexibility Index (Anderson)"
summ index_Flexibility_And_el

**creating the Flexibility index (Regular)
egen index_Flexibility_Reg_el = rowmean(pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum)
label var index_Flexibility_Reg_el "Flexibility Index (Regular)"
summ index_Flexibility_Reg_el

*generating histogram for the Flexibility indices (Anderson + Regular)
histogram index_Flexibility_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F1)
histogram index_Flexibility_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F2)

***Social Desirability Index***

**codebook of variables to be used for Social Desirability Index
codebook sdb_1_el sdb_2_el sdb_3_el sdb_4_el sdb_5_el sdb_6_el sdb_7_el sdb_8_el sdb_9_el sdb_10_el sdb_11_el sdb_12_el sdb_13_el

gen sdb_1_el_dum = sdb_1_el
gen sdb_2_el_dum = sdb_2_el
gen sdb_3_el_dum = sdb_3_el
gen sdb_4_el_dum = sdb_4_el
gen sdb_5_el_dum = sdb_5_el
gen sdb_6_el_dum = sdb_6_el
gen sdb_7_el_dum = sdb_7_el
gen sdb_8_el_dum = sdb_8_el
gen sdb_9_el_dum = sdb_9_el
gen sdb_10_el_dum = sdb_10_el
gen sdb_11_el_dum = sdb_11_el
gen sdb_12_el_dum = sdb_12_el
gen sdb_13_el_dum = sdb_13_el

//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
recode sdb_5_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_7_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_9_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_10_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_13_el_dum 0=1 1=0 /*reversing the direction of the variable*/

/*
**assigning correct labels to the recoded variables
label def SDB_el 0 "TRUE" 1 "FALSE"
label values sdb_5_el SDB_el
label values sdb_7_el SDB_el
label values sdb_9_el SDB_el
label values sdb_10_el SDB_el
label values sdb_13_el SDB_el
*/

**creating the Social Desirability index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Desir sdb_1_el_dum sdb_2_el_dum sdb_3_el_dum sdb_4_el_dum sdb_5_el_dum sdb_6_el_dum sdb_7_el_dum sdb_8_el_dum sdb_9_el_dum sdb_10_el_dum sdb_11_el_dum sdb_12_el_dum sdb_13_el_dum

make_index_gr Desirability_And_el wgt stdgroup `Desir'
cap egen Desirability_And_el = std(index_Desirability_And_el)
label var index_Desirability_And_el "Desirability Index (Anderson)"
summ index_Desirability_And_el

**creating the Social Desirability index (Regular)
egen index_Desirability_Reg_el = rowtotal(sdb_1_el_dum sdb_2_el_dum sdb_3_el_dum sdb_4_el_dum sdb_5_el_dum sdb_6_el_dum sdb_7_el_dum sdb_8_el_dum sdb_9_el_dum sdb_10_el_dum sdb_11_el_dum sdb_12_el_dum sdb_13_el_dum)
label var index_Desirability_Reg_el "Desirability Index (Regular)"
summ index_Desirability_Reg_el

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S1)
histogram index_Desirability_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S2)

***Anxiety Index***

**codebook of variables to be used for Anxiety Index
codebook gad_1_el gad_2_el gad_3_el gad_4_el gad_5_el gad_6_el gad_7_el

gen gad_1_el_dum = gad_1_el
gen gad_2_el_dum = gad_2_el
gen gad_3_el_dum = gad_3_el
gen gad_4_el_dum = gad_4_el
gen gad_5_el_dum = gad_5_el
gen gad_6_el_dum = gad_6_el
gen gad_7_el_dum = gad_7_el

**recoding Refused to Answer and DN values
recode gad_1_el_dum -999=1 -666=1
recode gad_2_el_dum -999=1 -666=1
recode gad_3_el_dum -999=1 -666=1
recode gad_4_el_dum -999=1 -666=1
recode gad_5_el_dum -999=1 -666=1
recode gad_6_el_dum -999=1 -666=1
recode gad_7_el_dum -999=1 -666=1.

**converting the GAD scale from 1-4 to 0-3
replace gad_1_el_dum = gad_1_el_dum - 1
replace gad_2_el_dum = gad_2_el_dum - 1
replace gad_3_el_dum = gad_3_el_dum - 1
replace gad_4_el_dum = gad_4_el_dum - 1
replace gad_5_el_dum = gad_5_el_dum - 1
replace gad_6_el_dum = gad_6_el_dum - 1
replace gad_7_el_dum = gad_7_el_dum - 1

/*
**assigning correct labels to the recoded variables
label define GAD_2 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values gad_1_el GAD_2
label values gad_2_el GAD_2
label values gad_3_el GAD_2
label values gad_4_el GAD_2
label values gad_5_el GAD_2
label values gad_6_el GAD_2
label values gad_7_el GAD_2
*/

**creating the Anxiety Index
egen index_Anxiety_el = rowtotal(gad_1_el_dum gad_2_el_dum gad_3_el_dum gad_4_el_dum gad_5_el_dum gad_6_el_dum gad_7_el_dum)

label var index_Anxiety_el "Anxiety Index"
summ index_Anxiety_el

*generating histogram for the Anxiety Index
histogram index_Anxiety_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(X1)

***Depression Index***

**codebook of variables to be used for Depression Index
codebook phq_1_el phq_2_el phq_3_el phq_4_el phq_5_el phq_6_el phq_7_el phq_8_el phq_9_el

gen phq_1_el_dum = phq_1_el
gen phq_2_el_dum = phq_2_el
gen phq_3_el_dum = phq_3_el
gen phq_4_el_dum = phq_4_el
gen phq_5_el_dum = phq_5_el
gen phq_6_el_dum = phq_6_el
gen phq_7_el_dum = phq_7_el
gen phq_8_el_dum = phq_8_el
gen phq_9_el_dum = phq_9_el

recode phq_1_el_dum -999=1 -666=1
recode phq_2_el_dum -999=1 -666=1
recode phq_3_el_dum -999=1 -666=1
recode phq_4_el_dum -999=1 -666=1
recode phq_5_el_dum -999=1 -666=1
recode phq_6_el_dum -999=1 -666=1
recode phq_7_el_dum -999=1 -666=1
recode phq_8_el_dum -999=1 -666=1
recode phq_9_el_dum -999=1 -666=1

**converting the PHQ scale from 1-4 to 0-3
replace phq_1_el_dum = phq_1_el_dum - 1
replace phq_2_el_dum = phq_2_el_dum - 1
replace phq_3_el_dum = phq_3_el_dum - 1
replace phq_4_el_dum = phq_4_el_dum - 1
replace phq_5_el_dum = phq_5_el_dum - 1
replace phq_6_el_dum = phq_6_el_dum - 1
replace phq_7_el_dum = phq_7_el_dum - 1
replace phq_8_el_dum = phq_8_el_dum - 1
replace phq_9_el_dum = phq_9_el_dum - 1

/*
**assigning correct labels to the recoded variables
label define PHQ_2 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values phq_1_el PHQ_2
label values phq_2_el PHQ_2
label values phq_3_el PHQ_2
label values phq_4_el PHQ_2
label values phq_5_el PHQ_2
label values phq_6_el PHQ_2
label values phq_7_el PHQ_2
label values phq_8_el PHQ_2
label values phq_9_el PHQ_2
*/

**creating the Depression Index
egen index_Depression_el = rowtotal(phq_1_el_dum phq_2_el_dum phq_3_el_dum phq_4_el_dum phq_5_el_dum phq_6_el_dum phq_7_el_dum phq_8_el_dum phq_9_el_dum)

label var index_Depression_el "Depression Index"
summ index_Depression_el

*generating histogram for the Depression Index
histogram index_Depression_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P1)

***Attitude Towards GBV Index***

**codebook of variables to be used for Attitudes Index
codebook land_compromise_el fem_cases_overattention_el
codebook gbv_abusive_beh_el gbv_fem_fault_el

**replacing multivariates with dummy variables
gen land_compromise_dum_el = land_compromise_el
recode land_compromise_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen fem_cases_overattention_dum_el = fem_cases_overattention_el
recode fem_cases_overattention_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_abusive_beh_dum_el = gbv_abusive_beh_el
recode gbv_abusive_beh_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen gbv_fem_fault_dum_el = gbv_fem_fault_el
recode gbv_fem_fault_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Attitudes towards GBV index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Atti land_compromise_dum_el fem_cases_overattention_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el

make_index_gr AttitudeGBV_And_el wgt stdgroup `Atti'
label var index_AttitudeGBV_And_el "Attitudes toward GBV Index (Anderson)"
summ index_AttitudeGBV_And_el

**creating the Attitudes towards GBV index (Regular)
egen index_AttitudeGBV_Reg_el = rowmean(land_compromise_dum_el fem_cases_overattention_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el)
label var index_AttitudeGBV_Reg_el "Attitudes toward GBV Index (Regular)"
summ index_AttitudeGBV_Reg_el

*generating histogram for the Attitudes towards GBV indices (Anderson + Regular)
histogram index_AttitudeGBV_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A1)
histogram index_AttitudeGBV_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A2)

***Externalising Police Responses Index***

**codebook of variables to be used for Externalising Police Responses Index
codebook dv1_internal_matter_el dv1_common_incident_el dv1_fears_beating_el
codebook gbv_police_help_el non_gbv_fir_el
codebook caste_police_help_el

gen dv1_internal_matter_el_dum = dv1_internal_matter_el
gen dv1_common_incident_el_dum = dv1_common_incident_el
gen dv1_fears_beating_el_dum = dv1_fears_beating_el

**recoding variables
recode dv1_internal_matter_el_dum 0=1 1=0 -999=0 -666=0
recode dv1_common_incident_el_dum 0=1 1=0 -999=0 -666=0
recode dv1_fears_beating_el_dum 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen gbv_police_help_dum_el = gbv_police_help_el
recode gbv_police_help_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

gen non_gbv_fir_dum_el = non_gbv_fir_el
recode non_gbv_fir_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

gen caste_police_help_dum_el = caste_police_help_el
recode caste_police_help_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

**creating the Externalising Police Responses Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Ext dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el

make_index_gr ExtPol_And_el wgt stdgroup `Ext'
label var index_ExtPol_And_el "Externalising Police Responses Index (Anderson)"
summ index_ExtPol_And_el

**creating the Externalising Police Responses Index (Regular)
egen index_ExtPol_Reg_el = rowmean(dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el)
label var index_ExtPol_Reg_el "Externalising Police Responses Index (Regular)"
summ index_ExtPol_Reg_el

*generating histogram for the Externalising Police Responses indices (Anderson + Regular)
histogram index_ExtPol_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E1)
histogram index_ExtPol_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E2)

***Discrimination Index***

**codebook of variables to be used for Discrimination Index
codebook caste_empathy_el caste_fault_el caste_framing_man_el caste_true_el

**replacing multivariates with dummy variables
gen caste_empathy_dum_el = caste_empathy_el
recode caste_empathy_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen caste_fault_dum_el = caste_fault_el
recode caste_fault_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen caste_framing_man_dum_el = caste_framing_man_el
recode caste_framing_man_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen caste_true_dum_el = caste_true_el
recode caste_true_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

**creating the Discrimination Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Discr caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el

make_index_gr Discrimination_And_el wgt stdgroup `Discr'
label var index_Discrimination_And_el "Discrimination Index (Anderson)"
summ index_Discrimination_And_el

**creating the Discrimination Index (Regular)
egen index_Discrimination_Reg_el = rowmean(caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el)
label var index_Discrimination_Reg_el "Discrimination Index (Regular)"
summ index_Discrimination_Reg_el

*generating histogram for the Discrimination indices (Anderson + Regular)
histogram index_Discrimination_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D1)
histogram index_Discrimination_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D2)

***Truthfulness of Complaints Index***

**codebook of variables to be used for Truthfulness Index
codebook land_false_el premarital_false_el premarital_framing_el believable_with_relative_el gbv_true_el non_gbv_true_el

**replacing multivariates with dummy variables
gen land_false_dum_el = land_false_el
recode land_false_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 
gen premarital_false_dum_el = premarital_false_el
recode premarital_false_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 -999=0 -666=0  
gen premarital_framing_dum_el = premarital_framing_el
recode premarital_framing_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0  -999=0 -666=0 
gen believable_with_relative_dum_el = believable_with_relative_el
recode believable_with_relative_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_true_dum_el = gbv_true_el
recode gbv_true_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen non_gbv_true_dum_el = non_gbv_true_el
recode non_gbv_true_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

gen land_false_sa_dum_el = land_false_sa_el
recode land_false_sa_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0

**creating the Truthfulness Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Truth land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believable_with_relative_dum_el gbv_true_dum_el non_gbv_true_dum_el

make_index_gr Truth_And_el wgt stdgroup `Truth'
label var index_Truth_And_el "Truthfulness Index (Anderson)"
summ index_Truth_And_el

**creating the Truthfulness Index (Regular)
egen index_Truth_Reg_el = rowmean(land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believable_with_relative_dum_el gbv_true_dum_el non_gbv_true_dum_el)
label var index_Truth_Reg_el "Truthfulness Index (Regular)"
summ index_Truth_Reg_el

*generating histogram for the Truthfulness indices (Anderson + Regular)
histogram index_Truth_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R1)
histogram index_Truth_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R2)

*summarising the indices
summ index_VictimBlame_And_el index_Techskills_And_el index_Empathy_And_el index_Flexibility_And_el index_Desirability_And_el index_AttitudeGBV_And_el index_ExtPol_And_el index_Discrimination_And_el index_Truth_And_el index_Openness_And_el
summ index_VictimBlame_Reg_el index_Techskills_Reg_el index_Empathy_Reg_el index_Flexibility_Reg_el index_AttitudeGBV_Reg_el index_ExtPol_Reg_el index_Discrimination_Reg_el index_Truth_Reg_el index_Openness_Reg_el
summ index_Desirability_Reg_el index_Anxiety_el index_Depression_el





*append using "${intermediate_dta}baselineonly.dta"
save "$MO_endline_clean_dta\endline_indices.dta", replace