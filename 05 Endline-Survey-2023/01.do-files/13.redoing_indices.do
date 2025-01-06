/*==============================================================================
File Name: Baseline Officer's Survey 2022 - Creating Endline Indices
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/01/2023
Created by: Aadya Gupta
Updated on: 30/05/2023
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

**File Directory

*dibbo -- username for Dibyajyoti.
*Acer -- username for Shubhro. 
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 

if "`c(username)'"=="HP"{
	global dropbox "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Endline-Survey-2023"
	}	
else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Endline-Survey-2023"
	}
	
	else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Endline-Survey-2023"
	}
	
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}
	
di "`dropbox'"
	
*File Path

global raw "$dropbox\00.raw-data"
global do_files "$dropbox\01.do-files"
global intermediate_dta "$dropbox\02.intermediate-data\"
global tables "$dropbox\03.tables\"
global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\05.log-files\"
global clean_dta "$dropbox\06.clean-data\"


* We will log in
capture log close 

log using "${log_files}officersurvey_endlineindices_redoing.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


*****only keeping baseline data to redo the baseline indices
use "${intermediate_dta}endline_intermediate.dta", clear
keep if dum_baseline == 1
drop openness_1_dum_bl-index_Truth_Reg_bl
drop *_el
order dum_baselineonly
drop dum_baseline-dum_decoy_treatment

 ****************************************REDOING THE INDICES**********************************************************************
 **Rationale for recoding 0 = gender-regressive, 1 = gender-progressive (or simply regressive/progressive for indices like Flexibility, Desirability, etc.) 
/*The individual variables are first converted to dummy variables. For questions that used a 5-point Likert scale, the binary variable was coded as 1 if the respondent answered "Strongly Agree" or "Agree" with a gender-progressive statement (or "Strongly Disagree" or "Disagree" with a gender-regressive statement), and 0 otherwise. (Jayachandran, 2018)*/

drop ps_dist sv_id sv_location ps_series ps_series_os po_rank ps_confirm formdef_version sv_date sv_start sv_stop

rename *_bl *
 
 **Replacing multivariates with dummy variables
 
 gen openness_1_dum=openness_1
 recode openness_1_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_2_dum=openness_2
 recode openness_2_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_3_dum=openness_3 
 recode openness_3_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_4_dum=openness_4
 recode openness_4_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_5_dum=openness_5
 recode openness_5_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_6_dum=openness_6
 recode openness_6_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_7_dum=openness_7
 recode openness_7_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_8_dum=openness_8
 recode openness_8_dum 1=1 2=1 3=0 4=0 5=0
 gen openness_9_dum=openness_9
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
drop wgt stdgroup
gen wgt=1
gen stdgroup=1
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file
local open1 openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum
make_index_gr Openness_And wgt stdgroup `open1'
cap egen std_Openness_And = std(index_Openness_And)
label var index_Openness_And "Openness Index (Anderson)"
summ index_Openness_And

**creating the Openness index (Regular)
egen index_Openness_Reg = rowmean(openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum)
label var index_Openness_Reg "Openness Index (Regular)"
summ index_Openness_Reg

***Victim-Blaming Index***

**codebook of variables to be used for the Victim Blaming index
codebook dv2_goes_without_informing dv2_neglects_children dv2_burns_food dv2_argues dv2_refuses_sex
codebook psu
codebook non_gbv_fem_fault
*rename premarital_socially_unacceptable psu

**recoding 0 = positive outcome, 1 = negative outcome
gen dv2_without_informing_dum = dv2_goes_without_informing
recode dv2_without_informing_dum 0=1 1=0 -999=0 -666=0
gen dv2_neglects_children_dum = dv2_neglects_children
recode dv2_neglects_children_dum 0=1 1=0 -999=0 -666=0
gen dv2_burns_food_dum = dv2_burns_food
recode dv2_burns_food_dum 0=1 1=0 -999=0 -666=0
gen dv2_argues_dum = dv2_argues
recode dv2_argues_dum 0=1 1=0 -999=0 -666=0
gen dv2_refuses_sex_dum = dv2_refuses_sex
recode dv2_refuses_sex_dum 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen psu_dum = psu
recode psu_dum 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen non_gbv_fem_fault_dum = non_gbv_fem_fault
recode non_gbv_fem_fault_dum 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Victim-Blaming index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

*gen wgt=1
*gen stdgroup=1

local VB dv2_without_informing_dum dv2_neglects_children_dum dv2_burns_food_dum dv2_argues_dum dv2_refuses_sex_dum psu_dum non_gbv_fem_fault_dum
make_index_gr VictimBlame_And wgt stdgroup `VB'
egen std_VictimBlame_And = std(index_VictimBlame_And)
label var index_VictimBlame_And "Victim Blaming Index (Anderson)"

summ index_VictimBlame_And

**creating the Victim-Blaming index (Regular)
egen index_VictimBlame_Reg = rowmean(dv2_without_informing_dum dv2_neglects_children_dum dv2_burns_food_dum dv2_argues_dum dv2_refuses_sex_dum psu_dum non_gbv_fem_fault_dum)
label var index_VictimBlame_Reg "Victim Blaming Index (Regular)"
summ index_VictimBlame_Reg

*generating histogram for the Victim-Blaming indices (Anderson + Regular)
histogram index_VictimBlame_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V1)
histogram index_VictimBlame_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V2)

***Technical Skills Index***

**codebook of variables to be used for Technical Skills Index
codebook dv_complaint_relative sa_burden_proof eviction_dv fem_shelter verbal_abuse_public verbal_abuse_ipc sa_identity_leaked sa_identity_ipc

**replacing multivariates with dummy variables
gen dv_complaint_relative_dum = dv_complaint_relative 
recode dv_complaint_relative_dum 1=1 2=0 3=0 -999=0 -666=0
gen sa_burden_proof_dum = sa_burden_proof 
recode sa_burden_proof_dum 1=0 2=0 3=0 4=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eviction_dv_dum = eviction_dv
recode eviction_dv_dum 1=1 2=0 3=0 -999=0 -666=0
gen fem_shelter_dum = fem_shelter
recode fem_shelter_dum 1=1 2=0 3=0 4=0 -999=0 -666=0

**creating dummy variables for follow up questions
gen verbal_abuse_public_dum = 0
replace verbal_abuse_public_dum = 1 if verbal_abuse_public == 1
gen verbal_abuse_ipc_dum = 0
replace verbal_abuse_ipc_dum = 1 if verbal_abuse_ipc == 3
gen sa_identity_leaked_dum = 0
replace sa_identity_leaked_dum = 1 if sa_identity_leaked == 1
gen sa_identity_ipc_dum = 0
replace sa_identity_ipc_dum = 1 if sa_identity_ipc == 3

**creating the Technical Skills index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local TS dv_complaint_relative_dum sa_burden_proof_dum eviction_dv_dum fem_shelter_dum verbal_abuse_public_dum verbal_abuse_ipc_dum sa_identity_leaked_dum sa_identity_ipc_dum
make_index_gr Techskills_And wgt stdgroup `TS'
cap egen std_Techskills_And = std(index_Techskills_And)
label var index_Techskills_And "Technical Skills Index (Anderson)"
summ index_Techskills_And

**creating the Technical Skills index (Regular)
egen index_Techskills_Reg = rowmean(dv_complaint_relative_dum sa_burden_proof_dum eviction_dv_dum fem_shelter_dum verbal_abuse_public_dum verbal_abuse_ipc_dum sa_identity_leaked_dum sa_identity_ipc_dum)
label var index_Techskills_Reg "Technical Skills Index (Regular)"
summ index_Techskills_Reg

*generating histogram for the Technical Skills indices (Anderson + Regular)
histogram index_Techskills_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T1)
histogram index_Techskills_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T2)

***Empathy Index***

**codebook of variables to be used for Empathy Index
codebook eq_1 eq_2 eq_3 eq_4 eq_5 eq_6 gbv_empathy non_gbv_empathy

**replacing multivariates with dummy variables
gen eq_1_dum = eq_1
recode eq_1_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eq_2_dum = eq_2
recode eq_2_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_3_dum = eq_3
recode eq_3_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_4_dum = eq_4
recode eq_4_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen eq_5_dum = eq_5
recode eq_5_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen eq_6_dum = eq_6
recode eq_6_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen gbv_empathy_dum = gbv_empathy
recode gbv_empathy_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen non_gbv_empathy_dum = non_gbv_empathy
recode non_gbv_empathy_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

**creating the Empathy index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Emp eq_1_dum eq_2_dum eq_3_dum eq_4_dum eq_5_dum eq_6_dum gbv_empathy_dum non_gbv_empathy_dum
make_index_gr Empathy_And wgt stdgroup `Emp'
cap egen std_Empathy_And = std(index_Empathy_And)
label var index_Empathy_And "Empathy Index (Anderson)"
summ index_Empathy_And

**creating the Empathy index (Regular)
egen index_Empathy_Reg = rowmean(eq_1_dum eq_2_dum eq_3_dum eq_4_dum eq_5_dum eq_6_dum gbv_empathy_dum non_gbv_empathy_dum)
label var index_Empathy_Reg "Empathy Index (Regular)"
summ index_Empathy_Reg

*generating histogram for the Empathy indices (Anderson + Regular)
histogram index_Empathy_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M1)
histogram index_Empathy_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M2)

***Flexibility Index***
****Scale of Personal Rigidity derived by Rebisch (1958)
****Qs 8, 10, 14, 16, 17, 19, 22, 25, 26
**codebook of variables to be used for Flexibility Index
codebook pri_1 pri_2 pri_3 pri_4 pri_5 pri_6 pri_7 pri_8 pri_9

*recode pri_1 0=1 1=0 /*reversing the direction of the variable*/
*recode pri_2 0=1 1=0 /*reversing the direction of the variable*/
recode pri_3 0=1 1=0 /*reversing the direction of the variable*/
recode pri_4 0=1 1=0 /*reversing the direction of the variable*/
recode pri_5 0=1 1=0 /*reversing the direction of the variable*/
recode pri_6 0=1 1=0 /*reversing the direction of the variable*/
recode pri_7 0=1 1=0 /*NOT reversing the direction of the variable*/
recode pri_8 0=1 1=0 /*NOT reversing the direction of the variable*/
*recode pri_9 0=1 1=0 /*reversing the direction of the variable*/

**assigning correct labels to the recoded variables
label def PRI_1 0 "TRUE" 1 "FALSE"
*label values pri_1 PRI
*label values pri_2 PRI
label values pri_3 PRI_1
label values pri_4 PRI_1
label values pri_5 PRI_1
label values pri_6 PRI_1
label values pri_7 PRI_1
label values pri_8 PRI_1
*label values pri_9 PRI

**creating the Flexibility index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Flex pri_1 pri_2 pri_3 pri_4 pri_5 pri_6 pri_7 pri_8 pri_9

make_index_gr Flexibility_And wgt stdgroup `Flex'
cap egen std_Flexibility_And = std(index_Flexibility_And)
label var index_Flexibility_And "Flexibility Index (Anderson)"
summ index_Flexibility_And

**creating the Flexibility index (Regular)
egen index_Flexibility_Reg = rowmean(pri_1 pri_2 pri_3 pri_4 pri_5 pri_6 pri_7 pri_8 pri_9)
label var index_Flexibility_Reg "Flexibility Index (Regular)"
summ index_Flexibility_Reg

*generating histogram for the Flexibility indices (Anderson + Regular)
histogram index_Flexibility_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F1)
histogram index_Flexibility_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F2)

***Social Desirability Index***

**codebook of variables to be used for Social Desirability Index
codebook sdb_1 sdb_2 sdb_3 sdb_4 sdb_5 sdb_6 sdb_7 sdb_8 sdb_9 sdb_10 sdb_11 sdb_12 sdb_13

//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
recode sdb_5 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_7 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_9 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_10 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_13 0=1 1=0 /*reversing the direction of the variable*/

**assigning correct labels to the recoded variables
label def SDB_1 0 "TRUE" 1 "FALSE"
label values sdb_5 SDB_1
label values sdb_7 SDB_1
label values sdb_9 SDB_1
label values sdb_10 SDB_1
label values sdb_13 SDB_1

**creating the Social Desirability index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Desir sdb_1 sdb_2 sdb_3 sdb_4 sdb_5 sdb_6 sdb_7 sdb_8 sdb_9 sdb_10 sdb_11 sdb_12 sdb_13

make_index_gr Desirability_And wgt stdgroup `Desir'
cap egen std_Desirability_And = std(index_Desirability_And)
label var index_Desirability_And "Desirability Index (Anderson)"
summ index_Desirability_And

**creating the Social Desirability index (Regular)
gen index_Desirability_Reg = sdb_1 + sdb_2 + sdb_3 + sdb_4 + sdb_5 + sdb_6 + sdb_7 + sdb_8 + sdb_9 + sdb_10 + sdb_11 + sdb_12 + sdb_13
label var index_Desirability_Reg "Desirability Index (Regular)"
summ index_Desirability_Reg

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S1)
histogram index_Desirability_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S2)

***Anxiety Index***

**codebook of variables to be used for Anxiety Index
codebook gad_1 gad_2 gad_3 gad_4 gad_5 gad_6 gad_7

**recoding Refused to Answer and DN values
recode gad_1 -999=1 -666=1
recode gad_2 -999=1 -666=1
recode gad_3 -999=1 -666=1
recode gad_4 -999=1 -666=1
recode gad_5 -999=1 -666=1
recode gad_6 -999=1 -666=1
recode gad_7 -999=1 -666=1

**converting the GAD scale from 1-4 to 0-3
replace gad_1 = gad_1 - 1
replace gad_2 = gad_2 - 1
replace gad_3 = gad_3 - 1
replace gad_4 = gad_4 - 1
replace gad_5 = gad_5 - 1
replace gad_6 = gad_6 - 1
replace gad_7 = gad_7 - 1

**assigning correct labels to the recoded variables
label define GAD_1 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values gad_1 GAD_1
label values gad_2 GAD_1
label values gad_3 GAD_1
label values gad_4 GAD_1
label values gad_5 GAD_1
label values gad_6 GAD_1
label values gad_7 GAD_1

**creating the Anxiety Index
gen index_Anxiety = gad_1 + gad_2 + gad_3 + gad_4 + gad_5 + gad_6 + gad_7

label var index_Anxiety "Anxiety Index"
summ index_Anxiety

*generating histogram for the Anxiety Index
histogram index_Anxiety, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(X1)

***Depression Index***

**codebook of variables to be used for Depression Index
codebook phq_1 phq_2 phq_3 phq_4 phq_5 phq_6 phq_7 phq_8 phq_9

recode phq_1 -999=1 -666=1
recode phq_2 -999=1 -666=1
recode phq_3 -999=1 -666=1
recode phq_4 -999=1 -666=1
recode phq_5 -999=1 -666=1
recode phq_6 -999=1 -666=1
recode phq_7 -999=1 -666=1
recode phq_8 -999=1 -666=1
recode phq_9 -999=1 -666=1

**converting the PHQ scale from 1-4 to 0-3
replace phq_1 = phq_1 - 1
replace phq_2 = phq_2 - 1
replace phq_3 = phq_3 - 1
replace phq_4 = phq_4 - 1
replace phq_5 = phq_5 - 1
replace phq_6 = phq_6 - 1
replace phq_7 = phq_7 - 1
replace phq_8 = phq_8 - 1
replace phq_9 = phq_9 - 1

**assigning correct labels to the recoded variables
label define PHQ_1 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values phq_1 PHQ_1
label values phq_2 PHQ_1
label values phq_3 PHQ_1
label values phq_4 PHQ_1
label values phq_5 PHQ_1
label values phq_6 PHQ_1
label values phq_7 PHQ_1
label values phq_8 PHQ_1
label values phq_9 PHQ_1

**creating the Depression Index
gen index_Depression = phq_1 + phq_2 + phq_3 + phq_4 + phq_5 + phq_6 + phq_7 + phq_8 + phq_9

label var index_Depression "Depression Index"
summ index_Depression

*generating histogram for the Depression Index
histogram index_Depression, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P1)

***Attitude Towards GBV Index***

**codebook of variables to be used for Attitudes Index
codebook land_compromise fem_cases_overattention
codebook gbv_abusive_beh_new gbv_fem_fault

**replacing multivariates with dummy variables
gen land_compromise_dum = land_compromise
recode land_compromise_dum 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen fem_cases_overattention_dum = fem_cases_overattention
recode fem_cases_overattention_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_abusive_beh_new_dum = gbv_abusive_beh_new
recode gbv_abusive_beh_new_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace gbv_abusive_beh_new_dum = 1 if gbv_abusive_beh == 1
replace gbv_abusive_beh_new_dum = 0 if gbv_abusive_beh != 1 & gbv_abusive_beh !=.
gen gbv_fem_fault_dum = gbv_fem_fault
recode gbv_fem_fault_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/

**creating the Attitudes towards GBV index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Atti land_compromise_dum fem_cases_overattention_dum gbv_abusive_beh_new_dum gbv_fem_fault_dum

make_index_gr AttitudeGBV_And wgt stdgroup `Atti'
cap egen std_AttitudeGBV_And = std(index_AttitudeGBV_And)
label var index_AttitudeGBV_And "Attitudes toward GBV Index (Anderson)"
summ index_AttitudeGBV_And

**creating the Attitudes towards GBV index (Regular)
egen index_AttitudeGBV_Reg = rowmean(land_compromise_dum fem_cases_overattention_dum gbv_abusive_beh_new_dum gbv_fem_fault_dum)
label var index_AttitudeGBV_Reg "Attitudes toward GBV Index (Regular)"
summ index_AttitudeGBV_Reg

*generating histogram for the Attitudes towards GBV indices (Anderson + Regular)
histogram index_AttitudeGBV_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A1)
histogram index_AttitudeGBV_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A2)

***Externalising Police Responses Index***

**codebook of variables to be used for Externalising Police Responses Index
codebook dv1_internal_matter dv1_common_incident dv1_fears_beating
codebook gbv_police_help_new non_gbv_fir_new
codebook caste_police_help_new

**recoding variables
recode dv1_internal_matter 0=1 1=0 -999=0 -666=0
recode dv1_common_incident 0=1 1=0 -999=0 -666=0
recode dv1_fears_beating 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen gbv_police_help_new_dum = gbv_police_help_new
recode gbv_police_help_new_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace gbv_police_help_new_dum = 1 if gbv_police_help == 1
replace gbv_police_help_new_dum = 0 if gbv_police_help != 1 & gbv_police_help !=.

gen non_gbv_fir_new_dum = non_gbv_fir_new
recode non_gbv_fir_new_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace non_gbv_fir_new_dum = 1 if non_gbv_fir == 1
replace non_gbv_fir_new_dum = 0 if non_gbv_fir != 1 & non_gbv_fir !=.

gen caste_police_help_new_dum = caste_police_help_new
recode caste_police_help_new_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
replace caste_police_help_new_dum = 1 if caste_police_help == 1
replace caste_police_help_new_dum = 0 if caste_police_help != 1 & caste_police_help !=.

**creating the Externalising Police Responses Index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Ext dv1_internal_matter dv1_common_incident dv1_fears_beating gbv_police_help_new_dum non_gbv_fir_new_dum caste_police_help_new_dum

make_index_gr ExtPol_And wgt stdgroup `Ext'
cap egen std_ExtPol_And = std(index_ExtPol_And)
label var index_ExtPol_And "Externalising Police Responses Index (Anderson)"
summ index_ExtPol_And

**creating the Externalising Police Responses Index (Regular)
egen index_ExtPol_Reg = rowmean(dv1_internal_matter dv1_common_incident dv1_fears_beating gbv_police_help_new_dum non_gbv_fir_new_dum caste_police_help_new_dum)
label var index_ExtPol_Reg "Externalising Police Responses Index (Regular)"
summ index_ExtPol_Reg

*generating histogram for the Externalising Police Responses indices (Anderson + Regular)
histogram index_ExtPol_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E1)
histogram index_ExtPol_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E2)

***Discrimination Index***

**codebook of variables to be used for Discrimination Index
codebook caste_empathy caste_fault_new caste_framing_man caste_true

**replacing multivariates with dummy variables
gen caste_empathy_dum = caste_empathy
recode caste_empathy_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen caste_fault_new_dum = caste_fault_new
recode caste_fault_new_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
replace caste_fault_new_dum = 1 if caste_fault == 1
replace caste_fault_new_dum = 0 if caste_fault != 1 & caste_fault !=.
gen caste_framing_man_dum = caste_framing_man
recode caste_framing_man_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen caste_true_dum = caste_true
recode caste_true_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

**creating the Discrimination Index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Discr caste_empathy_dum caste_fault_new_dum caste_framing_man_dum caste_true_dum

make_index_gr Discrimination_And wgt stdgroup `Discr'
cap egen std_Discrimination_And = std(index_Discrimination_And)
label var index_Discrimination_And "Discrimination Index (Anderson)"
summ index_Discrimination_And

**creating the Discrimination Index (Regular)
egen index_Discrimination_Reg = rowmean(caste_empathy_dum caste_fault_new_dum caste_framing_man_dum caste_true_dum)
label var index_Discrimination_Reg "Discrimination Index (Regular)"
summ index_Discrimination_Reg

*generating histogram for the Discrimination indices (Anderson + Regular)
histogram index_Discrimination_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D1)
histogram index_Discrimination_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D2)

***Truthfulness of Complaints Index***

**codebook of variables to be used for Truthfulness Index
codebook land_false premarital_false premarital_framing believable_with_relative gbv_true non_gbv_true

**replacing multivariates with dummy variables
gen land_false_dum = land_false
recode land_false_dum 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 
gen premarital_false_dum = premarital_false
recode premarital_false_dum 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0 -999=0 -666=0  
gen premarital_framing_dum = premarital_framing
recode premarital_framing_dum 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0  -999=0 -666=0 
gen believable_with_relative_dum = believable_with_relative
recode believable_with_relative_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 /*reversing the direction of the variable*/
gen gbv_true_dum = gbv_true
recode gbv_true_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen non_gbv_true_dum = non_gbv_true
recode non_gbv_true_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

**creating the Truthfulness Index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Truth land_false_dum premarital_false_dum premarital_framing_dum believable_with_relative_dum gbv_true_dum non_gbv_true_dum

make_index_gr Truth_And wgt stdgroup `Truth'
cap egen std_Truth_And = std(index_Truth_And)
label var index_Truth_And "Truthfulness Index (Anderson)"
summ index_Truth_And

**creating the Truthfulness Index (Regular)
egen index_Truth_Reg = rowmean(land_false_dum premarital_false_dum premarital_framing_dum believable_with_relative_dum gbv_true_dum non_gbv_true_dum)
label var index_Truth_Reg "Truthfulness Index (Regular)"
summ index_Truth_Reg

*generating histogram for the Truthfulness indices (Anderson + Regular)
histogram index_Truth_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R1)
histogram index_Truth_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R2)

*summarising the indices
summ index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_Desirability_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And
summ index_VictimBlame_Reg index_Techskills_Reg index_Empathy_Reg index_Flexibility_Reg index_AttitudeGBV_Reg index_ExtPol_Reg index_Discrimination_Reg index_Truth_Reg
summ index_Desirability_Reg index_Anxiety index_Depression

rename * *_bl
rename dum_baselineonly_bl dum_baselineonly
preserve
keep if dum_baselineonly == 1
save "${intermediate_dta}temp1.dta", replace
restore
drop if dum_baselineonly == 1
save "${intermediate_dta}baselineonly_indices.dta", replace


use "${intermediate_dta}endline_intermediate.dta", clear
keep if dum_endline == 1
rename key_bl key
drop *_bl
rename key key_bl
drop ps_bathroom-index_psfs_m_f_seg_Reg

 ****************************************REDOING THE INDICES**********************************************************************
 **Rationale for recoding 0 = gender-regressive, 1 = gender-progressive (or simply regressive/progressive for indices like Flexibility, Desirability, etc.) 
/*The individual variables are first converted to dummy variables. For questions that used a 5-point Likert scale, the binary variable was coded as 1 if the respondent answered "Strongly Agree" or "Agree" with a gender-progressive statement (or "Strongly Disagree" or "Disagree" with a gender-regressive statement), and 0 otherwise. (Jayachandran, 2018)*/

**Replacing multivariates with dummy variables
 
gen openness_1_dum_el=openness_1_el
recode openness_1_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_2_dum_el=openness_2_el
recode openness_2_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_3_dum_el=openness_3_el 
recode openness_3_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_4_dum_el=openness_4_el
recode openness_4_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_5_dum_el=openness_5_el
recode openness_5_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_6_dum_el=openness_6_el
recode openness_6_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_7_dum_el=openness_7_el
recode openness_7_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_8_dum_el=openness_8_el
recode openness_8_dum_el 1=1 2=1 3=0 4=0 5=0
gen openness_9_dum_el=openness_9_el
recode openness_9_dum_el 1=1 2=1 3=0 4=0 5=0
 
**recoding Refused to Answer and DN values
 
recode openness_1_dum_el -666=0    
recode openness_2_dum_el -666=0    
recode openness_3_dum_el -666=0    
recode openness_4_dum_el -666=0    
recode openness_5_dum_el -666=0    
recode openness_6_dum_el -666=0    
recode openness_7_dum_el -666=0    
recode openness_8_dum_el -666=0    
recode openness_9_dum_el -666=0   
 
**creating the Openness index (Anderson)
*drop wgt stdgroup
gen wgt=1
gen stdgroup=1
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file
local open1 openness_1_dum_el openness_2_dum_el openness_3_dum_el openness_4_dum_el openness_5_dum_el openness_6_dum_el openness_7_dum_el openness_8_dum_el openness_9_dum_el
make_index_gr Openness_And_el wgt stdgroup `open1'
cap egen std_Openness_And_el = std(index_Openness_And_el)
label var index_Openness_And_el "Openness Index (Anderson)"
summ index_Openness_And_el

**creating the Openness index (Regular)
egen index_Openness_Reg_el = rowmean(openness_1_dum_el openness_2_dum_el openness_3_dum_el openness_4_dum_el openness_5_dum_el openness_6_dum_el openness_7_dum_el openness_8_dum_el openness_9_dum_el) if dum_endline == 1
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
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local VB dv2_without_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el
make_index_gr VictimBlame_And_el wgt stdgroup `VB'
cap egen std_VictimBlame_And_el = std(index_VictimBlame_And_el)
label var index_VictimBlame_And_el "Victim Blaming Index (Anderson)"

summ index_VictimBlame_And_el

**creating the Victim-Blaming index (Regular)
egen index_VictimBlame_Reg_el = rowmean(dv2_without_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el) if dum_endline == 1
label var index_VictimBlame_Reg_el "Victim Blaming Index (Regular)"
summ index_VictimBlame_Reg_el

*generating histogram for the Victim-Blaming indices (Anderson + Regular)
histogram index_VictimBlame_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V_1)
histogram index_VictimBlame_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(V_2)

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
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local TS dv_complaint_relative_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el
make_index_gr Techskills_And_el wgt stdgroup `TS'
cap egen std_Techskills_And_el = std(index_Techskills_And_el)
label var index_Techskills_And_el "Technical Skills Index (Anderson)"
summ index_Techskills_And_el

**creating the Technical Skills index (Regular)
egen index_Techskills_Reg_el = rowmean(dv_complaint_relative_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum)
label var index_Techskills_Reg_el "Technical Skills Index (Regular)"
summ index_Techskills_Reg_el

*generating histogram for the Technical Skills indices (Anderson + Regular)
histogram index_Techskills_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T_1)
histogram index_Techskills_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(T_2)

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
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Emp eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el
make_index_gr Empathy_And_el wgt stdgroup `Emp'
cap egen std_Empathy_And_el = std(index_Empathy_And_el)
label var index_Empathy_And_el "Empathy Index (Anderson)"
summ index_Empathy_And_el

**creating the Empathy index (Regular)
egen index_Empathy_Reg_el = rowmean(eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el) if dum_endline == 1
label var index_Empathy_Reg_el "Empathy Index (Regular)"
summ index_Empathy_Reg_el

*generating histogram for the Empathy indices (Anderson + Regular)
histogram index_Empathy_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M_1)
histogram index_Empathy_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(M_2)

***Flexibility Index***
****Scale of Personal Rigidity derived by Rebisch (1958)
****Qs 8, 10, 14, 16, 17, 19, 22, 25, 26
**codebook of variables to be used for Flexibility Index
codebook pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el

*recode pri_1_el 0=1 1=0 /*reversing the direction of the variable*/
*recode pri_2_el 0=1 1=0 /*reversing the direction of the variable*/
recode pri_3_el 0=1 1=0 /*reversing the direction of the variable*/
recode pri_4_el 0=1 1=0 /*reversing the direction of the variable*/
recode pri_5_el 0=1 1=0 /*reversing the direction of the variable*/
recode pri_6_el 0=1 1=0 /*reversing the direction of the variable*/
recode pri_7_el 0=1 1=0 /*NOT reversing the direction of the variable*/
recode pri_8_el 0=1 1=0 /*NOT reversing the direction of the variable*/
*recode pri_9_el 0=1 1=0 /*reversing the direction of the variable*/

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

**creating the Flexibility index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Flex pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el

make_index_gr Flexibility_And_el wgt stdgroup `Flex'
cap egen std_Flexibility_And_el = std(index_Flexibility_And_el)
label var index_Flexibility_And_el "Flexibility Index (Anderson)"
summ index_Flexibility_And_el

**creating the Flexibility index (Regular)
egen index_Flexibility_Reg_el = rowmean(pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el) if dum_endline == 1
label var index_Flexibility_Reg_el "Flexibility Index (Regular)"
summ index_Flexibility_Reg_el

*generating histogram for the Flexibility indices (Anderson + Regular)
histogram index_Flexibility_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F_1)
histogram index_Flexibility_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F_2)

***Social Desirability Index***

**codebook of variables to be used for Social Desirability Index
codebook sdb_1_el sdb_2_el sdb_3_el sdb_4_el sdb_5_el sdb_6_el sdb_7_el sdb_8_el sdb_9_el sdb_10_el sdb_11_el sdb_12_el sdb_13_el


//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
recode sdb_5_el 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_7_el 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_9_el 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_10_el 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_13_el 0=1 1=0 /*reversing the direction of the variable*/

**assigning correct labels to the recoded variables
label def SDB_el 0 "TRUE" 1 "FALSE"
label values sdb_5_el SDB_el
label values sdb_7_el SDB_el
label values sdb_9_el SDB_el
label values sdb_10_el SDB_el
label values sdb_13_el SDB_el

**creating the Social Desirability index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Desir sdb_1_el sdb_2_el sdb_3_el sdb_4_el sdb_5_el sdb_6_el sdb_7_el sdb_8_el sdb_9_el sdb_10_el sdb_11_el sdb_12_el sdb_13_el

make_index_gr Desirability_And_el wgt stdgroup `Desir'
cap egen std_Desirability_And_el = std(index_Desirability_And_el)
label var index_Desirability_And_el "Desirability Index (Anderson)"
summ index_Desirability_And_el

**creating the Social Desirability index (Regular)
gen index_Desirability_Reg_el = (sdb_1_el + sdb_2_el + sdb_3_el + sdb_4_el + sdb_5_el + sdb_6_el + sdb_7_el + sdb_8_el + sdb_9_el + sdb_10_el + sdb_11_el + sdb_12_el + sdb_13_el) if dum_endline == 1
label var index_Desirability_Reg_el "Desirability Index (Regular)"
summ index_Desirability_Reg_el

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S_1)
histogram index_Desirability_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S_2)

***Anxiety Index***

**codebook of variables to be used for Anxiety Index
codebook gad_1_el gad_2_el gad_3_el gad_4_el gad_5_el gad_6_el gad_7_el

**recoding Refused to Answer and DN values
recode gad_1_el -999=1 -666=1
recode gad_2_el -999=1 -666=1
recode gad_3_el -999=1 -666=1
recode gad_4_el -999=1 -666=1
recode gad_5_el -999=1 -666=1
recode gad_6_el -999=1 -666=1
recode gad_7_el -999=1 -666=1.

**converting the GAD scale from 1-4 to 0-3
replace gad_1_el = gad_1_el - 1
replace gad_2_el = gad_2_el - 1
replace gad_3_el = gad_3_el - 1
replace gad_4_el = gad_4_el - 1
replace gad_5_el = gad_5_el - 1
replace gad_6_el = gad_6_el - 1
replace gad_7_el = gad_7_el - 1

**assigning correct labels to the recoded variables
label define GAD_2 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values gad_1_el GAD_2
label values gad_2_el GAD_2
label values gad_3_el GAD_2
label values gad_4_el GAD_2
label values gad_5_el GAD_2
label values gad_6_el GAD_2
label values gad_7_el GAD_2

**creating the Anxiety Index
gen index_Anxiety_el = (gad_1_el + gad_2_el + gad_3_el + gad_4_el + gad_5_el + gad_6_el + gad_7_el) if dum_endline == 1

label var index_Anxiety_el "Anxiety Index"
summ index_Anxiety_el

*generating histogram for the Anxiety Index
histogram index_Anxiety_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(X_1)

***Depression Index***

**codebook of variables to be used for Depression Index
codebook phq_1_el phq_2_el phq_3_el phq_4_el phq_5_el phq_6_el phq_7_el phq_8_el phq_9_el

recode phq_1_el -999=1 -666=1
recode phq_2_el -999=1 -666=1
recode phq_3_el -999=1 -666=1
recode phq_4_el -999=1 -666=1
recode phq_5_el -999=1 -666=1
recode phq_6_el -999=1 -666=1
recode phq_7_el -999=1 -666=1
recode phq_8_el -999=1 -666=1
recode phq_9_el -999=1 -666=1

**converting the PHQ scale from 1-4 to 0-3
replace phq_1_el = phq_1_el - 1
replace phq_2_el = phq_2_el - 1
replace phq_3_el = phq_3_el - 1
replace phq_4_el = phq_4_el - 1
replace phq_5_el = phq_5_el - 1
replace phq_6_el = phq_6_el - 1
replace phq_7_el = phq_7_el - 1
replace phq_8_el = phq_8_el - 1
replace phq_9_el = phq_9_el - 1

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

**creating the Depression Index
gen index_Depression_el = (phq_1_el + phq_2_el + phq_3_el + phq_4_el + phq_5_el + phq_6_el + phq_7_el + phq_8_el + phq_9_el) if dum_endline == 1

label var index_Depression_el "Depression Index"
summ index_Depression_el

*generating histogram for the Depression Index
histogram index_Depression_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P_1)

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
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Atti land_compromise_dum_el fem_cases_overattention_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el

make_index_gr AttitudeGBV_And_el wgt stdgroup `Atti'
cap egen std_AttitudeGBV_And_el = std(index_AttitudeGBV_And_el)
label var index_AttitudeGBV_And_el "Attitudes toward GBV Index (Anderson)"
summ index_AttitudeGBV_And_el

**creating the Attitudes towards GBV index (Regular)
egen index_AttitudeGBV_Reg_el = rowmean(land_compromise_dum_el fem_cases_overattention_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el) if dum_endline == 1
label var index_AttitudeGBV_Reg_el "Attitudes toward GBV Index (Regular)"
summ index_AttitudeGBV_Reg_el

*generating histogram for the Attitudes towards GBV indices (Anderson + Regular)
histogram index_AttitudeGBV_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A_1)
histogram index_AttitudeGBV_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A_2)

***Externalising Police Responses Index***

**codebook of variables to be used for Externalising Police Responses Index
codebook dv1_internal_matter_el dv1_common_incident_el dv1_fears_beating_el
codebook gbv_police_help_el non_gbv_fir_el
codebook caste_police_help_el

**recoding variables
recode dv1_internal_matter_el 0=1 1=0 -999=0 -666=0
recode dv1_common_incident_el 0=1 1=0 -999=0 -666=0
recode dv1_fears_beating_el 0=1 1=0 -999=0 -666=0

**replacing multivariates with dummy variables
gen gbv_police_help_dum_el = gbv_police_help_el
recode gbv_police_help_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

gen non_gbv_fir_dum_el = non_gbv_fir_el
recode non_gbv_fir_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

gen caste_police_help_dum_el = caste_police_help_el
recode caste_police_help_dum_el 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0

**creating the Externalising Police Responses Index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Ext dv1_internal_matter_el dv1_common_incident_el dv1_fears_beating_el gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el

make_index_gr ExtPol_And_el wgt stdgroup `Ext'
cap egen std_ExtPol_And_el = std(index_ExtPol_And_el)
label var index_ExtPol_And_el "Externalising Police Responses Index (Anderson)"
summ index_ExtPol_And_el

**creating the Externalising Police Responses Index (Regular)
egen index_ExtPol_Reg_el = rowmean(dv1_internal_matter_el dv1_common_incident_el dv1_fears_beating_el gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el) if dum_endline == 1
label var index_ExtPol_Reg_el "Externalising Police Responses Index (Regular)"
summ index_ExtPol_Reg_el

*generating histogram for the Externalising Police Responses indices (Anderson + Regular)
histogram index_ExtPol_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E_1)
histogram index_ExtPol_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E_2)

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
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Discr caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el

make_index_gr Discrimination_And_el wgt stdgroup `Discr'
cap egen std_Discrimination_And_el = std(index_Discrimination_And_el)
label var index_Discrimination_And_el "Discrimination Index (Anderson)"
summ index_Discrimination_And_el

**creating the Discrimination Index (Regular)
egen index_Discrimination_Reg_el = rowmean(caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el) if dum_endline == 1
label var index_Discrimination_Reg_el "Discrimination Index (Regular)"
summ index_Discrimination_Reg_el

*generating histogram for the Discrimination indices (Anderson + Regular)
histogram index_Discrimination_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D_1)
histogram index_Discrimination_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D_2)

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

**creating the Truthfulness Index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file

local Truth land_false_dum_el premarital_false_dum_el premarital_framing_dum_el believable_with_relative_dum_el gbv_true_dum_el non_gbv_true_dum_el

make_index_gr Truth_And_el wgt stdgroup `Truth'
cap egen std_Truth_And_el = std(index_Truth_And_el)
label var index_Truth_And_el "Truthfulness Index (Anderson)"
summ index_Truth_And_el

**creating the Truthfulness Index (Regular)
egen index_Truth_Reg_el = rowmean(land_false_dum_el premarital_false_dum_el premarital_framing_dum_el believable_with_relative_dum_el gbv_true_dum_el non_gbv_true_dum_el) if dum_endline == 1
label var index_Truth_Reg_el "Truthfulness Index (Regular)"
summ index_Truth_Reg_el

*generating histogram for the Truthfulness indices (Anderson + Regular)
histogram index_Truth_And_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R_1)
histogram index_Truth_Reg_el, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R_2)

*summarising the indices
summ index_VictimBlame_And_el index_Techskills_And_el index_Empathy_And_el index_Flexibility_And_el index_Desirability_And_el index_AttitudeGBV_And_el index_ExtPol_And_el index_Discrimination_And_el index_Truth_And_el index_Openness_And_el
summ index_VictimBlame_Reg_el index_Techskills_Reg_el index_Empathy_Reg_el index_Flexibility_Reg_el index_AttitudeGBV_Reg_el index_ExtPol_Reg_el index_Discrimination_Reg_el index_Truth_Reg_el index_Openness_Reg_el
summ index_Desirability_Reg_el index_Anxiety_el index_Depression_el

preserve
keep if dum_endlineonly == 1
save "${intermediate_dta}temp2.dta", replace
restore
drop if dum_endlineonly == 1
save "${intermediate_dta}endline_indices_redone.dta", replace

use "${intermediate_dta}baselineonly_indices.dta", clear
merge 1:1 key_bl using "${intermediate_dta}endline_indices_redone.dta"
drop _m
append using "${intermediate_dta}temp1.dta"
append using "${intermediate_dta}temp2.dta"
order ps_dist_bl ps_dist_id_bl ps_name_bl treatment_bl ps_dist_el ps_dist_id_el ps_name_el treatment_el dum_baseline dum_endline dum_bothsurveys dum_baselineonly dum_endlineonly-dum_decoy_treatment
save "${clean_dta}endline_indices_redone.dta", replace