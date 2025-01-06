/*==============================================================================
File Name: PSFS-2022 - Anonymization do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	07/02/2023
Created by: Aadya Gupta
Updated on: 22/11/2024
Updated by: Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to append PSFS_v1 Survey 2022 to PSFS Survey 2022. 

*	Inputs: 06.clean-data  "02.PSFS_clean_deidentified" "02.PSFS_v1_clean_deidentified"
*	Outputs: 06.clean-data "03.PSFS_clean_deidentified_new"

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

global psfs_v1 "$psfs\PSFS_v1-2022\06.clean-data"




* We will log in
capture log close 

log using "$psfs_log_files\PSFS_new_appending.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 06.clean-data  "02.PSFS_clean_deindentified"

use "$psfs_clean_dta\02.PSFS_clean_deidentified.dta", clear


//===================Appending=======================//

append using "$psfs_v1\02.PSFS_v1_clean_deidentified.dta", generate(_new) force


/* 
append using "C:\Users\AG\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\PSFS_v1-2022\0
> 6.clean-data\02.PSFS_v1_clean_deidentified.dta", generate(_new) force
*/

//Some of the gps variables need to be re-assigned 
replace e2latitude=gpslocationlatitude if _new==1 

replace e2longitude=gpslocationlongitude if _new==1

replace e2altitude=gpslocationaltitude if _new==1

replace e2accuracy=gpslocationaccuracy if _new==1


drop gpslocationlatitude gpslocationlongitude gpslocationaltitude gpslocationaccuracy   

* Checking data
duplicates list
duplicates report // No duplicates

/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ADD PS Series and Unique PS ID for missing


*/

br if ps_dist_id=="" //ID missing for Pawapuri Op, Nalanda

replace ps_series="99" if key=="uuid:0e5b6874-5d2d-43f1-8d29-99928839c8ac"

replace ps_dist_id="1007_99" if key=="uuid:0e5b6874-5d2d-43f1-8d29-99928839c8ac"

   

* var _new indicates data source of submissions

* This is the deidentified data for Bettiah and Bagaha which would be used for all the analysis purposes for these two districts

save "$psfs_clean_dta\03.PSFS_clean_deidentified_new.dta", replace