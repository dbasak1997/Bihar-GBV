/*==============================================================================
File Name: Decoy Survey 2023 - Cleaning do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	21/05/2024
Created by: Dibyajyoti Basak
Updated on: 21/05/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to clean the data for the Decoy Survey 2023

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

global raw "$decoy\00.raw-data"
global do_files "$decoy\01.do-files"
global intermediate_dta "$decoy\02.intermediate-data\"
global tables "$decoy\03.tables\"
global graphs "$decoy\04.graphs\"
global log_files "$decoy\05.log-files\"
global clean_dta "$decoy\06.clean-data\"

* We will log in
capture log close 

log using "$decoy_log_files\decoysurvey_clean.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\endline_secondaryoutcomes.dta", clear
duplicates drop gbv_uid_bl, force
tempfile endlinedata
save `endlinedata'

use "$decoy_intermediate_dta\Decoy Survey.dta", clear

replace police_district_station = "1010_27" if key == "uuid:b014625d-c7a4-4cbe-b37f-766b61d744f3"
replace a6label = "Pupri PS" if key == "uuid:b014625d-c7a4-4cbe-b37f-766b61d744f3"

replace police_district_station = "1004_10" if key == "uuid:56049b38-d645-414b-b80c-dc65158b30df"
replace a6label = "Baikunthpur PS" if key == "uuid:56049b38-d645-414b-b80c-dc65158b30df"

replace police_district_station = "1004_23" if key == "uuid:fd411aa1-51eb-49e6-8fdc-55e161bdfe5b"
replace a6label = "Mohammadpur PS" if key == "uuid:fd411aa1-51eb-49e6-8fdc-55e161bdfe5b"

replace police_district_station = "1004_15" if key == "uuid:f043568d-4852-4af1-a34d-d390efa57cb3"
replace a6label = "Gopalpur PS" if key == "uuid:f043568d-4852-4af1-a34d-d390efa57cb3"

drop if key == "uuid:3f762896-919f-41df-a5f5-0ad8729fc534"
drop if key == "uuid:15afea13-22b7-442e-bc93-57252a8d87f1"
drop if key == "uuid:2f3be005-b95e-4478-945d-2ccdc2775124"
drop if key == "uuid:9c29be0c-ae2a-4e15-829c-2709cfdb60b6"
drop if key == "uuid:27f72fe1-25ed-4539-86fb-662372bf4cbd"
drop if key == "uuid:de444567-d625-4b5a-a221-b66b83ac7650"
drop if key == "uuid:088c73aa-1768-41ff-be99-8bd88e5aa249" 

replace b1 = b1_full if b1 == "-888" & b1_full != "-888" & b1_full != ""
replace b1 = "" if b1 == "-888"
rename b1 gbv_uid_bl
merge m:1 gbv_uid_bl using `endlinedata'
drop if _m == 2
drop _m

destring a5, gen(ps_dist_decoy)
label define ps_dist_decoy 1003 "Bhojpur" 1004 "Gopalganj" 1006 "Muzaffarpur" 1007 "Nalanda" 1010 "Sitamarhi" 1011 "Siwan", add
label values ps_dist_decoy ps_dist_decoy

gen visit =.
gen date_num = a1
format date_num %9.0f

//Visit 1
replace visit = 1 if ps_dist_decoy == 1003 & (date_num == 23319 | date_num == 23320 | date_num == 23321)
replace visit = 1 if ps_dist_decoy == 1011 & (date_num == 23322 | date_num == 23323 | date_num == 23324)
replace visit = 1 if ps_dist_decoy == 1010 & (date_num == 23336)
replace visit = 1 if ps_dist_decoy == 1007 & (date_num == 23345 | date_num == 23346)
replace visit = 1 if ps_dist_decoy == 1004 & (date_num == 23345 | date_num == 23351)
replace visit = 1 if ps_dist_decoy == 1006 & (date_num == 23360 | date_num == 23361 | date_num == 23362 | date_num == 23363)

//Visit 2
replace visit = 2 if ps_dist_decoy == 1003 & (date_num == 23329 | date_num == 23330)
replace visit = 2 if ps_dist_decoy == 1011 & (date_num == 23338 | date_num == 23339)
replace visit = 2 if ps_dist_decoy == 1010 & (date_num == 23356)
replace visit = 2 if ps_dist_decoy == 1007 & (date_num == 23364 | date_num == 23365)
replace visit = 2 if ps_dist_decoy == 1004 & (date_num == 23367)
replace visit = 2 if ps_dist_decoy == 1006 & (date_num == 23372 | date_num == 23373)

//Visit 3
replace visit = 3 if ps_dist_decoy == 1003 & (date_num == 23341 | date_num == 23342 | date_num == 23343)
replace visit = 3 if ps_dist_decoy == 1011 & (date_num == 23353 | date_num == 23354 | date_num == 23719)
replace visit = 3 if ps_dist_decoy == 1010 & (date_num == 23370)
replace visit = 3 if ps_dist_decoy == 1004 & (date_num == 23376 | date_num == 23377)
replace visit = 3 if ps_dist_decoy == 1007 & (date_num == 23378 | date_num == 23379)
replace visit = 3 if ps_dist_decoy == 1006 & (date_num == 23381 | date_num == 23383)

keep deviceid-a1 treatment_bl po_age_bl-po_rank_sho_bl dum_bothsurveys dum_transfer dum_training dum_decoy index_Openness_And_bl index_Openness_Reg_bl index_VictimBlame_And_bl index_VictimBlame_Reg_bl index_Techskills_And_bl index_Techskills_Reg_bl index_Empathy_And_bl index_Empathy_Reg_bl index_Flexibility_And_bl index_Flexibility_Reg_bl index_Desirability_And_bl index_Desirability_Reg_bl index_Depression_bl index_AttitudeGBV_And_bl index_AttitudeGBV_Reg_bl index_ExtPol_And_bl index_ExtPol_Reg_bl index_Discrimination_And_bl index_Discrimination_Reg_bl index_Truth_And_bl index_Truth_Reg_bl date_num ps_dist_decoy visit 

gen dum_gbv_case =.
replace dum_gbv_case = 1 if (c1 == 4 | c1 == 5 | c1 == 6 | c1 == 7)
replace dum_gbv_case = 0 if (c1 == 1 | c1 == 2 | c1 == 3)

rename *_bl *_decoy
rename treatment_decoy treatment_bl
drop deviceid-uploadstamp 
order ps_dist_decoy police_district_station visit a1 date_num dum_gbv_case a2-index_Truth_Reg_decoy

tostring visit, gen(visit_str)
replace visit_str = "_visit" + visit_str 
drop visit
rename po_caste_dum_general_decoy po_caste_dumgen_decoy
rename po_highest_educ* po_educ*
rename index_* *

rename police_district_station ps_dist_id

tempfile rough
save `rough'


*reshape wide a1-Truth_Reg_decoy, i(ps_dist_id) j(visit_str) string


merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta" //merging with PS level data
drop if _m != 3
drop _m



*drop wgt stdgroup index_psfs_gen_And-index_psfs_m_f_seg_Reg

rename treatment treatment_station_decoy
rename ps_dist_id ps_dist_id_decoy
*rename index_* *
order ps_dist_id_decoy ps_dist_decoy treatment_station_decoy, first


save "$decoy_clean_dta\decoy_clean_LONG.dta", replace


use `rough'
reshape wide a1-Truth_Reg_decoy, i(ps_dist_id) j(visit_str) string


merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta" //merging with PS level data
drop if _m != 3
drop _m

*drop wgt stdgroup index_psfs_gen_And-index_psfs_m_f_seg_Reg

rename treatment treatment_station_decoy
rename ps_dist_id ps_dist_id_decoy
*rename index_* *
order ps_dist_id_decoy ps_dist_decoy treatment_station_decoy, first

save "$decoy_clean_dta\decoy_clean_WIDE.dta", replace
