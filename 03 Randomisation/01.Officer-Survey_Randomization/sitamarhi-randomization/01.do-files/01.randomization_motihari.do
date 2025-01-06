/*==============================================================================
File Name:	Randomization: Sitamarhi Baseline-Survey-2022
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	02/02/2023
Created by: Aadya Gupta
Updated on:	--
Updated by:	--


*Notes READ ME:
*This is a staggerd implementation project and the randomization
 is done phase wise by district as the baseline is complete. 
 
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


/* Installing packages
ssc install unique
ssc install outreg2
*/

**File Directory

/*dibbo -- username for Dibyajyoti. 
Acer -- username for Shubhro. 
For others, please enter your PC Name as username and copy the file path of your DB Desktop. 
*/ 

else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\03 Randomisation\01.Officer-Survey_Randomization\sitamarhi-randomization"
	}
	
else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization-2022\01.Officer-Survey_Randomization\sitamarhi-randomization"
	}
		
else if "`c(username)'"=="User2"{
	global dropbox "File-Path"
	}
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}
	
di "`dropbox'"

* File path
global raw "$dropbox\00.raw-data"
global do_files "$dropbox\01.do-files"
global intermediate_dta "$dropbox\02.intermediate-data\"
global tables "$dropbox\03.tables\"
global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\05.log-files\"
global clean_dta "$dropbox\06.clean-data\"


//Global File Path for using data from the source -- PSFS and Officer's survey clean data

if "`c(username)'"=="HP"{
	global source "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data\psfs-officer_merged"
	} 
	
else if "`c(username)'"=="dibbo"{
	global source "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\02 Baseline-Survey-2022\Baseline Survey_versions 1-3\Officer-Survey-2022\06.clean-data\psfs-officer_merged"
	} 

else if "`c(username)'"=="Acer"{
	global source "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data\psfs-officer_merged"
	}  
		
else if "`c(username)'"=="User2"{
	global source "File-Path"
	}
else if "`c(username)'"=="User3"{
	global source "File-Path"
	}
	
di "`source'"


	

* We will log in
capture log close 

log using "${log_files}randomisation_sitamarhi.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME


**Preparing the Dataset 

* Loading the merged baseline for Bhojpur
use "$source\1010_sitamarhi-merged.dta"

tab po_grandtotal, missing // No missing values

egen mean_officers = mean(po_grandtotal)
egen median_officers = median(po_grandtotal)
gen above_median_officers=(po_grandtotal>=median_officers)
* We have on average 25 officers per station. The median is 25 officers. 
* We have 47 stations. 24 PS should fall above the median, 23 should fall below the median.

unique ps_dist_id if above_median_officers == 1
unique ps_dist_id if above_median_officers == 0 
//We have 21 PS with above median number of Police Officers and 26 PS with below median Police Officers strength. 

save "${intermediate_dta}1010_sitamarhi-merged_prep.dta", replace

collapse (mean) above_median_officers, by ( ps_dist_id)
rename  above_median_officers strata


*2. Randomization of stations
set seed 68200923
gen random = uniform()
egen ordem = rank(random), by (strata) unique 
egen n_obs = count(random), by (strata)
gen cutoff = n_obs*(1/2)
gen cutoffA = round(cutoff)
gen T = (ordem<= cutoffA)

save "${intermediate_dta}randomization_sitamarhi.dta", replace

tab T strata