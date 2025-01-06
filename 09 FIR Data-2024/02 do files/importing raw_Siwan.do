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

log using "${log_files}importing FIR Data_Siwan.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Siwan\Andar PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_10"
save "${intermediate_dta}Siwan\ps1.dta", replace
clear

import delimited "${raw}\Siwan\Asanwa PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_11"
save "${intermediate_dta}Siwan\ps2.dta", replace
clear

import delimited "${raw}\Siwan\Barharia PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_12"
save "${intermediate_dta}Siwan\ps3.dta", replace
clear

import delimited "${raw}\Siwan\Basantpur PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_13"
save "${intermediate_dta}Siwan\ps4.dta", replace
clear

import delimited "${raw}\Siwan\Bhagwanpur hat PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_14"
save "${intermediate_dta}Siwan\ps5.dta", replace
clear

import delimited "${raw}\Siwan\Darauli PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_16"
save "${intermediate_dta}Siwan\ps7.dta", replace
clear

import delimited "${raw}\Siwan\Daraunda PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_17"
save "${intermediate_dta}Siwan\ps8.dta", replace
clear

import delimited "${raw}\Siwan\G. B.  Nagar Tarbara PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_19"
save "${intermediate_dta}Siwan\ps10.dta", replace
clear

import delimited "${raw}\Siwan\Gauriyakothi PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_20"
save "${intermediate_dta}Siwan\ps11.dta", replace
clear

import delimited "${raw}\Siwan\Guthani PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_21"
save "${intermediate_dta}Siwan\ps12.dta", replace
clear

import delimited "${raw}\Siwan\Husainganj PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_22"
save "${intermediate_dta}Siwan\ps13.dta", replace
clear

import delimited "${raw}\Siwan\Jammbo bazar PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_23"
save "${intermediate_dta}Siwan\ps14.dta", replace
clear

import delimited "${raw}\Siwan\Jiradai PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_24"
save "${intermediate_dta}Siwan\ps15.dta", replace
clear

import delimited "${raw}\Siwan\M. H. Nagar PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_26"
save "${intermediate_dta}Siwan\ps17.dta", replace
clear

import delimited "${raw}\Siwan\Maharajganj PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_28"
save "${intermediate_dta}Siwan\ps19.dta", replace
clear

import delimited "${raw}\Siwan\Mairwan PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_30"
save "${intermediate_dta}Siwan\ps21.dta", replace
clear

import delimited "${raw}\Siwan\Muffasil PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_31"
save "${intermediate_dta}Siwan\ps22.dta", replace
clear

import delimited "${raw}\Siwan\Nautan PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_32"
save "${intermediate_dta}Siwan\ps23.dta", replace
clear

import delimited "${raw}\Siwan\Panchrukhi PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_33"
save "${intermediate_dta}Siwan\ps24.dta", replace
clear

import delimited "${raw}\Siwan\Raghunathpur PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_34"
save "${intermediate_dta}Siwan\ps25.dta", replace
clear

import delimited "${raw}\Siwan\Siswan PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_37"
save "${intermediate_dta}Siwan\ps28.dta", replace
clear

import delimited "${raw}\Siwan\Town PS.csv"
gen ps_dist = 1011
gen ps_dist_id = "1011_39"
save "${intermediate_dta}Siwan\ps30.dta", replace
clear

use "${intermediate_dta}Siwan\ps1.dta", clear
append using "${intermediate_dta}Siwan\ps2.dta"
append using "${intermediate_dta}Siwan\ps3.dta"
append using "${intermediate_dta}Siwan\ps4.dta"
append using "${intermediate_dta}Siwan\ps5.dta"
append using "${intermediate_dta}Siwan\ps7.dta"
append using "${intermediate_dta}Siwan\ps8.dta"
append using "${intermediate_dta}Siwan\ps10.dta"
append using "${intermediate_dta}Siwan\ps11.dta"
append using "${intermediate_dta}Siwan\ps12.dta"
append using "${intermediate_dta}Siwan\ps13.dta"
append using "${intermediate_dta}Siwan\ps14.dta"
append using "${intermediate_dta}Siwan\ps15.dta"
append using "${intermediate_dta}Siwan\ps17.dta"
append using "${intermediate_dta}Siwan\ps19.dta"
append using "${intermediate_dta}Siwan\ps21.dta"
append using "${intermediate_dta}Siwan\ps22.dta"
append using "${intermediate_dta}Siwan\ps23.dta"
append using "${intermediate_dta}Siwan\ps24.dta"
append using "${intermediate_dta}Siwan\ps25.dta"
append using "${intermediate_dta}Siwan\ps28.dta"
append using "${intermediate_dta}Siwan\ps30.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Siwan_FIR.dta", replace
