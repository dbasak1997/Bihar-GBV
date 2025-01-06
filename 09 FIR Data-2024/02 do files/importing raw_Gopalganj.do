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

log using "${log_files}importing FIR Data_Gopalganj.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Gopalganj\Baikunthpur PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_10"
save "${intermediate_dta}Gopalganj\ps1.dta", replace
clear

import delimited "${raw}\Gopalganj\Barauli PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_11"
save "${intermediate_dta}Gopalganj\ps2.dta", replace
clear

import delimited "${raw}\Gopalganj\Bhore PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_12"
save "${intermediate_dta}Gopalganj\ps3.dta", replace
clear

import delimited "${raw}\Gopalganj\Bishwambharpur PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_13"
save "${intermediate_dta}Gopalganj\ps4.dta", replace
clear

import delimited "${raw}\Gopalganj\Gopalganj PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_14"
save "${intermediate_dta}Gopalganj\ps5.dta", replace
clear

import delimited "${raw}\Gopalganj\Gopalpur PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_15"
save "${intermediate_dta}Gopalganj\ps6.dta", replace
clear

import delimited "${raw}\Gopalganj\Hathua PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_16"
save "${intermediate_dta}Gopalganj\ps7.dta", replace
clear

import delimited "${raw}\Gopalganj\Kataiya PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_17"
save "${intermediate_dta}Gopalganj\ps8.dta", replace
clear

import delimited "${raw}\Gopalganj\Kuchaikot PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_18"
save "${intermediate_dta}Gopalganj\ps9.dta", replace
clear

import delimited "${raw}\Gopalganj\Manjhagarh PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_21"
save "${intermediate_dta}Gopalganj\ps12.dta", replace
clear

import delimited "${raw}\Gopalganj\Mirganj PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_22"
save "${intermediate_dta}Gopalganj\ps13.dta", replace
clear

import delimited "${raw}\Gopalganj\Mohammadpur PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_23"
save "${intermediate_dta}Gopalganj\ps14.dta", replace
clear

import delimited "${raw}\Gopalganj\Phulwaria PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_24"
save "${intermediate_dta}Gopalganj\ps15.dta", replace
clear

import delimited "${raw}\Gopalganj\Sidhwalia PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_26"
save "${intermediate_dta}Gopalganj\ps17.dta", replace
clear

import delimited "${raw}\Gopalganj\Thawe PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_28"
save "${intermediate_dta}Gopalganj\ps19.dta", replace
clear

import delimited "${raw}\Gopalganj\Uchakagaon PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_29"
save "${intermediate_dta}Gopalganj\ps20.dta", replace
clear

import delimited "${raw}\Gopalganj\Vijaypur PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_30"
save "${intermediate_dta}Gopalganj\ps21.dta", replace
clear

import delimited "${raw}\Gopalganj\Yadopur PS.csv"
gen ps_dist = 1004
gen ps_dist_id = "1004_31"
save "${intermediate_dta}Gopalganj\ps22.dta", replace
clear


use "${intermediate_dta}Gopalganj\ps1.dta", clear
append using "${intermediate_dta}Gopalganj\ps2.dta"
append using "${intermediate_dta}Gopalganj\ps3.dta"
append using "${intermediate_dta}Gopalganj\ps4.dta"
append using "${intermediate_dta}Gopalganj\ps5.dta"
append using "${intermediate_dta}Gopalganj\ps6.dta"
append using "${intermediate_dta}Gopalganj\ps7.dta"
append using "${intermediate_dta}Gopalganj\ps8.dta"
append using "${intermediate_dta}Gopalganj\ps9.dta"
append using "${intermediate_dta}Gopalganj\ps12.dta"
append using "${intermediate_dta}Gopalganj\ps13.dta"
append using "${intermediate_dta}Gopalganj\ps14.dta"
append using "${intermediate_dta}Gopalganj\ps15.dta"
append using "${intermediate_dta}Gopalganj\ps17.dta"
append using "${intermediate_dta}Gopalganj\ps19.dta"
append using "${intermediate_dta}Gopalganj\ps20.dta"
append using "${intermediate_dta}Gopalganj\ps21.dta"
append using "${intermediate_dta}Gopalganj\ps22.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Gopalganj_FIR.dta", replace
