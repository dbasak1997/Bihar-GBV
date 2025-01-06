//Master do-file for appending

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
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\FIR Data-2024"
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

log using "${log_files}Do_Appending.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "${intermediate_dta}Clean_Python\clean_bagaha.dta", clear
append using "${intermediate_dta}Clean_Python\clean_bettiah.dta"
append using "${intermediate_dta}Clean_Python\clean_bhojpur.dta"
append using "${intermediate_dta}Clean_Python\clean_gopalganj.dta"
append using "${intermediate_dta}Clean_Python\clean_motihari.dta"
append using "${intermediate_dta}Clean_Python\clean_muzaffarpur.dta"
append using "${intermediate_dta}Clean_Python\clean_nalanda.dta"
append using "${intermediate_dta}Clean_Python\clean_patna.dta"
append using "${intermediate_dta}Clean_Python\clean_saran.dta"
append using "${intermediate_dta}Clean_Python\clean_sitamarhi.dta"
append using "${intermediate_dta}Clean_Python\clean_siwan.dta"
append using "${intermediate_dta}Clean_Python\clean_vaishali.dta"

save "${intermediate_dta}FIR_intermediate.dta", replace
