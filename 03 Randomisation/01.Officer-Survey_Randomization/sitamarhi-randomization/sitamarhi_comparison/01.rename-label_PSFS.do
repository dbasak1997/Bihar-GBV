/*==============================================================================
File Name: PSFS-2022 - Renaming and Labeling do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	30/11/2022
Created by: Shubhro Bhattacharya
Updated on:	-----
Updated by:	-----

*Notes READ ME:
*This is the Renaming and Labeling Do file for the PSFS Survey 2022. 

*	Inputs: 02.intermediate-data  "01.import-PSFS_intermediate"
*	Outputs: 02.intermediate-data  "02.ren-PSFS_intermediate"

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

*Acer -- username for Shubhro. For others, please enter your PC Name as username and copy the file path of your DB Desktop. 

if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\PSFS-2022"
	}  
	
else if "`c(username)'"=="User2"{
	global dropbox "File-Path"
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


* We will log in
capture log close 

log using "${log_files}PSFS_rename.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 02.intermediate-data  "01.import-PSFS_intermediate"

use "${intermediate_dta}01.import-PSFS_intermediate.dta" , clear


/*================Dropping Superfluous Variables===================================*/

*Text Audit Data and Survey CTO internal variables are dropped here

cap drop deviceid devicephonenum username ///
device_info duration caseid ///
p1 p2 var_comment uploadstamp ///
e1 instancename


/*====================Renaming and Labeling Round 2.0===========================*/

/*Abbreviations:

sv: Survey 
ps: Police Station
po: Police Officer
dist: District 
uid: Unique Identifier 
tr: Training
fem: female
suff: sufficient
tot: total
wtconstable: writer constable (munshi)
ins: Inspector
si: Sub-Inspector
asi: Assistant Sub-Inspector
sho: Station House Officer
*/

rename submissiondate sv_date
la var  sv_date "Survey Date"

rename starttime sv_start
la var sv_start "Survey Start Time"

rename endtime sv_stop
la var sv_stop "Survey Stop Time"

rename p3 sv_name
la var sv_name "Surveyor Name"

rename p4 sv_location
la var sv_location "Location of the Survey"

rename p5 ps_dist
la var ps_dist "District of the Police Station"

rename p6 ps_series
la var ps_series "Serial Number Assigned to the Police Station in the district"

/*Some Police Stations were not in the original list (mostly the Outposts), hence a serial number was not assigned to this PS by SurveyCTO automatically */

rename p6_os ps_series_os
la var ps_series_os "Other Specify: Police Station in the district (Non-Listed)"


/*Notes:
1. The following variable "ps_dist_id" is an ID variable created by merging the District ID and the PS Series variable generated for the respective district.

2. Please ensure that the variable name is uniform across all the datasets, since this is the unique id for a PS for our purposes and would be used as a merging variable. 
*/

rename intvar1 ps_dist_id
la var ps_dist_id "Police Station ID in the District"

rename p6label ps_name
la var ps_name "Name of the Police Station"

rename p7 po_name
la var po_name "Name of the Respondent for PSFS Survey (including Munshi/Constable)"

rename p8 po_rank
la var po_rank "Rank of the Respondent for PSFS Survey (including Munshi/Constable)"

rename p9 ps_confirm 
la var ps_confirm "Confirm that you are in the Same Police Station?"

rename e3 sv_comments
la var sv_comments "Surveyor Comments"

*The labelling for the below variables seem to be fine from the Round 1.0 hence there is no need for a fresh round. 

rename q901 ps_bathroom

rename q902 ps_fembathroom

rename q903 ps_confidential

rename q903a ps_femconfidential

rename q904 ps_electricity

rename q905a ps_fourwheeler

rename q905b ps_twowheeler

rename q906 ps_computer

rename q907 ps_seating

rename q908 ps_cleaning

rename q909 ps_water

rename q910 ps_barrack 

rename q910a ps_fembarrack 

rename q910b ps_suffbarrack

rename q911 ps_storage

rename q912 ps_evidence

rename q913 ps_phone

rename q914a ps_lockup

rename q914b ps_femlockup

rename q915 ps_shelter

rename q915a ps_femshelter

rename q916 ps_cctv

rename q916a ps_new_cctv

rename q917 ps_fir


*Notes: Number of Police Officers Rank-wise should be named as: po_`gender#rank' 
*Labelling required for these variables


rename q918a_male po_m_headconstable
la var po_m_headconstable "Number of Male Head Constables in the PS"


rename q918a_female po_f_headconstable 
la var po_f_headconstable "Number of Female Head Constables in the PS"

rename q918a_total po_tot_headconstable
la var po_tot_headconstable "Total number of Head Constables in the PS"


rename q918b_male po_m_wtconstable
la var po_m_wtconstable "Number of Male Writer Constables (Munshi) in the PS"

rename q918b_female po_f_wtconstable
la var po_f_wtconstable "Number of Female Writer Constables (Munshi) in the PS"

rename q918b_total po_tot_wtconstable
la var po_tot_wtconstable "Total number of Writer Constables (Munshi) in the PS"


rename q918c_male po_m_constable
la var po_m_constable "Number of Male Constables in the PS"

rename q918c_female po_f_constable
la var po_f_constable "Number of Female Constables in the PS"

rename q918c_total po_tot_constable
la var po_tot_constable "Total number of Constables in the PS"


rename q918d_male po_m_asi
la var po_m_asi "Number of Male Assistant Sub-Inspectors"

rename q918d_female po_f_asi
la var po_f_asi "Number of Female Assistant Sub-Inspectors"

rename q918d_total po_tot_asi
la var po_tot_asi "Total number of Assistant Sub-Inspectors"

rename q918e_male po_m_si
la var po_m_si "Number of Male Sub-Inspectors"

rename q918e_female po_f_si
la var po_f_si "Number of Female Sub-Inspectors"

rename q918e_total po_tot_si
la var po_tot_si "Total number of Sub-Inspectors"

rename q918f_male po_m_ins
la var po_m_ins "Number of Male Inspectors"

rename q918f_female po_f_ins
la var po_f_ins "Number of Female Inspectors"

rename q918f_total po_tot_ins
la var po_tot_ins "Total number of Inspectors"

rename q918g_male po_m_sho
la var po_m_sho "Number of Male Station House Officers (SHOs)"

rename q918g_female po_f_sho
la var po_f_sho "Number of Female Station House Officers (SHOs)"

rename q918g_total po_tot_sho
la var po_tot_sho "Total number of Station House Officers (SHOs)"

*Missing Values for Female Specific Variables -- Recoded to "Yes" and "No"
//Logical Check: If Total Number of a facility in a PS is recorded as "No" it should also be recorded as a "No" for IF there is Seperate facility for females.

replace ps_fembathroom=0 if ps_bathroom==0

replace ps_femconfidential=0 if ps_confidential==0

replace ps_fembarrack=0 if ps_barrack==0

replace ps_fembarrack=0 if ps_suffbarrack==0

replace ps_femlockup=0 if ps_lockup==0

replace ps_femshelter=0 if ps_shelter==0

*Save the dataset in the Intermediate Folder. We would now conduct all the error and logical consistency checks on the saved dta file.

save "${intermediate_dta}02.ren-PSFS_intermediate.dta", replace












