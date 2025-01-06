/*==============================================================================
File Name: Baseline Officer's Survey 2022 - Rename do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	30/05/2023
Created by: Dibyajyoti Basak
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the do-file for generating the indices and graphs for the combined baseline survey

*	Inputs:  02 clean-data "01.officersurvey_clean_deidentified_combined.dta"
*	Outputs: 02 clean-data "02.officersurvey_clean_deidentified_indices.dta"

==============================================================================*/


**refer to the Excel file in Dropbox for index construction
**https://www.dropbox.com/s/z0cs0ntl1qs7akp/27022023_Officers_Survey_Outcomes_and_Meachanisms_AG_SB_DB_v2.xlsx?dl=0
	
**install these packages
*ssc install veracrypt
*ssc install revrs

**loading the clean baseline survey data
clear all
use "$MO_baseline_clean_dta\01.officersurvey_clean_deidentified_combined.dta" , clear

**dropping missing obs
*drop if gbv_uid == ""

 ****************************************REDOING THE INDICES**********************************************************************
 **Rationale for recoding 0 = gender-regressive, 1 = gender-progressive (or simply regressive/progressive for indices like Flexibility, Desirability, etc.) 
/*The individual variables are first converted to dummy variables. For questions that used a 5-point Likert scale, the binary variable was coded as 1 if the respondent answered "Strongly Agree" or "Agree" with a gender-progressive statement (or "Strongly Disagree" or "Disagree" with a gender-regressive statement), and 0 otherwise. (Jayachandran, 2018)*/

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
gen wgt=1
gen stdgroup=1
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file
local open1 openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum
make_index_gr Openness_And wgt stdgroup `open1'
label var index_Openness_And "Openness Index (Anderson)"
summ index_Openness_And

**creating the Openness index (Regular)
egen index_Openness_Reg = rowmean(openness_1_dum openness_2_dum openness_3_dum openness_4_dum openness_5_dum openness_6_dum openness_7_dum openness_8_dum openness_9_dum)
label var index_Openness_Reg "Openness Index (Regular)"
summ index_Openness_Reg

***Victim-Blaming Index***

**codebook of variables to be used for the Victim Blaming index
codebook dv2_goes_without_informing dv2_neglects_children dv2_burns_food dv2_argues dv2_refuses_sex
codebook premarital_socially_unacceptable
codebook non_gbv_fem_fault
rename premarital_socially_unacceptable psu

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
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

*gen wgt=1
*gen stdgroup=1

local VB dv2_without_informing_dum dv2_neglects_children_dum dv2_burns_food_dum dv2_argues_dum dv2_refuses_sex_dum psu_dum non_gbv_fem_fault_dum
make_index_gr VictimBlame_And wgt stdgroup `VB'
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
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local TS dv_complaint_relative_dum sa_burden_proof_dum eviction_dv_dum fem_shelter_dum verbal_abuse_public_dum verbal_abuse_ipc_dum sa_identity_leaked_dum sa_identity_ipc_dum
make_index_gr Techskills_And wgt stdgroup `TS'
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
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Emp eq_1_dum eq_2_dum eq_3_dum eq_4_dum eq_5_dum eq_6_dum gbv_empathy_dum non_gbv_empathy_dum
make_index_gr Empathy_And wgt stdgroup `Emp'
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

gen pri_1_dum = pri_1
gen pri_2_dum = pri_2
gen pri_3_dum = pri_3
gen pri_4_dum = pri_4
gen pri_5_dum = pri_5
gen pri_6_dum = pri_6
gen pri_7_dum = pri_7
gen pri_8_dum = pri_8
gen pri_9_dum = pri_9

*recode pri_1 0=1 1=0 /*NOT reversing the direction of the variable*/
*recode pri_2 0=1 1=0 /*NOT reversing the direction of the variable*/
recode pri_3_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_4_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_5_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_6_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_7_dum 0=1 1=0 /*reversing the direction of the variable*/
recode pri_8_dum 0=1 1=0 /*reversing the direction of the variable*/
*recode pri_9 0=1 1=0 /*NOT reversing the direction of the variable*/

/*
**assigning correct labels to the recoded variables
label def PRI 0 "TRUE" 1 "FALSE"
*label values pri_1 PRI
*label values pri_2 PRI
label values pri_3 PRI
label values pri_4 PRI
label values pri_5 PRI
label values pri_6 PRI
label values pri_7 PRI
label values pri_8 PRI
*label values pri_9 PRI
*/

**creating the Flexibility index (Anderson)
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Flex pri_1_dum pri_2_dum pri_3_dum pri_4_dum pri_5_dum pri_6_dum pri_7_dum pri_8_dum pri_9_dum

make_index_gr Flexibility_And wgt stdgroup `Flex'
cap egen Flexibility_And = std(index_Flexibility_And)
label var index_Flexibility_And "Flexibility Index (Anderson)"
summ index_Flexibility_And

**creating the Flexibility index (Regular)
egen index_Flexibility_Reg = rowmean(pri_1_dum pri_2_dum pri_3_dum pri_4_dum pri_5_dum pri_6_dum pri_7_dum pri_8_dum pri_9_dum)
label var index_Flexibility_Reg "Flexibility Index (Regular)"
summ index_Flexibility_Reg

*generating histogram for the Flexibility indices (Anderson + Regular)
histogram index_Flexibility_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F1)
histogram index_Flexibility_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(F2)

***Social Desirability Index***

**codebook of variables to be used for Social Desirability Index
codebook sdb_1 sdb_2 sdb_3 sdb_4 sdb_5 sdb_6 sdb_7 sdb_8 sdb_9 sdb_10 sdb_11 sdb_12 sdb_13

gen sdb_1_dum = sdb_1
gen sdb_2_dum = sdb_2
gen sdb_3_dum = sdb_3
gen sdb_4_dum = sdb_4
gen sdb_5_dum = sdb_5
gen sdb_6_dum = sdb_6
gen sdb_7_dum = sdb_7
gen sdb_8_dum = sdb_8
gen sdb_9_dum = sdb_9
gen sdb_10_dum = sdb_10
gen sdb_11_dum = sdb_11
gen sdb_12_dum = sdb_12
gen sdb_13_dum = sdb_13

//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
recode sdb_5_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_7_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_9_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_10_dum 0=1 1=0 /*reversing the direction of the variable*/
recode sdb_13_dum 0=1 1=0 /*reversing the direction of the variable*/

/*
**assigning correct labels to the recoded variables
label def SDB 0 "TRUE" 1 "FALSE"
label values sdb_5 SDB
label values sdb_7 SDB
label values sdb_9 SDB
label values sdb_10 SDB
label values sdb_13 SDB
*/

**creating the Social Desirability index (Anderson)
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Desir sdb_1_dum sdb_2_dum sdb_3_dum sdb_4_dum sdb_5_dum sdb_6_dum sdb_7_dum sdb_8_dum sdb_9_dum sdb_10_dum sdb_11_dum sdb_12_dum sdb_13_dum

make_index_gr Desirability_And wgt stdgroup `Desir'
cap egen Desirability_And = std(index_Desirability_And)
label var index_Desirability_And "Desirability Index (Anderson)"
summ index_Desirability_And

**creating the Social Desirability index (Regular)
egen index_Desirability_Reg = rowtotal(sdb_1_dum sdb_2_dum sdb_3_dum sdb_4_dum sdb_5_dum sdb_6_dum sdb_7_dum sdb_8_dum sdb_9_dum sdb_10_dum sdb_11_dum sdb_12_dum sdb_13_dum)
label var index_Desirability_Reg "Desirability Index (Regular)"
summ index_Desirability_Reg

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S1)
histogram index_Desirability_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S2)

***Anxiety Index***

**codebook of variables to be used for Anxiety Index
codebook gad_1 gad_2 gad_3 gad_4 gad_5 gad_6 gad_7

gen gad_1_dum = gad_1
gen gad_2_dum = gad_2
gen gad_3_dum = gad_3
gen gad_4_dum = gad_4
gen gad_5_dum = gad_5
gen gad_6_dum = gad_6
gen gad_7_dum = gad_7

**recoding Refused to Answer and DN values
recode gad_1_dum -999=1 -666=1
recode gad_2_dum -999=1 -666=1
recode gad_3_dum -999=1 -666=1
recode gad_4_dum -999=1 -666=1
recode gad_5_dum -999=1 -666=1
recode gad_6_dum -999=1 -666=1
recode gad_7_dum -999=1 -666=1

**converting the GAD scale from 1-4 to 0-3
replace gad_1_dum = gad_1_dum - 1
replace gad_2_dum = gad_2_dum - 1
replace gad_3_dum = gad_3_dum - 1
replace gad_4_dum = gad_4_dum - 1
replace gad_5_dum = gad_5_dum - 1
replace gad_6_dum = gad_6_dum - 1
replace gad_7_dum = gad_7_dum - 1

/*
**assigning correct labels to the recoded variables
label define GAD 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values gad_1 GAD
label values gad_2 GAD
label values gad_3 GAD
label values gad_4 GAD
label values gad_5 GAD
label values gad_6 GAD
label values gad_7 GAD
*/

**creating the Anxiety Index
egen index_Anxiety = rowtotal(gad_1_dum gad_2_dum gad_3_dum gad_4_dum gad_5_dum gad_6_dum gad_7_dum)

label var index_Anxiety "Anxiety Index"
summ index_Anxiety

*generating histogram for the Anxiety Index
histogram index_Anxiety, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(X1)

***Depression Index***

**codebook of variables to be used for Depression Index
codebook phq_1 phq_2 phq_3 phq_4 phq_5 phq_6 phq_7 phq_8 phq_9

gen phq_1_dum = phq_1
gen phq_2_dum = phq_2
gen phq_3_dum = phq_3
gen phq_4_dum = phq_4
gen phq_5_dum = phq_5
gen phq_6_dum = phq_6
gen phq_7_dum = phq_7
gen phq_8_dum = phq_8
gen phq_9_dum = phq_9

recode phq_1_dum -999=1 -666=1
recode phq_2_dum -999=1 -666=1
recode phq_3_dum -999=1 -666=1
recode phq_4_dum -999=1 -666=1
recode phq_5_dum -999=1 -666=1
recode phq_6_dum -999=1 -666=1
recode phq_7_dum -999=1 -666=1
recode phq_8_dum -999=1 -666=1
recode phq_9_dum -999=1 -666=1

**converting the PHQ scale from 1-4 to 0-3
replace phq_1_dum = phq_1_dum - 1
replace phq_2_dum = phq_2_dum - 1
replace phq_3_dum = phq_3_dum - 1
replace phq_4_dum = phq_4_dum - 1
replace phq_5_dum = phq_5_dum - 1
replace phq_6_dum = phq_6_dum - 1
replace phq_7_dum = phq_7_dum - 1
replace phq_8_dum = phq_8_dum - 1
replace phq_9_dum = phq_9_dum - 1

/*
**assigning correct labels to the recoded variables
label define PHQ 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values phq_1 PHQ
label values phq_2 PHQ
label values phq_3 PHQ
label values phq_4 PHQ
label values phq_5 PHQ
label values phq_6 PHQ
label values phq_7 PHQ
label values phq_8 PHQ
label values phq_9 PHQ
*/

**creating the Depression Index
egen index_Depression = rowtotal(phq_1_dum phq_2_dum phq_3_dum phq_4_dum phq_5_dum phq_6_dum phq_7_dum phq_8_dum phq_9_dum)

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
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Atti land_compromise_dum fem_cases_overattention_dum gbv_abusive_beh_new_dum gbv_fem_fault_dum

make_index_gr AttitudeGBV_And wgt stdgroup `Atti'
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

gen dv1_internal_matter_dum = dv1_internal_matter
gen dv1_common_incident_dum = dv1_common_incident
gen dv1_fears_beating_dum = dv1_fears_beating

**recoding variables
recode dv1_internal_matter_dum 0=1 1=0 -999=0 -666=0
recode dv1_common_incident_dum 0=1 1=0 -999=0 -666=0
recode dv1_fears_beating_dum 0=1 1=0 -999=0 -666=0

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
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Ext dv1_internal_matter_dum dv1_common_incident_dum dv1_fears_beating_dum gbv_police_help_new_dum non_gbv_fir_new_dum caste_police_help_new_dum

make_index_gr ExtPol_And wgt stdgroup `Ext'
label var index_ExtPol_And "Externalising Police Responses Index (Anderson)"
summ index_ExtPol_And

**creating the Externalising Police Responses Index (Regular)
egen index_ExtPol_Reg = rowmean(dv1_internal_matter_dum dv1_common_incident_dum dv1_fears_beating_dum gbv_police_help_new_dum non_gbv_fir_new_dum caste_police_help_new_dum)
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
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Discr caste_empathy_dum caste_fault_new_dum caste_framing_man_dum caste_true_dum

make_index_gr Discrimination_And wgt stdgroup `Discr'
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
gen land_false_sa_dum = land_false_sa
recode land_false_sa_dum 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0

**creating the Truthfulness Index (Anderson)
qui do "$MO_baseline_do_files\make_index_gr.do" //Execute Anderson index do file

local Truth land_false_dum land_false_sa_dum premarital_false_dum premarital_framing_dum believable_with_relative_dum gbv_true_dum non_gbv_true_dum

make_index_gr Truth_And wgt stdgroup `Truth'
label var index_Truth_And "Truthfulness Index (Anderson)"
summ index_Truth_And

**creating the Truthfulness Index (Regular)
egen index_Truth_Reg = rowmean(land_false_dum land_false_sa_dum premarital_false_dum premarital_framing_dum believable_with_relative_dum gbv_true_dum non_gbv_true_dum)
label var index_Truth_Reg "Truthfulness Index (Regular)"
summ index_Truth_Reg

*generating histogram for the Truthfulness indices (Anderson + Regular)
histogram index_Truth_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R1)
histogram index_Truth_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(R2)

*summarising the indices
summ index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_Desirability_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And
summ index_VictimBlame_Reg index_Techskills_Reg index_Empathy_Reg index_Flexibility_Reg index_AttitudeGBV_Reg index_ExtPol_Reg index_Discrimination_Reg index_Truth_Reg
summ index_Desirability_Reg index_Anxiety index_Depression

save "$MO_baseline_clean_dta\02.officersurvey_clean_deidentified_indices.dta" , replace
**end**
