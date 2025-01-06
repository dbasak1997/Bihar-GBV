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

*dibbo -- username for Dibyajyoti.
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 

if "`c(username)'"=="HP"{
	global dropbox "C:\Users\HP\Dropbox\"
	}
else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\RA-GBV-2023\005-Data-and-analysis-2022\FIR Data-2024"
	}	
/*enter the main folder for the project in Dropbox as per your system*/	
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}

di "`dropbox'"
	
*File Path
/*enter the local names for the different folders, create the folders if they don't exist*/
global raw "$dropbox\01 raw data"
global do_files "$dropbox\02 do files"
global intermediate_dta "$dropbox\03 intermediate\"
*global tables "$dropbox\03.tables\"
*global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\04 log files\"
global clean_dta "$dropbox\05 clean data\"


* We will log in
capture log close 

log using "${log_files}importing FIR Data_Bagaha.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Bagaha\Bagaha PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_10"
save "${intermediate_dta}Bagaha\ps1.dta", replace
clear

import delimited "${raw}\Bagaha\Balmikinagar PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_11"
save "${intermediate_dta}Bagaha\ps2.dta", replace
clear

import delimited "${raw}\Bagaha\Bhitaha PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_14"
save "${intermediate_dta}Bagaha\ps4.dta", replace
clear

import delimited "${raw}\Bagaha\Chautarva PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_15"
save "${intermediate_dta}Bagaha\ps5.dta", replace
clear

import delimited "${raw}\Bagaha\Dhanha PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_17"
save "${intermediate_dta}Bagaha\ps7.dta", replace
clear

import delimited "${raw}\Bagaha\Gobardhana PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_18"
save "${intermediate_dta}Bagaha\ps8.dta", replace
clear

import delimited "${raw}\Bagaha\Gobrahia PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_19"
save "${intermediate_dta}Bagaha\ps9.dta", replace
clear

import delimited "${raw}\Bagaha\Laukaria PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_20"
save "${intermediate_dta}Bagaha\ps10.dta", replace
clear

import delimited "${raw}\Bagaha\Nadi PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_26"
save "${intermediate_dta}Bagaha\ps16.dta", replace
clear

import delimited "${raw}\Bagaha\Naurangia PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_22"
save "${intermediate_dta}Bagaha\ps12.dta", replace
clear

import delimited "${raw}\Bagaha\Piprasi PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_24"
save "${intermediate_dta}Bagaha\ps14.dta", replace
clear

import delimited "${raw}\Bagaha\Ramnagar PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_25"
save "${intermediate_dta}Bagaha\ps15.dta", replace
clear

import delimited "${raw}\Bagaha\Semra PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_28"
save "${intermediate_dta}Bagaha\ps18.dta", replace
clear

import delimited "${raw}\Bagaha\Thakraha PS.csv"
gen ps_dist = 1001
gen ps_dist_id = "1001_29"
save "${intermediate_dta}Bagaha\ps19.dta", replace
clear

use "${intermediate_dta}Bagaha\ps1.dta", clear
append using "${intermediate_dta}Bagaha\ps2.dta"
append using "${intermediate_dta}Bagaha\ps4.dta"
append using "${intermediate_dta}Bagaha\ps5.dta"
append using "${intermediate_dta}Bagaha\ps7.dta"
append using "${intermediate_dta}Bagaha\ps8.dta"
append using "${intermediate_dta}Bagaha\ps9.dta"
append using "${intermediate_dta}Bagaha\ps10.dta"
append using "${intermediate_dta}Bagaha\ps12.dta"
append using "${intermediate_dta}Bagaha\ps14.dta"
append using "${intermediate_dta}Bagaha\ps15.dta"
append using "${intermediate_dta}Bagaha\ps16.dta"
append using "${intermediate_dta}Bagaha\ps18.dta"
append using "${intermediate_dta}Bagaha\ps19.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Bagaha_FIR.dta", replace
