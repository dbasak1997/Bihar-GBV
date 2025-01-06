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

log using "${log_files}importing FIR Data_Bettiah.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Bettiah\Bairiya PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_10"
save "${intermediate_dta}Bettiah\ps1.dta", replace
clear

import delimited "${raw}\Bettiah\Balthar PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_11"
save "${intermediate_dta}Bettiah\ps2.dta", replace
clear

import delimited "${raw}\Bettiah\Bhangaha PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_12"
save "${intermediate_dta}Bettiah\ps4.dta", replace
clear

import delimited "${raw}\Bettiah\Chanpatia PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_16"
save "${intermediate_dta}Bettiah\ps6.dta", replace
clear

import delimited "${raw}\Bettiah\Gaunaha PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_17"
save "${intermediate_dta}Bettiah\ps7.dta", replace
clear

import delimited "${raw}\Bettiah\Gopalpur PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_18"
save "${intermediate_dta}Bettiah\ps8.dta", replace
clear

import delimited "${raw}\Bettiah\Inarwa PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_19"
save "${intermediate_dta}Bettiah\ps9.dta", replace
clear

import delimited "${raw}\Bettiah\Kangli PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_22"
save "${intermediate_dta}Bettiah\ps12.dta", replace
clear

import delimited "${raw}\Bettiah\Lauria PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_24"
save "${intermediate_dta}Bettiah\ps14.dta", replace
clear

import delimited "${raw}\Bettiah\Mainatand PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_26"
save "${intermediate_dta}Bettiah\ps16.dta", replace
clear

import delimited "${raw}\Bettiah\Majhaulia PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_27"
save "${intermediate_dta}Bettiah\ps17.dta", replace
clear

import delimited "${raw}\Bettiah\Manpur PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_28"
save "${intermediate_dta}Bettiah\ps18.dta", replace
clear

import delimited "${raw}\Bettiah\Matiyaria PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_30"
save "${intermediate_dta}Bettiah\ps20.dta", replace
clear

import delimited "${raw}\Bettiah\Muffasil PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_31"
save "${intermediate_dta}Bettiah\ps21.dta", replace
clear

import delimited "${raw}\Bettiah\Nautan PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_33"
save "${intermediate_dta}Bettiah\ps23.dta", replace
clear

import delimited "${raw}\Bettiah\Purushottampur PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_35"
save "${intermediate_dta}Bettiah\ps25.dta", replace
clear

import delimited "${raw}\Bettiah\Sahodra PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_36"
save "${intermediate_dta}Bettiah\ps26.dta", replace
clear

import delimited "${raw}\Bettiah\Shathi PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_39"
save "${intermediate_dta}Bettiah\ps29.dta", replace
clear

import delimited "${raw}\Bettiah\Shikarpur PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_40"
save "${intermediate_dta}Bettiah\ps30.dta", replace
clear

import delimited "${raw}\Bettiah\Sikta PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_42"
save "${intermediate_dta}Bettiah\ps32.dta", replace
clear

import delimited "${raw}\Bettiah\Srinagar PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_44"
save "${intermediate_dta}Bettiah\ps34.dta", replace
clear

import delimited "${raw}\Bettiah\Town PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_45"
save "${intermediate_dta}Bettiah\ps35.dta", replace
clear

import delimited "${raw}\Bettiah\Yogapatti PS.csv"
gen ps_dist = 1002
gen ps_dist_id = "1002_46"
save "${intermediate_dta}Bettiah\ps36.dta", replace
clear

use "${intermediate_dta}Bettiah\ps1.dta", clear
append using "${intermediate_dta}Bettiah\ps2.dta"
append using "${intermediate_dta}Bettiah\ps4.dta"
append using "${intermediate_dta}Bettiah\ps6.dta"
append using "${intermediate_dta}Bettiah\ps7.dta"
append using "${intermediate_dta}Bettiah\ps8.dta"
append using "${intermediate_dta}Bettiah\ps9.dta"
append using "${intermediate_dta}Bettiah\ps12.dta"
append using "${intermediate_dta}Bettiah\ps14.dta"
append using "${intermediate_dta}Bettiah\ps16.dta"
append using "${intermediate_dta}Bettiah\ps17.dta"
append using "${intermediate_dta}Bettiah\ps18.dta"
append using "${intermediate_dta}Bettiah\ps20.dta"
append using "${intermediate_dta}Bettiah\ps21.dta"
append using "${intermediate_dta}Bettiah\ps23.dta"
append using "${intermediate_dta}Bettiah\ps25.dta"
append using "${intermediate_dta}Bettiah\ps26.dta"
append using "${intermediate_dta}Bettiah\ps29.dta"
append using "${intermediate_dta}Bettiah\ps30.dta"
append using "${intermediate_dta}Bettiah\ps32.dta"
append using "${intermediate_dta}Bettiah\ps34.dta"
append using "${intermediate_dta}Bettiah\ps35.dta"
append using "${intermediate_dta}Bettiah\ps36.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
replace district = "Bettiah" if district == "West Champaran"
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Bettiah_FIR.dta", replace
