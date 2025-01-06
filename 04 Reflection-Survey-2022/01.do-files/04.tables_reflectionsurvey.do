/*==============================================================================
File Name: Reflection Survey 2022 - Tables do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	22/02/2023
Created by: Aadya Gupta
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Tables Do file for tables of Reflection Survey

*	Inputs:  06.clean-data "01.reflectionsurvey_clean"
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


/* Install packages:
ssc install estout
*/


* We will log in
capture log close 

log using "$reflection_log_files\reflectionsurvey_tables.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

* We open the input dta file: 
use "$reflection_clean_dta\reflection_clean.dta", clear
drop if consent == 0
rename ps_dist ps_dist_ref
merge m:1 ps_dist_id using "$psfs_clean_dta\psfs_combined.dta" //merging with PSFS data
drop if _m != 3
label variable treatment "Treatment"


//Recoding the variables

****Satisfaction with Training
foreach var of varlist tr_satisfaction tr_helpful tr_recommend tr_self tr_femalecentric {
	gen `var'_dum = `var'
}

recode tr_satisfaction_dum 1=1 2=1 3=0 4=0 5=0
recode tr_helpful_dum 1=1 2=0
recode tr_recommend_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=1 8=1 9=1 10=1
recode tr_self_dum 0=0 1=1
recode tr_femalecentric_dum 0=0 1=1



*******Reflection Scales
foreach var of numlist 2 4 9 14 18 20 22 {
	rename rs_bec`var' ref_scale_`var'
}

foreach var of numlist 3 8 11 15 21 25 28 {
	rename rs_bpt`var' ref_scale_`var'
}

foreach var of varlist ref_scale_2 ref_scale_9 ref_scale_20 ref_scale_22 {
	gen `var'_dum = `var'
	recode `var'_dum 1=0 2=0 3=0 4=1 5=1
}

foreach var of varlist ref_scale_4 ref_scale_14 ref_scale_18 {
	gen `var'_dum = `var'
	recode `var'_dum 1=1 2=1 3=0 4=0 5=0
}

foreach var of varlist ref_scale_8 ref_scale_11 ref_scale_21 ref_scale_25 ref_scale_28 {
	gen `var'_dum = `var'
	recode `var'_dum 1=0 2=0 3=0 4=1 5=1
}

foreach var of varlist ref_scale_3 ref_scale_15 {
	gen `var'_dum = `var'
	recode `var'_dum 1=1 2=1 3=0 4=0 5=0
}


//Creating indices using swindex

drop stdgroup
gen stdgroup = treatment == 0 //generating a variable stdgroup which takes value for the control group

*Training satisfaction
swindex tr_satisfaction_dum tr_helpful_dum tr_recommend_dum tr_self_dum tr_femalecentric_dum, g(swindex_Satisfaction) normby(stdgroup) displayw
label variable swindex_Satisfaction "Training satisfaction"

*Reflection Scales
swindex ref_scale_2_dum ref_scale_9_dum ref_scale_20_dum ref_scale_22_dum ref_scale_4_dum ref_scale_14_dum ref_scale_18_dum ref_scale_8_dum ref_scale_11_dum ref_scale_21_dum ref_scale_25_dum ref_scale_28_dum ref_scale_3_dum ref_scale_15_dum, g(swindex_Reflection) normby(stdgroup) displayw
label variable swindex_Reflection "Reflection scales"


****swindex - PSFS

swindex ps_bathroom ps_confidential dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv, g(swindex_psfs_gen_bl) normby(stdgroup) displayw

swindex ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter, g(swindex_psfs_fem_infra_bl) normby(stdgroup) displayw

swindex dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho, g(swindex_psfs_m_f_seg_bl) normby(stdgroup) displayw

drop stdgroup


save "$reflection_clean_dta\reflection_clean_merged.dta", replace

************

********Balance Tables










*******Regression Tables
eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe swindex_Reflection treatment, absorb(ps_dist strata) cluster(ps_dist_id_bl)
sum swindex_Reflection if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "No"
*estadd local Control "No"
*estadd local Control_2 "No"
estadd local Control_3 "No"

/*
//Estimation 2
eststo model2: reghdfe swindex_Reflection treatment index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And, absorb(ps_dist strata) cluster(ps_dist_id_bl)
sum swindex_Reflection if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Control_2 "No"
estadd local Control_3 "No"

//Estimation 3
eststo model3: reghdfe swindex_Reflection treatment index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg, absorb(ps_dist strata) cluster(ps_dist_id_bl)
sum swindex_Reflection if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
estadd local Control "No"
estadd local Control_2 "Yes"
estadd local Control_3 "No"

*/
//Estimation 4
eststo model4: reghdfe swindex_Reflection treatment swindex_psfs_gen_bl swindex_psfs_fem_infra_bl swindex_psfs_m_f_seg_bl, absorb(ps_dist strata) cluster(ps_dist_id_bl)
sum swindex_Reflection if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
*estadd local Control "No"
*estadd local Control_2 "No"
estadd local Control_3 "Yes"


esttab model1 model4 using "$reflection_tables\regression_table_swindex_Reflection.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on `: var lab swindex_Reflection'") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Control_3 Station controls" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$reflection_tables\regression_table_swindex_Reflection.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use FIR data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile


// Formatting Latex tables
cd "$reflection_tables\"	
	// Define file paths
	local original "regression_table_swindex_Reflection.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
	while r(eof) == 0 {
						// Write the original line to the new file
						file write newfile "`line'" _n
    
						// Check if the line contains the caption command
						if strpos("`line'", "\caption{") {
														// Add the vspace command after the caption line
														file write newfile "\vspace{0.3cm}" _n
														}
    
						// Read the next line
						file read myfile line
						}

// Close the files
file close myfile
file close newfile

// Check if the original file exists before deleting it
capture confirm file "`original'"
					if !_rc {
						// Delete the original file
						erase "`original'"
					}

// Rename the modified file to the original file name
shell move "`modified'" "`original'"
	
eststo clear
clear






