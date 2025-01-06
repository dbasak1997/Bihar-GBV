/*==============================================================================
File Name: Female Constables Survey 2022 - Cleaning do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	16/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to perform the error and logical consistency checks on the Baseline Officer's Survey 2022. 

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

log using "$FC_survey_log_files\femaleconstables_cleaning.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 02.intermediate-data  "02.ren-officersurvey_intermediate"

use "$FC_survey_intermediate_dta\Female Constable Survey.dta" , clear


//replacing blank police station ids
replace intvar1 = "1007_99" if key == "uuid:126b9189-1a5a-4371-a0a8-20ac6c7a3a29"
replace intvar1 = "1007_99" if key == "uuid:52ce7c67-155b-4090-8419-3b4568ece6c9"
replace intvar1 = "1007_99" if key == "uuid:932c2443-9aeb-4564-b45b-853702afab98"
replace intvar1 = "1007_99" if key == "uuid:9a757af3-06b6-4f25-8478-8acef5272f76"
replace intvar1 = "1002_12" if key == "uuid:95a1f908-eff9-4bc3-b16c-da7e9ab16731"
replace intvar1 = "1006_29" if key == "uuid:f026e3d1-d953-43e0-8859-95f2c3b90816"
replace intvar1 = "1008_42" if intvar1 == "1008_41"
replace intvar1 = "1008_65" if intvar1 == "1008_63"
drop if intvar1 == ""

*rename sv_date fem_sv_date

//Cleaning highest level of education variable from Others Specify
replace q1002 = 5 if key == "uuid:dda1a95e-863e-4dec-90b2-e9d21438bd82"
replace q1002 = 1 if key == "uuid:db863bd7-3d55-471f-a353-3dcd37f0dff2"
replace q1002 = 5 if key == "uuid:68cc4e8b-8a07-4f31-930a-4b13d757410b"
replace q1002 = 5 if key == "uuid:de0892f7-d430-422c-be43-3605b48d0de6"
replace q1002 = 6 if key == "uuid:b6583291-acab-4f90-b49a-65a1328c23f9"
replace q1002 = 5 if key == "uuid:b31c588e-7859-469c-aebb-af38893f9142"
replace q1002 = 5 if key == "uuid:c8bfcfa6-3ead-4f81-ad12-36a2075feca6"
replace q1002 = 5 if key == "uuid:b67d33c3-9931-47e2-8d01-d42af829c7ce"
replace q1002 = 1 if key == "uuid:4cfb9b32-6621-49c5-9327-fc8789a77864"
replace q1002 = 5 if key == "uuid:7cf0f493-68dd-422c-b19e-42dc00d960ab"
replace q1002 = 1 if key == "uuid:67661fac-aae1-4fe3-9d81-e8cbd6ef5355"
replace q1002 = 1 if key == "uuid:f16223f6-57f4-4455-bd08-1c63cb0f970b"


// Generating submission date variable
gen submission_date_only = dofc(submissiondate)
format submission_date_only %td

gen submission_year = year(submission_date_only)
gen submission_month = month(submission_date_only)

gen submissiondate_final = ym(submission_year, submission_month)
format submissiondate_final %tm

// Generating variable for joining date in Bihar Police
gen bp_combined = ym(q1003_year, q1003_month)
format bp_combined %tm

// Generating variable for joining date in current PS
gen ps_combined =  ym(q1004_year, q1004_month)
format ps_combined %tm

// Generating variable for time in current PS (weeks)
gen fem_bpservice_weeks = (submissiondate_final - bp_combined)*4
gen fem_psservice_weeks = (submissiondate_final - ps_combined)*4
la var fem_bpservice_weeks "Time since joining Bihar Police (weeks)"
la var fem_psservice_weeks "Time since joining current PS (weeks)"

// Generating variable for time in current PS (months)
gen fem_bpservice_months = submissiondate_final - bp_combined
gen fem_psservice_months = submissiondate_final - ps_combined
la var fem_bpservice_months "Time since joining Bihar Police (months)"
la var fem_psservice_months "Time since joining current PS (months)"

// Generating variable for time in current PS (years)
gen fem_bpservice_years = (submissiondate_final - bp_combined)/12
gen fem_psservice_years = (submissiondate_final - ps_combined)/12
la var fem_bpservice_years "Time since joining Bihar Police (years)"
la var fem_psservice_years "Time since joining current PS (years)"

foreach var of varlist fem_bpservice_weeks fem_psservice_weeks fem_bpservice_months fem_psservice_months fem_bpservice_years fem_psservice_years {
	replace `var' =. if `var' < 0 // 6 obs, constables reported their joining in the PS as later than submission date of survey, replacing them as missing
}

**recoding officer caste
tab c6, gen (fem_po_caste_dum)
rename fem_po_caste_dum1 fem_po_caste_dum_refuse
rename fem_po_caste_dum2 fem_po_caste_dum_sc
rename fem_po_caste_dum3 fem_po_caste_dum_st
rename fem_po_caste_dum4 fem_po_caste_dum_obc
rename fem_po_caste_dum5 fem_po_caste_dum_general

**generating and renaming higher education variables
tab q1002, gen(fem_po_highest_educ)
rename fem_po_highest_educ1 fem_po_highest_educ_10th
rename fem_po_highest_educ2 fem_po_highest_educ_12th
rename fem_po_highest_educ3 fem_po_highest_educ_diploma
rename fem_po_highest_educ4 fem_po_highest_educ_college
rename fem_po_highest_educ5 fem_po_highest_educ_ba
rename fem_po_highest_educ6 fem_po_highest_educ_ma

**generating marital status dummy
gen fem_po_marital_dum =.
replace fem_po_marital_dum = 1 if c4 == 2 | c4 == 3
replace fem_po_marital_dum = 0 if c4 == 1 | c4 == 6 | c4 == -666

//dropping duplicate entries
drop if key == "uuid:20f383b7-e923-4e86-abed-c82377dc1e93"

//dropping PII
drop q1 q10 q11 q8 q8_os

save "$FC_survey_clean_dta\femaleconstables_clean.dta", replace
