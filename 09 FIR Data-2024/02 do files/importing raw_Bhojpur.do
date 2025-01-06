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

log using "${log_files}importing FIR Data_Bhojpur.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Bhojpur\Agiaon Bazar PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_10"
save "${intermediate_dta}Bhojpur\ps1.dta", replace
clear

import delimited "${raw}\Bhojpur\Ayar PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_11"
save "${intermediate_dta}Bhojpur\ps2.dta", replace
clear

import delimited "${raw}\Bhojpur\Azimabad PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_12"
save "${intermediate_dta}Bhojpur\ps3.dta", replace
clear

import delimited "${raw}\Bhojpur\Barhara PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_14"
save "${intermediate_dta}Bhojpur\ps5.dta", replace
clear

import delimited "${raw}\Bhojpur\Bihia PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_15"
save "${intermediate_dta}Bhojpur\ps7.dta", replace
clear

import delimited "${raw}\Bhojpur\Chandi PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_17"
save "${intermediate_dta}Bhojpur\ps8.dta", replace
clear

import delimited "${raw}\Bhojpur\Charpokhari PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_18"
save "${intermediate_dta}Bhojpur\ps9.dta", replace
clear

import delimited "${raw}\Bhojpur\Chauri PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_19"
save "${intermediate_dta}Bhojpur\ps10.dta", replace
clear

import delimited "${raw}\Bhojpur\Dhangai PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_20"
save "${intermediate_dta}Bhojpur\ps11.dta", replace
clear

import delimited "${raw}\Bhojpur\Imadpur PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_26"
save "${intermediate_dta}Bhojpur\ps17.dta", replace
clear

import delimited "${raw}\Bhojpur\Jagdishpur PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_27"
save "${intermediate_dta}Bhojpur\ps18.dta", replace
clear

import delimited "${raw}\Bhojpur\Koilwar PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_31"
save "${intermediate_dta}Bhojpur\ps22.dta", replace
clear

import delimited "${raw}\Bhojpur\Muffassil PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_35"
save "${intermediate_dta}Bhojpur\ps26.dta", replace
clear

import delimited "${raw}\Bhojpur\Narainpur PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_36"
save "${intermediate_dta}Bhojpur\ps27.dta", replace
clear

import delimited "${raw}\Bhojpur\Nawada PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_37"
save "${intermediate_dta}Bhojpur\ps28.dta", replace
clear

import delimited "${raw}\Bhojpur\Pawana PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_38"
save "${intermediate_dta}Bhojpur\ps29.dta", replace
clear

import delimited "${raw}\Bhojpur\Piro PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_40"
save "${intermediate_dta}Bhojpur\ps31.dta", replace
clear

import delimited "${raw}\Bhojpur\Sahar PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_42"
save "${intermediate_dta}Bhojpur\ps33.dta", replace
clear

import delimited "${raw}\Bhojpur\Sandesh PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_43"
save "${intermediate_dta}Bhojpur\ps34.dta", replace
clear

import delimited "${raw}\Bhojpur\Shahpur PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_44"
save "${intermediate_dta}Bhojpur\ps35.dta", replace
clear

import delimited "${raw}\Bhojpur\Sikarhatta PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_45"
save "${intermediate_dta}Bhojpur\ps36.dta", replace
clear

import delimited "${raw}\Bhojpur\Tarari PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_47"
save "${intermediate_dta}Bhojpur\ps38.dta", replace
clear

import delimited "${raw}\Bhojpur\Tiyar PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_48"
save "${intermediate_dta}Bhojpur\ps39.dta", replace
clear

import delimited "${raw}\Bhojpur\Town PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_49"
save "${intermediate_dta}Bhojpur\ps40.dta", replace
clear

import delimited "${raw}\Bhojpur\Udwant Nagar PS.csv"
gen ps_dist = 1003
gen ps_dist_id = "1003_51"
save "${intermediate_dta}Bhojpur\ps42.dta", replace
clear

use "${intermediate_dta}Bhojpur\ps1.dta", clear
append using "${intermediate_dta}Bhojpur\ps2.dta"
append using "${intermediate_dta}Bhojpur\ps3.dta"
append using "${intermediate_dta}Bhojpur\ps5.dta"
append using "${intermediate_dta}Bhojpur\ps7.dta"
append using "${intermediate_dta}Bhojpur\ps8.dta"
append using "${intermediate_dta}Bhojpur\ps9.dta"
append using "${intermediate_dta}Bhojpur\ps10.dta"
append using "${intermediate_dta}Bhojpur\ps11.dta"
append using "${intermediate_dta}Bhojpur\ps17.dta"
append using "${intermediate_dta}Bhojpur\ps18.dta"
append using "${intermediate_dta}Bhojpur\ps22.dta"
append using "${intermediate_dta}Bhojpur\ps26.dta"
append using "${intermediate_dta}Bhojpur\ps27.dta"
append using "${intermediate_dta}Bhojpur\ps28.dta"
append using "${intermediate_dta}Bhojpur\ps29.dta"
append using "${intermediate_dta}Bhojpur\ps31.dta"
append using "${intermediate_dta}Bhojpur\ps33.dta"
append using "${intermediate_dta}Bhojpur\ps34.dta"
append using "${intermediate_dta}Bhojpur\ps35.dta"
append using "${intermediate_dta}Bhojpur\ps36.dta"
append using "${intermediate_dta}Bhojpur\ps38.dta"
append using "${intermediate_dta}Bhojpur\ps39.dta"
append using "${intermediate_dta}Bhojpur\ps40.dta"
append using "${intermediate_dta}Bhojpur\ps42.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Bhojpur_FIR.dta", replace
