/*==============================================================================
File Name:	Randomization: Pooled
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	07/02/2023
Created by: Aadya Gupta
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak


*Notes READ ME:
*This is a staggered implementation project and the randomization is done phase wise by district as the baseline is complete. This is the do-file to append these district wise files into a single dataset.
 
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


global source "$randomisation\01.Officer-Survey_Randomization"


* We will log in
capture log close 

log using "$randomisation_log_files\randomisation_pooled.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME

import excel "$randomisation_raw\PS_Popdensity.xlsx", sheet("Sheet1") firstrow
drop ps_dist ps_name
tempfile ps_density
save `ps_density' 

clear

**Preparing the Dataset 

use "$source\bagaha-randomization\02.intermediate-data\randomization_bagaha.dta", clear 
append using "$source\bettiah-randomization\02.intermediate-data\randomization_bettiah.dta"
append using "$source\bhojpur-randomization\02.intermediate-data\randomization_bhojpur.dta"
gen tag_dum = 0
replace tag_dum = 1 if ps_dist_id == "1003_53"
append using "$source\gopalganj-randomization\02.intermediate-data\randomization_gopalganj.dta"
append using "$source\motihari-randomization\02.intermediate-data\randomization_motihari.dta"
replace ps_dist_id = "1005_53" if ps_dist_id == "1003_53" & tag_dum !=1
drop tag_dum
append using "$source\muzaffarpur-randomization\Data\randomization_muzaffarpur.dta"
append using "$source\nalanda-randomization\02.intermediate-data\randomization_nalanda.dta"
append using "$source\patna-randomization\02.intermediate-data\randomization_patna.dta"
append using "$source\saran-randomization\02.intermediate-data\randomization_saran.dta"
append using "$source\sitamarhi-randomization\02.intermediate-data\randomization_sitamarhi.dta"
append using "$source\siwan-randomization\02.intermediate-data\randomization_siwan.dta"
append using "$source\vaishali-randomization\02.intermediate-data\randomization_vaishali.dta"
rename T treatment

merge 1:1 ps_dist_id using `ps_density' 
drop if _m != 3
drop random ordem n_obs cutoff cutoffA _merge ps_lat ps_long
gen ruralurban_dum = 0
replace ruralurban_dum = 1 if popdensity > 2000 // setting dum = 1 if average population density/sqkm of a radius of 10sqkm around the PS is greater than 2000
label define ruralurban_dum 0 "Rural" 1"Urban"
label values ruralurban_dum ruralurban_dum
label variable ruralurban_dum "Rural/Urban (0=Rural,1=Urban)"

save "$randomisation_clean_dta\pooled_randomisation.dta", replace