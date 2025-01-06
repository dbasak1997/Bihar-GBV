/*==============================================================================
File Name: Treatment identification do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	02/02/2023
Created by: Aadya Gupta
Updated on:	--
Updated by:	--

*Notes READ ME:
* This file retrieves PII information for treatment and control officers for Bhojpur.

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

**File Directory

*HP -- username for Aadya.
*AG -- temp username for Aadya.
*Acer -- username for Shubhro. 
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 
*NOTE: Please change pathway if you have copied pr moved this file.

if "`c(username)'"=="AG"{
	global dropbox "C:\Users\AG\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization-2022\01.Officer-Survey_Randomization\bhojpur-randomization"
	}
	
else if "`c(username)'"=="HP"{
	global dropbox "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization-2022\01.Officer-Survey_Randomization\bhojpur-randomization"
	}
	
else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Debiasing Police in India\005-Data-and-analysis-2022\Randomization-2022\01.Officer-Survey_Randomization\bhojpur-randomization"
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
global po_list "$dropbox\07.po-list\"


if "`c(username)'"=="AG"{
	global baseline "C:\Users\AG\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data"
	}
	
else if "`c(username)'"=="HP"{
	global baseline "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data"
	}
	
else if "`c(username)'"=="Acer"{
	global baseline "D:\Dropbox_SB\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data"
	}
else if "`c(username)'"=="User3"{
	global baseline "File-Path"
	}
	
di "`baseline'"


* We will log in
capture log close 

log using "${log_files}identification_bhojpur.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops

noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


* Importing the input dta file

import excel "${clean_dta}treatment-stations_bhojpur.xls", sheet("Sheet1") firstrow

save "${clean_dta}treatment-stations_bhojpur.dta", replace


* Merging the treatment list of police stations to PII baseline data to identify officers for training by station and determine their PII
clear 

use "$baseline\01.officersurvey_clean_PII.dta", clear 

* From the clean baseline PII, selecting Bhojpur district
keep if ps_dist == 1003

merge m:m ps_dist_id ps_name using "${clean_dta}treatment-stations_bhojpur.dta", force // All observations match


* Some basic checks
tab T, missing // No missing values

tab ps_dist_id, missing // No missing values

tab ps_name, missing // No missing values


/* FOR TREATMENT
* Saving the dataset that identifies officers to be trained in Patna

save "${po_list}1003_bhojpur-training.dta", replace

keep if T == 1

export excel gbv_uid ps_dist ps_series ps_dist_id ps_name po_name po_rank po_mobnum po_mobnum_alt T using "${po_list}1003_bhojpur-treatment.xls", firstrow(variables)
*/


/* FOR CONTROL
* Saving the dataset that identifies officers to be trained in Patna

save "${po_list}1003_bhojpur-control.dta", replace

keep if T == 0

export excel gbv_uid ps_dist ps_series ps_dist_id ps_name po_name po_rank po_mobnum po_mobnum_alt T using "${po_list}1003_bhojpur-control.xls", firstrow(variables)
*/
