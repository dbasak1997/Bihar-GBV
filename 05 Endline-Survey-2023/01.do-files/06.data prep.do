/*==============================================================================
File Name: Endline Survey - data prep
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to prep the data for analysis


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

log using "$MO_endline_log_files\dataprep.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\endline_secondaryoutcomes", clear

/*
gen verbal_abuse_public_dum_bl = 0
replace verbal_abuse_public_dum_bl = 1 if verbal_abuse_public_bl == 1
gen verbal_abuse_ipc_dum_bl = 0
replace verbal_abuse_ipc_dum_bl = 1 if verbal_abuse_ipc_bl == 3
gen sa_identity_leaked_dum_bl = 0
replace sa_identity_leaked_dum_bl = 1 if sa_identity_leaked_bl == 1
gen sa_identity_ipc_dum_bl = 0
replace sa_identity_ipc_dum_bl = 1 if sa_identity_ipc_bl == 3
replace verbal_abuse_public_dum_bl = . if dum_baseline ==0
replace sa_identity_leaked_dum_bl = . if dum_baseline ==0
replace verbal_abuse_ipc_dum_bl = . if dum_baseline ==0
replace sa_identity_ipc_dum_bl = . if dum_baseline ==0

gen land_false_sa_dum_bl = land_false_sa_bl
recode land_false_sa_dum_bl 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
gen land_false_sa_dum_el = land_false_sa_el
recode land_false_sa_dum_el 0=1 1=1 2=1 3=1 4=1 5=1 6=0 7=0 8=0 9=0 10=0 -999=0 -666=0
*/
rename dv2_goes_without_informing_bl dv2_goes_wo_informing_bl
rename dv_complaint_relative_dum_bl dv_compl_rel_dum_bl
rename fem_cases_overattention_dum_bl fem_cases_over_dum_bl
rename caste_police_help_new_dum_bl castepolicehelpnewdum_bl
rename believable_with_relative_dum_bl believe_w_relat_dum_bl

rename dv2_goes_without_informing_el dv2_goes_wo_informing_el
rename dv_complaint_relative_dum_el dv_compl_rel_dum_el
rename fem_cases_overattention_dum_el fem_cases_over_dum_el
*rename caste_police_help_new_dum_el castepolicehelpnewdum_el
rename believable_with_relative_dum_el believe_w_relat_dum_el


****Creating dummy if trained officers are atleast 50% of officer strength in the police station
bysort ps_dist_id_el: egen count_po_trained = total(dum_training) if dum_endline == 1
bysort ps_dist_id_el: egen count_po_total = count(key_el) if dum_endline == 1
gen ratio_trained = count_po_trained/count_po_total
gen dum_officerstrained = ratio_trained >= 0.5
replace dum_officerstrained = . if ratio_trained ==.

gen dum_officerstrained = .
replace dum_officerstrained = 1 if dum_endline == 1 & count_po_trained/count_po_total >= 0.5 & count_po_trained/count_po_total !=.
replace dum_officerstrained = 0 if dum_endline == 1 & dum_officerstrained != 1
la var dum_officerstrained "Officers trained"
la define dum_officerstrained 0"No Training" 1"Trained"
la values dum_officerstrained dum_officerstrained

*****Dropping officers who have not completed both surveys
drop if dum_bothsurveys == 0

replace po_highest_educ_10th_bl = 0 if key_bl == "uuid:7e122ffb-10fe-48c9-86d3-67196eb702da"
replace po_highest_educ_12th_bl = 0 if key_bl == "uuid:7e122ffb-10fe-48c9-86d3-67196eb702da"
replace po_highest_educ_diploma_bl = 0 if key_bl == "uuid:7e122ffb-10fe-48c9-86d3-67196eb702da"
replace po_highest_educ_college_bl = 0 if key_bl == "uuid:7e122ffb-10fe-48c9-86d3-67196eb702da"
replace po_highest_educ_ba_bl = 0 if key_bl == "uuid:7e122ffb-10fe-48c9-86d3-67196eb702da"
replace po_highest_educ_ma_bl = 0 if key_bl == "uuid:7e122ffb-10fe-48c9-86d3-67196eb702da"    


gen ps_femconfid_dum_bl = 0
replace ps_femconfid_dum_bl = 1 if ps_femconfidential_bl == 0

save "$MO_endline_clean_dta\combined_FINAL_analysis.dta", replace