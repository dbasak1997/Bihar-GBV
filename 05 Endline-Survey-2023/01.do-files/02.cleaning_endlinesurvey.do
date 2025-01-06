/*==============================================================================
File Name: Baseline Officer's Survey 2022 - Error and Logical Consistency Checks do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	21/09/2023
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
	
*File Path

global raw "$MO_endline\00.raw-data"
global do_files "$MO_endline\01.do-files"
global intermediate_dta "$MO_endline\02.intermediate-data\"
global tables "$MO_endline\03.tables\"
global graphs "$MO_endline\04.graphs\"
global log_files "$MO_endline\05.log-files\"
global clean_dta "$MO_endline\06.clean-data\"


* We will log in
capture log close 

log using "$MO_endline_log_files\officersurveyv3_endline_cleaning.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 02.intermediate-data  "02.ren-officersurvey_intermediate"

use "$MO_endline_intermediate_dta\02.ren-officerendline_intermediate.dta" , clear

/* District codes: For reference and use throughout this do-file

Bagaha (1001)
Bettiah (1002)
Bhojpur (1003)
Gopalganj (1004)
Motihari (1005)
Muzaffarpur (1006)
Nalanda (1007)
Patna (1008)
Saran (1009)
Sitamarhi (1010)
Siwan (1011)
Vaishali (1012)
*/

* Attaching _el suffix to all variables to denote endline
rename premarital_socially_unacceptable prem_soc_unacceptable
rename * *_el
rename a7_el_el a7_el
rename marital_el_el marital_el

* Generating a single baseline key
replace key_baseline_el = l1p1_blkey_el if key_baseline_el == "" & l1p1_blkey_el != ""

* Generating a single officer name
replace po_name_el = l1p1_os_el if po_name_el == "" & l1p1_os_el != ""
replace po_name_el = l1p1_name_el if po_name_el == "" & l1p1_name_el != "" 
replace po_name_el = i1_name_el if po_name_el == "" & i1_name_el != ""

* Generating a single PO unique id
replace po_unique_id_el = a7_el if po_unique_id_el == "-888" & a7_el != "-888"

* Generating a single PO rank
replace b2a_el = b2_el if b2a_el ==.

* Generating a single PO phone number
replace po_mobnum_el = i1_phno_el if po_mobnum_el == "" & i1_phno_el != ""
replace po_mobnum_el = l1p1_phno_el if po_mobnum_el == "" & l1p1_phno_el != ""

* Generating a single PO marital status
destring marital_bl_el, gen(marital_bl_el_new)
replace marital_el = marital_bl_el_new if marital_el ==. & marital_bl_el_new !=. & marital_check_el != 0
replace marital_el = -666 if marital_status_el == "Refuse to answer" & marital_check_el != 0
replace marital_el = 1 if marital_status_el == "Never married" & marital_check_el != 0
replace marital_el = 2 if marital_status_el == "Married and lives together" & marital_check_el != 0
replace marital_el = 3 if marital_status_el == "Married but Lives Separately" & marital_check_el != 0
replace marital_el = 4 if marital_status_el == "Divorced" & marital_check_el != 0
replace marital_el = 5 if marital_status_el == "Separated" & marital_check_el != 0
replace marital_el = 6 if marital_status_el == "Widower" & marital_check_el != 0
replace marital_el = 2 if key_el == "uuid:da647e3f-5567-4c27-b12f-2eeff2a3aba5"

*recoding DN, Refuse to Answer values
/*
qui ds, has(type numeric)
foreach i of varlist `r(varlist)' {
replace `i' =. if `i' == -777
replace `i' =. if `i' == -888
replace `i' =. if `i' == -999
}
*/
qui ds, has(type string)
foreach i of varlist `r(varlist)' {
replace `i' ="" if `i' == "-777"
replace `i' ="" if `i' == "-888"
replace `i' ="" if `i' == "-999"
}

*drop a7_el l1p1_el i1_name_el l1p1_os_el l1p1_name_el b2_el_new i1_phno_el l1p1_phno_el 
replace po_name_el = "Upendra Rai" if key_el == "uuid:8fc0138f-8aa2-452b-83fb-b9c9dbefa59e"
replace po_name_el = "Md Khurshid Ansari" if key_el == "uuid:ed9de42e-d6f8-4d64-9560-8cec60b6f059"

replace po_name_el = upper(po_name_el)
replace po_name_el = trim(po_name_el)
replace po_name_el = itrim(po_name_el)

drop if key_el == "uuid:a1377d54-b383-41ea-acac-fbef2896f602"
drop if key_el == "uuid:da34cd8d-7a66-4e25-93f2-5b5cde800b6a"
drop if key_el == "uuid:93c669f5-6dfb-407f-9a3f-c2426dbacacd"
drop if key_el == "uuid:3385383b-d4e3-4ab9-9010-c1bc279af8f7"
drop if key_el == "uuid:293f0ca2-5e87-4711-a5a3-a49d5cbc6d09"
drop if key_el == "uuid:4e83ac11-5203-4da0-bbd6-f63c92af2f80"
drop if key_el == "uuid:b8d1c171-8dee-44e6-9845-2d6e71705235"
drop if key_el == "uuid:c3d4f8bf-06d3-4688-96c9-512d02f282c7"
drop if key_el == "uuid:e364d681-ee44-44f2-a8a8-7c0cb0e4976f"
drop if key_el == "uuid:0f469db1-edfc-429e-a17f-a012331e730e"
drop if key_el == "uuid:a5f50af1-f4b2-4e46-90ed-abb1e3560853"
drop if key_el == "uuid:8bdd70a6-98d3-4bfa-b4e6-42c0ac4c558d"
drop if key_el == "uuid:7a6c53f5-2ac4-4786-8539-42eba86532e4"
drop if key_el == "uuid:e991482e-6102-4a9f-a620-69f86a444998"
drop if key_el == "uuid:5d8fc5e6-ddde-4130-9fa0-ff9fd6e74623"
drop if key_el == "uuid:18763e1c-2c8e-47c9-974c-a891d3db20f4"

replace key_baseline_el = "" if key_el == "uuid:9a236c2e-6128-43b5-b5aa-c2583b6372cf"
replace key_baseline_el = "" if key_el == "uuid:be2ae519-a8fb-413f-b805-cb3e80175fcc"
replace key_baseline_el = "uuid:237a65a6-8fe6-4d4d-bde5-6f1aa8a308cb" if key_el == "uuid:957f371b-907c-45b4-aeed-c420fcc8788c"
replace key_baseline_el = "" if key_el == "uuid:998dafef-c084-4303-b349-b1fd55f123e5"
replace key_baseline_el = "" if key_el == "uuid:96601082-911b-47dd-8dfc-634aad794961"
replace key_baseline_el = "uuid:fe5cd173-9791-4509-8f3c-1fc00ee7dbb2" if key_el == "uuid:9018372f-29d1-46ae-bd1c-ed405df50221"
replace key_baseline_el = "" if key_el == "uuid:58a8edb5-f2b7-47f7-8b1d-c6c1d4102f45"
replace key_baseline_el = "" if key_el == "uuid:a05882d8-6f6d-4ad0-a3aa-03584004038d"
replace key_baseline_el = "" if key_el == "uuid:05448ce1-b094-4bd0-a4c5-f70e56a8c13c"

*duplicates drop key_baseline_el if key_baseline_el!="", force

****

**Cleaning PS data using OS data
replace k5p1_el = "1007" if key_el == "uuid:51b21f61-1a15-4955-a2fb-975f988aa62b"
replace k6p1_el = "19" if key_el == "uuid:51b21f61-1a15-4955-a2fb-975f988aa62b"
replace po_new_station_el = "1007_19" if key_el == "uuid:51b21f61-1a15-4955-a2fb-975f988aa62b"

replace k5p1_el = "1005" if key_el == "uuid:6ca81757-0418-45de-bd8b-3c8303df1081"
replace k6p1_el = "12" if key_el == "uuid:6ca81757-0418-45de-bd8b-3c8303df1081"
replace po_new_station_el = "1005_12" if key_el == "uuid:6ca81757-0418-45de-bd8b-3c8303df1081"

replace k5p1_el = "1006" if key_el == "uuid:f1eb95e1-a557-4e20-aca8-08b1abaa09ea"
replace k6p1_el = "44" if key_el == "uuid:f1eb95e1-a557-4e20-aca8-08b1abaa09ea"
replace po_new_station_el = "1006_44" if key_el == "uuid:f1eb95e1-a557-4e20-aca8-08b1abaa09ea"

replace k5p1_el = "1007" if key_el == "uuid:568ad932-7f9b-4e30-a6a7-576168b46561"
replace k6p1_el = "45" if key_el == "uuid:568ad932-7f9b-4e30-a6a7-576168b46561"
replace po_new_station_el = "1007_45" if key_el == "uuid:568ad932-7f9b-4e30-a6a7-576168b46561"

replace k5p1_el = "1010" if key_el == "uuid:afa93f56-b14c-48a2-8baa-5b9d52c78f82"
replace k6p1_el = "27" if key_el == "uuid:afa93f56-b14c-48a2-8baa-5b9d52c78f82"
replace po_new_station_el = "1010_27" if key_el == "uuid:afa93f56-b14c-48a2-8baa-5b9d52c78f82"

replace k5p1_el = "1010" if key_el == "uuid:f0148906-9f03-4ef6-90d0-483083f8f248"
replace k6p1_el = "32" if key_el == "uuid:f0148906-9f03-4ef6-90d0-483083f8f248"
replace po_new_station_el = "1010_32" if key_el == "uuid:f0148906-9f03-4ef6-90d0-483083f8f248"

replace k5p1_el = "1003" if key_el == "uuid:3792375e-f428-4cd8-a05f-ab311a3ec63c"
replace k6p1_el = "31" if key_el == "uuid:3792375e-f428-4cd8-a05f-ab311a3ec63c"
replace po_new_station_el = "1003_31" if key_el == "uuid:3792375e-f428-4cd8-a05f-ab311a3ec63c"

replace k5p1_el = "1001" if key_el == "uuid:147bb1f8-60d9-4aa2-a9e1-b2884aab4080"
replace k6p1_el = "10" if key_el == "uuid:147bb1f8-60d9-4aa2-a9e1-b2884aab4080"
replace po_new_station_el = "1001_10" if key_el == "uuid:147bb1f8-60d9-4aa2-a9e1-b2884aab4080"

replace k5p1_el = "1001" if key_el == "uuid:a1912291-3040-494d-b04b-8f756f5b1ed4"
replace k6p1_el = "16" if key_el == "uuid:a1912291-3040-494d-b04b-8f756f5b1ed4"
replace po_new_station_el = "1001_16" if key_el == "uuid:a1912291-3040-494d-b04b-8f756f5b1ed4"

replace k5p1_el = "1002" if key_el == "uuid:d1a460c9-5fb4-43c5-bd61-4ac45c0a1fd6"
replace k6p1_el = "18" if key_el == "uuid:d1a460c9-5fb4-43c5-bd61-4ac45c0a1fd6"
replace po_new_station_el = "1002_18" if key_el == "uuid:d1a460c9-5fb4-43c5-bd61-4ac45c0a1fd6"

replace k5p1_el = "10018" if key_el == "uuid:0654ea21-b4d1-4e68-8f7f-12a2ae6aa040"
replace k6p1_el = "22" if key_el == "uuid:0654ea21-b4d1-4e68-8f7f-12a2ae6aa040"
replace po_new_station_el = "1008_22" if key_el == "uuid:0654ea21-b4d1-4e68-8f7f-12a2ae6aa040"

replace k5p1_el = "1012" if key_el == "uuid:c4870037-c044-475e-9933-341bd65b93b4"
replace k6p1_el = "35" if key_el == "uuid:c4870037-c044-475e-9933-341bd65b93b4"
replace po_new_station_el = "1012_35" if key_el == "uuid:c4870037-c044-475e-9933-341bd65b93b4"

replace k5p1_el = "1002" if key_el == "uuid:194e1d91-5140-40a6-bf5f-9affb62495bd"
replace k6p1_el = "27" if key_el == "uuid:194e1d91-5140-40a6-bf5f-9affb62495bd"
replace po_new_station_el = "1002_27" if key_el == "uuid:194e1d91-5140-40a6-bf5f-9affb62495bd"

replace k5p1_el = "1002" if key_el == "uuid:18d601fe-ed5d-4143-8e6c-62af6b34070e"
replace k6p1_el = "27" if key_el == "uuid:18d601fe-ed5d-4143-8e6c-62af6b34070e"
replace po_new_station_el = "1002_27" if key_el == "uuid:18d601fe-ed5d-4143-8e6c-62af6b34070e"

replace k5p1_el = "1002" if key_el == "uuid:b1b8e5f7-373c-4cf4-a2b5-d7c6593bda9d"
replace k6p1_el = "27" if key_el == "uuid:b1b8e5f7-373c-4cf4-a2b5-d7c6593bda9d"
replace po_new_station_el = "1002_27" if key_el == "uuid:b1b8e5f7-373c-4cf4-a2b5-d7c6593bda9d"

replace k5p1_el = "1002" if key_el == "uuid:76b20115-d372-4107-a3c9-c04c3e031c38"
replace k6p1_el = "31" if key_el == "uuid:76b20115-d372-4107-a3c9-c04c3e031c38"
replace po_new_station_el = "1002_31" if key_el == "uuid:76b20115-d372-4107-a3c9-c04c3e031c38"

replace k5p1_el = "10012" if key_el == "uuid:bad09cb5-d376-4847-89c6-e9e07fe67ccc"
replace k6p1_el = "36" if key_el == "uuid:bad09cb5-d376-4847-89c6-e9e07fe67ccc"
replace po_new_station_el = "1002_36" if key_el == "uuid:bad09cb5-d376-4847-89c6-e9e07fe67ccc"

replace k5p1_el = "1004" if key_el == "uuid:516f1e12-5e41-4c70-b82e-cf3a26dc7ebd"
replace k6p1_el = "14" if key_el == "uuid:516f1e12-5e41-4c70-b82e-cf3a26dc7ebd"
replace po_new_station_el = "1004_14" if key_el == "uuid:516f1e12-5e41-4c70-b82e-cf3a26dc7ebd"

replace k5p1_el = "1006" if key_el == "uuid:b7d5c8b0-471f-42b6-a9d6-762525216703"
replace k6p1_el = "26" if key_el == "uuid:b7d5c8b0-471f-42b6-a9d6-762525216703"
replace po_new_station_el = "1006_26" if key_el == "uuid:b7d5c8b0-471f-42b6-a9d6-762525216703"

replace k5p1_el = "1006" if key_el == "uuid:de234e77-0800-41c3-86ad-a22f37a7293c"
replace k6p1_el = "41" if key_el == "uuid:de234e77-0800-41c3-86ad-a22f37a7293c"
replace po_new_station_el = "1006_41" if key_el == "uuid:de234e77-0800-41c3-86ad-a22f37a7293c"

replace k5p1_el = "1007" if key_el == "uuid:460eed70-6280-4ff2-85ce-9f827fb570cf"
replace k6p1_el = "45" if key_el == "uuid:460eed70-6280-4ff2-85ce-9f827fb570cf"
replace po_new_station_el = "1007_45" if key_el == "uuid:460eed70-6280-4ff2-85ce-9f827fb570cf"

replace k5p1_el = "1008" if key_el == "uuid:460eed70-6280-4ff2-85ce-9f827fb570cf"
replace k6p1_el = "38" if key_el == "uuid:460eed70-6280-4ff2-85ce-9f827fb570cf"
replace po_new_station_el = "1008_38" if key_el == "uuid:460eed70-6280-4ff2-85ce-9f827fb570cf"

replace k5p1_el = "1010" if key_el == "uuid:f69d9269-27a3-4c60-b965-5e9d4a9f9451"
replace k6p1_el = "13" if key_el == "uuid:f69d9269-27a3-4c60-b965-5e9d4a9f9451"
replace po_new_station_el = "1010_13" if key_el == "uuid:f69d9269-27a3-4c60-b965-5e9d4a9f9451"



order ps_dist_el ps_series_el ps_dist_id_el ps_name_el po_unique_id_el po_name_el b2a_el po_mobnum_el key_baseline

save "$MO_endline_intermediate_dta\endline_clean.dta", replace

rename key_baseline_el key_baseline
preserve
drop if key_baseline == ""
save "$MO_endline_intermediate_dta\Endline_w_Baseline.dta", replace

restore
drop if key_baseline != ""
save "$MO_endline_intermediate_dta\Endline_wo_Baseline.dta", replace

* Save the dataset in the Clean Data Folder. We would use the saved clean dta file 


