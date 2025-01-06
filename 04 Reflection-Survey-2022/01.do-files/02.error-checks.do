/*==============================================================================
File Name:	Reflection Survey - Error Checks Do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	19/11/2022
Created by: Shubhro Bhattacharya
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This Do File is to rename and label the reflection survey
*
*	Inputs:  "Officer Reflection Survey Treatment.dta" appended with "Officer Reflection Survey Treatment.dta"
*	Outputs: "reflection_PII.dta"
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

log using "$reflection_log_files\02.reflection_errorchecks.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*Load the rename-labelled dataset from the Intermediate data folder
 
use "$reflection_intermediate_dta\reflection-survey_renlabel.dta", clear


/*Errors and Logical Checks: A pooled checks for all the districts have been performed here*/

*Matching Data from the records:

replace po_mobile="8409898969" if key=="uuid:a83e0680-c834-49ef-a28e-2402e3529b13" //Matched from the Officer Survey List  

//Checking duplicates in mobile numbers

duplicates tag po_mobile, generate(tag)
tab tag // there are 22 mobile numbers which are currently repeating
sort tag

replace po_mobile=phonenumber if key=="uuid:1edd23f0-947c-4604-8c56-816bdf52c4b0"

replace po_mobile="9470441269" if key=="uuid:62ff289c-ebb2-478d-90db-17f0f72566a9" //Matched from Officer list

replace po_mobile="7903908918" if key=="uuid:83991995-74aa-4570-85dd-cf83ff3974aa" //Matched from Officer list

//drop duplicate observations
drop if key== "uuid:4d195952-071a-487b-8424-ec2568708872"

drop if key== "uuid:b5aa07e9-6e9a-44ca-8464-dbb39b137137"


drop if key== "uuid:a6b9987e-51c9-4e6c-b852-022a2fa1d0e6"

drop if key=="uuid:93f412c1-16f0-4cf4-8596-abda6c74543f" //Officer surveyed twice, so we keep the updated survey. 

drop if key=="uuid:b7a9bab3-e774-4ed6-a0f8-58abd00b7427" //Officer surveyed twice, so we keep the updated survey. 

drop if key=="uuid:267e422f-09ed-4bf7-8afd-27911aa3fa41" //Officer surveyed twice, so we keep the updated survey. 

drop if key=="uuid:35819e13-bc1d-4c75-8ca5-486f7d3c5626" //Officer surveyed twice, so we keep the updated survey. 

drop if key=="uuid:2ef4292b-753a-42a7-8de9-35e336c5553d" //Officer surveyed twice, so we keep the updated survey. 

replace phonenumber=po_mobile if key=="uuid:62ff289c-ebb2-478d-90db-17f0f72566a9" //Matched from the records

*Checking Mobile number duplicacies again
drop tag
duplicates tag po_mobile, generate(rep)
tab rep //All mobile numbers are unique in our records now. (21feb2023)
drop rep



*Misc. cleaning exercises: Re-ordering variables, dropping superfluous variables.


order e2latitude e2longitude e2altitude e2accuracy formdef_version key sv_date sv_start sv_stop, last




save "$reflection_clean_dta\reflection_PII.dta", replace






//=============END do file. Supplementary Codes=====================


/* Fixing the UiDs for Sitamarhi 

ren po_mobile ospo_mobnum

merge 1:1 ospo_mobnum using "${intermediate_dta}sitamarhi_officersurvey.dta", force

drop if _merge==2


*Filling in the GBV uid variables from the database
//Refer to CSV File: Sitamarhi_reflection_merge

replace osgbv_uid= gbv_uid if gbv_uid=="-888"

replace osgbv_uid= "10101111008" if ospo_mobnum=="6206906823"
replace osgbv_uid= "10101221016" if ospo_mobnum=="8809536900"
replace osgbv_uid= "10101321023" if ospo_mobnum=="9431830015"
replace osgbv_uid= "10101351022" if ospo_mobnum=="9431822372"
replace osgbv_uid= "10101421031" if ospo_mobnum=="8969035890"
replace osgbv_uid= "10101441030" if ospo_mobnum=="9937067970"
replace osgbv_uid= "10101551035" if ospo_mobnum=="9264497213"
replace osgbv_uid= "10101611039" if ospo_mobnum=="6200339651"
replace osgbv_uid= "10101611040" if ospo_mobnum=="7250316449"
replace osgbv_uid= "10101721043" if ospo_mobnum=="6287289099"
replace osgbv_uid= "10101721046" if ospo_mobnum=="8825111267"
replace osgbv_uid= "10102011062" if ospo_mobnum=="7908666032"
replace osgbv_uid= "10102511093" if ospo_mobnum=="9430873779"
replace osgbv_uid= "10102651104" if ospo_mobnum=="8292167287"
replace osgbv_uid= "10102921132" if ospo_mobnum=="9123264916"
replace osgbv_uid= "10102921135" if ospo_mobnum=="9576430618"
replace osgbv_uid= "10103011141" if ospo_mobnum=="9661211521"
replace osgbv_uid= "10103211145" if ospo_mobnum=="8709965776"
replace osgbv_uid= "10103211151" if ospo_mobnum=="8340536006"
replace osgbv_uid= "10103321164" if ospo_mobnum=="9102081618"
replace osgbv_uid= "10103521176" if ospo_mobnum=="7192966778"
replace osgbv_uid= "10103551178" if ospo_mobnum=="8210107397"

sort osgbv_uid 
order osgbv_uid
drop gbv_uid

gen ref="REF"
egen temp_id= concat(ref ps_dist ps_series po_rank po_series) 

replace osgbv_uid= temp_id if osgbv_uid=="-888"
drop temp_id ref
rename osgbv_uid gbv_uid

duplicates report gbv_uid // This variable should be unique with no duplicates. 
//Also, each observation should be assigned a uid so check for missing values. 

drop _merge ospo_rank ospo_name osps_name osps_dist_id osps_series osps_dist ossv_location

rename ospo_mobnum po_mobnum

order po_mobnum po_altmobile, after(po_name)
 
*/





/* ============Verifying the merge with Officers Survey ============

ren gbv_uid osgbv_uid
 
merge 1:1 osgbv_uid using "${intermediate_dta}sitamarhi_officersurvey.dta", force

drop if _merge==2
sort _merge

The _merge==1 observations should only contain:
1. Those officers who were NOT a part of the baseline but part of the Reflection Survey

2. These officers should have a uid starting with REF<10 digit code>   

 */










