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

log using "${log_files}importing FIR Data_Sitamarhi.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Sitamarhi\Bajpatti PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_10"
save "${intermediate_dta}Sitamarhi\ps1.dta", replace
clear

import delimited "${raw}\Sitamarhi\Bargainia PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_11"
save "${intermediate_dta}Sitamarhi\ps2.dta", replace
clear

import delimited "${raw}\Sitamarhi\Bathnaha PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_12"
save "${intermediate_dta}Sitamarhi\ps3.dta", replace
clear

import delimited "${raw}\Sitamarhi\Bela PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_13"
save "${intermediate_dta}Sitamarhi\ps4.dta", replace
clear

import delimited "${raw}\Sitamarhi\Belsand PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_14"
save "${intermediate_dta}Sitamarhi\ps5.dta", replace
clear

import delimited "${raw}\Sitamarhi\Charaut OP.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_16"
save "${intermediate_dta}Sitamarhi\ps7.dta", replace
clear

import delimited "${raw}\Sitamarhi\Dumra PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_17"
save "${intermediate_dta}Sitamarhi\ps8.dta", replace
clear

import delimited "${raw}\Sitamarhi\Kanhauli PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_18"
save "${intermediate_dta}Sitamarhi\ps9.dta", replace
clear

import delimited "${raw}\Sitamarhi\Mahindwara OP.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_20"
save "${intermediate_dta}Sitamarhi\ps11.dta", replace
clear

import delimited "${raw}\Sitamarhi\Mejorganj PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_22"
save "${intermediate_dta}Sitamarhi\ps13.dta", replace
clear

import delimited "${raw}\Sitamarhi\Nanpur PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_23"
save "${intermediate_dta}Sitamarhi\ps14.dta", replace
clear

import delimited "${raw}\Sitamarhi\Parihar PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_24"
save "${intermediate_dta}Sitamarhi\ps15.dta", replace
clear

import delimited "${raw}\Sitamarhi\Parsauni PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_25"
save "${intermediate_dta}Sitamarhi\ps16.dta", replace
clear

import delimited "${raw}\Sitamarhi\Punaura OP.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_26"
save "${intermediate_dta}Sitamarhi\ps17.dta", replace
clear

import delimited "${raw}\Sitamarhi\Pupri PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_27"
save "${intermediate_dta}Sitamarhi\ps18.dta", replace
clear

import delimited "${raw}\Sitamarhi\Riga PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_28"
save "${intermediate_dta}Sitamarhi\ps19.dta", replace
clear

import delimited "${raw}\Sitamarhi\Runisaidpur PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_29"
save "${intermediate_dta}Sitamarhi\ps20.dta", replace
clear

import delimited "${raw}\Sitamarhi\Sahiyara PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_30"
save "${intermediate_dta}Sitamarhi\ps21.dta", replace
clear

import delimited "${raw}\Sitamarhi\Sitamarhi PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_32"
save "${intermediate_dta}Sitamarhi\ps23.dta", replace
clear

import delimited "${raw}\Sitamarhi\Sonbarsa PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_33"
save "${intermediate_dta}Sitamarhi\ps24.dta", replace
clear

import delimited "${raw}\Sitamarhi\Suppi OP.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_34"
save "${intermediate_dta}Sitamarhi\ps25.dta", replace
clear

import delimited "${raw}\Sitamarhi\Sursand PS.csv"
gen ps_dist = 1010
gen ps_dist_id = "1010_35"
save "${intermediate_dta}Sitamarhi\ps26.dta", replace
clear


use "${intermediate_dta}Sitamarhi\ps1.dta", clear
append using "${intermediate_dta}Sitamarhi\ps2.dta"
append using "${intermediate_dta}Sitamarhi\ps3.dta"
append using "${intermediate_dta}Sitamarhi\ps4.dta"
append using "${intermediate_dta}Sitamarhi\ps5.dta"
append using "${intermediate_dta}Sitamarhi\ps7.dta"
append using "${intermediate_dta}Sitamarhi\ps8.dta"
append using "${intermediate_dta}Sitamarhi\ps9.dta"
append using "${intermediate_dta}Sitamarhi\ps11.dta"
append using "${intermediate_dta}Sitamarhi\ps13.dta"
append using "${intermediate_dta}Sitamarhi\ps14.dta"
append using "${intermediate_dta}Sitamarhi\ps15.dta"
append using "${intermediate_dta}Sitamarhi\ps16.dta"
append using "${intermediate_dta}Sitamarhi\ps17.dta"
append using "${intermediate_dta}Sitamarhi\ps18.dta"
append using "${intermediate_dta}Sitamarhi\ps19.dta"
append using "${intermediate_dta}Sitamarhi\ps20.dta"
append using "${intermediate_dta}Sitamarhi\ps21.dta"
append using "${intermediate_dta}Sitamarhi\ps23.dta"
append using "${intermediate_dta}Sitamarhi\ps24.dta"
append using "${intermediate_dta}Sitamarhi\ps25.dta"
append using "${intermediate_dta}Sitamarhi\ps26.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Sitamarhi_FIR.dta", replace
