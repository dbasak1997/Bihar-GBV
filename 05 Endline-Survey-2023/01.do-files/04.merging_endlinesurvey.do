/*==============================================================================
File Name: Baseline Officer's Survey 2022 - Error and Logical Consistency Checks do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	29/04/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to merge the endline with the baseline 

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

log using "$MO_endline_log_files\officersurvey_merging.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$psfs_clean_dta\psfs_combined.dta", clear
keep ps_dist_id treatment
tempfile temp_1
save `temp_1'

//Loading the baseline data
use "$MO_baseline_clean_dta\03.officersurvey_clean_deidentified_indices.dta" , clear
 
**merging baseline and PSFS data
merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta"
drop _m
rename * *_bl

save "$MO_endline_intermediate_dta\Baseline_PSFS.dta", replace

rename key_bl key_baseline_el
*drop _m
merge 1:m key_baseline_el using "$MO_endline_clean_dta\endline_indices.dta"
*append using "${intermediate_dta}Endline_wo_Baseline.dta"
*replace _m = 2 if _m ==.
rename key_baseline_el key_bl

**generating dummies for completion of surveys
gen dum_baseline = 0
replace dum_baseline = 1 if key_bl != ""
gen dum_endline = 0
replace dum_endline = 1 if key_el != ""
gen dum_bothsurveys = 0
replace dum_bothsurveys = 1 if dum_baseline == 1 & dum_endline == 1
gen dum_baselineonly = 0
replace dum_baselineonly = 1 if dum_baseline == 1 & dum_endline == 0
gen dum_endlineonly = 0
replace dum_endlineonly = 1 if dum_baseline == 0 & dum_endline == 1
gen dum_training = 0
replace dum_training = 1 if cs2_el == 1

//Cleaning PS names
replace ps_name_bl = "Pawapuri OP Nalanda" if ps_dist_id_bl == "1007_99"
replace ps_name_el = "Pawapuri OP Nalanda" if ps_dist_id_el == "1007_99"
replace ps_name_bl = "Panchmahla PS" if ps_dist_id_bl == "1008_65"
replace ps_name_el = "Panchmahla PS" if ps_dist_id_el == "1008_65"
replace ps_name_bl = "Hajipur Sadar PS" if ps_dist_id_bl == "1012_20"
replace ps_name_el = "Hajipur Sadar PS" if ps_dist_id_el == "1012_20"
replace ps_name_bl = "Hajipur Sadar PS" if key_bl == "uuid:da808601-a0fa-4f91-894f-f074258e8876"
replace ps_dist_id_bl = "1012_20" if key_bl == "uuid:da808601-a0fa-4f91-894f-f074258e8876"

//Merging to get treatment value for PS that officers may have been transferred to in between baseline and endline
rename po_new_station_el ps_dist_id
drop _m
merge m:1 ps_dist_id using `temp_1'
rename ps_dist_id po_new_station_el
rename treatment treatment_transfer
drop if _m == 2
drop _m

replace treatment_bl = 0 if ps_dist_id_bl == "1003_53" & ps_dist_bl == 1005
replace treatment_bl = 0 if ps_dist_id_bl == "1003_53" & ps_dist_bl == 1008
replace ps_dist_id_bl = "1005_53" if ps_dist_id_bl == "1003_53" & ps_dist_bl == 1005
replace ps_dist_id_bl = "1008_53" if ps_dist_id_bl == "1003_53" & ps_dist_bl == 1008

**generating dummies related to transfers
gen dum_transfer = 0
replace dum_transfer = 1 if (dum_bothsurveys == 1 | dum_endlineonly == 1) & ps_dist_id_el != "" & po_new_station_el != "" & substr(po_new_station_el,5,9) != "-8881" & (b3f_el == 1 | ps_dist_id_bl != ps_dist_id_el | ps_dist_id_bl != po_new_station_el)

gen dum_transfer_ctoc = 0
replace dum_transfer_ctoc = 1 if dum_transfer == 1 & (dum_bothsurveys == 1 | dum_baseline == 1) & treatment_bl == 0 & treatment_el == 0 & treatment_transfer == 0

gen dum_transfer_ttot = 0
replace dum_transfer_ttot = 1 if dum_transfer == 1 & (dum_bothsurveys == 1 | dum_baseline == 1) & treatment_bl == 1 & treatment_el == 1 & treatment_transfer == 1

gen dum_transfer_ctot = 0
replace dum_transfer_ctot = 1 if dum_transfer == 1 & (dum_bothsurveys == 1 | dum_baseline == 1) & treatment_bl == 0 & (treatment_el == 1 | treatment_transfer == 1)

gen dum_transfer_ttoc = 0
replace dum_transfer_ttoc = 1 if dum_transfer == 1 & (dum_bothsurveys == 1 | dum_baseline == 1) & treatment_bl == 1 & (treatment_el == 0 | treatment_transfer == 0)

gen dum_transfer_outsampletocontrol = 0
replace dum_transfer_outsampletocontrol = 1 if (treatment_el == 0 & substr(po_new_station_el,1,4) == "-888") | (dum_endlineonly == 1 & treatment_el == 0)

gen dum_transfer_outsamptotreatment = 0
replace dum_transfer_outsamptotreatment = 1 if (treatment_el == 1 & substr(po_new_station_el,1,4) == "-888") | (dum_endlineonly == 1 & treatment_el == 1)

gen dum_transfer_controltooutsample = 0
replace dum_transfer_controltooutsample = 1 if treatment_bl == 0 & dum_baselineonly == 1

gen dum_transfer_treatmenttooutsamp = 0
replace dum_transfer_treatmenttooutsamp = 1 if treatment_bl == 1 & dum_baselineonly == 1

gen dum_core_transfer_control =.
replace dum_core_transfer_control = 0 if dum_bothsurveys==1 & dum_transfer==0
replace dum_core_transfer_control = 1 if dum_bothsurveys==1 & treatment_bl == 0

gen dum_core_transfer_treatment =.
replace dum_core_transfer_treatment = 0 if dum_bothsurveys==1 & dum_transfer==0
replace dum_core_transfer_treatment = 1 if dum_bothsurveys==1 & treatment_bl == 1

gen dum_notransfer_treatment =.
replace dum_notransfer_treatment = 0 if dum_bothsurveys == 1 & treatment_bl == 1
replace dum_notransfer_treatment = 1 if dum_bothsurveys == 1 & treatment_bl == 1 & dum_transfer == 0

gen dum_notransfer_control =.
replace dum_notransfer_control = 0 if dum_bothsurveys == 1 & treatment_bl == 0
replace dum_notransfer_control = 1 if dum_bothsurveys == 1 & treatment_bl == 0 & dum_transfer == 0

gen dum_ctoc_transfer =.
replace dum_ctoc_transfer = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_ctoc_transfer = 1 if dum_transfer_ctoc == 1

gen dum_ttot_transfer =.
replace dum_ttot_transfer = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_ttot_transfer = 1 if dum_transfer_ttot == 1

gen dum_ctot_transfer =.
replace dum_ctot_transfer = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_ctot_transfer = 1 if dum_transfer_ctot == 1

gen dum_ttoc_transfer =.
replace dum_ttoc_transfer = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_ttoc_transfer = 1 if dum_transfer_ttoc == 1

gen dum_endline_treatment_transfer=.
replace dum_endline_treatment_transfer = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_endline_treatment_transfer = 1 if dum_endlineonly == 1 & treatment_el == 1

gen dum_endline_control_transfer=.
replace dum_endline_control_transfer = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_endline_control_transfer = 1 if dum_endlineonly == 1 & treatment_el == 0

gen dum_baseline_transfer_out =.
replace dum_baseline_transfer_out = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_baseline_transfer_out = 1 if dum_baselineonly == 1

gen dum_endline_treatment_training =.
replace dum_endline_treatment_training = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_endline_treatment_training = 1 if dum_endlineonly == 1 & dum_training == 1 & treatment_el == 1

gen dum_endline_control_training =.
replace dum_endline_control_training = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_endline_control_training = 1 if dum_endlineonly == 1 & dum_training == 1 & treatment_el == 0

gen dum_decoy =. 
replace dum_decoy = 0 if key_bl != ""
replace dum_decoy = 1 if ps_dist_bl == 1003 | ps_dist_bl == 1004 | ps_dist_bl == 1006 | ps_dist_bl == 1007 | ps_dist_bl == 1010 | ps_dist_bl == 1011

gen dum_decoy_control =.
replace dum_decoy_control = 0 if dum_decoy == 1 & dum_baseline == 1 & treatment_bl == 0
replace dum_decoy_control = 1 if dum_decoy == 0 & dum_baseline == 1 & treatment_bl == 0
gen dum_decoy_treatment =.
replace dum_decoy_treatment = 0 if dum_decoy == 1 & dum_baseline == 1 & treatment_bl == 1
replace dum_decoy_treatment = 1 if dum_decoy == 0 & dum_baseline == 1 & treatment_bl == 1

gen dum_outsample =.
replace dum_outsample = 0 if dum_bothsurveys == 1 & dum_transfer == 0
replace dum_outsample = 1 if dum_endlineonly == 1


**labelling dummies
label variable dum_bothsurveys "0=Both Surveys Incomplete,1=Both Surveys Completed"

label variable dum_baselineonly "0=Baseline Not Completed,1=Baseline Completed"

label variable dum_endlineonly "0=Endline Not Completed,1=Endline Completed"

label variable dum_training "0=Training Not Completed,1=Training Completed"

label variable dum_transfer "0 = No Transfer, 1 = Transfer"

label variable dum_transfer_ctoc "0=No Transfer,1=Transfer from Control to Control"

label variable dum_transfer_ttot "0=No Transfer,1=Transfer from Treatment to Treatment"

label variable dum_transfer_ctot "0=No Transfer,1=Transfer from Control to Treatment"

label variable dum_transfer_ttoc "0=No Transfer,1=Transfer from Treatment to Control"

label variable dum_transfer_outsampletocontrol "0=No Transfer,1=Transfer from OutofSample to Control"

label variable dum_transfer_outsamptotreatment "0=No Transfer,1=Transfer from OutofSample to Treatment"

label variable dum_transfer_controltooutsample "0=No Transfer,1=Transfer from Control to OutofSample"

label variable dum_transfer_treatmenttooutsamp "0=No Transfer,1=Transfer from Treatment to OutofSample"

**generating dummies for caste
tab po_caste_bl, gen(po_caste_dum_bl)
tab po_caste_el, gen(po_caste_dum_el)
         
rename po_caste_dum_bl1 po_caste_dum_refuse_bl
rename po_caste_dum_bl2 po_caste_dum_sc_bl
rename po_caste_dum_bl3 po_caste_dum_st_bl
rename po_caste_dum_bl4 po_caste_dum_obc_bl
rename po_caste_dum_bl5 po_caste_dum_general_bl

rename po_caste_dum_el1 po_caste_dum_refuse_el
rename po_caste_dum_el2 po_caste_dum_sc_el
rename po_caste_dum_el3 po_caste_dum_st_el
rename po_caste_dum_el4 po_caste_dum_obc_el
rename po_caste_dum_el5 po_caste_dum_general_el

**generating combined variable for years of service
gen bp_yearsofservice_bl = bp_years_of_service_bl + (bp_months_of_service_bl/12)
gen ps_yearsofservice_bl = ps_years_of_service_bl + (ps_months_of_service_bl/12)  
label variable bp_yearsofservice_bl "Number of years in Bihar Police"
label variable ps_yearsofservice_bl "Number of years in current police station"

**replacing higher education other specify in baseline
replace po_highest_educ_bl = 5 if key_bl == "uuid:d5e78d19-0470-4f15-a434-caacd98615df"
replace po_highest_educ_bl = 5 if key_bl == "uuid:d6a2a3fc-4a1c-4c5b-adbc-ec3e53b6d191"
replace po_highest_educ_bl = 5 if key_bl == "uuid:7c7192e3-7029-4098-a3e5-dbd724bd7088"
replace po_highest_educ_bl = 5 if key_bl == "uuid:b83b4f2f-e062-4d0a-916d-9225f75cc055"
replace po_highest_educ_bl = 6 if key_bl == "uuid:cf5640c7-af57-4124-b176-b69875731bb0"
replace po_highest_educ_bl = 1 if key_bl == "uuid:0ee25371-9b38-4dc6-b10c-caf9e7a4e07b"
replace po_highest_educ_bl = 5 if key_bl == "uuid:18b00c6f-47cc-47b7-83e3-15cc3dd5f61e"
replace po_highest_educ_bl = 5 if key_bl == "uuid:2d45e3be-8d3f-40a2-935a-8d5d5f91d407"
replace po_highest_educ_bl = 6 if key_bl == "uuid:4a633b1b-89dc-4669-bff8-9ea91893e75b"
replace po_highest_educ_bl = 5 if key_bl == "uuid:a95bb002-6442-44ea-8acd-3c185af9ca80"
replace po_highest_educ_bl = 6 if key_bl == "uuid:70f96fb3-933e-4f27-a175-76505e4aa57e"
replace po_highest_educ_bl = 5 if key_bl == "uuid:862ee132-a9f9-4442-a7b5-c57d438844d6"
replace po_highest_educ_bl = 6 if key_bl == "uuid:36e4503d-5f1a-4ea1-8697-bdfaadbf0c39"
replace po_highest_educ_bl = 6 if key_bl == "uuid:d93c0c87-5e22-4d3b-883d-63c7c85954ae"
replace po_highest_educ_bl = 5 if key_bl == "uuid:c5bf01e2-e439-4611-bf42-272603d23f0f"
replace po_highest_educ_bl = 5 if key_bl == "uuid:6a126d96-5289-4cee-b3d6-8e8987e05f59"
replace po_highest_educ_bl = 5 if key_bl == "uuid:0894583e-81ce-45d1-b7ba-6a90e8a2e099"
replace po_highest_educ_bl = 5 if key_bl == "uuid:c4aa3829-7742-4247-9b75-c0101073bcc5"
replace po_highest_educ_bl = 6 if key_bl == "uuid:858a510e-e878-4da7-8038-28a4a64390c6"
replace po_highest_educ_bl = 6 if key_bl == "uuid:47f12e1e-f423-4e75-9aaf-8cdf5a52c931"
replace po_highest_educ_bl = 5 if key_bl == "uuid:9b379786-ca50-4e4b-ab6c-8c0f875e1902"
replace po_highest_educ_bl = 5 if key_bl == "uuid:0af6af72-9d6b-48c7-8d61-c5b60abeff28"
replace po_highest_educ_bl = 5 if key_bl == "uuid:2fa2ba68-63aa-4d23-993a-7cb674d5cc65"
replace po_highest_educ_bl = 6 if key_bl == "uuid:d45ebd30-1064-4738-8fe0-ee5a29517d5e"
replace po_highest_educ_bl = 6 if key_bl == "uuid:ad64b709-89da-4d3d-b19f-698c7aeb790a"
replace po_highest_educ_bl = 5 if key_bl == "uuid:9993b31d-ae22-47af-b27e-e24deb87d821"
replace po_highest_educ_bl = 5 if key_bl == "uuid:bf61573b-2d5d-40b4-8075-cd1b83ba2e2c"
replace po_highest_educ_bl = 5 if key_bl == "uuid:0b159dc6-e130-4b3f-b108-442701de98d6"
replace po_highest_educ_bl = 5 if key_bl == "uuid:6f1b36ec-a834-45de-96f2-60b8596f307e"
replace po_highest_educ_bl = 6 if key_bl == "uuid:ebfcb401-3572-4cdc-89de-b7bb6182875a"
replace po_highest_educ_bl = 5 if key_bl == "uuid:1b778974-1d7f-4dfa-8518-18b1afcdc508"
replace po_highest_educ_bl = 6 if key_bl == "uuid:81c4d402-fc56-47fa-9588-343a87d5ec98"
replace po_highest_educ_bl = 6 if key_bl == "uuid:92f4d835-8412-439c-a6d1-ec0cad6312eb"
replace po_highest_educ_bl = 6 if key_bl == "uuid:203622ac-72cb-4bbd-a015-ac40a1817bfb"
replace po_highest_educ_bl = 5 if key_bl == "uuid:08ed8dab-6fc8-46de-94ae-72ec279f5fa1"
replace po_highest_educ_bl = 6 if key_bl == "uuid:99ee687d-d76d-46e1-aa4f-a77eda559bb6"
replace po_highest_educ_bl = 5 if key_bl == "uuid:499d8c71-9627-4a09-85f6-b217bcb1635f"
replace po_highest_educ_bl = 5 if key_bl == "uuid:d9948cb2-0928-407f-bbb5-c9346649014f"
replace po_highest_educ_bl =. if po_highest_educ_bl == -888

**generating and renaming rank variables
tab po_rank_bl, gen(po_rank)
rename po_rank1 po_rank_asi_bl
rename po_rank2 po_rank_si_bl
rename po_rank3 po_rank_psi_bl
rename po_rank4 po_rank_insp_bl
rename po_rank5 po_rank_sho_bl

**generating and renaming higher education variables
tab po_highest_educ_bl, gen(po_highest_educ)
rename po_highest_educ1 po_highest_educ_10th_bl
rename po_highest_educ2 po_highest_educ_12th_bl
rename po_highest_educ3 po_highest_educ_diploma_bl
rename po_highest_educ4 po_highest_educ_college_bl
rename po_highest_educ5 po_highest_educ_ba_bl
rename po_highest_educ6 po_highest_educ_ma_bl

**generating marital status dummy
gen po_marital_dum_bl =.
replace po_marital_dum_bl = 1 if po_marital_status_bl == 2 | po_marital_status_bl == 3
replace po_marital_dum_bl = 0 if po_marital_status_bl == 1 | po_marital_status_bl == 6
replace po_marital_dum_bl = 0 if po_marital_dum_bl ==.
label variable po_marital_dum_bl "Marital Status of Officer"

**labelling of newly created variables
label variable po_age_bl "Officer Age (baseline)"
la var po_caste_dum_sc_bl "Officer Caste - SC"
la var po_caste_dum_st_bl "Officer Caste - ST"
la var po_caste_dum_obc_bl "Officer Caste - OBC"
la var po_caste_dum_general_bl "Officer Caste - General"
la var po_highest_educ_10th_bl "Officer Education - 10th"
la var po_highest_educ_12th_bl "Officer Education - 12th"
la var po_highest_educ_diploma_bl "Officer Education - Diploma"
la var po_highest_educ_college_bl "Officer Education - Started College"
la var po_highest_educ_ba_bl "Officer Education - Graduate"
la var po_highest_educ_ma_bl "Officer Education - Postgraduate"
la var po_rank_asi_bl "Officer Rank - ASI"
la var po_rank_si_bl "Officer Rank - SI"
la var po_rank_psi_bl "Officer Rank - PSI"
la var po_rank_insp_bl "Officer Rank - Inspector"
la var po_rank_sho_bl "Officer Rank - SHO"

**dropping non-consent
replace dum_endline = 0 if key_el == "uuid:dae09398-f501-4b92-acab-d03677585bcb"
replace dum_bothsurveys = 0 if key_el == "uuid:dae09398-f501-4b92-acab-d03677585bcb"

replace dum_endline = 0 if key_el == "uuid:913a42c2-b30a-4582-91aa-14f1e791012a"
replace dum_bothsurveys = 0 if key_el == "uuid:913a42c2-b30a-4582-91aa-14f1e791012a"

replace dum_endline = 0 if key_el == "uuid:32ee5747-e8c5-464b-a457-adce1b104207"
replace dum_bothsurveys = 0 if key_el == "uuid:32ee5747-e8c5-464b-a457-adce1b104207"

replace dum_endline = 0 if key_el == "uuid:8c2d6945-835f-4706-b96a-1c6d29f85a34"
replace dum_bothsurveys = 0 if key_el == "uuid:8c2d6945-835f-4706-b96a-1c6d29f85a34"

replace dum_endline = 0 if key_el == "uuid:843b70b5-c46a-4d5f-b306-a9a77f4ded85"
replace dum_bothsurveys = 0 if key_el == "uuid:843b70b5-c46a-4d5f-b306-a9a77f4ded85"

replace dum_endline = 0 if key_el == "uuid:da647e3f-5567-4c27-b12f-2eeff2a3aba5"
replace dum_bothsurveys = 0 if key_el == "uuid:da647e3f-5567-4c27-b12f-2eeff2a3aba5"

replace dum_endline = 0 if key_el == "uuid:4172ae6a-53b6-493c-baa6-5326e0c0cd03"
replace dum_bothsurveys = 0 if key_el == "uuid:4172ae6a-53b6-493c-baa6-5326e0c0cd03"

drop if key_el == "uuid:5f2fb5cf-609c-4640-9ca4-0467314acf05"
drop if key_el == "uuid:76da5f30-bcdf-4276-9abc-a5080a4df94a"
drop if key_el == "uuid:a4ebe632-2824-4a1d-bdf5-8a6e742f97cc"
drop if key_el == "uuid:be3d8d69-2929-4110-8b6d-3620d98b5d0e"


sort ps_dist_bl ps_dist_id_bl ps_dist_el ps_dist_id_el


//dropping endline PII
drop po_name_el i1_name_el l1p1_el l1p1_os_el l1p1_name_el wifename_el officeraddress_el wifephone_el wifealternate_el gpslocationlatitude_el gpslocationlongitude_el gpslocationaltitude_el gpslocationaccuracy_el po_mobnum_bl po_mobnum_alt_bl po_mobnum_el po_mobnum_alt_el

order ps_dist_bl ps_dist_id_bl ps_name_bl ps_dist_el ps_dist_id_el ps_name_el treatment_bl treatment_transfer treatment_el po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl po_marital_dum_bl po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl dum_baseline dum_endline dum_bothsurveys dum_baselineonly dum_endlineonly dum_training dum_transfer dum_transfer_ctoc dum_transfer_ttot dum_transfer_ctot dum_transfer_ttoc dum_outsample dum_transfer_outsampletocontrol dum_transfer_outsamptotreatment dum_transfer_controltooutsample dum_transfer_treatmenttooutsamp dum_core_transfer_control dum_core_transfer_treatment dum_notransfer_treatment dum_notransfer_control dum_ctoc_transfer dum_ttot_transfer dum_ctot_transfer dum_ttoc_transfer dum_endline_treatment_transfer dum_endline_control_transfer dum_baseline_transfer_out dum_endline_treatment_training dum_endline_control_training dum_decoy dum_decoy_control dum_decoy_treatment key_el k5p1_el k5p1_os_el k6p1_el k6p1_os_el b3f_el b3g_el b3h_el b3h_os_el b3i_el b3j_el b3j_os_el po_new_station_el 
* Save the dataset in the Clean Data Folder. We would use the saved clean dta file 


replace gbv_uid_bl = "10041011004" if key_bl == "uuid:20400b34-1aba-4eea-b9d9-72d9ccf57224"

drop if ps_dist_bl ==. & ps_dist_id_bl != ""

save "${intermediate_dta}endline_intermediate.dta", replace