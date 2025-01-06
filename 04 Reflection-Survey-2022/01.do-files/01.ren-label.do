/*==============================================================================
File Name:	Reflection Survey (Treatment) - Rename-Label do file
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	19/11/2022
Created by: Shubhro Bhattacharya
Updated on:	22/02/2023
Updated by:	Shubhro Bhattacharya

*Notes READ ME:
*This Do File is to rename and label the reflection survey
*
*	Inputs:  "Officer Reflection Survey Treatment.dta" appended with "Officer Reflection Survey Treatment.dta"
*	Outputs: "ren-label_reflection.dta"
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

log using "$reflection_log_files\01.reflection_renlabel.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*Now we append the Treatment and Control datasets for the reflection survey.

use "$reflection_intermediate_dta\C_reflection-survey", clear
gen survey = "Control"
tempfile control
save `control'

use "$reflection_intermediate_dta\T_reflection-survey", clear
gen survey = "Treatment"

append using `control', force


*Renaming and Labeling

/*Abbreviations:

cp: current posting
prev: previous posting
trf: transfer 
bl: baseline
dist: district
os:Other's Specify

*/

//Renaming and Labeling Variables for the Current Transfer Postings

//These questions are only asked to the Officers if they do not confirm to be posted in the PS from the Officer's Baseline Survey

ren l3a cptrf_samedist
la var cptrf_samedist "L3a. Whether the current transfer posting is within the same district or Different district"    

ren l3a_os cptrf_otherdist_os
la var cptrf_otherdist_os "L3a_os. Others Specify for whether the current transfer posting is within the same district or Different district" 

ren l3b cptrf_samedist_ps
la var cptrf_samedist_ps "L3b. Specify Police Station of the Current Transfer Posting (For Within District Transfer)" 

ren l3b_os cptrf_samedist_ps_os
la var cptrf_samedist_ps_os "L3b_os. Others Specify Police Station of the Current Transfer Posting (For Within District Transfer)" 

ren l3cdistrict cptrf_otherdist
la var cptrf_otherdist "L3c. District of the Current Transfer Posting (For Outside District Transfer)" 

ren l3cpolicestation cptrf_otherdist_ps
la var cptrf_otherdist_ps "L3c. Police Station of the Current Transfer Posting (For Outside District Transfer)" 

ren l3cpolicestation_os cptrf_otherdist_ps_os
la var cptrf_otherdist_ps_os "L3c. Other Specify Police Station of the Current Transfer Posting (For Outside District Transfer)"

ren l3d_day cptrf_otherdist_day
la var cptrf_otherdist_day "L3d. Day of the Current Transfer Posting (For Outside District Transfer)" 

ren l3d_month cptrf_otherdist_month
la var cptrf_otherdist_month "L3d. Month of the Current Transfer Posting (For Outside District Transfer)" 

ren l3d_year cptrf_otherdist_year
la var cptrf_otherdist_year "L3d. Year of the Current Transfer Posting (For Outside District Transfer)" 

//Set of l3 questions are more for confirming our data -- ideally it will be dropped at the end once we have verified all our data. 


//Renaming Variables for the Previous Transfer Postings q.L4 onwards in Reflection Survey. 

ren l4 prevtrf
la var prevtrf "L4. Transferred in the Past 6 months?" 

ren l4a prevtrf_dist
la var prevtrf_dist "L4a. District of Previous Transfer Posting" 


ren l4a_os prevtrf_dist_os
la var prevtrf_dist_os "L4a_os. Other's specify District of Previous Transfer Posting" 

ren l4b prevtrf_samedist
la var prevtrf_samedist "L4b Police Station of the Previous Transfer Posting? (For Within District)" 

ren l4b_os prevtrf_samedist_os
la var prevtrf_samedist_os "L4b Other Specify Police Station of the Previous Transfer Posting? (For Within District)"  

ren l4bcode prevtrf_ps_series
la var prevtrf_ps_series "Police Station Series Code for Previous Transfer Posting (Within Same District)?"

ren l4bname prevtrf_ps_name
la var prevtrf_ps_name "Police Station Series Code for Previous Transfer Posting (Within Same District)?"

ren l4cdistrict prevtrf_otherdist
la var prevtrf_otherdist "L4c District of Previous Transfer Posting (For Outside District)"  

ren l4cpolicestation prevtrf_otherdist_ps
la var prevtrf_otherdist_ps "L4c Police Station of Previous Transfer Posting (For Outside District)"  


ren l4cpolicestation_os prevtrf_otherdist_os
la var prevtrf_otherdist_os "Other Specify Police Station of the Previous Transfer Posting? (For Outside District)"  

       

/* 
The current gbv_uid system was not implemented at the time of implementing the reflection survey in Sitamarhi and hence, several officers who were transferred in were not assigned any uid. Hence, we had to verify the master list for Sitamarhi and assign the uid's manually for Sitamarhi district to account for all the transfers. 

*/
merge 1:1 key using "$reflection_raw\sit_uid_key.dta"

drop _merge //All the 133 observations from Sitamarhi are assigned uids and we will continue using these ids for the entire duration of our study. 

//Those officers who were not present during the baseline but attended our training have been assigned alpha-numeric uids starting with REF. 


//Clubbing all the uid variables together to make "gbv_uid_ref" variable which would be later used to create a merge with the baseline.

gen gbv_uid_ref=gbv_uid

replace gbv_uid_ref=l1p1 if gbv_uid=="-888"

replace gbv_uid_ref=sit_gbv_uid if ps_dist=="1010"

replace gbv_uid_ref="-888" if gbv_uid_ref==""

/*1. gbv_uid_ref is the uid which will be used throughout the study and this is the key which matches with the baseline officers survey

  2. Those officers who were not surveyed during our Officer's baseline survey have been assigned "-888" codes for the moment. (Exception: Sitamarhi) -- all uids have been assigned for Sitamarhi.
 */

//dropping other uid variables to avoid confusion:

drop gbv_uid l1p1 sit_gbv_uid
order gbv_uid_ref

label variable gbv_uid_ref "Officer unique id (merging with baseline)"

//Renaming and Labelling variables from the latest version of Reflection Survey (using fresh transfer tracker)

order l1p1_phno phonenumber po_mobile, after(po_listname) 

//For the moment we are going to keep all the mobile number variables. if not required, we will drop the variables "l1p1_phno phonenumber i1_phno" at the end. 

label variable l1p1_phno "(Not for use) Extra phone number variable"
label variable i1_phno "(Not for use) Extra phone number variable"
label variable phonenumber "(Not for use) Extra phone number variable"


replace po_mobile=phonenumber if po_mobile=="-111"  
replace po_mobile=phonenumber if po_mobile==""

//For the rest of the districts we will be importing the gbv_uids directly from our baseline surveys. 

ren k5p1 bl_district 
la var bl_district "In which district were you posted during Baseline Survey?"

ren k5p1_os bl_district_os 
la var bl_district_os "Others Specify: In which district were you posted during Baseline Survey?"

ren k6p1 bl_ps_series 
la var bl_ps_series "Police Station in which officer was posted during Baseline Survey"

ren po_new_station bl_ps_dist_id 
la var bl_ps_dist_id "Police Station in which officer was posted during Baseline Survey"

ren l1p1_name bl_po_name 
la var bl_po_name "Officer's Name from Baseline Survey List"


order po_listname bl_po_name po_nolistname displayname, before(po_rank)  

ren displayname po_name_ref // This will be the only variable left after we have collected all the data. Other officer name variables will be dropped. 
	   
la var po_name_ref "Name of the Officer (Mathced with Baseline Survey)"

	   
*Save dataset

save "$reflection_intermediate_dta\reflection-survey_renlabel.dta", replace
