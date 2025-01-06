/*==============================================================================
File Name: Endline Survey - Regressions
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/05/2024
Created by: Dibyajyoti Basak
Updated on: 03/05/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to run regressions on the Endline Officer's Survey 2023. 


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

log using "$MO_endline_log_files\officersurvey_tables.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\endline_secondaryoutcomes", clear



***********Regression for officers never transferred within full sample (dum_bothsurveys == 1 & dum_transfer == 0) (reghdfe)***********

foreach i in index_Openness_And index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i'_el treatment_bl if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

//Estimation 2
eststo model2: reghdfe `i'_el treatment_bl `i'_bl index_Desirability_And_bl if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

//Estimation 3
eststo model3: reghdfe `i'_el treatment_bl `i'_bl index_Desirability_And_bl /// Baseline Controls
index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were never transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

//Estimation 4
eststo model4: reghdfe `i'_el treatment_bl `i'_bl index_Desirability_And_bl /// Baseline Controls
index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
index_Perception_Integ_And index_Workenv_Rel_And index_Workenv_Rep_And index_Workenv_Male_And index_WorkDistr_And index_TrainingLearning_And index_harassment_And index_Desirability_And_fem /// secondary outcomes (female constables)
if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were never transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_notransfers.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment Effects on `: var lab `i'_el' (Non-transferred officers)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Basic controls" "Secondary Secondary outcomes" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_notransfers.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile "\\All regressions are for officers who were not transferred during the period of the study."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_Openness_And index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And {	
	// Define file paths
	local original "regression_table_`i'_notransfers.tex"
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
}		



********Regression for officers transferred within full sample (dum_bothsurveys == 1 & dum_transfer == 1) (reghdfe)*************

foreach i in index_Openness_And index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And {
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el treatment_bl if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 2
eststo model2: reghdfe `i'_el treatment_bl `i'_bl index_Desirability_And_bl if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 3
eststo model3: reghdfe `i'_el treatment_bl `i'_bl index_Desirability_And_bl /// Baseline Controls
index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

// Estimation 4
eststo model4: reghdfe `i'_el treatment_bl `i'_bl index_Desirability_And_bl /// Baseline Controls
index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
index_Perception_Integ_And index_Workenv_Rel_And index_Workenv_Rep_And index_Workenv_Male_And index_WorkDistr_And index_TrainingLearning_And index_harassment_And index_Desirability_And_fem /// secondary outcomes (female constables)
if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_transferred.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment Effects on `: var lab `i'_el' (Transferred officers)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Basic controls" "Secondary Secondary outcomes" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_transferred.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_Openness_And index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And {	
	// Define file paths
	local original "regression_table_`i'_transferred.tex"
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
}	



***********Regression for officers never transferred within full sample (dum_bothsurveys == 1 & dum_transfer == 0) (ppmlhdfe)************

foreach i in index_Openness_Reg index_VictimBlame_Reg index_Techskills_Reg index_Empathy_Reg index_Flexibility_Reg index_AttitudeGBV_Reg index_ExtPol_Reg index_Discrimination_Reg index_Truth_Reg {
	
eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: ppmlhdfe `i'_el treatment_bl if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

//Estimation 2
eststo model2: ppmlhdfe `i'_el treatment_bl `i'_bl index_Desirability_Reg_bl if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

//Estimation 3
eststo model3: ppmlhdfe `i'_el treatment_bl `i'_bl index_Desirability_Reg_bl /// Baseline Controls
index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were never transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

//Estimation 4
eststo model4: ppmlhdfe `i'_el treatment_bl `i'_bl index_Desirability_Reg_bl /// Baseline Controls
index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
index_Perception_Integ_And index_Workenv_Rel_And index_Workenv_Rep_And index_Workenv_Male_And index_WorkDistr_And index_TrainingLearning_And index_harassment_And index_Desirability_And_fem /// secondary outcomes (female constables)
if dum_bothsurveys == 1 & dum_transfer == 0, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were never transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_notransfers.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment Effects on `: var lab `i'_el' (Non-transferred officers)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Basic controls" "Secondary Secondary outcomes" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_notransfers.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile "\\All regressions are for officers who were not transferred during the period of the study."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_Openness_Reg index_VictimBlame_Reg index_Techskills_Reg index_Empathy_Reg index_Flexibility_Reg index_AttitudeGBV_Reg index_ExtPol_Reg index_Discrimination_Reg index_Truth_Reg {	
	// Define file paths
	local original "regression_table_`i'_notransfers.tex"
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
}



*********Regression for officers transferred within full sample (dum_bothsurveys == 1 & dum_transfer == 1) (ppmlhdfe)************

foreach i in index_Openness_Reg index_VictimBlame_Reg index_Techskills_Reg index_Empathy_Reg index_Flexibility_Reg index_AttitudeGBV_Reg index_ExtPol_Reg index_Discrimination_Reg index_Truth_Reg {

eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: ppmlhdfe `i'_el treatment_bl if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 2
eststo model2: ppmlhdfe `i'_el treatment_bl `i'_bl index_Desirability_Reg_bl if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal)
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 3
eststo model3: ppmlhdfe `i'_el treatment_bl `i'_bl index_Desirability_Reg_bl /// Baseline Controls
index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

// Estimation 4
eststo model4: ppmlhdfe `i'_el treatment_bl `i'_bl index_Desirability_Reg_bl /// Baseline Controls
index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg /// PSFS indices
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank
index_Perception_Integ_And index_Workenv_Rel_And index_Workenv_Rep_And index_Workenv_Male_And index_WorkDistr_And index_TrainingLearning_And index_harassment_And index_Desirability_And_fem /// secondary outcomes (female constables)
if dum_bothsurveys == 1 & dum_transfer == 1, absorb(ps_dist_bl po_grandtotal) //restricting sample to officers who were transferred, and including strata variables
sum `i'_bl if e(sample) == 1 & treatment_bl == 0 & dum_bothsurveys == 1 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_transferred.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment Effects on `: var lab `i'_el' (Transferred officers)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Basic controls" "Secondary Secondary outcomes" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_transferred.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_Openness_Reg index_VictimBlame_Reg index_Techskills_Reg index_Empathy_Reg index_Flexibility_Reg index_AttitudeGBV_Reg index_ExtPol_Reg index_Discrimination_Reg index_Truth_Reg {	
	// Define file paths
	local original "regression_table_`i'_transferred.tex"
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
}		
