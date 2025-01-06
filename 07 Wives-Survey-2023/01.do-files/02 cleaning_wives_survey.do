/*==============================================================================
File Name: Wives' Survey 2023 - Cleaning do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	21/05/2024
Created by: Dibyajyoti Basak
Updated on: 27/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to clean the data for the Wives' Survey 2023

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

*File Path

global raw "$Wives_survey\00.raw-data"
global do_files "$Wives_survey\01.do-files"
global intermediate_dta "$Wives_survey\02.intermediate-data\"
global tables "$Wives_survey\03.tables\"
global graphs "$Wives_survey\04.graphs\"
global log_files "$Wives_survey\05.log-files\"
global clean_dta "$Wives_survey\06.clean-data\"


* We will log in
capture log close 

log using "$Wives_survey_log_files\wivessurvey_cleaning.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

***loading training attendance data
use "$MO_endline\06.clean-data\endline_baseline_training.dta"
drop if key_el == ""
tempfile endline_training
keep trainingdate_officer trainingdays_officer date_firsttraining_ps dum_trainingcompleted key_el
save `endline_training'

use "$Wives_survey_intermediate_dta\Wives Survey.dta", clear
rename a5 ps_dist_wiv //renaming
rename a6 ps_dist_id //renaming
merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta" //merging with PS level data
drop if _m != 3
drop _m

**cleaning
drop if key == "uuid:c1651d1f-a900-4ecd-a3c9-ec06bd3c7212"
replace endlinekey = "uuid:f2a914aa-f0f1-48ae-8645-003f2cdb0dcb" if endlinekey == "uuid:e991482e-6102-4a9f-a620-69f86a444998"
rename endlinekey key_el

replace q1002 = 7 if q1002 == -888
label define q1002 7 "Not completed schooling", add

//generating variable for length of marriage
replace q1003_months = 0 if q1003_months == -999
gen months_marriage = (q1003_months/12)
gen years_marriage = q1003_years + months_marriage

merge 1:1 key_el using "$MO_endline_clean_dta\endline_indices.dta" //merging with endline data
drop if _m != 3
drop _m

merge 1:1 key_el using `endline_training' //merging with training attendance data
drop if _m != 3
drop _m


// Communication and Conflict Resolution Index
codebook q2001 q2002 q2003 q2004 q2006 q2007 q2008 q2009

gen q2001_dum = q2001
recode q2001_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0
gen q2002_dum = q2002
recode q2002_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0
gen q2003_dum = q2003
recode q2003_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0
gen q2004_dum = q2004
recode q2004_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 //reversing
gen q2006_dum = q2006
recode q2006_dum 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0
gen q2007_dum = q2007
recode q2007_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 //reversing
gen q2008_dum = q2008
recode q2008_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen q2009_dum = q2009
recode q2009_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 

drop wgt stdgroup
gen wgt = 1
gen stdgroup = (treatment==0)

**creating the Communication and Conflict Resolution Index (Anderson)
qui do "$Wives_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Communication q2001_dum q2002_dum q2003_dum q2004_dum q2006_dum q2007_dum q2008_dum q2009_dum

make_index_gr Comm_And wgt stdgroup `Communication'
label var index_Comm_And "Communication and Conflict Resolution Index (Anderson)"
summ index_Comm_And

**creating the Communication and Conflict Resolution Index (Regular)
egen index_Comm_Reg = rowmean(q2001_dum q2002_dum q2003_dum q2004_dum q2006_dum q2007_dum q2008_dum q2009_dum)
label var index_Comm_Reg "Communication and Conflict Resolution Index (Regular)"
summ index_Comm_Reg

*generating histogram for the Communication and Conflict Resolution indices (Anderson + Regular)
histogram index_Comm_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(C1)
histogram index_Comm_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(C2)


// Attitudes towards GBV Index
codebook q3001 q3002 q3003 q3004 q3005

gen q3001_dum = q3001
recode q3001_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen q3002_dum = q3002
recode q3002_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen q3003_dum = q3003
recode q3003_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 //reversing
gen q3004_dum = q3004
recode q3004_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 //reversing
gen q3005_dum = q3005
recode q3005_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0

**creating the Attitudes towards GBV Index (Anderson)
qui do "$Wives_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Spouse_Atti_GBV q3001_dum q3002_dum q3003_dum q3004_dum q3005_dum

make_index_gr Spouse_Atti_And wgt stdgroup `Spouse_Atti_GBV'
label var index_Spouse_Atti_And "Attitudes towards GBV Index (Anderson)"
summ index_Spouse_Atti_And

**creating the Attitudes towards GBV Index (Regular)
egen index_Spouse_Atti_Reg = rowmean(q3001_dum q3002_dum q3003_dum q3004_dum q3005_dum)
label var index_Spouse_Atti_Reg "Attitudes towards GBV Index (Regular)"
summ index_Spouse_Atti_Reg

*generating histogram for the Attitudes towards GBV indices (Anderson + Regular)
histogram index_Spouse_Atti_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A1)
histogram index_Spouse_Atti_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(A2)


// Perceived Empathy Index
codebook rsbec2 rsbec4 rsbec9 rsbec14 rsbec18 rsbec20 rsbec22

encode rsbec2, gen(rsbec2_1)
gen rsbec2_dum = rsbec2_1
recode rsbec2_dum 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0

encode rsbec4, gen(rsbec4_1)
gen rsbec4_dum = rsbec4_1
recode rsbec4_dum 1=1 2=1 3=1 4=0 5=0 -999=0 -666=0 //reversing

encode rsbec9, gen(rsbec9_1)
gen rsbec9_dum = rsbec9_1
recode rsbec9_dum 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0

encode rsbec14, gen(rsbec14_1)
gen rsbec14_dum = rsbec14_1
recode rsbec14_dum 1=1 2=1 3=1 4=0 5=0 -999=0 -666=0 //reversing

encode rsbec18, gen(rsbec18_1)
gen rsbec18_dum = rsbec18_1
recode rsbec18_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 //reversing

encode rsbec20, gen(rsbec20_1)
gen rsbec20_dum = rsbec20_1
recode rsbec20_dum 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0

encode rsbec22, gen(rsbec22_1)
gen rsbec22_dum = rsbec22_1
recode rsbec22_dum 1=0 2=0 3=0 4=1 5=1 -999=0 -666=0


**creating the Perceived Empathy Index (Anderson)
qui do "$Wives_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Spouse_Empathy rsbec2_dum rsbec4_dum rsbec9_dum rsbec14_dum rsbec18_dum rsbec20_dum rsbec22_dum

make_index_gr Spouse_Empathy_And wgt stdgroup `Spouse_Empathy'
label var index_Spouse_Empathy_And "Perceived Empathy Index (Anderson)"
summ index_Spouse_Empathy_And

**creating the Perceived Empathy Index (Regular)
egen index_Spouse_Empathy_Reg = rowmean(rsbec2_dum rsbec4_dum rsbec9_dum rsbec14_dum rsbec18_dum rsbec20_dum rsbec22_dum)
label var index_Spouse_Empathy_Reg "Perceived Empathy Index (Regular)"
summ index_Spouse_Empathy_Reg

*generating histogram for the Perceived Empathy indices (Anderson + Regular)
histogram index_Spouse_Empathy_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E1)
histogram index_Spouse_Empathy_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(E2)

// Beliefs on Gender Equality Index
codebook q6001 q6002 q6003 q6004 q6005 q6006 q6007 q6008

gen q6001_dum = q6001
recode q6001_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen q6002_dum = q6002
recode q6002_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen q6003_dum = q6003
recode q6003_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen q6004_dum = q6004
recode q6004_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 
gen q6005_dum = q6005
recode q6005_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 //reversing
gen q6006_dum = q6006
recode q6006_dum 1=0 2=0 3=1 4=1 5=1 -999=0 -666=0 //reversing
gen q6007_dum = q6007
recode q6007_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0
gen q6008_dum = q6008
recode q6008_dum 1=1 2=1 3=0 4=0 5=0 -999=0 -666=0 

**creating the Beliefs on Gender Equality Index (Anderson)
qui do "$Wives_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Belief q6001_dum q6002_dum q6003_dum q6004_dum q6005_dum q6006_dum q6007_dum q6008_dum

make_index_gr Belief_And wgt stdgroup `Belief'
label var index_Belief_And "Beliefs on Gender Equality Index (Anderson)"
summ index_Belief_And

**creating the Beliefs on Gender Equality Index (Regular)
egen index_Belief_Reg = rowmean(q6001_dum q6002_dum q6003_dum q6004_dum q6005_dum q6006_dum q6007_dum q6008_dum)
label var index_Belief_Reg "Beliefs on Gender Equality Index (Regular)"
summ index_Belief_Reg

*generating histogram for the Beliefs on Gender Equality indices (Anderson + Regular)
histogram index_Belief_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(B1)
histogram index_Belief_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(B2)

// Social Desirability Index


**codebook of variables to be used for Social Desirability Index
codebook q7001 q7002 q7003 q7004 q7005 q7006 q7007 q7008 q7009 q7010 q7011 q7012 q7013

label def SDB 0 "NEGATIVE" 1 "POSITIVE"
//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
foreach i in 7001 7002 7003 7004 7005 7006 7007 7008 7009 7010 7011 7012 7013 {
	gen q`i'_dum = q`i' //for all questions, we have 2 - False , 1 - True
	recode q`i'_dum 2=0 1=1 if (`i' == 7005 | `i' == 7007 | `i' == 7009 | `i' == 7010 | `i' == 7013) // recoding questions 5,7,9,10,13 where True indicates higher SDB
	recode q`i'_dum 2=1 1=0 if (`i' != 7005 & `i' != 7007 & `i' != 7009 & `i' != 7010 & `i' != 7013) //recoding for all other questions where False indicates higher SDB
	label values q`i'_dum SDB
}


**creating the Social Desirability index (Anderson)
qui do "$Wives_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Desir q7001_dum q7002_dum q7003_dum q7004_dum q7005_dum q7006_dum q7007_dum q7008_dum q7009_dum q7010_dum q7011_dum q7012_dum q7013_dum

make_index_gr Desirability_And_wiv wgt stdgroup `Desir'
label var index_Desirability_And_wiv "Desirability Index (Anderson)"
summ index_Desirability_And_wiv

**creating the Social Desirability index (Regular)
egen index_Desirability_Reg_wiv = rowtotal(q7001 q7002 q7003 q7004 q7005 q7006 q7007 q7008 q7009 q7010 q7011 q7012 q7013)
label var index_Desirability_Reg_wiv "Desirability Index (Regular)"
summ index_Desirability_Reg_wiv

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And_wiv, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D1)
histogram index_Desirability_Reg_wiv, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D2)

//dropping PII
drop officername wifename r2latitude r2longitude r2altitude r2accuracy i1_name_el l1p1_el l1p1_os_el l1p1_name_el po_mobnum_el i1_phno_el l1p1_phno_el po_mobnum_alt_el wifename_el officeraddress_el wifephone_el wifealternate_el po_name_el

save "$Wives_survey_clean_dta\wivessurvey_clean.dta", replace 