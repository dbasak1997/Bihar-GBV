/*==============================================================================
File Name: Endline Survey - Cleaning Network Data
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	13/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to clean network data on the Endline Officer's Survey 2023. 


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

log using "$MO_endline_log_files\officersurvey_network.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*use  "${random}\pooled_randomisation.dta", clear
*br if ps_dist_id == "1005_15"


use "$MO_endline_intermediate_dta\Baseline_PSFS.dta" , clear

order key_bl gbv_uid_bl bp_years_of_service_bl ps_years_of_service_bl po_age_bl 
keep key_bl gbv_uid_bl treatment_bl bp_years_of_service_bl ps_years_of_service_bl po_age_bl //ordering and keeping these variables
rename treatment_bl treatment_network
*save `tempnetwork'.dta, replace
save "$MO_endline_intermediate_dta\baseline_network_intermediate.dta", replace //saving this dataset as a network officers' dataset

forval i = 1/10 {
    use "$MO_endline_intermediate_dta\endline_intermediate.dta", clear
    keep po_age_el bp_years_of_service_el ps_years_of_service_el network_officer_name_`i'_el network_officer_name_os_`i'_el network_officer_rank_`i'_el key_el dum_training
    rename network_officer_name_`i'_el gbv_uid_bl //renaming the network uid variable to ensure merge
	duplicates drop gbv_uid_bl, force
	drop if gbv_uid_bl == ""
    merge 1:1 gbv_uid_bl using "$MO_endline_intermediate_dta\baseline_network_intermediate.dta"
    keep if _m == 3
    drop _m
    *duplicates drop key_bl, force //many officers choose the same officer in their network, hence duplicates need to be dropped
    rename bp_years_of_service_bl bp_yearsofservice_network_`i' //renaming
    rename ps_years_of_service_bl ps_yearsofservice_network_`i'
    rename po_age_bl po_age_network_`i'
    rename treatment_network treatment_network_`i'
    rename dum_training dum_training_network_`i'
    gen dum_senior_age_`i' = 0 //generating dummy variable = 1 if age of network officer > age of surveyed officers
    replace dum_senior_age_`i' = 1 if (po_age_el < po_age_network_`i' & po_age_network_`i' !=.)
    gen dum_senior_bp_service_`i' = 0 //generating dummy variable = 1 if years of service in Bihar Police of network officer > years of service in Bihar Police of surveyed officers
    replace dum_senior_bp_service_`i' = 1 if (bp_years_of_service_el < bp_yearsofservice_network_`i' & bp_yearsofservice_network_`i' !=.)
    gen dum_senior_ps_service_`i' = 0 //generating dummy variable = 1 if years of service in current PS of network officer > years of service in current PS of surveyed officers
    replace dum_senior_ps_service_`i' = 1 if (ps_years_of_service_el < ps_yearsofservice_network_`i' & ps_yearsofservice_network_`i' !=.)
    save "$MO_endline_intermediate_dta\baseline_network_`i'.dta", replace //saving individual datasets of selected officer 1, selected officer 2, etc.)
}

use "$MO_endline_intermediate_dta\endline_intermediate.dta", clear
forval i = 1/10 {
    qui merge m:1 key_el using "$MO_endline_intermediate_dta\baseline_network_`i'.dta" //merging network officers with endline data using endline survey key
    drop _m
}

*drop po_avgnetworkage bp_avgnetworkyears ps_avgnetworkyears share_networktreatment share_networktraining share_networkage share_network_bpyears share_network_psyears po_count_final

// Initialize new variable
gen po_count_final = .

// Loop through the variables
forval i = 1/10 {
    // Set value of po_count_final to position of non-missing value
    replace po_count_final = `i' if !missing(po_age_network_`i')
}

//Average age of network officers
egen po_avgnetworkage = rowmean(po_age_network_1 po_age_network_2 po_age_network_3 po_age_network_4 po_age_network_5 po_age_network_6 po_age_network_7 po_age_network_8 po_age_network_9 po_age_network_10)
label variable po_avgnetworkage "Average age of officers in network"

//Average years of network officers in Bihar Police
egen bp_avgnetworkyears = rowmean(bp_yearsofservice_network_1 bp_yearsofservice_network_2 bp_yearsofservice_network_3 bp_yearsofservice_network_4 bp_yearsofservice_network_5 bp_yearsofservice_network_6 bp_yearsofservice_network_7 bp_yearsofservice_network_8 bp_yearsofservice_network_9 bp_yearsofservice_network_10)
label variable bp_avgnetworkyears "Average years of service in Bihar Police for officers in network"

//Average years of network officers in current PS
egen ps_avgnetworkyears = rowmean(ps_yearsofservice_network_1 ps_yearsofservice_network_2 ps_yearsofservice_network_3 ps_yearsofservice_network_4 ps_yearsofservice_network_5 ps_yearsofservice_network_6 ps_yearsofservice_network_7 ps_yearsofservice_network_8 ps_yearsofservice_network_9 ps_yearsofservice_network_10)
label variable ps_avgnetworkyears "Average years of service in current PS for officers in network"

//Share of treated officers in network
egen share_networktreatment = rowtotal(treatment_network_1 treatment_network_2 treatment_network_3 treatment_network_4 treatment_network_5 treatment_network_6 treatment_network_7 treatment_network_8 treatment_network_9 treatment_network_10)
replace share_networktreatment = share_networktreatment/po_count_final
label variable share_networktreatment "Share of treated officers in network"

//Share of trained officers in network
egen share_networktraining = rowtotal(dum_training_network_1 dum_training_network_2 dum_training_network_3 dum_training_network_4 dum_training_network_5 dum_training_network_6 dum_training_network_7 dum_training_network_8 dum_training_network_9 dum_training_network_10)
replace share_networktraining = share_networktraining/po_count_final
label variable share_networktraining "Share of trained officers in network"

//Share of senior officers (by age) in network
egen share_networkage = rowtotal(dum_senior_age_1 dum_senior_age_2 dum_senior_age_3 dum_senior_age_4 dum_senior_age_5 dum_senior_age_6 dum_senior_age_7 dum_senior_age_8 dum_senior_age_9 dum_senior_age_10)
replace share_networkage = share_networkage/po_count_final
label variable share_networkage "Share of senior officers (by age) in network"

//Share of senior officers (by years in BP) in network
egen share_network_bpyears = rowtotal(dum_senior_bp_service_1 dum_senior_bp_service_2 dum_senior_bp_service_3 dum_senior_bp_service_4 dum_senior_bp_service_5 dum_senior_bp_service_6 dum_senior_bp_service_7 dum_senior_bp_service_8 dum_senior_bp_service_9 dum_senior_bp_service_10)
replace share_network_bpyears = share_network_bpyears/po_count_final
label variable share_network_bpyears "Share of senior officers (by years in BP) in network"

//Share of senior officers (by years in current PS) in network
egen share_network_psyears = rowtotal(dum_senior_ps_service_1 dum_senior_ps_service_2 dum_senior_ps_service_3 dum_senior_ps_service_4 dum_senior_ps_service_5 dum_senior_ps_service_6 dum_senior_ps_service_7 dum_senior_ps_service_8 dum_senior_ps_service_9 dum_senior_ps_service_10)
replace share_network_psyears = share_network_psyears/po_count_final
label variable share_network_psyears "Share of senior officers (by years in current PS) in network"


label variable treatment_bl "Treatment"
label variable index_VictimBlame_And_bl "Victim Blaming Index (Baseline)"
label variable index_Desirability_And_bl "Social Desirability Index (Baseline)"
/*
label variable index_psfs_gen_And "Police Station Infrastructure Index"
label variable index_psfs_fem_infra_And "Police Station Gender Facilities Index"
label variable index_psfs_m_f_seg_And "Police Station Gender Segregation Index"
*/
label variable po_age_bl "Officer age"
label variable po_marital_dum_bl "Marital status of officer"
label variable po_caste_dum_sc_bl "Officer caste - SC"     
label variable po_caste_dum_st_bl "Officer caste - ST"
label variable po_caste_dum_obc_bl "Officer caste - OBC"     
label variable po_caste_dum_general_bl "Officer caste - General"
label variable po_highest_educ_10th_bl "Officer education - 10th"
label variable po_highest_educ_12th_bl "Officer education - 12th"
label variable po_highest_educ_diploma_bl "Officer education - Diploma" 
label variable po_highest_educ_college_bl "Officer education - Started college"    
label variable po_highest_educ_ba_bl "Officer education - Graduate"
label variable po_rank_asi_bl "Officer rank - ASI"
label variable po_rank_si_bl "Officer rank - SI"
label variable po_rank_psi_bl "Officer rank - PSI" 
label variable po_rank_insp_bl "Officer rank - Inspector"
label variable index_Openness_And_el "Openness"
label variable index_VictimBlame_And_el "Victim-Blaming"
label variable index_Techskills_And_el "Technical Skills"
label variable index_Empathy_And_el "Empathy"
label variable index_Flexibility_And_el "Flexibility"
label variable index_AttitudeGBV_And_el "Attitudes towards GBV"
label variable index_ExtPol_And_el "Externalising Police Responsibilities"
label variable index_Discrimination_And_el "Discrimination"
label variable index_Truth_And_el "Assessing Truthfulness of Complaints"

tempfile rough
save `rough'

**Generating count of officers in PS at endline who have undergone training
keep ps_dist_id_el dum_training treatment_el
drop if ps_dist_id_el == ""
bysort ps_dist_id_el: egen count_officers_trained_ps = total(dum_training)
duplicates drop ps_dist_id_el, force
summ count_officers_trained_ps if count_officers_trained_ps!=0, detail
gen dum_median_officerstrained = (count_officers_trained_ps > r(p50) & count_officers_trained_ps!=0)
tab dum_median_officerstrained treatment_el
keep ps_dist_id_el count_officers_trained_ps dum_median_officerstrained

tempfile trained
save `trained'
save "$MO_endline_intermediate_dta\officerstrained_ps.dta", replace

use `rough', clear
merge m:1 ps_dist_id_el using `trained'
drop _m

save "$MO_endline_clean_dta\endline_secondaryoutcomes", replace

