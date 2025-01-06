/*==============================================================================
File Name: PSFS-2022 - Anonymization do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	14/12/2022
Created by: Shubhro Bhattacharya
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to remove PII Information from the PSFS Survey 2022. 

*	Inputs: 06.clean-data  "01.PSFS_clean_PII"
*	Outputs: 06.clean-data  "02.PSFS_clean_deidentified"

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

log using "$psfs_log_files\PSFS_anonymization.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 06.clean-data  "01.PSFS_clean_PII"

use "$psfs_clean_dta\01.PSFS_clean_PII.dta" , clear


//===================Anonymization=======================//

*1. Surveyor Names
gen sv_id=.
replace sv_id=sv_name
drop sv_name 
order sv_id, first

*2. Police Officer Names

drop po_name // We can simply drop the names of the Police Officers at this stage since this information is no longer required. 


*3. Dropping surveyor comments
drop sv_comments // For the sake of neatness of the data -- All surveyor comments/suggestions should have been addressed and incorporated in the data by this point. 

//==========End of Do Files==================================//

//This is the final deidentified data which would be used for all the analysis purposes. 

save "$psfs_clean_dta\02.PSFS_clean_deidentified.dta", replace

