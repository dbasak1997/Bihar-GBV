/*==============================================================================
File Name: PSFS 2022- Index do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	27/03/2023
Created by: Aadya Gupta
Updated on:	-
Updated by:	-

*Notes READ ME:
*This is the Index Do file for the Baseline PSFS 2022. The Excel sheet for constricting indices for PSFS can be found at https://www.dropbox.com/scl/fi/hyna5bu4vcb414q4hb72y/27032023_PSFS-Indices_AG_v2.gsheet?dl=0&rlkey=c8dcapkoresnh9wl2dtnn6ue7

*	Inputs: 06.clean-data  "02.PSFS_clean_deidentified_compiled"  
*	Outputs: 

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

**File Directory

*dibbo -- username name for Dibyajyoti.
*Acer -- username for Shubhro. 
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 


else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\01 PSFS-2024\PSFS-2022"
	}		
	
else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\PSFS-2022"
	}
	
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}
	
di "`dropbox'"
	
*File Path

global raw "$dropbox\00.raw-data"
global do_files "$dropbox\01.do-files"
global intermediate_dta "$dropbox\02.intermediate-data\"
global tables "$dropbox\03.tables\"
global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\05.log-files\"
global clean_dta "$dropbox\06.clean-data\"


/* Install packages
ssc install veracrypt
ssc install revrs
*/


* We will log in
capture log close 

log using "${log_files}psfs_index.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 01.clean-data "02.PSFS_clean_deidentified_compiled"
use "${clean_dta}02.PSFS_clean_deidentified_compiled.dta", clear

/* Indices for PSFS-2022
I construct 3 indices from the police station level data collected from PSFS (all versions)-

1. PSFS- 
This index combines all infrastructure and facilities-related questions into one index. 
This index has 18 items.
I use the rowmean method to construct this index.

2. Female-specific infrastructure-
This index captures the facilities within a PS that cater to the needs of a female victim and/or a female police officer/staff at the station.
This index has 5 items.
I use the rowmean method to construct this index.

3. Female representation in PS-
This index captures the representation of female officers at the police station across all ranks.
This index has 7 items.
The construction of this index is a simple no. of female officers/total no. of officers at the PS. 

Note: 
A. I use the compiled PSFS dataset- constructed by appending PSFS-2022 and PSFS-2022_v1- for index construction. 

B. I have NOT mapped the question of 'number of FIRs filed' in any index as of now.
*/


** Index- PSFS (index_psfs)
codebook ps_bathroom ps_confidential ps_electricity ps_fourwheeler ps_twowheeler ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_storage ps_evidence ps_phone ps_lockup ps_shelter ps_cctv ps_fourwheeler ps_twowheeler ps_lockup ps_cctv ps_suffbarrack ps_new_cctv ps_computer // recoding needed for questions that have numeric answers


/* Recoding needed for variables as they have numeric answers:
ps_fourwheeler ps_twowheeler ps_lockup ps_cctv ps_computer
*/

/* The following variables are follow-up questions, i.e. their responses depend on the response to the question above:
ps_suffbarrack ps_new_cctv
*/


* Interim PSFS index- For this index_psfs, I do not include the variables that need recoding and the variables that are follow-up questions.

egen index_psfs_int = rowmean(ps_bathroom ps_confidential ps_electricity ps_seating ps_cleaning ps_water ps_barrack ps_storage ps_evidence ps_phone ps_shelter)

la var index_psfs_int "Interim PSFS Index"

summ index_psfs_int 

histogram index_psfs_int, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(PSFS_int)


** Index- Female-specific infrastructure (index_fem_infra)
codebook ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter // no recoding required

egen index_fem_infra = rowmean(ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter)

la var index_fem_infra "Female-specific infrastructure Index"

summ index_fem_infra

histogram index_fem_infra, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(FSI)


** Index- Female representation in PS (fem_rep)
codebook po_f_headconstable po_f_wtconstable po_f_constable po_f_asi po_f_si po_f_ins po_f_sho // no recoding required

egen fem_rep = rowtotal (po_f_headconstable po_f_wtconstable po_f_constable po_f_asi po_f_si po_f_ins po_f_sho)

gen index_fem_rep = fem_rep/po_grandtotal

la var index_fem_rep "Female representation in PS"

summ index_fem_rep

histogram index_fem_rep 
