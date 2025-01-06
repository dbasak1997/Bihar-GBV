/*==============================================================================
File Name: Merge randomisation do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	20/01/2022
Created by: Aadya Gupta
Updated on:	--
Updated by:	--

*Notes READ ME:
*This is the Do file to merge the results of randomisation to the PII baseline data. 

*	Inputs: 06.clean-data/psfs-officer_merged  "1008_patna-merged", 00.raw-data "list_patna" 
*	Outputs: 06.clean-data  "1008_patna-training"

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
	global dropbox "C:\Users\AG\Dropbox\GBV_AG_SB\Randomisation_WIP"
	}
	
else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\GBV_AG_SB\Randomisation_WIP"
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


* We will log in
capture log close 

log using "${log_files}merge_randomisation.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops

noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


/* Please note: This file will 
*/

* 1008 Patna

* Importing the input dta file: 00.raw-data "list_patna"

import delimited "C:\Users\AG\Dropbox\GBV_AG_SB\Randomisation_WIP\00.raw-data\list_patna.csv"

save "$dropbox\02.intermediate-data\list_patna.dta", replace


* Merging the treatment list of thanas to PII baseline data to identify officers for training by station and determine their PII
clear 

use "C:\Users\AG\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data\01.officersurvey_clean_PII.dta" 

* From the clean baseline PII, selecting Patna district
keep if ps_dist == 1008

merge m:m ps_dist_id ps_name using "$dropbox\02.intermediate-data\list_patna.dta", force

* _merge==1 and _merge==2, so something doesn't add up
sort ps_name

list ps_name _merge if _merge == 1
list ps_name _merge if _merge == 2
/* Malsalami PS seems to be the problem for both values of the _merge variable.
AG went back to the the master file and using file for this merge- both record 679 observations for Patna. 
The resultant merge file records 690 observations for Patna. Sure enough, when all files are checked for Malsalami PS, the master file and using files show only 11 observations for Malsalami PS, while the merged file has 22 observations for Malsalami PS.
*/
tab ps_name t, missing


* Here, you see that Malsalami PS has 11 observations where treatment status is assigned and 11 observations with missing treatment status. Dropping the observations with missing ps_series should fix the issue.

drop if ps_series == ""
* Now we have 679 observations, same as the observations recorded in the baseline for Patna.

tab ps_name t, missing
*Unfortunately, we have a missing treatment status for Malsalami PS. Checking and assigning the treatment status == 0 from SA's list.
replace t = 0 if t == .

tab ps_name t, missing
* No missing values now!

drop _merge


* FOR TREATMENT
* Saving the dataset that identifies officers to be trained in Patna

save "$dropbox\06.clean-data\1008_patna-training.dta", replace

keep if t == 1

export delimited gbv_uid ps_dist ps_series ps_dist_id ps_name po_name po_rank po_mobnum po_mobnum_alt t using "C:\Users\AG\Dropbox\GBV_AG_SB\Randomisation_WIP\06.clean-data\1008_patna-treatment.csv", replace

/* FOR CONTROL
* Saving the dataset that identifies offcieers to be trained in Patna

save "$dropbox\06.clean-data\1008_patna-control.dta", replace

keep if t == 0

export delimited gbv_uid ps_dist ps_series ps_dist_id ps_name po_name po_rank po_mobnum po_mobnum_alt t using "C:\Users\AG\Dropbox\GBV_AG_SB\Randomisation_WIP\06.clean-data\1008_patna-control.csv", replace

