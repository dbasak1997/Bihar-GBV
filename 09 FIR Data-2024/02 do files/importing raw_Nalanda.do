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

log using "${log_files}importing FIR Data_Nalanda.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Nalanda\Ashthawan PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_10"
save "${intermediate_dta}Nalanda\ps1.dta", replace
clear

import delimited "${raw}\Nalanda\Aungari PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_11"
save "${intermediate_dta}Nalanda\ps2.dta", replace
clear

import delimited "${raw}\Nalanda\Ben PS..csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_12"
save "${intermediate_dta}Nalanda\ps3.dta", replace
clear

import delimited "${raw}\Nalanda\Bena PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_13"
save "${intermediate_dta}Nalanda\ps4.dta", replace
clear

import delimited "${raw}\Nalanda\Bhaganbigha O. P..csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_14"
save "${intermediate_dta}Nalanda\ps5.dta", replace
clear

import delimited "${raw}\Nalanda\Biharsharif PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_15"
save "${intermediate_dta}Nalanda\ps6.dta", replace
clear

import delimited "${raw}\Nalanda\Bind PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_16"
save "${intermediate_dta}Nalanda\ps7.dta", replace
clear

import delimited "${raw}\Nalanda\Chandi PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_17"
save "${intermediate_dta}Nalanda\ps8.dta", replace
clear

import delimited "${raw}\Nalanda\Chero O. P..csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_18"
save "${intermediate_dta}Nalanda\ps9.dta", replace
clear

import delimited "${raw}\Nalanda\Chhabilapur PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_19"
save "${intermediate_dta}Nalanda\ps10.dta", replace
clear

import delimited "${raw}\Nalanda\Chiksora PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_20"
save "${intermediate_dta}Nalanda\ps11.dta", replace
clear

import delimited "${raw}\Nalanda\Dipnagar PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_21"
save "${intermediate_dta}Nalanda\ps12.dta", replace
clear

import delimited "${raw}\Nalanda\Ekangarsarai PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_22"
save "${intermediate_dta}Nalanda\ps13.dta", replace
clear

import delimited "${raw}\Nalanda\Giryak PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_23"
save "${intermediate_dta}Nalanda\ps14.dta", replace
clear

import delimited "${raw}\Nalanda\Gokhulpur PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_24"
save "${intermediate_dta}Nalanda\ps15.dta", replace
clear

import delimited "${raw}\Nalanda\Harnaut PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_25"
save "${intermediate_dta}Nalanda\ps16.dta", replace
clear

import delimited "${raw}\Nalanda\Hilsha PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_26"
save "${intermediate_dta}Nalanda\ps17.dta", replace
clear

import delimited "${raw}\Nalanda\Islampur PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_28"
save "${intermediate_dta}Nalanda\ps19.dta", replace
clear

import delimited "${raw}\Nalanda\Karai Parsurai PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_30"
save "${intermediate_dta}Nalanda\ps21.dta", replace
clear

import delimited "${raw}\Nalanda\Katrisarai PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_32"
save "${intermediate_dta}Nalanda\ps23.dta", replace
clear

import delimited "${raw}\Nalanda\Khudaganj PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_33"
save "${intermediate_dta}Nalanda\ps24.dta", replace
clear

import delimited "${raw}\Nalanda\Lehri PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_34"
save "${intermediate_dta}Nalanda\ps25.dta", replace
clear

import delimited "${raw}\Nalanda\Manpur PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_36"
save "${intermediate_dta}Nalanda\ps27.dta", replace
clear

import delimited "${raw}\Nalanda\Nagar Nausa PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_38"
save "${intermediate_dta}Nalanda\ps29.dta", replace
clear

import delimited "${raw}\Nalanda\Nalanda PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_39"
save "${intermediate_dta}Nalanda\ps30.dta", replace
clear

import delimited "${raw}\Nalanda\Noorsarai PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_41"
save "${intermediate_dta}Nalanda\ps32.dta", replace
clear

import delimited "${raw}\Nalanda\Parwalpur PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_42"
save "${intermediate_dta}Nalanda\ps33.dta", replace
clear

import delimited "${raw}\Nalanda\Pirbigha O. P..csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_43"
save "${intermediate_dta}Nalanda\ps34.dta", replace
clear

import delimited "${raw}\Nalanda\Rahui PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_44"
save "${intermediate_dta}Nalanda\ps35.dta", replace
clear

import delimited "${raw}\Nalanda\Rajgir PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_45"
save "${intermediate_dta}Nalanda\ps36.dta", replace
clear

import delimited "${raw}\Nalanda\Sare PS..csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_46"
save "${intermediate_dta}Nalanda\ps37.dta", replace
clear

import delimited "${raw}\Nalanda\Sarmera PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_47"
save "${intermediate_dta}Nalanda\ps38.dta", replace
clear

import delimited "${raw}\Nalanda\Silao PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_49"
save "${intermediate_dta}Nalanda\ps40.dta", replace
clear

import delimited "${raw}\Nalanda\Sohsarai PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_50"
save "${intermediate_dta}Nalanda\ps41.dta", replace
clear

import delimited "${raw}\Nalanda\Telhara PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_51"
save "${intermediate_dta}Nalanda\ps42.dta", replace
clear

import delimited "${raw}\Nalanda\Telmar PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_52"
save "${intermediate_dta}Nalanda\ps43.dta", replace
clear

import delimited "${raw}\Nalanda\Tharthari PS.csv"
gen ps_dist = 1007
gen ps_dist_id = "1007_53"
save "${intermediate_dta}Nalanda\ps44.dta", replace
clear

use "${intermediate_dta}Nalanda\ps1.dta", clear
append using "${intermediate_dta}Nalanda\ps2.dta"
append using "${intermediate_dta}Nalanda\ps3.dta"
append using "${intermediate_dta}Nalanda\ps4.dta"
append using "${intermediate_dta}Nalanda\ps5.dta"
append using "${intermediate_dta}Nalanda\ps6.dta"
append using "${intermediate_dta}Nalanda\ps7.dta"
append using "${intermediate_dta}Nalanda\ps8.dta"
append using "${intermediate_dta}Nalanda\ps9.dta"
append using "${intermediate_dta}Nalanda\ps10.dta"
append using "${intermediate_dta}Nalanda\ps11.dta"
append using "${intermediate_dta}Nalanda\ps12.dta"
append using "${intermediate_dta}Nalanda\ps13.dta"
append using "${intermediate_dta}Nalanda\ps14.dta"
append using "${intermediate_dta}Nalanda\ps15.dta"
append using "${intermediate_dta}Nalanda\ps16.dta"
append using "${intermediate_dta}Nalanda\ps17.dta"
append using "${intermediate_dta}Nalanda\ps19.dta"
append using "${intermediate_dta}Nalanda\ps21.dta"
append using "${intermediate_dta}Nalanda\ps23.dta"
append using "${intermediate_dta}Nalanda\ps24.dta"
append using "${intermediate_dta}Nalanda\ps25.dta"
append using "${intermediate_dta}Nalanda\ps27.dta"
append using "${intermediate_dta}Nalanda\ps29.dta"
append using "${intermediate_dta}Nalanda\ps30.dta"
append using "${intermediate_dta}Nalanda\ps32.dta"
append using "${intermediate_dta}Nalanda\ps33.dta"
append using "${intermediate_dta}Nalanda\ps34.dta"
append using "${intermediate_dta}Nalanda\ps35.dta"
append using "${intermediate_dta}Nalanda\ps36.dta"
append using "${intermediate_dta}Nalanda\ps37.dta"
append using "${intermediate_dta}Nalanda\ps38.dta"
append using "${intermediate_dta}Nalanda\ps40.dta"
append using "${intermediate_dta}Nalanda\ps41.dta"
append using "${intermediate_dta}Nalanda\ps42.dta"
append using "${intermediate_dta}Nalanda\ps43.dta"
append using "${intermediate_dta}Nalanda\ps44.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Nalanda_FIR.dta", replace
