/*==============================================================================
File Name: Final Dataset - Redoing Indices
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to redo the indices for the final dataset


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

log using "$MO_endline_log_files\final_index_preparation.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\combined_FINAL_analysis.dta", clear

*dropping previously made indices
drop index_Openness_And_bl index_VictimBlame_And_bl index_Techskills_And_bl index_Empathy_And_bl index_Flexibility_And_bl Flexibility_And_bl index_Desirability_And_bl Desirability_And_bl index_AttitudeGBV_And_bl index_ExtPol_And_bl index_Discrimination_And_bl index_Truth_And_bl 
drop index_Openness_Reg_bl index_VictimBlame_Reg_bl index_Techskills_Reg_bl index_Empathy_Reg_bl index_Flexibility_Reg_bl index_Desirability_Reg_bl index_AttitudeGBV_Reg_bl index_ExtPol_Reg_bl index_Discrimination_Reg_bl index_Truth_Reg_bl index_Anxiety_bl index_Depression_bl
drop index_Openness_And_el index_VictimBlame_And_el index_Techskills_And_el index_Empathy_And_el index_Flexibility_And_el Flexibility_And_el index_Desirability_And_el Desirability_And_el index_AttitudeGBV_And_el index_ExtPol_And_el index_Discrimination_And_el index_Truth_And_el
drop index_Openness_Reg_el index_VictimBlame_Reg_el index_Techskills_Reg_el index_Empathy_Reg_el index_Flexibility_Reg_el index_Desirability_Reg_el index_AttitudeGBV_Reg_el index_ExtPol_Reg_el index_Discrimination_Reg_el index_Truth_Reg_el index_Anxiety_el index_Depression_el
drop openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl dv2_without_informing_dum_bl dv2_neglects_children_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl dv_compl_rel_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl land_false_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl land_false_sa_dum_bl dv2_without_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el land_false_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el land_false_sa_dum_el openness_1_el_dum openness_2_el_dum openness_3_el_dum openness_4_el_dum openness_5_el_dum openness_6_el_dum openness_7_el_dum openness_8_el_dum openness_9_el_dum castepolicehelpnewdum_bl pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum sdb_1_el_dum sdb_2_el_dum sdb_3_el_dum sdb_4_el_dum sdb_5_el_dum sdb_6_el_dum sdb_7_el_dum sdb_8_el_dum sdb_9_el_dum sdb_10_el_dum sdb_11_el_dum sdb_12_el_dum sdb_13_el_dum gad_1_el_dum gad_2_el_dum gad_3_el_dum gad_4_el_dum gad_5_el_dum gad_6_el_dum gad_7_el_dum phq_1_el_dum phq_2_el_dum phq_3_el_dum phq_4_el_dum phq_5_el_dum phq_6_el_dum phq_7_el_dum phq_8_el_dum phq_9_el_dum dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum pri_1_dum_bl pri_2_dum_bl pri_3_dum_bl pri_4_dum_bl pri_5_dum_bl pri_6_dum_bl pri_7_dum_bl pri_8_dum_bl pri_9_dum_bl sdb_1_dum_bl sdb_2_dum_bl sdb_3_dum_bl sdb_4_dum_bl sdb_5_dum_bl sdb_6_dum_bl sdb_7_dum_bl sdb_8_dum_bl sdb_9_dum_bl sdb_10_dum_bl sdb_11_dum_bl sdb_12_dum_bl sdb_13_dum_bl gad_1_dum_bl gad_2_dum_bl gad_3_dum_bl gad_4_dum_bl gad_5_dum_bl gad_6_dum_bl gad_7_dum_bl phq_1_dum_bl phq_2_dum_bl phq_3_dum_bl phq_4_dum_bl phq_5_dum_bl phq_6_dum_bl phq_7_dum_bl phq_8_dum_bl phq_9_dum_bl dv1_internal_matter_dum_bl dv1_common_incident_dum_bl dv1_fears_beating_dum_bl
drop wgt wgt_bl stdgroup stdgroup_bl



 ****************************************REDOING THE INDICES**********************************************************************
 **Rationale for recoding 0 = gender-regressive, 1 = gender-progressive (or simply regressive/progressive for indices like Flexibility, Desirability, etc.) 
/*The individual variables are first converted to dummy variables. For questions that used a 5-point Likert scale, the binary variable was coded as 1 if the respondent answered "Strongly Agree" or "Agree" with a gender-progressive statement (or "Strongly Disagree" or "Disagree" with a gender-regressive statement), and 0 otherwise. (Jayachandran, 2018)*/

*###########Baseline#############


 **Replacing multivariates with dummy variables
 
 gen openness_1_dum_bl=openness_1_bl
 recode openness_1_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_2_dum_bl=openness_2_bl
 recode openness_2_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_3_dum_bl=openness_3_bl 
 recode openness_3_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_4_dum_bl=openness_4_bl
 recode openness_4_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_5_dum_bl=openness_5_bl
 recode openness_5_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_6_dum_bl=openness_6_bl
 recode openness_6_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_7_dum_bl=openness_7_bl
 recode openness_7_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_8_dum_bl=openness_8_bl
 recode openness_8_dum_bl 1=1 2=1 3=0 4=0 5=0
 gen openness_9_dum_bl=openness_9_bl
 recode openness_9_dum_bl 1=1 2=1 3=0 4=0 5=0
 
  **recoding Refused to Answer and DN values
 
 recode openness_1_dum_bl -666=0    
 recode openness_2_dum_bl -666=0    
 recode openness_3_dum_bl -666=0    
 recode openness_4_dum_bl -666=0    
 recode openness_5_dum_bl -666=0    
 recode openness_6_dum_bl -666=0    
 recode openness_7_dum_bl -666=0    
 recode openness_8_dum_bl -666=0    
 recode openness_9_dum_bl -666=0   
 
 **creating the Openness index (Anderson)
gen wgt=1
gen stdgroup= (treatment_bl==0)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file
local open1 openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl
make_index_gr Openness_And wgt stdgroup `open1'
label var index_Openness_And "Openness Index (Anderson)"
summ index_Openness_And

**creating the Openness index (Regular)
egen index_Openness_Reg = rowmean(openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl)
label var index_Openness_Reg "Openness Index (Regular)"
summ index_Openness_Reg

***Victim-Blaming Index***

**codebook of variables to be used for the Victim Blaming index
codebook dv2_goes_wo_informing_bl dv2_neglects_children_bl dv2_burns_food_bl dv2_argues_bl dv2_refuses_sex_bl psu_bl
*codebook premarital_socially_unacceptable
codebook non_gbv_fem_fault_bl
*rename premarital_socially_unacceptable psu

**recoding 0 = positive outcome, 1 = negative outcome
gen dv2_goes_wo_informing_dum_bl = dv2_goes_wo_informing_bl
recode dv2_goes_wo_informing_dum_bl 0=1 1=0 -999=0 -666=0
gen dv2_neglects_children_dum_bl = dv2_neglects_children_bl
recode dv2_neglects_children_dum_bl 0=1 1=0 -999=0 -666=0
gen dv2_burns_food_dum_bl = dv2_burns_food_bl
recode dv2_burns_food_dum_bl 0=1 1=0 -999=0 -666=0
gen dv2_argues_dum_bl = dv2_argues_bl
recode dv2_argues_dum_bl 0=1 1=0 -999=0 -666=0
gen dv2_refuses_sex_dum_bl = dv2_refuses_sex_bl
recode dv2_refuses_sex_dum_bl 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen psu_dum_bl = psu_bl
recode psu_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen non_gbv_fem_fault_dum_bl = non_gbv_fem_fault_bl
recode non_gbv_fem_fault_dum_bl 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Victim-Blaming index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

*gen wgt=1
*gen stdgroup=1

local VB dv2_goes_wo_informing_dum_bl dv2_neglects_children_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl
make_index_gr VictimBlame_And_bl wgt stdgroup `VB'
label var index_VictimBlame_And_bl "Victim Blaming Index (Anderson)"

summ index_VictimBlame_And_bl

**creating the Victim-Blaming index (Regular)
egen index_VictimBlame_Reg_bl = rowmean(dv2_goes_wo_informing_dum_bl dv2_neglects_children_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl)
label var index_VictimBlame_Reg_bl "Victim Blaming Index (Regular)"
summ index_VictimBlame_Reg_bl

*generating histogram for the Victim-Blaming indices (Anderson + Regular)
histogram index_VictimBlame_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V1)
histogram index_VictimBlame_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V2)

***Technical Skills Index***

**codebook of variables to be used for Technical Skills Index
codebook dv_complaint_relative_bl sa_burden_proof_bl eviction_dv_bl fem_shelter_bl verbal_abuse_public_bl verbal_abuse_ipc_bl sa_identity_leaked_bl sa_identity_ipc_bl

**replacing multivariates with dummy variables
gen dv_compl_rel_dum_bl = dv_complaint_relative_bl
recode dv_compl_rel_dum_bl 1=1 2=0 3=0 -999=0 -666=0
gen sa_burden_proof_dum_bl = sa_burden_proof_bl 
recode sa_burden_proof_dum_bl 1=0 2=0 3=0 4=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eviction_dv_dum_bl = eviction_dv_bl
recode eviction_dv_dum_bl 1=1 2=0 3=0 -999=0 -666=0
gen fem_shelter_dum_bl = fem_shelter_bl
recode fem_shelter_dum_bl 1=1 2=0 3=0 4=0 -999=0 -666=0

**creating dummy variables for follow up questions
gen verbal_abuse_public_dum_bl = 0
replace verbal_abuse_public_dum_bl = 1 if verbal_abuse_public_bl == 1
gen verbal_abuse_ipc_dum_bl = 0
replace verbal_abuse_ipc_dum_bl = 1 if verbal_abuse_ipc_bl == 3
gen sa_identity_leaked_dum_bl = 0
replace sa_identity_leaked_dum_bl = 1 if sa_identity_leaked_bl == 1
gen sa_identity_ipc_dum_bl = 0
replace sa_identity_ipc_dum_bl = 1 if sa_identity_ipc_bl == 3

**creating the Technical Skills index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local TS dv_compl_rel_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl
make_index_gr Techskills_And_bl wgt stdgroup `TS'
label var index_Techskills_And_bl "Technical Skills Index (Anderson)"
summ index_Techskills_And_bl

**creating the Technical Skills index (Regular)
egen index_Techskills_Reg_bl = rowmean(dv_compl_rel_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl)
label var index_Techskills_Reg_bl "Technical Skills Index (Regular)"
summ index_Techskills_Reg_bl

*generating histogram for the Technical Skills indices (Anderson + Regular)
histogram index_Techskills_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T1)
histogram index_Techskills_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T2)

***Empathy Index***

**codebook of variables to be used for Empathy Index
codebook eq_1_bl eq_2_bl eq_3_bl eq_4_bl eq_5_bl eq_6_bl gbv_empathy_bl non_gbv_empathy_bl

**replacing multivariates with dummy variables
gen eq_1_dum_bl = eq_1_bl
recode eq_1_dum_bl 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eq_2_dum_bl = eq_2_bl
recode eq_2_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_3_dum_bl = eq_3_bl
recode eq_3_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_4_dum_bl = eq_4_bl
recode eq_4_dum_bl 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eq_5_dum_bl = eq_5_bl
recode eq_5_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_6_dum_bl = eq_6_bl
recode eq_6_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen gbv_empathy_dum_bl = gbv_empathy_bl
recode gbv_empathy_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen non_gbv_empathy_dum_bl = non_gbv_empathy_bl
recode non_gbv_empathy_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

**creating the Empathy index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Emp eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl
make_index_gr Empathy_And_bl wgt stdgroup `Emp'
label var index_Empathy_And_bl "Empathy Index (Anderson)"
summ index_Empathy_And_bl

**creating the Empathy index (Regular)
egen index_Empathy_Reg_bl = rowmean(eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl)
label var index_Empathy_Reg_bl "Empathy Index (Regular)"
summ index_Empathy_Reg_bl

*generating histogram for the Empathy indices (Anderson + Regular)
histogram index_Empathy_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M1)
histogram index_Empathy_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M2)

***Flexibility Index***
****Scale of Personal Rigidity derived by Rehfisch (1958)
****Qs 8, 10, 14, 16, 17, 19, 22, 25, 26
**codebook of variables to be used for Flexibility Index
codebook pri_1_bl pri_2_bl pri_3_bl pri_4_bl pri_5_bl pri_6_bl pri_7_bl pri_8_bl pri_9_bl

gen pri_1_bl_dum = pri_1_bl
gen pri_2_bl_dum = pri_2_bl
gen pri_3_bl_dum = pri_3_bl
gen pri_4_bl_dum = pri_4_bl
gen pri_5_bl_dum = pri_5_bl
gen pri_6_bl_dum = pri_6_bl
gen pri_7_bl_dum = pri_7_bl
gen pri_8_bl_dum = pri_8_bl
gen pri_9_bl_dum = pri_9_bl

*recode pri_1 0=1 1=0 /*NOT reversing the direction of the variable*/
*recode pri_2 0=1 1=0 /*NOT reversing the direction of the variable*/
recode pri_3_bl_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_4_bl_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_5_bl_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_6_bl_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_7_bl_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_8_bl_dum 0=1 1=0 /*reversing the direction of the variable*/
*recode pri_9 0=1 1=0 /*NOT reversing the direction of the variable*/

/*
**assigning correct labels to the recoded variables
label drop PRI
label def PRI 0 "TRUE" 1 "FALSE"
*label values pri_1 PRI
*label values pri_2 PRI
label values pri_3_bl PRI
label values pri_4_bl PRI
label values pri_5_bl PRI
label values pri_6_bl PRI
label values pri_7_bl PRI
label values pri_8_bl PRI
*label values pri_9 PRI
*/

**creating the Flexibility index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Flex pri_1_bl_dum pri_2_bl_dum pri_3_bl_dum pri_4_bl_dum pri_5_bl_dum pri_6_bl_dum pri_7_bl_dum pri_8_bl_dum pri_9_bl_dum

make_index_gr Flexibility_And_bl wgt stdgroup `Flex'
cap egen Flexibility_And_bl = std(index_Flexibility_And_bl)
label var index_Flexibility_And_bl "Flexibility Index (Anderson)"
summ index_Flexibility_And_bl

**creating the Flexibility index (Regular)
egen index_Flexibility_Reg_bl = rowmean(pri_1_bl_dum pri_2_bl_dum pri_3_bl_dum pri_4_bl_dum pri_5_bl_dum pri_6_bl_dum pri_7_bl_dum pri_8_bl_dum pri_9_bl_dum)
label var index_Flexibility_Reg_bl "Flexibility Index (Regular)"
summ index_Flexibility_Reg_bl

*generating histogram for the Flexibility indices (Anderson + Regular)
histogram index_Flexibility_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F1)
histogram index_Flexibility_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F2)

***Social Desirability Index***

**codebook of variables to be used for Social Desirability Index
codebook sdb_1_bl sdb_2_bl sdb_3_bl sdb_4_bl sdb_5_bl sdb_6_bl sdb_7_bl sdb_8_bl sdb_9_bl sdb_10_bl sdb_11_bl sdb_12_bl sdb_13_bl

label def SDB 0 "NEGATIVE" 1 "POSITIVE"
//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 {
	gen sdb_`i'_bl_dum = sdb_`i'_bl //for all questions, we have 0 - False , 1 - True
	recode sdb_`i'_bl_dum 0=1 1=0 if (`i' != 5 & `i' != 7 & `i' != 9 & `i' != 10 & `i' != 13) //recoding for all questions where False indicates higher SDB. This excludes 5,7,9,10,13 where True indicates higher SDB
	label values sdb_`i'_bl_dum SDB
}

**creating the Social Desirability index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Desir sdb_1_bl_dum sdb_2_bl_dum sdb_3_bl_dum sdb_4_bl_dum sdb_5_bl_dum sdb_6_bl_dum sdb_7_bl_dum sdb_8_bl_dum sdb_9_bl_dum sdb_10_bl_dum sdb_11_bl_dum sdb_12_bl_dum sdb_13_bl_dum

make_index_gr Desirability_And_bl wgt stdgroup `Desir'
cap egen Desirability_And_bl = std(index_Desirability_And_bl)
label var index_Desirability_And_bl "Desirability Index (Anderson)"
summ index_Desirability_And_bl

**creating the Social Desirability index (Regular)
egen index_Desirability_Reg_bl = rowtotal(sdb_1_bl_dum sdb_2_bl_dum sdb_3_bl_dum sdb_4_bl_dum sdb_5_bl_dum sdb_6_bl_dum sdb_7_bl_dum sdb_8_bl_dum sdb_9_bl_dum sdb_10_bl_dum sdb_11_bl_dum sdb_12_bl_dum sdb_13_bl_dum)
label var index_Desirability_Reg_bl "Desirability Index (Regular)"
summ index_Desirability_Reg_bl

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S1)
histogram index_Desirability_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S2)

***Anxiety Index***

**codebook of variables to be used for Anxiety Index
codebook gad_1_bl gad_2_bl gad_3_bl gad_4_bl gad_5_bl gad_6_bl gad_7_bl

gen gad_1_bl_dum = gad_1_bl
gen gad_2_bl_dum = gad_2_bl
gen gad_3_bl_dum = gad_3_bl
gen gad_4_bl_dum = gad_4_bl
gen gad_5_bl_dum = gad_5_bl
gen gad_6_bl_dum = gad_6_bl
gen gad_7_bl_dum = gad_7_bl

**recoding Refused to Answer and DN values
recode gad_1_bl_dum -999=1 -666=1
recode gad_2_bl_dum -999=1 -666=1
recode gad_3_bl_dum -999=1 -666=1
recode gad_4_bl_dum -999=1 -666=1
recode gad_5_bl_dum -999=1 -666=1
recode gad_6_bl_dum -999=1 -666=1
recode gad_7_bl_dum -999=1 -666=1

**converting the GAD scale from 1-4 to 0-3
replace gad_1_bl_dum = gad_1_bl_dum - 1
replace gad_2_bl_dum = gad_2_bl_dum- 1
replace gad_3_bl_dum = gad_3_bl_dum - 1
replace gad_4_bl_dum = gad_4_bl_dum - 1
replace gad_5_bl_dum = gad_5_bl_dum - 1
replace gad_6_bl_dum = gad_6_bl_dum - 1
replace gad_7_bl_dum = gad_7_bl_dum - 1

/*
**assigning correct labels to the recoded variables
label drop GAD
label define GAD 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values gad_1_bl GAD
label values gad_2_bl GAD
label values gad_3_bl GAD
label values gad_4_bl GAD
label values gad_5_bl GAD
label values gad_6_bl GAD
label values gad_7_bl GAD
*/

**creating the Anxiety Index
egen index_Anxiety_bl = rowtotal(gad_1_bl_dum gad_2_bl_dum gad_3_bl_dum gad_4_bl_dum gad_5_bl_dum gad_6_bl_dum gad_7_bl_dum)
label var index_Anxiety_bl "Anxiety Index"

*generating histogram for the Anxiety Index
histogram index_Anxiety_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(X1)

***Depression Index***

**codebook of variables to be used for Depression Index
codebook phq_1_bl phq_2_bl phq_3_bl phq_4_bl phq_5_bl phq_6_bl phq_7_bl phq_8_bl phq_9_bl

gen phq_1_bl_dum = phq_1_bl
gen phq_2_bl_dum = phq_2_bl
gen phq_3_bl_dum = phq_3_bl
gen phq_4_bl_dum = phq_4_bl
gen phq_5_bl_dum = phq_5_bl
gen phq_6_bl_dum = phq_6_bl
gen phq_7_bl_dum = phq_7_bl
gen phq_8_bl_dum = phq_8_bl
gen phq_9_bl_dum = phq_9_bl

recode phq_1_bl_dum -999=1 -666=1
recode phq_2_bl_dum -999=1 -666=1
recode phq_3_bl_dum -999=1 -666=1
recode phq_4_bl_dum -999=1 -666=1
recode phq_5_bl_dum -999=1 -666=1
recode phq_6_bl_dum -999=1 -666=1
recode phq_7_bl_dum -999=1 -666=1
recode phq_8_bl_dum -999=1 -666=1
recode phq_9_bl_dum -999=1 -666=1

**converting the PHQ scale from 1-4 to 0-3
replace phq_1_bl_dum = phq_1_bl_dum - 1
replace phq_2_bl_dum = phq_2_bl_dum - 1
replace phq_3_bl_dum = phq_3_bl_dum - 1
replace phq_4_bl_dum = phq_4_bl_dum - 1
replace phq_5_bl_dum = phq_5_bl_dum - 1
replace phq_6_bl_dum = phq_6_bl_dum - 1
replace phq_7_bl_dum = phq_7_bl_dum - 1
replace phq_8_bl_dum = phq_8_bl_dum - 1
replace phq_9_bl_dum = phq_9_bl_dum - 1

/*
**assigning correct labels to the recoded variables
label drop PHQ
label define PHQ 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values phq_1_bl PHQ
label values phq_2_bl PHQ
label values phq_3_bl PHQ
label values phq_4_bl PHQ
label values phq_5_bl PHQ
label values phq_6_bl PHQ
label values phq_7_bl PHQ
label values phq_8_bl PHQ
label values phq_9_bl PHQ
*/

**creating the Depression Index
egen index_Depression_bl = rowtotal(phq_1_bl_dum phq_2_bl_dum phq_3_bl_dum phq_4_bl_dum phq_5_bl_dum phq_6_bl_dum phq_7_bl_dum phq_8_bl_dum phq_9_bl_dum)

label var index_Depression_bl "Depression Index"
summ index_Depression_bl

*generating histogram for the Depression Index
histogram index_Depression_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P1)

***Attitude Towards GBV Index***

**codebook of variables to be used for Attitudes Index
codebook land_compromise_bl fem_cases_overattention_bl
codebook gbv_abusive_beh_new_bl gbv_fem_fault_bl

**replacing multivariates with dummy variables
gen land_compromise_dum_bl = land_compromise_bl
recode land_compromise_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen fem_cases_over_dum_bl = fem_cases_overattention_bl
recode fem_cases_over_dum_bl 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_abusive_beh_new_dum_bl = gbv_abusive_beh_new_bl
recode gbv_abusive_beh_new_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace gbv_abusive_beh_new_dum_bl = 1 if gbv_abusive_beh_bl == 1
replace gbv_abusive_beh_new_dum_bl = 0 if gbv_abusive_beh_bl != 1 & gbv_abusive_beh_bl !=.
gen gbv_fem_fault_dum_bl = gbv_fem_fault_bl
recode gbv_fem_fault_dum_bl 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Attitudes towards GBV index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Atti land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl

make_index_gr AttitudeGBV_And_bl wgt stdgroup `Atti'
label var index_AttitudeGBV_And_bl "Attitudes toward GBV Index (Anderson)"
summ index_AttitudeGBV_And_bl

**creating the Attitudes towards GBV index (Regular)
egen index_AttitudeGBV_Reg_bl = rowmean(land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl)
label var index_AttitudeGBV_Reg_bl "Attitudes toward GBV Index (Regular)"
summ index_AttitudeGBV_Reg_bl

*generating histogram for the Attitudes towards GBV indices (Anderson + Regular)
histogram index_AttitudeGBV_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A1)
histogram index_AttitudeGBV_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A2)

***Externalising Police Responses Index***

**codebook of variables to be used for Externalising Police Responses Index
codebook dv1_internal_matter_bl dv1_common_incident_bl dv1_fears_beating_bl
codebook gbv_police_help_new_bl non_gbv_fir_new_bl
codebook caste_police_help_new_bl

gen dv1_internal_matter_bl_dum = dv1_internal_matter_bl
gen dv1_common_incident_bl_dum = dv1_common_incident_bl
gen dv1_fears_beating_bl_dum = dv1_fears_beating_bl

**recoding variables
recode dv1_internal_matter_bl_dum 0=1 1=0 -999=0 -666=0
recode dv1_common_incident_bl_dum 0=1 1=0 -999=0 -666=0
recode dv1_fears_beating_bl_dum 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen gbv_police_help_new_dum_bl = gbv_police_help_new_bl
recode gbv_police_help_new_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace gbv_police_help_new_dum_bl = 1 if gbv_police_help_bl == 1
replace gbv_police_help_new_dum_bl = 0 if gbv_police_help_bl != 1 & gbv_police_help_bl !=.

gen non_gbv_fir_new_dum_bl = non_gbv_fir_new_bl
recode non_gbv_fir_new_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace non_gbv_fir_new_dum_bl = 1 if non_gbv_fir_bl == 1
replace non_gbv_fir_new_dum_bl = 0 if non_gbv_fir_bl != 1 & non_gbv_fir_bl !=.

gen castepolicehelpnewdum_bl = caste_police_help_new_bl
recode castepolicehelpnewdum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace castepolicehelpnewdum_bl = 1 if caste_police_help_bl == 1
replace castepolicehelpnewdum_bl = 0 if caste_police_help_bl != 1 & caste_police_help_bl !=.

**creating the Externalising Police Responses Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Ext dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl

make_index_gr ExtPol_And_bl wgt stdgroup `Ext'
label var index_ExtPol_And_bl "Externalising Police Responses Index (Anderson)"
summ index_ExtPol_And_bl

**creating the Externalising Police Responses Index (Regular)
egen index_ExtPol_Reg_bl = rowmean(dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl)
label var index_ExtPol_Reg_bl "Externalising Police Responses Index (Regular)"
summ index_ExtPol_Reg_bl

*generating histogram for the Externalising Police Responses indices (Anderson + Regular)
histogram index_ExtPol_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E1)
histogram index_ExtPol_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E2)

***Discrimination Index***

**codebook of variables to be used for Discrimination Index
codebook caste_empathy_bl caste_fault_new_bl caste_framing_man_bl caste_true_bl

**replacing multivariates with dummy variables
gen caste_empathy_dum_bl = caste_empathy_bl
recode caste_empathy_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen caste_fault_new_dum_bl = caste_fault_new_bl
recode caste_fault_new_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
replace caste_fault_new_dum_bl = 1 if caste_fault_bl == 1
replace caste_fault_new_dum_bl = 0 if caste_fault_bl != 1 & caste_fault_bl !=.
gen caste_framing_man_dum_bl = caste_framing_man_bl
recode caste_framing_man_dum_bl 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen caste_true_dum_bl = caste_true_bl
recode caste_true_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

**creating the Discrimination Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Discr caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl

make_index_gr Discrimination_And_bl wgt stdgroup `Discr'
label var index_Discrimination_And_bl "Discrimination Index (Anderson)"
summ index_Discrimination_And_bl

**creating the Discrimination Index (Regular)
egen index_Discrimination_Reg_bl = rowmean(caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl)
label var index_Discrimination_Reg_bl "Discrimination Index (Regular)"
summ index_Discrimination_Reg_bl

*generating histogram for the Discrimination indices (Anderson + Regular)
histogram index_Discrimination_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D1)
histogram index_Discrimination_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D2)

***Truthfulness of Complaints Index***

**codebook of variables to be used for Truthfulness Index
codebook land_false_bl land_false_sa_bl premarital_false_bl premarital_framing_bl believable_with_relative_bl gbv_true_bl non_gbv_true_bl

**replacing multivariates with dummy variables
gen land_false_dum_bl = land_false_bl
recode land_false_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 
gen premarital_false_dum_bl = premarital_false_bl
recode premarital_false_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 -999=0 -666=0  
gen premarital_framing_dum_bl = premarital_framing_bl
recode premarital_framing_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0  -999=0 -666=0 
gen believe_w_relat_dum_bl = believable_with_relative_bl
recode believe_w_relat_dum_bl 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_true_dum_bl = gbv_true_bl
recode gbv_true_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen non_gbv_true_dum_bl = non_gbv_true_bl
recode non_gbv_true_dum_bl 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen land_false_sa_dum_bl = land_false_sa_bl
recode land_false_sa_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0

**creating the Truthfulness Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Truth land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl

make_index_gr Truth_And_bl wgt stdgroup `Truth'
label var index_Truth_And_bl "Truthfulness Index (Anderson)"
summ index_Truth_And_bl

**creating the Truthfulness Index (Regular)
egen index_Truth_Reg_bl = rowmean(land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl)
label var index_Truth_Reg_bl "Truthfulness Index (Regular)"
summ index_Truth_Reg_bl

*generating histogram for the Truthfulness indices (Anderson + Regular)
histogram index_Truth_And_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R1)
histogram index_Truth_Reg_bl, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R2)

*summarising the indices
summ index_VictimBlame_And_bl index_Techskills_And_bl index_Empathy_And_bl index_Flexibility_And_bl index_Desirability_And_bl index_AttitudeGBV_And_bl index_ExtPol_And_bl index_Discrimination_And_bl index_Truth_And_bl
summ index_VictimBlame_Reg_bl index_Techskills_Reg_bl index_Empathy_Reg_bl index_Flexibility_Reg_bl index_AttitudeGBV_Reg_bl index_ExtPol_Reg_bl index_Discrimination_Reg_bl index_Truth_Reg_bl
summ index_Desirability_Reg_bl index_Anxiety_bl index_Depression_bl


*###########Endline#############

**Replacing multivariates with dummy variables
 
 gen openness_1_dum=openness_1_el
 recode openness_1_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_2_dum=openness_2_el
 recode openness_2_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_3_dum=openness_3_el 
 recode openness_3_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_4_dum=openness_4_el
 recode openness_4_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_5_dum=openness_5_el
 recode openness_5_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_6_dum=openness_6_el
 recode openness_6_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_7_dum=openness_7_el
 recode openness_7_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_8_dum=openness_8_el
 recode openness_8_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_9_dum=openness_9_el
 recode openness_9_dum 1=1 2=1 3=0 4=0 5=0
 
  **recoding Refused to Answer and DN values
 
 recode openness_1_dum -666=0    
 recode openness_2_dum -666=0    
 recode openness_3_dum -666=0    
 recode openness_4_dum -666=0    
 recode openness_5_dum -666=0    
 recode openness_6_dum -666=0    
 recode openness_7_dum -666=0    
 recode openness_8_dum -666=0    
 recode openness_9_dum -666=0   
 
 **creating the Openness index (Anderson)
drop stdgroup
gen stdgroup = (treatment_el==0)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file
local open1 openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum
make_index_gr Openness_And_el wgt stdgroup `open1'
label var index_Openness_And_el "Openness Index (Anderson)"
summ index_Openness_And_el

**creating the Openness index (Regular)
egen index_Openness_Reg_el = rowmean(openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum)
label var index_Openness_Reg_el "Openness Index (Regular)"
summ index_Openness_Reg_el

***Victim-Blaming Index***

**codebook of variables to be used for the Victim Blaming index
codebook dv2_goes_wo_informing_el dv2_neglects_children_el dv2_burns_food_el dv2_argues_el dv2_refuses_sex_el
*rename prem_soc_unacceptable_el psu_el
codebook psu_el
*codebook non_gbv_fem_fault_el

**recoding 0 = positive outcome, 1 = negative outcome
gen dv2_wo_informing_dum_el = dv2_goes_wo_informing_el
recode dv2_wo_informing_dum_el 0=1 1=0 -999=0 -666=0
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

local VB dv2_wo_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el
make_index_gr VictimBlame_And_el wgt stdgroup `VB'
label var index_VictimBlame_And_el "Victim Blaming Index (Anderson)"

summ index_VictimBlame_And_el

**creating the Victim-Blaming index (Regular)
egen index_VictimBlame_Reg_el = rowmean(dv2_wo_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el)
label var index_VictimBlame_Reg_el "Victim Blaming Index (Regular)"
summ index_VictimBlame_Reg_el

*generating histogram for the Victim-Blaming indices (Anderson + Regular)
histogram index_VictimBlame_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EV1)
histogram index_VictimBlame_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EV2)

***Technical Skills Index***

**codebook of variables to be used for Technical Skills Index
codebook dv_complaint_relative_el sa_burden_proof_el eviction_dv_el fem_shelter_el verbal_abuse_public_el verbal_abuse_ipc_el sa_identity_leaked_el sa_identity_ipc_el

**replacing multivariates with dummy variables
gen dv_compl_rel_dum_el = dv_complaint_relative_el 
recode dv_compl_rel_dum_el 1=1 2=0 3=0 4=0 -999=0 -666=0
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
replace verbal_abuse_ipc_dum_el = 1 if verbal_abuse_ipc_el == 3
gen sa_identity_leaked_dum_el = 0
replace sa_identity_leaked_dum_el = 1 if sa_identity_leaked_el == 1
gen sa_identity_ipc_dum_el = 0
replace sa_identity_ipc_dum_el = 1 if sa_identity_ipc_el == 3

gen ipc_dum_os = regexm(verbal_abuse_ipc_os_el,"509") 
replace verbal_abuse_ipc_dum_el = 1 if ipc_dum_os == 1
drop ipc_dum_os

**creating the Technical Skills index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local TS dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el
make_index_gr Techskills_And_el wgt stdgroup `TS'
label var index_Techskills_And_el "Technical Skills Index (Anderson)"
summ index_Techskills_And_el

**creating the Technical Skills index (Regular)
egen index_Techskills_Reg_el = rowmean(dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el)
label var index_Techskills_Reg_el "Technical Skills Index (Regular)"
summ index_Techskills_Reg_el

*generating histogram for the Technical Skills indices (Anderson + Regular)
histogram index_Techskills_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ET1)
histogram index_Techskills_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ET2)

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
histogram index_Empathy_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EM1)
histogram index_Empathy_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EM2)

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

*recode pri_1_el 0=1 1=0 /*NOT reversing the direction of the variable*/
*recode pri_2_el 0=1 1=0 /*NOT reversing the direction of the variable*/
recode pri_3_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_4_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_5_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_6_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_7_el_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_8_el_dum 0=1 1=0 /*reversing the direction of the variable*/
*recode pri_9_el 0=1 1=0 /*NOT reversing the direction of the variable*/

/*
**assigning correct labels to the recoded variables
label drop PRI_el
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
histogram index_Flexibility_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EF1)
histogram index_Flexibility_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EF2)

***Social Desirability Index***

**codebook of variables to be used for Social Desirability Index
codebook sdb_1_el sdb_2_el sdb_3_el sdb_4_el sdb_5_el sdb_6_el sdb_7_el sdb_8_el sdb_9_el sdb_10_el sdb_11_el sdb_12_el sdb_13_el

//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 {
	gen sdb_`i'_el_dum = sdb_`i'_el //for all questions, we have 0 - False , 1 - True
	recode sdb_`i'_el_dum 0=1 1=0 if (`i' != 5 & `i' != 7 & `i' != 9 & `i' != 10 & `i' != 13) //recoding for all questions where False indicates higher SDB. This excludes 5,7,9,10,13 where True indicates higher SDB
	label values sdb_`i'_el_dum SDB
}

/*
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
label drop SDB_el
label def SDB_el 0 "TRUE" 1 "FALSE"
label values sdb_5_el SDB_el
label values sdb_7_el SDB_el
label values sdb_9_el SDB_el
label values sdb_10_el SDB_el
label values sdb_13_el SDB_el
*/
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
histogram index_Desirability_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ES1)
histogram index_Desirability_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ES2)

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
label drop GAD_2
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
histogram index_Anxiety_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EX1)

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
label drop PHQ_2
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
histogram index_Depression_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EP1)

***Attitude Towards GBV Index***

**codebook of variables to be used for Attitudes Index
codebook land_compromise_el fem_cases_overattention_el
codebook gbv_abusive_beh_el gbv_fem_fault_el

**replacing multivariates with dummy variables
gen land_compromise_dum_el = land_compromise_el
recode land_compromise_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen fem_cases_over_dum_el = fem_cases_overattention_el
recode fem_cases_over_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_abusive_beh_dum_el = gbv_abusive_beh_el
recode gbv_abusive_beh_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen gbv_fem_fault_dum_el = gbv_fem_fault_el
recode gbv_fem_fault_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Attitudes towards GBV index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Atti land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el

make_index_gr AttitudeGBV_And_el wgt stdgroup `Atti'
label var index_AttitudeGBV_And_el "Attitudes toward GBV Index (Anderson)"
summ index_AttitudeGBV_And_el

**creating the Attitudes towards GBV index (Regular)
egen index_AttitudeGBV_Reg_el = rowmean(land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el)
label var index_AttitudeGBV_Reg_el "Attitudes toward GBV Index (Regular)"
summ index_AttitudeGBV_Reg_el

*generating histogram for the Attitudes towards GBV indices (Anderson + Regular)
histogram index_AttitudeGBV_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EA1)
histogram index_AttitudeGBV_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EA2)

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
histogram index_ExtPol_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EE1)
histogram index_ExtPol_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(EE2)

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
histogram index_Discrimination_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ED1)
histogram index_Discrimination_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ED2)

***Truthfulness of Complaints Index***

**codebook of variables to be used for Truthfulness Index
codebook land_false_el land_false_sa_el premarital_false_el premarital_framing_el believable_with_relative_el gbv_true_el non_gbv_true_el

**replacing multivariates with dummy variables
gen land_false_dum_el = land_false_el
recode land_false_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 
gen premarital_false_dum_el = premarital_false_el
recode premarital_false_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 -999=0 -666=0  
gen premarital_framing_dum_el = premarital_framing_el
recode premarital_framing_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0  -999=0 -666=0 
gen believe_w_relat_dum_el = believable_with_relative_el
recode believe_w_relat_dum_el 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_true_dum_el = gbv_true_el
recode gbv_true_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen non_gbv_true_dum_el = non_gbv_true_el
recode non_gbv_true_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

gen land_false_sa_dum_el = land_false_sa_el
recode land_false_sa_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0

**creating the Truthfulness Index (Anderson)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file

local Truth land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el

make_index_gr Truth_And_el wgt stdgroup `Truth'
label var index_Truth_And_el "Truthfulness Index (Anderson)"
summ index_Truth_And_el

**creating the Truthfulness Index (Regular)
egen index_Truth_Reg_el = rowmean(land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el)
label var index_Truth_Reg_el "Truthfulness Index (Regular)"
summ index_Truth_Reg_el

*generating histogram for the Truthfulness indices (Anderson + Regular)
histogram index_Truth_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ER1)
histogram index_Truth_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(ER2)

*summarising the indices
summ index_VictimBlame_And_el index_Techskills_And_el index_Empathy_And_el index_Flexibility_And_el index_Desirability_And_el index_AttitudeGBV_And_el index_ExtPol_And_el index_Discrimination_And_el index_Truth_And_el index_Openness_And_el
summ index_VictimBlame_Reg_el index_Techskills_Reg_el index_Empathy_Reg_el index_Flexibility_Reg_el index_AttitudeGBV_Reg_el index_ExtPol_Reg_el index_Discrimination_Reg_el index_Truth_Reg_el index_Openness_Reg_el
summ index_Desirability_Reg_el index_Anxiety_el index_Depression_el


**********Creating combined index
drop wgt stdgroup
gen wgt=1
gen stdgroup = (treatment_bl == 0)
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file
local combined_bl index_VictimBlame_And_bl index_Empathy_And_bl index_Flexibility_And_bl index_AttitudeGBV_And_bl index_ExtPol_And_bl index_Discrimination_And_bl index_Truth_And_bl
make_index_gr Combined_And_bl wgt stdgroup `combined_bl'
label var index_Combined_And_bl "Soft skills index"
summ index_Combined_And_bl

local combined_bl2 index_VictimBlame_And_bl index_Techskills_And_bl index_Empathy_And_bl index_Flexibility_And_bl index_AttitudeGBV_And_bl index_ExtPol_And_bl index_Discrimination_And_bl index_Truth_And_bl
make_index_gr Combined_And2_bl wgt stdgroup `combined_bl2'
label var index_Combined_And2_bl "GBV skills index"
summ index_Combined_And2_bl

drop wgt stdgroup
gen wgt=1
gen stdgroup = (treatment_el == 0)
local combined_el index_VictimBlame_And_el index_Empathy_And_el index_Flexibility_And_el index_AttitudeGBV_And_el index_ExtPol_And_el index_Discrimination_And_el index_Truth_And_el
make_index_gr Combined_And_el wgt stdgroup `combined_el'
label var index_Combined_And_el "Soft skills index"
summ index_Combined_And_el

local combined_el2 index_VictimBlame_And_el index_Techskills_And_el index_Empathy_And_el index_Flexibility_And_el index_AttitudeGBV_And_el index_ExtPol_And_el index_Discrimination_And_el index_Truth_And_el
make_index_gr Combined_And2_el wgt stdgroup `combined_el2'
label var index_Combined_And2_el "GBV skills index"
summ index_Combined_And2_el

**********Creating combined index (disaggregated)
drop wgt stdgroup
gen wgt=1
gen stdgroup = (treatment_bl == 0)
local combined_disagg_bl openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl dv2_goes_wo_informing_dum_bl dv2_neglects_children_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl pri_1_bl_dum pri_2_bl_dum pri_3_bl_dum pri_4_bl_dum pri_5_bl_dum pri_6_bl_dum pri_7_bl_dum pri_8_bl_dum pri_9_bl_dum land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl
make_index_gr Combined_disag_And_bl wgt stdgroup `combined_disagg_bl'
label var index_Combined_disag_And_bl "GBV skills index - disaggregated"
summ index_Combined_disag_And_bl

drop wgt stdgroup
gen wgt=1
gen stdgroup = (treatment_el == 0)
local combined_disagg_el openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum dv2_wo_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el
make_index_gr Combined_disag_And_el wgt stdgroup `combined_disagg_el'
label var index_Combined_disag_And_el "GBV skills index - disaggregated"
summ index_Combined_disag_And_el

rename dv2_goes_wo_informing_dum_bl dv2_wo_informing_dum_bl 
rename dv2_neglects_children_dum_bl dv2_negchildren_dum_bl
rename dv2_neglects_children_dum_el dv2_negchildren_dum_el

*******Swindex - Baseline (using treatment_bl as independent variable)

gen sw_dum_training = dum_training
recode sw_dum_training 0=1 1=0
gen sw_dum_treatment_bl = treatment_bl
recode sw_dum_treatment_bl 0=1 1=0
gen sw_dum_treatment_el = treatment_el
recode sw_dum_treatment_el 0=1 1=0

swindex openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl, g(swindex_Openness_bl) normby(sw_dum_treatment_bl) displayw

swindex dv2_wo_informing_dum_bl dv2_negchildren_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl, g(swindex_VictimBlame_bl) normby(sw_dum_treatment_bl) displayw

swindex dv_compl_rel_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl, g(swindex_TechSkills_bl) normby(sw_dum_treatment_bl) displayw

swindex eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl, g(swindex_Empathy_bl) normby(sw_dum_treatment_bl) displayw

swindex pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum, g(swindex_Flexibility_bl) normby(sw_dum_treatment_bl) displayw

swindex sdb_1_bl_dum sdb_2_bl_dum sdb_3_bl_dum sdb_4_bl_dum sdb_5_bl_dum sdb_6_bl_dum sdb_7_bl_dum sdb_8_bl_dum sdb_9_bl_dum sdb_10_bl_dum sdb_11_bl_dum sdb_12_bl_dum sdb_13_bl_dum, g(swindex_Desirability_bl) normby(sw_dum_treatment_bl) displayw

swindex land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl, g(swindex_AttitudeGBV_bl) normby(sw_dum_treatment_bl) displayw

swindex dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl, g(swindex_ExtPol_bl) normby(sw_dum_treatment_bl) displayw

swindex caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl caste_true_dum_bl, g(swindex_Discrimination_bl) normby(sw_dum_treatment_bl) displayw

swindex land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl, g(swindex_Truth_bl) normby(sw_dum_treatment_bl) displayw

swindex swindex_Openness_bl swindex_VictimBlame_bl swindex_Empathy_bl swindex_Flexibility_bl swindex_AttitudeGBV_bl swindex_ExtPol_bl swindex_Discrimination_bl swindex_Truth_bl, g(swindex_Combined_bl) normby(sw_dum_treatment_bl) displayw

*******Swindex - Endline (using treatment_bl as independent variable)

swindex openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum , g(swindex_Openness_el) normby(sw_dum_treatment_el) displayw

swindex dv2_wo_informing_dum_el dv2_negchildren_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el , g(swindex_VictimBlame_el) normby(sw_dum_treatment_el) displayw

swindex dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el , g(swindex_TechSkills_el) normby(sw_dum_treatment_el) displayw

swindex eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el , g(swindex_Empathy_el) normby(sw_dum_treatment_el) displayw

swindex pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el , g(swindex_Flexibility_el) normby(sw_dum_treatment_el) displayw

swindex sdb_1_el_dum sdb_2_el_dum sdb_3_el_dum sdb_4_el_dum sdb_5_el_dum sdb_6_el_dum sdb_7_el_dum sdb_8_el_dum sdb_9_el_dum sdb_10_el_dum sdb_11_el_dum sdb_12_el_dum sdb_13_el_dum , g(swindex_Desirability_el) normby(sw_dum_treatment_el) displayw

swindex land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el , g(swindex_AttitudeGBV_el) normby(sw_dum_treatment_el) displayw

swindex dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el , g(swindex_ExtPol_el) normby(sw_dum_treatment_el) displayw

swindex caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el , g(swindex_Discrimination_el) normby(sw_dum_treatment_el) displayw

swindex land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el , g(swindex_Truth_el) normby(sw_dum_treatment_el) displayw

swindex swindex_Openness_el swindex_VictimBlame_el swindex_Empathy_el swindex_Flexibility_el swindex_AttitudeGBV_el swindex_ExtPol_el swindex_Discrimination_el swindex_Truth_el, g(swindex_Combined_el) normb(sw_dum_treatment_el) displayw

label variable swindex_Openness_bl "Openness"
label variable swindex_Openness_el "openness"

label variable swindex_VictimBlame_bl "Victim-blaming"
label variable swindex_VictimBlame_el "victim blaming"

label variable swindex_TechSkills_bl "Technical skills"
label variable swindex_TechSkills_el "technical skills"

label variable swindex_Empathy_bl "Empathy"
label variable swindex_Empathy_el "empathy"

label variable swindex_Flexibility_bl "Flexibility"
label variable swindex_Flexibility_el "flexibility"

label variable swindex_Desirability_bl "Social desirability"
label variable swindex_Desirability_el "desirability"

label variable swindex_AttitudeGBV_bl "Attitudes towards GBV"
label variable swindex_AttitudeGBV_el "attitudes towards GBV"

label variable swindex_ExtPol_bl "Externalising police responses"
label variable swindex_ExtPol_el "externalising police responsiblities"

label variable swindex_Discrimination_bl "Discrimination"
label variable swindex_Discrimination_el "discrimination"

label variable swindex_Truth_bl "Truthfulness of complaints"
label variable swindex_Truth_el "truthfulness of complaints"

label variable swindex_Combined_bl "GBV skills index"
label variable swindex_Combined_el "GBV skills index"

swindex openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl dv2_wo_informing_dum_bl dv2_negchildren_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl pri_1_bl_dum pri_2_bl_dum pri_3_bl_dum pri_4_bl_dum pri_5_bl_dum pri_6_bl_dum pri_7_bl_dum pri_8_bl_dum pri_9_bl_dum land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl, g(swindex_Combined_disag_bl) normby(sw_dum_treatment_bl) displayw

swindex openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum dv2_wo_informing_dum_el dv2_negchildren_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el, g(swindex_Combined_disag_el) normby(sw_dum_treatment_el) displayw

label variable swindex_Combined_disag_bl "GBV skills index - disaggregated"
label variable swindex_Combined_disag_el "GBV skills index - disaggregated"


*******Swindex - Baseline (using training as independent variable)

swindex openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl, g(swindex_Openness_tr_bl) normby(sw_dum_training) displayw

swindex dv2_wo_informing_dum_bl dv2_negchildren_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl, g(swindex_VictimBlame_tr_bl) normby(sw_dum_training) displayw

swindex dv_compl_rel_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl, g(swindex_TechSkills_tr_bl) normby(sw_dum_training) displayw

swindex eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl, g(swindex_Empathy_tr_bl) normby(sw_dum_training) displayw

swindex pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum, g(swindex_Flexibility_tr_bl) normby(sw_dum_training) displayw

swindex sdb_1_bl_dum sdb_2_bl_dum sdb_3_bl_dum sdb_4_bl_dum sdb_5_bl_dum sdb_6_bl_dum sdb_7_bl_dum sdb_8_bl_dum sdb_9_bl_dum sdb_10_bl_dum sdb_11_bl_dum sdb_12_bl_dum sdb_13_bl_dum, g(swindex_Desirability_tr_bl) normby(sw_dum_training) displayw

swindex land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl, g(swindex_AttitudeGBV_tr_bl) normby(sw_dum_training) displayw

swindex dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl, g(swindex_ExtPol_tr_bl) normby(sw_dum_training) displayw

swindex caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl caste_true_dum_bl, g(swindex_Discrimination_tr_bl) normby(sw_dum_training) displayw

swindex land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl, g(swindex_Truth_tr_bl) normby(sw_dum_training) displayw

swindex swindex_Openness_bl swindex_VictimBlame_bl swindex_Empathy_bl swindex_Flexibility_bl swindex_AttitudeGBV_bl swindex_ExtPol_bl swindex_Discrimination_bl swindex_Truth_bl, g(swindex_Combined_tr_bl) normby(sw_dum_training) displayw

*******Swindex - Endline (using training as independent variable)

swindex openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum , g(swindex_Openness_tr_el) normby(sw_dum_training) displayw

swindex dv2_wo_informing_dum_el dv2_negchildren_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el , g(swindex_VictimBlame_tr_el) normby(sw_dum_training) displayw

swindex dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el , g(swindex_TechSkills_tr_el) normby(sw_dum_training) displayw

swindex eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el , g(swindex_Empathy_tr_el) normby(sw_dum_training) displayw

swindex pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el , g(swindex_Flexibility_tr_el) normby(sw_dum_training) displayw

swindex sdb_1_el_dum sdb_2_el_dum sdb_3_el_dum sdb_4_el_dum sdb_5_el_dum sdb_6_el_dum sdb_7_el_dum sdb_8_el_dum sdb_9_el_dum sdb_10_el_dum sdb_11_el_dum sdb_12_el_dum sdb_13_el_dum , g(swindex_Desirability_tr_el) normby(sw_dum_training) displayw

swindex land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el , g(swindex_AttitudeGBV_tr_el) normby(sw_dum_training) displayw

swindex dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el , g(swindex_ExtPol_tr_el) normby(sw_dum_training) displayw

swindex caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el , g(swindex_Discrimination_tr_el) normby(sw_dum_training) displayw

swindex land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el , g(swindex_Truth_tr_el) normby(sw_dum_training) displayw

swindex swindex_Openness_el swindex_VictimBlame_el swindex_Empathy_el swindex_Flexibility_el swindex_AttitudeGBV_el swindex_ExtPol_el swindex_Discrimination_el swindex_Truth_el, g(swindex_Combined_tr_el) normb(sw_dum_training) displayw

label variable swindex_Openness_tr_bl "Openness"
label variable swindex_Openness_tr_el "openness"

label variable swindex_VictimBlame_tr_bl "Victim-blaming"
label variable swindex_VictimBlame_tr_el "victim blaming"

label variable swindex_TechSkills_tr_bl "Technical skills"
label variable swindex_TechSkills_tr_el "technical skills"

label variable swindex_Empathy_tr_bl "Empathy"
label variable swindex_Empathy_tr_el "empathy"

label variable swindex_Flexibility_tr_bl "Flexibility"
label variable swindex_Flexibility_tr_el "flexibility"

label variable swindex_Desirability_tr_bl "Social desirability"
label variable swindex_Desirability_tr_el "desirability"

label variable swindex_AttitudeGBV_tr_bl "Attitudes towards GBV"
label variable swindex_AttitudeGBV_tr_el "attitudes towards GBV"

label variable swindex_ExtPol_tr_bl "Externalising police responses"
label variable swindex_ExtPol_tr_el "externalising police responsiblities"

label variable swindex_Discrimination_tr_bl "Discrimination"
label variable swindex_Discrimination_tr_el "discrimination"

label variable swindex_Truth_tr_bl "Truthfulness of complaints"
label variable swindex_Truth_tr_el "truthfulness of complaints"

label variable swindex_Combined_tr_bl "GBV skills index"
label variable swindex_Combined_tr_el "GBV skills index"

swindex openness_1_dum_bl openness_2_dum_bl openness_3_dum_bl openness_4_dum_bl openness_5_dum_bl openness_6_dum_bl openness_7_dum_bl openness_8_dum_bl openness_9_dum_bl dv2_wo_informing_dum_bl dv2_negchildren_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl pri_1_bl_dum pri_2_bl_dum pri_3_bl_dum pri_4_bl_dum pri_5_bl_dum pri_6_bl_dum pri_7_bl_dum pri_8_bl_dum pri_9_bl_dum land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl dv1_internal_matter_bl_dum dv1_common_incident_bl_dum dv1_fears_beating_bl_dum gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl, g(swindex_Combined_disag_tr_bl) normby(sw_dum_training) displayw

swindex openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum dv2_wo_informing_dum_el dv2_negchildren_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el, g(swindex_Combined_disag_tr_el) normby(sw_dum_training) displayw

label variable swindex_Combined_disag_tr_bl "GBV skills index - disaggregated"
label variable swindex_Combined_disag_tr_el "GBV skills index - disaggregated"

*******Swindex - PSFS (using treatment_bl as independent variable)

swindex ps_bathroom_bl  ps_confidential_bl ps_electricity_bl dum_ps_fourwheeler_bl dum_ps_twowheeler_bl dum_ps_computer_bl ps_seating_bl ps_cleaning_bl ///
ps_water_bl ps_barrack_bl ps_storage_bl ps_evidence_bl ps_phone_bl dum_lockup_bl ps_shelter_bl dum_ps_cctv_bl if dum_baseline == 1, g(swindex_psfs_gen_bl) normby(sw_dum_treatment_bl) displayw

swindex ps_fembathroom_bl ps_femconfid_dum_bl ps_fembarrack_bl ps_femlockup_bl ps_femshelter_bl if dum_baseline == 1, g(swindex_psfs_fem_infra_bl) normby(sw_dum_treatment_bl) displayw

swindex dum_headconstable_bl dum_wtconstable_bl dum_constable_bl dum_asi_bl dum_si_bl dum_ins_bl dum_sho_bl if dum_baseline == 1, g(swindex_psfs_m_f_seg_bl) normby(sw_dum_treatment_bl) displayw


*******Swindex - PSFS (using training as independent variable)

swindex ps_bathroom_bl  ps_confidential_bl ps_electricity_bl dum_ps_fourwheeler_bl dum_ps_twowheeler_bl dum_ps_computer_bl ps_seating_bl ps_cleaning_bl ///
ps_water_bl ps_barrack_bl ps_storage_bl ps_evidence_bl ps_phone_bl dum_lockup_bl ps_shelter_bl dum_ps_cctv_bl if dum_baseline == 1, g(swindex_psfs_gen_tr_bl) normby(sw_dum_training) displayw

swindex ps_fembathroom_bl ps_femconfid_dum_bl ps_fembarrack_bl ps_femlockup_bl ps_femshelter_bl if dum_baseline == 1, g(swindex_psfs_fem_infra_tr_bl) normby(sw_dum_training) displayw

swindex dum_headconstable_bl dum_wtconstable_bl dum_constable_bl dum_asi_bl dum_si_bl dum_ins_bl dum_sho_bl if dum_baseline == 1, g(swindex_psfs_m_f_seg_tr_bl) normby(sw_dum_training) displayw

*drop index_psfs_gen_And index_psfs_gen_Reg index_psfs_fem_infra_And index_psfs_fem_infra_Reg index_psfs_m_f_seg_And index_psfs_m_f_seg_Reg
 **creating the PSFS (General) index (Anderson)
drop  wgt stdgroup
gen wgt = 1
gen stdgroup = sw_dum_treatment_bl
qui do "$MO_endline_do_files\make_index_gr.do" //Execute Anderson index do file
local psfs_gen ps_bathroom_bl ps_confidential_bl ps_electricity_bl dum_ps_fourwheeler_bl dum_ps_twowheeler_bl dum_ps_computer_bl ps_seating_bl ps_cleaning_bl ///
ps_water_bl ps_barrack_bl ps_storage_bl ps_evidence_bl ps_phone_bl dum_lockup_bl ps_shelter_bl dum_ps_cctv_bl 
make_index_gr psfs_gen_And wgt stdgroup `psfs_gen' if dum_baseline == 1
egen std_index_psfs_gen_And = std(index_psfs_gen_And)
label var index_psfs_gen_And "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_And

**creating the PSFS (General) index (Regular)
egen index_psfs_gen_Reg = rowmean(ps_confidential_bl ps_electricity_bl dum_ps_fourwheeler_bl dum_ps_twowheeler_bl dum_ps_computer_bl ps_seating_bl ps_cleaning_bl ///
ps_water_bl ps_barrack_bl ps_storage_bl ps_evidence_bl ps_phone_bl dum_lockup_bl ps_shelter_bl dum_ps_cctv_bl) if dum_baseline == 1
label var index_psfs_gen_Reg "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_Reg

 **creating the PSFS (Fem Infra) index (Anderson)

local psfs_fem_infra ps_fembathroom_bl ps_femconfid_dum_bl ps_fembarrack_bl ps_femlockup_bl ps_femshelter_bl 
make_index_gr psfs_fem_infra_And wgt stdgroup `psfs_fem_infra' if dum_baseline == 1
egen std_index_psfs_fem_infra_And = std(index_psfs_fem_infra_And)
label var index_psfs_fem_infra_And "Police Station Gender Facilities Index (Anderson)"
summ index_psfs_fem_infra_And

**creating the PSFS (Fem Infra) index (Regular)
egen index_psfs_fem_infra_Reg = rowmean(ps_fembathroom_bl ps_femconfid_dum_bl ps_fembarrack_bl ps_femlockup_bl ps_femshelter_bl) if dum_baseline == 1
label var index_psfs_fem_infra_Reg "Police Station Gender Facilities Index (Regular)"
summ index_psfs_fem_infra_Reg

foreach var of varlist dum_headconstable_bl dum_wtconstable_bl dum_constable_bl dum_asi_bl dum_si_bl dum_ins_bl dum_sho_bl{
	replace `var' = . if dum_baseline == 0
}

**creating the PSFS (Male-Female Segregation) index (Anderson)

local psfs_m_f_seg_1 dum_headconstable_bl dum_wtconstable_bl dum_constable_bl dum_asi_bl dum_si_bl dum_ins_bl dum_sho_bl
make_index_gr psfs_m_f_seg_And wgt stdgroup `psfs_m_f_seg_1' if dum_baseline == 1
egen std_index_psfs_m_f_seg_And = std(index_psfs_m_f_seg_And)
label var index_psfs_m_f_seg_And "PSFS (Male-Female Segregation) Index (Anderson)"
summ index_psfs_m_f_seg_And 

**creating the PSFS (Male-Female Segregation) index (Regular)
egen index_psfs_m_f_seg_Reg = rowmean(dum_headconstable_bl dum_wtconstable_bl dum_constable_bl dum_asi_bl dum_si_bl dum_ins_bl dum_sho_bl) if dum_baseline == 1
label var index_psfs_m_f_seg_Reg "PSFS (Male-Female Segregation) Index (Regular)"
summ index_psfs_m_f_seg_Reg

drop sw_dum_training sw_dum_treatment_bl sw_dum_treatment_el

save "$MO_endline_clean_dta\combined_FINAL_indices.dta", replace