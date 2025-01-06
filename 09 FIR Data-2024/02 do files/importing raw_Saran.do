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

log using "${log_files}importing FIR Data_Saran.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Saran\Amnaur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_11"
save "${intermediate_dta}Saran\ps2.dta", replace
clear

import delimited "${raw}\Saran\Awtarnagar PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_12"
save "${intermediate_dta}Saran\ps3.dta", replace
clear

import delimited "${raw}\Saran\Baniapur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_13"
save "${intermediate_dta}Saran\ps4.dta", replace
clear

import delimited "${raw}\Saran\Bhagwanbazar PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_15"
save "${intermediate_dta}Saran\ps6.dta", replace
clear

import delimited "${raw}\Saran\Bheldi PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_16"
save "${intermediate_dta}Saran\ps7.dta", replace
clear

import delimited "${raw}\Saran\Dariapur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_17"
save "${intermediate_dta}Saran\ps8.dta", replace
clear

import delimited "${raw}\Saran\Daudpur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_18"
save "${intermediate_dta}Saran\ps9.dta", replace
clear

import delimited "${raw}\Saran\Derni PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_19"
save "${intermediate_dta}Saran\ps10.dta", replace
clear

import delimited "${raw}\Saran\Dighwara PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_20"
save "${intermediate_dta}Saran\ps11.dta", replace
clear

import delimited "${raw}\Saran\Doriganj PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_21"
save "${intermediate_dta}Saran\ps12.dta", replace
clear

import delimited "${raw}\Saran\Ekma PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_22"
save "${intermediate_dta}Saran\ps13.dta", replace
clear

import delimited "${raw}\Saran\Garkha PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_23"
save "${intermediate_dta}Saran\ps14.dta", replace
clear

import delimited "${raw}\Saran\Isuapur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_26"
save "${intermediate_dta}Saran\ps17.dta", replace
clear

import delimited "${raw}\Saran\Jalalpur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_27"
save "${intermediate_dta}Saran\ps18.dta", replace
clear

import delimited "${raw}\Saran\Jantabazar PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_28"
save "${intermediate_dta}Saran\ps19.dta", replace
clear

import delimited "${raw}\Saran\Khaira PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_29"
save "${intermediate_dta}Saran\ps20.dta", replace
clear

import delimited "${raw}\Saran\kopa PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_30"
save "${intermediate_dta}Saran\ps21.dta", replace
clear

import delimited "${raw}\Saran\Maker PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_32"
save "${intermediate_dta}Saran\ps23.dta", replace
clear

import delimited "${raw}\Saran\Manjhi PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_33"
save "${intermediate_dta}Saran\ps24.dta", replace
clear

import delimited "${raw}\Saran\Marhaura PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_34"
save "${intermediate_dta}Saran\ps25.dta", replace
clear

import delimited "${raw}\Saran\Masrakh PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_35"
save "${intermediate_dta}Saran\ps26.dta", replace
clear

import delimited "${raw}\Saran\Muffasil PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_36"
save "${intermediate_dta}Saran\ps27.dta", replace
clear

import delimited "${raw}\Saran\Nayagaon PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_38"
save "${intermediate_dta}Saran\ps29.dta", replace
clear

import delimited "${raw}\Saran\Panapur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_40"
save "${intermediate_dta}Saran\ps31.dta", replace
clear

import delimited "${raw}\Saran\Parsa PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_41"
save "${intermediate_dta}Saran\ps32.dta", replace
clear

import delimited "${raw}\Saran\Rasulpur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_43"
save "${intermediate_dta}Saran\ps34.dta", replace
clear

import delimited "${raw}\Saran\Rivelganj PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_44"
save "${intermediate_dta}Saran\ps35.dta", replace
clear

import delimited "${raw}\Saran\Sahajitpur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_45"
save "${intermediate_dta}Saran\ps36.dta", replace
clear

import delimited "${raw}\Saran\Sonpur PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_47"
save "${intermediate_dta}Saran\ps38.dta", replace
clear

import delimited "${raw}\Saran\Taraiya PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_48"
save "${intermediate_dta}Saran\ps39.dta", replace
clear

import delimited "${raw}\Saran\Town PS.csv"
gen ps_dist = 1009
gen ps_dist_id = "1009_49"
save "${intermediate_dta}Saran\ps40.dta", replace
clear

use "${intermediate_dta}Saran\ps2.dta", clear
append using "${intermediate_dta}Saran\ps3.dta"
append using "${intermediate_dta}Saran\ps4.dta"
append using "${intermediate_dta}Saran\ps6.dta"
append using "${intermediate_dta}Saran\ps7.dta"
append using "${intermediate_dta}Saran\ps8.dta"
append using "${intermediate_dta}Saran\ps9.dta"
append using "${intermediate_dta}Saran\ps10.dta"
append using "${intermediate_dta}Saran\ps11.dta"
append using "${intermediate_dta}Saran\ps12.dta"
append using "${intermediate_dta}Saran\ps13.dta"
append using "${intermediate_dta}Saran\ps14.dta"
append using "${intermediate_dta}Saran\ps17.dta"
append using "${intermediate_dta}Saran\ps18.dta"
append using "${intermediate_dta}Saran\ps19.dta"
append using "${intermediate_dta}Saran\ps20.dta"
append using "${intermediate_dta}Saran\ps21.dta"
append using "${intermediate_dta}Saran\ps23.dta"
append using "${intermediate_dta}Saran\ps24.dta"
append using "${intermediate_dta}Saran\ps25.dta"
append using "${intermediate_dta}Saran\ps26.dta"
append using "${intermediate_dta}Saran\ps27.dta"
append using "${intermediate_dta}Saran\ps29.dta"
append using "${intermediate_dta}Saran\ps31.dta"
append using "${intermediate_dta}Saran\ps32.dta"
append using "${intermediate_dta}Saran\ps34.dta"
append using "${intermediate_dta}Saran\ps35.dta"
append using "${intermediate_dta}Saran\ps36.dta"
append using "${intermediate_dta}Saran\ps38.dta"
append using "${intermediate_dta}Saran\ps39.dta"
append using "${intermediate_dta}Saran\ps40.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Saran_FIR.dta", replace
