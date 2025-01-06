/*==============================================================================
File Name: Merging Training Attendance data with survey data
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	26/11/2024
Created by: Dibyajyoti Basak
Updated on: 27/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to merge training attendance data with survey data

==============================================================================*/

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


* We will log in
capture log close 

log using "$MO_endline_log_files\officersurvey_merging_training.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

** Importing and saving the training attendance data
clear
import excel "$MO_endline_raw\Attendance Data_Training.xlsx", sheet("Sheet1") firstrow
drop if key_bl == "" & key_el == ""
drop if key_bl == "uuid:4026dddd-12ae-4674-b1e8-a4f89c14125a" & district == "Patna"

keep if key_bl != "" & key_el == ""
gen key_bl_temp = key_bl
gen key_el_temp = key_el

drop key_el key_el_temp key_bl
tempfile attendance_bl // Saving a file with officers who attended training but only completed baseline
save `attendance_bl'

clear
import excel "$MO_endline_raw\Attendance Data_Training.xlsx", sheet("Sheet1") firstrow
drop if key_bl == "" & key_el == ""
drop if key_bl == "uuid:4026dddd-12ae-4674-b1e8-a4f89c14125a" & district == "Patna"

keep if key_el != ""
gen key_bl_temp = key_bl
gen key_el_temp = key_el

replace key_bl_temp = "" if key_el_temp != "" & key_bl_temp != ""

drop key_bl key_bl_temp key_el
tempfile attendance_el // Saving a file with officers who attended training and completed endline
save `attendance_el'

***Loading merged dataset of baseline+endline officers
use "$MO_endline_clean_dta\endline_secondaryoutcomes.dta", clear
gen key_bl_temp = key_bl
gen key_el_temp = key_el

tempfile surveydata 
save `surveydata'

use `attendance_bl', clear //using the baseline attendance first

merge 1:m key_bl_temp using `surveydata' //merging using the key_bl

foreach var of varlist batch attendancedays trainingdate {
	rename `var' `var'_bl
}

preserve 

keep if _m == 3 //here we save the successfully merged officers
tempfile merged1
save `merged1'

restore

preserve 

keep if _m == 2 //here we save the officers from the main dataset who were not merged, this will be used for further merging
drop _m

tempfile tobemerged
save `tobemerged'

restore

keep if _m == 1 //keeping officers from attendance data who did not merge
drop ps_dist_bl-dum_median_officerstrained key_el
gen tag = 1

replace key_el_temp = key_bl_temp if _m == 1 //replacing the endline key with baseline key
replace key_bl_temp = "" if _m == 1
drop if key_el_temp == ""
drop _m

append using `attendance_el' //appending the endline attendance data, now we have a new training attendance dataset to be merged

drop key_bl key_bl_temp

merge 1:m key_el_temp using `tobemerged' //merging with remainder from original merged dataset

drop if _m == 1 //dropping if officers from training did not merge with either baseline or endline officers

append using `merged1' //appending the successfully merged officers from the first round of merging


foreach var of varlist batch attendancedays trainingdate {
	rename `var' `var'_el
}


gen trainingdate_officer = . //generating the date when each officer attended the first date of training
replace trainingdate_officer = trainingdate_el
replace trainingdate_officer = trainingdate_bl if dum_endline == 1 & trainingdate_officer ==.

gen trainingdays_officer = . //generating the number of training days attended
replace trainingdays_officer = attendancedays_el
replace trainingdays_officer = attendancedays_bl if dum_endline == 1 & trainingdays_officer ==.

drop district psname officersname batch_bl attendancedays_bl trainingdate_bl batch_el attendancedays_el trainingdate_el

keep trainingdate_officer trainingdays_officer key_el key_bl key_el_temp key_bl_temp tag  //keeping only the relevant variables

tempfile rough
save `rough'

use `surveydata', clear //merging with combined dataset

preserve  //saving officers who did not complete endline separately
drop if key_el != ""
tempfile noendline
save `noendline'
restore

drop if key_el == "" //keeping only officers who completed endline
merge 1:m key_el_temp using `rough' //merging with officers who completed training and completed endline
drop if _m == 2

append using `noendline' //appending officers who did not complete endline

bysort ps_dist_id_el: egen date_firsttraining_ps = min(trainingdate_officer) //generating first date of officer training in each police station

format trainingdate_officer %td //formatting the datetime variables to be in readable format
format date_firsttraining_ps %td

drop key_bl_temp key_el_temp _merge

gen dum_trainingcompleted = 0
replace dum_trainingcompleted = 1 if trainingdate_officer !=.

la var trainingdate_officer "First date of training for officer"
la var date_firsttraining_ps "First date of training for officers in each PS"
la var trainingdays_officer "Number of training days completed"
la var dum_trainingcompleted "Dummy for completion of training (0 if not completed, 1 if completed)"

*sort ps_dist_el ps_dist_id_el ps_name_el
*order trainingdate_officer trainingdays_officer i1_name_el l1p1_name_el key_el key_bl

save "$MO_endline_clean_dta\endline_baseline_training.dta", replace
