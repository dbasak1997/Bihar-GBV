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

log using "${log_files}importing FIR Data_Motihari.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Motihari\Adapur PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_10"
save "${intermediate_dta}Motihari\ps1.dta", replace
clear

import delimited "${raw}\Motihari\Banjaria PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_12"
save "${intermediate_dta}Motihari\ps3.dta", replace
clear

import delimited "${raw}\Motihari\Chakia PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_16"
save "${intermediate_dta}Motihari\ps7.dta", replace
clear

import delimited "${raw}\Motihari\Chhatauni PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_17"
save "${intermediate_dta}Motihari\ps8.dta", replace
clear

import delimited "${raw}\Motihari\Chhauradana PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_18"
save "${intermediate_dta}Motihari\ps9.dta", replace
clear

import delimited "${raw}\Motihari\Chiraiya PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_19"
save "${intermediate_dta}Motihari\ps10.dta", replace
clear

import delimited "${raw}\Motihari\Darpa PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_20"
save "${intermediate_dta}Motihari\ps11.dta", replace
clear

import delimited "${raw}\Motihari\Dhaka PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_21"
save "${intermediate_dta}Motihari\ps12.dta", replace
clear

import delimited "${raw}\Motihari\Dumariaghat PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_22"
save "${intermediate_dta}Motihari\ps13.dta", replace
clear

import delimited "${raw}\Motihari\Ghorasahan PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_23"
save "${intermediate_dta}Motihari\ps14.dta", replace
clear

import delimited "${raw}\Motihari\Gobindganj PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_24"
save "${intermediate_dta}Motihari\ps15.dta", replace
clear

import delimited "${raw}\Motihari\Harsiddhi PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_28"
save "${intermediate_dta}Motihari\ps19.dta", replace
clear

import delimited "${raw}\Motihari\Jharokhar PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_30"
save "${intermediate_dta}Motihari\ps21.dta", replace
clear

import delimited "${raw}\Motihari\Jitna PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_31"
save "${intermediate_dta}Motihari\ps22.dta", replace
clear

import delimited "${raw}\Motihari\Kalyanpur PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_32"
save "${intermediate_dta}Motihari\ps23.dta", replace
clear

import delimited "${raw}\Motihari\Kesaria PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_33"
save "${intermediate_dta}Motihari\ps24.dta", replace
clear

import delimited "${raw}\Motihari\Kotawa PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_34"
save "${intermediate_dta}Motihari\ps25.dta", replace
clear

import delimited "${raw}\Motihari\Lakhaura PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_35"
save "${intermediate_dta}Motihari\ps26.dta", replace
clear

import delimited "${raw}\Motihari\Madhuwan PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_36"
save "${intermediate_dta}Motihari\ps27.dta", replace
clear

import delimited "${raw}\Motihari\Mahuaawa PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_38"
save "${intermediate_dta}Motihari\ps29.dta", replace
clear

import delimited "${raw}\Motihari\Malahi PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_39"
save "${intermediate_dta}Motihari\ps30.dta", replace
clear

import delimited "${raw}\Motihari\Mehsi PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_40"
save "${intermediate_dta}Motihari\ps31.dta", replace
clear

import delimited "${raw}\Motihari\Muffasil PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_41"
save "${intermediate_dta}Motihari\ps32.dta", replace
clear

import delimited "${raw}\Motihari\Nakadei PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_42"
save "${intermediate_dta}Motihari\ps33.dta", replace
clear

import delimited "${raw}\Motihari\Paharpur PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_44"
save "${intermediate_dta}Motihari\ps35.dta", replace
clear

import delimited "${raw}\Motihari\Pakridayal PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_45"
save "${intermediate_dta}Motihari\ps36.dta", replace
clear

import delimited "${raw}\Motihari\Palanwa PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_46"
save "${intermediate_dta}Motihari\ps37.dta", replace
clear

import delimited "${raw}\Motihari\Panhara PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_47"
save "${intermediate_dta}Motihari\ps38.dta", replace
clear

import delimited "${raw}\Motihari\Patahi PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_48"
save "${intermediate_dta}Motihari\ps39.dta", replace
clear

import delimited "${raw}\Motihari\Pipra PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_49"
save "${intermediate_dta}Motihari\ps40.dta", replace
clear

import delimited "${raw}\Motihari\Piprakothi PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_50"
save "${intermediate_dta}Motihari\ps41.dta", replace
clear

import delimited "${raw}\Motihari\Rajpur PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_52"
save "${intermediate_dta}Motihari\ps43.dta", replace
clear

import delimited "${raw}\Motihari\Ramgarhwa PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_53"
save "${intermediate_dta}Motihari\ps44.dta", replace
clear

import delimited "${raw}\Motihari\Raxaul PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_54"
save "${intermediate_dta}Motihari\ps45.dta", replace
clear

import delimited "${raw}\Motihari\Sangrampur PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_55"
save "${intermediate_dta}Motihari\ps46.dta", replace
clear

import delimited "${raw}\Motihari\Shikarganj PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_57"
save "${intermediate_dta}Motihari\ps48.dta", replace
clear

import delimited "${raw}\Motihari\Sugauli PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_58"
save "${intermediate_dta}Motihari\ps49.dta", replace
clear

import delimited "${raw}\Motihari\Town PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_59"
save "${intermediate_dta}Motihari\ps50.dta", replace
clear

import delimited "${raw}\Motihari\Turkaulia PS.csv"
gen ps_dist = 1005
gen ps_dist_id = "1005_60"
save "${intermediate_dta}Motihari\ps51.dta", replace
clear

use "${intermediate_dta}Motihari\ps1.dta", clear
append using "${intermediate_dta}Motihari\ps3.dta"
append using "${intermediate_dta}Motihari\ps7.dta"
append using "${intermediate_dta}Motihari\ps8.dta"
append using "${intermediate_dta}Motihari\ps9.dta"
append using "${intermediate_dta}Motihari\ps10.dta"
append using "${intermediate_dta}Motihari\ps11.dta"
append using "${intermediate_dta}Motihari\ps12.dta"
append using "${intermediate_dta}Motihari\ps13.dta"
append using "${intermediate_dta}Motihari\ps14.dta"
append using "${intermediate_dta}Motihari\ps15.dta"
append using "${intermediate_dta}Motihari\ps19.dta"
append using "${intermediate_dta}Motihari\ps21.dta"
append using "${intermediate_dta}Motihari\ps22.dta"
append using "${intermediate_dta}Motihari\ps23.dta"
append using "${intermediate_dta}Motihari\ps24.dta"
append using "${intermediate_dta}Motihari\ps25.dta"
append using "${intermediate_dta}Motihari\ps26.dta"
append using "${intermediate_dta}Motihari\ps27.dta"
append using "${intermediate_dta}Motihari\ps29.dta"
append using "${intermediate_dta}Motihari\ps30.dta"
append using "${intermediate_dta}Motihari\ps31.dta"
append using "${intermediate_dta}Motihari\ps32.dta"
append using "${intermediate_dta}Motihari\ps33.dta"
append using "${intermediate_dta}Motihari\ps35.dta"
append using "${intermediate_dta}Motihari\ps36.dta"
append using "${intermediate_dta}Motihari\ps37.dta"
append using "${intermediate_dta}Motihari\ps38.dta"
append using "${intermediate_dta}Motihari\ps39.dta"
append using "${intermediate_dta}Motihari\ps40.dta"
append using "${intermediate_dta}Motihari\ps41.dta"
append using "${intermediate_dta}Motihari\ps43.dta"
append using "${intermediate_dta}Motihari\ps44.dta"
append using "${intermediate_dta}Motihari\ps45.dta"
append using "${intermediate_dta}Motihari\ps46.dta"
append using "${intermediate_dta}Motihari\ps48.dta"
append using "${intermediate_dta}Motihari\ps49.dta"
append using "${intermediate_dta}Motihari\ps50.dta"
append using "${intermediate_dta}Motihari\ps51.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
replace district = "Motihari" if district == "East Champaran"
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Motihari_FIR.dta", replace
