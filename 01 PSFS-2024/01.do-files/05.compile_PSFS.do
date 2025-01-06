/*==============================================================================
File Name: PSFS 2022- Compile do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	27/03/2023
Created by: Aadya Gupta
Updated on:	18/05/2023
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Index Do file for the Baseline PSFS 2022. It compiles the data from 

*	Inputs: 06.clean-data  "02.PSFS_clean_deidentified" "02.PSFS_clean_deidentified_v1" 
*	Outputs: 06.clean-data  "02.PSFS_clean_deidentified_compile"

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

**File Directory

*HP -- username for Aadya.
*AG -- temp user name for Aadya.
*Acer -- username for Shubhro.
*dibbo -- username for Dibyajyoti 
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 

* For PSFS

if "`c(username)'"=="HP"{
	global dropbox "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\PSFS-2022"
	}
	

else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\01 PSFS-2024\PSFS-2022"
	}	
	
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}
	
di "`dropbox'"
	
*File Path

global raw "$dropbox\00.raw-data"
global do_files "$dropbox\01.do-files"
global intermediate_dta "$dropbox\02.intermediate-data\"
global tables "$dropbox\03.tables\"
global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\05.log-files\"
global clean_dta "$dropbox\06.clean-data\"


* For PSFS_v1

if "`c(username)'"=="HP"{
	global psfs_v1 "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\PSFS_v1-2022"
	}
	

else if "`c(username)'"=="dibbo"{
	global psfs_v1 "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\01 PSFS-2024\PSFS_v1-2022"
	}	
	
else if "`c(username)'"=="User3"{
	global psfs_v1 "File-Path"
	}
	
di "`psfs_v1'"
	

* We will log in
capture log close 

log using "${log_files}psfs_compile.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

* Open the input dta file: 01.clean-data "02.psfs_deidentified"
use "${clean_dta}02.PSFS_clean_deidentified.dta", clear

* Appending PSFS and PSFS_v1 
append using "$psfs_v1\06.clean-data\02.PSFS_v1_clean_deidentified.dta", generate(append) force

* Saving this compiled PSFS dataset
save "${clean_dta}02.PSFS_clean_deidentified_compiled.dta", replace

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


save "${clean_dta}02.PSFS_clean_deidentified_compiled.dta", replace
