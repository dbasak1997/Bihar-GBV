/*==============================================================================
File Name: Baseline Officer's Survey 2022 - Combining deidentified data of previous rounds of baseline survey
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	30/05/2023
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to perform the error and logical consistency checks on the Baseline Officer's Survey 2022. 

*	Inputs: 06.clean-data  "02.officersurvey_clean_deidentified", "02.officersurveyv3_clean_deidentified"
*	Outputs: 01.clean-data  "01.officersurvey_clean_deidentified_combined"

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


global dropbox "$MO_baseline\Baseline Survey_versions 1-3"

use "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey-2022\06.clean-data\02.officersurvey_clean_deidentified.dta" //calling version 1 of the baseline survey
append using "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey-v3-2023\06.clean-data\02.officersurveyv3_clean_deidentified.dta" //appending version 3 of the baseline survey

*saving as a combined .dta file
save "$MO_baseline_clean_dta\01.officersurvey_clean_deidentified_combined.dta", replace
