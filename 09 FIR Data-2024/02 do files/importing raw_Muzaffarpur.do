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

log using "${log_files}importing FIR Data_Muzaffarpur.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Muzaffarpur\Ahiapur PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_10"
save "${intermediate_dta}Muzaffarpur\ps1.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Aurai PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_12"
save "${intermediate_dta}Muzaffarpur\ps3.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Barhmpura PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_13"
save "${intermediate_dta}Muzaffarpur\ps4.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Baruraj PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_15"
save "${intermediate_dta}Muzaffarpur\ps6.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Bela PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_16"
save "${intermediate_dta}Muzaffarpur\ps7.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Bochha PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_18"
save "${intermediate_dta}Muzaffarpur\ps9.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Deoria PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_19"
save "${intermediate_dta}Muzaffarpur\ps10.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Gayghat PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_21"
save "${intermediate_dta}Muzaffarpur\ps12.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Hathauri PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_22"
save "${intermediate_dta}Muzaffarpur\ps13.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Kanti PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_25"
save "${intermediate_dta}Muzaffarpur\ps16.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Karja PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_26"
save "${intermediate_dta}Muzaffarpur\ps17.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Kathaiya PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_27"
save "${intermediate_dta}Muzaffarpur\ps18.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Katra PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_28"
save "${intermediate_dta}Muzaffarpur\ps19.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Kazi Mohammadpur PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_29"
save "${intermediate_dta}Muzaffarpur\ps20.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Kurhni PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_31"
save "${intermediate_dta}Muzaffarpur\ps22.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Maniyari PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_33"
save "${intermediate_dta}Muzaffarpur\ps24.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Minapur PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_34"
save "${intermediate_dta}Muzaffarpur\ps25.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Mithanpura PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_35"
save "${intermediate_dta}Muzaffarpur\ps26.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Motipur PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_36"
save "${intermediate_dta}Muzaffarpur\ps27.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Mushari PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_37"
save "${intermediate_dta}Muzaffarpur\ps28.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Paru PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_40"
save "${intermediate_dta}Muzaffarpur\ps31.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Piyar PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_41"
save "${intermediate_dta}Muzaffarpur\ps32.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Sadar PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_42"
save "${intermediate_dta}Muzaffarpur\ps33.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Sahebganj PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_43"
save "${intermediate_dta}Muzaffarpur\ps34.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Sakra PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_44"
save "${intermediate_dta}Muzaffarpur\ps35.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Saraiya PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_45"
save "${intermediate_dta}Muzaffarpur\ps36.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Siwaipatti PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_48"
save "${intermediate_dta}Muzaffarpur\ps39.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Town  PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_49"
save "${intermediate_dta}Muzaffarpur\ps40.dta", replace
clear

import delimited "${raw}\Muzaffarpur\Vishwavidyalay PS.csv"
gen ps_dist = 1006
gen ps_dist_id = "1006_51"
save "${intermediate_dta}Muzaffarpur\ps42.dta", replace
clear

use "${intermediate_dta}Muzaffarpur\ps1.dta", clear
append using "${intermediate_dta}Muzaffarpur\ps3.dta"
append using "${intermediate_dta}Muzaffarpur\ps4.dta"
append using "${intermediate_dta}Muzaffarpur\ps6.dta"
append using "${intermediate_dta}Muzaffarpur\ps7.dta"
append using "${intermediate_dta}Muzaffarpur\ps9.dta"
append using "${intermediate_dta}Muzaffarpur\ps12.dta"
append using "${intermediate_dta}Muzaffarpur\ps13.dta"
append using "${intermediate_dta}Muzaffarpur\ps16.dta"
append using "${intermediate_dta}Muzaffarpur\ps17.dta"
append using "${intermediate_dta}Muzaffarpur\ps18.dta"
append using "${intermediate_dta}Muzaffarpur\ps19.dta"
append using "${intermediate_dta}Muzaffarpur\ps20.dta"
append using "${intermediate_dta}Muzaffarpur\ps22.dta"
append using "${intermediate_dta}Muzaffarpur\ps24.dta"
append using "${intermediate_dta}Muzaffarpur\ps25.dta"
append using "${intermediate_dta}Muzaffarpur\ps26.dta"
append using "${intermediate_dta}Muzaffarpur\ps27.dta"
append using "${intermediate_dta}Muzaffarpur\ps28.dta"
append using "${intermediate_dta}Muzaffarpur\ps31.dta"
append using "${intermediate_dta}Muzaffarpur\ps32.dta"
append using "${intermediate_dta}Muzaffarpur\ps33.dta"
append using "${intermediate_dta}Muzaffarpur\ps34.dta"
append using "${intermediate_dta}Muzaffarpur\ps35.dta"
append using "${intermediate_dta}Muzaffarpur\ps36.dta"
append using "${intermediate_dta}Muzaffarpur\ps39.dta"
append using "${intermediate_dta}Muzaffarpur\ps40.dta"
append using "${intermediate_dta}Muzaffarpur\ps42.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Muzaffarpur_FIR.dta", replace
