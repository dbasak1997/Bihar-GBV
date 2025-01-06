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

log using "${log_files}importing FIR Data_Vaishali.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Vaishali\Adhyogik PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_10"
save "${intermediate_dta}Vaishali\ps1.dta", replace
clear

import delimited "${raw}\Vaishali\Baligaon PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_11"
save "${intermediate_dta}Vaishali\ps2.dta", replace
clear

import delimited "${raw}\Vaishali\Bhagwanpur PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_14"
save "${intermediate_dta}Vaishali\ps5.dta", replace
clear

import delimited "${raw}\Vaishali\Bidupur PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_15"
save "${intermediate_dta}Vaishali\ps6.dta", replace
clear

import delimited "${raw}\Vaishali\Desri PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_17"
save "${intermediate_dta}Vaishali\ps8.dta", replace
clear

import delimited "${raw}\Vaishali\Gangabridge PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_18"
save "${intermediate_dta}Vaishali\ps9.dta", replace
clear

import delimited "${raw}\Vaishali\Goraul PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_19"
save "${intermediate_dta}Vaishali\ps10.dta", replace
clear

import delimited "${raw}\Vaishali\Hajipur Sadar PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_20"
save "${intermediate_dta}Vaishali\ps11.dta", replace
clear

import delimited "${raw}\Vaishali\Jandaha PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_21"
save "${intermediate_dta}Vaishali\ps12.dta", replace
clear

import delimited "${raw}\Vaishali\Jurawanpur PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_22"
save "${intermediate_dta}Vaishali\ps13.dta", replace
clear

import delimited "${raw}\Vaishali\Kartahan PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_23"
save "${intermediate_dta}Vaishali\ps14.dta", replace
clear

import delimited "${raw}\Vaishali\Lalganj PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_25"
save "${intermediate_dta}Vaishali\ps16.dta", replace
clear

import delimited "${raw}\Vaishali\Mahnar PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_27"
save "${intermediate_dta}Vaishali\ps18.dta", replace
clear

import delimited "${raw}\Vaishali\Mahua PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_28"
save "${intermediate_dta}Vaishali\ps19.dta", replace
clear

import delimited "${raw}\Vaishali\Patepur PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_29"
save "${intermediate_dta}Vaishali\ps20.dta", replace
clear

import delimited "${raw}\Vaishali\Raghopur PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_30"
save "${intermediate_dta}Vaishali\ps21.dta", replace
clear

import delimited "${raw}\Vaishali\Rajapakar PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_31"
save "${intermediate_dta}Vaishali\ps22.dta", replace
clear

import delimited "${raw}\Vaishali\Sarai PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_35"
save "${intermediate_dta}Vaishali\ps26.dta", replace
clear

import delimited "${raw}\Vaishali\Tisiauta PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_36"
save "${intermediate_dta}Vaishali\ps27.dta", replace
clear

import delimited "${raw}\Vaishali\Town PS..csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_37"
save "${intermediate_dta}Vaishali\ps28.dta", replace
clear

import delimited "${raw}\Vaishali\Vaishali PS.csv"
gen ps_dist = 1012
gen ps_dist_id = "1012_39"
save "${intermediate_dta}Vaishali\ps30.dta", replace
clear

use "${intermediate_dta}Vaishali\ps1.dta", clear
append using "${intermediate_dta}Vaishali\ps2.dta"
append using "${intermediate_dta}Vaishali\ps5.dta"
append using "${intermediate_dta}Vaishali\ps6.dta"
append using "${intermediate_dta}Vaishali\ps8.dta"
append using "${intermediate_dta}Vaishali\ps9.dta"
append using "${intermediate_dta}Vaishali\ps10.dta"
append using "${intermediate_dta}Vaishali\ps11.dta"
append using "${intermediate_dta}Vaishali\ps12.dta"
append using "${intermediate_dta}Vaishali\ps13.dta"
append using "${intermediate_dta}Vaishali\ps14.dta"
append using "${intermediate_dta}Vaishali\ps16.dta"
append using "${intermediate_dta}Vaishali\ps18.dta"
append using "${intermediate_dta}Vaishali\ps19.dta"
append using "${intermediate_dta}Vaishali\ps20.dta"
append using "${intermediate_dta}Vaishali\ps21.dta"
append using "${intermediate_dta}Vaishali\ps22.dta"
append using "${intermediate_dta}Vaishali\ps26.dta"
append using "${intermediate_dta}Vaishali\ps27.dta"
append using "${intermediate_dta}Vaishali\ps28.dta"
append using "${intermediate_dta}Vaishali\ps30.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Vaishali_FIR.dta", replace
