/*==============================================================================
File Name: Endline Survey - Regressions - swindex
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

log using "$MO_endline_log_files\analysis_log.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\combined_FINAL_indices.dta", clear

****Creating SDB dummy and create interaction variable  with treatment
summ index_Desirability_And_bl, detail
local sdb_p75 = r(p75)
gen dum_SDB = (index_Desirability_And_bl > `sdb_p75')
*gen treatment_SDB = treatment_bl*dum_SDB
la var dum_SDB "High SDB"
la define dum_SDB 0"Low SDB" 1"High SDB"
la values dum_SDB dum_SDB

****Creating interaction variable for rural-urban dummy and treatment
*gen treatment_ruralurban = treatment_bl*ruralurban_dum_bl
la var ruralurban_dum_bl "Rural/urban"

**labelling variables
la var index_Openness_And_el "openness"
la var index_VictimBlame_And_el "victim blaming"
la var index_Techskills_And_el "technical skills"
la var index_Empathy_And_el "empathy"
la var index_Flexibility_And_el "flexibility"
la var index_Desirability_And_el "desirability"
la var index_AttitudeGBV_And_el "attitudes towards GBV"
la var index_ExtPol_And_el "externalising police responsibilities"
la var index_Discrimination_And_el "discrimination"
la var index_Truth_And_el "truthfulness of complaints"
la var index_Combined_And_el "GBV skills index"
la define treatment_bl 0"Control" 1"Treatment"
la values treatment_bl treatment_bl
la define dum_transfer 0"No Transfer" 1"Transferred"
la values dum_transfer dum_transfer
la var dum_training ""
la var dum_training "Training"
rename index_Openness_And index_Openness_And_bl
rename index_Openness_Reg index_Openness_Reg_bl

******setting up macros
macro drop stratafe sds swsdsstationcontrols swstationcontrols officercontrols
local stratafe ps_dist_bl strata_bl
local sds index_Desirability_And_bl
local swsds swindex_Desirability_bl
local stationcontrols index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And
local swstationcontrols swindex_psfs_gen_bl swindex_psfs_fem_infra_bl swindex_psfs_m_f_seg_bl
local officercontrols ///
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
po_caste_dum_refuse_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank

display "stratafe: `stratafe'"
display "sds: `sds'"
display "swsds: `swsds'"
display "stationcontrols: `stationcontrols'"
display "swstationcontrols: `swstationcontrols'"
display "officercontrols: `officercontrols'"

**# Bookmark #1
********Regression for clean sample  of officers (dum_bothsurveys == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el treatment_bl, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 2
eststo model2: reghdfe `i'_el treatment_bl `i'_bl `sds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 3
eststo model3: reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

// Estimation 4
eststo model4: reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_cleansample.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment effects on `: var lab `i'_el' (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_cleansample.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
	// Define file paths
	local original "regression_table_`i'_cleansample.tex"
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


**# Bookmark #2
***********Regression for officers never transferred within full sample (dum_bothsurveys == 1 & dum_transfer == 0) (reghdfe)***********

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i'_el treatment_bl if dum_transfer == 0, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

//Estimation 2: Baseline outcome controls
eststo model2: reghdfe `i'_el treatment_bl `i'_bl `sds' if dum_transfer == 0, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

//Estimation 3: Station controls
eststo model3: reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
if dum_transfer == 0, absorb(`stratafe') cluster (ps_dist_id_bl) //restricting sample to officers who were never transferred, and including strata variables
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

//Estimation 4: Officer controls
eststo model4: reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols' /// officer controls
if dum_transfer == 0, absorb(`stratafe') cluster (ps_dist_id_bl) //restricting sample to officers who were never transferred, and including strata variables
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
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
	title("Treatment effects on `: var lab `i'_el' (non-transferred officers)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_notransfers.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who were not transferred during the period of the study."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
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



**# Bookmark #3
********Regression for officers transferred within full sample (dum_bothsurveys == 1 & dum_transfer == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el treatment_bl if dum_transfer == 1, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 2
eststo model2: reghdfe `i'_el treatment_bl `i'_bl `sds' if dum_transfer == 1, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 3
eststo model3: reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
if dum_transfer == 1, absorb(`stratafe') cluster (ps_dist_id_bl) //restricting sample to officers who were transferred, and including strata variables
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

// Estimation 4
eststo model4: reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols' /// officer controls
if dum_transfer == 1, absorb(`stratafe') cluster (ps_dist_id_bl) //restricting sample to officers who were transferred, and including strata variables
sum `i'_el if e(sample) == 1 & treatment_el == 0 & dum_transfer == 1
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
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
	title("Treatment effects on `: var lab `i'_el' (transferred officers)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_transferred.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who were transferred during the period of the study."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
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


**# Bookmark #4
********Regression for SDB-treatment interaction for clean sample  of officers (dum_bothsurveys == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el i.treatment_bl##i.dum_SDB, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 2
eststo model2: reghdfe `i'_el i.treatment_bl##i.dum_SDB `i'_bl, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 3
eststo model3: reghdfe `i'_el i.treatment_bl##i.dum_SDB `i'_bl /// baseline controls
`stationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 4
eststo model4: reghdfe `i'_el i.treatment_bl##i.dum_SDB `i'_bl /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
test 1.treatment_bl + 1.treatment_bl#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_treatSDB.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment_bl 1.dum_SDB 1.treatment_bl#1.dum_SDB) ///
	title("Robustness check for social desirability bias on `: var lab `i'_el' (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("pvalue Treatment + Treatment $\times$ High SDB = 0" "cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_treatSDB.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{High SDB indicates desirability scores above the 75th percentile}."
	file write myfile " Col (2) includes the baseline value of the outcome of interest."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
	// Define file paths
	local original "regression_table_`i'_treatSDB.tex"
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


**# Bookmark #5
********Regression for female officer strength-treatment interaction for clean sample  of officers (dum_bothsurveys == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el i.treatment_bl##i.dum_fem_bl, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_fem_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 2
eststo model2: reghdfe `i'_el i.treatment_bl##i.dum_fem_bl `i'_bl `sds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_fem_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 3
eststo model3: reghdfe `i'_el i.treatment_bl##i.dum_fem_bl `i'_bl `sds' /// baseline controls
`stationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_fem_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 4
eststo model4: reghdfe `i'_el i.treatment_bl##i.dum_fem_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
test 1.treatment_bl + 1.treatment_bl#1.dum_fem_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_treatfem.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment_bl 1.dum_fem_bl 1.treatment_bl#1.dum_fem_bl) ///
	title("Robustness check for female officer strength (station-level) on `: var lab `i'_el' (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("pvalue Treatment + Treatment $\times$ Above median strength = 0" "cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_treatfem.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{Above median strength indicates female officer strength (station-level) greater than median}."
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
	// Define file paths
	local original "regression_table_`i'_treatfem.tex"
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


**# Bookmark #6
********Regression for rural/urban-treatment interaction for clean sample  of officers (dum_bothsurveys == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el i.treatment_bl##i.ruralurban_dum_bl, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.ruralurban_dum_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 2
eststo model2: reghdfe `i'_el i.treatment_bl##i.ruralurban_dum_bl `i'_bl `sds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.ruralurban_dum_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 3
eststo model3: reghdfe `i'_el i.treatment_bl##i.ruralurban_dum_bl `i'_bl `sds' /// baseline controls
`stationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.ruralurban_dum_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 4
eststo model4: reghdfe `i'_el i.treatment_bl##i.ruralurban_dum_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
test 1.treatment_bl + 1.treatment_bl#1.ruralurban_dum_bl == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_treaturban.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment_bl 1.ruralurban_dum_bl 1.treatment_bl#1.ruralurban_dum_bl) ///
	title("Robustness check for rural/urban on `: var lab `i'_el' (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("pvalue Treatment + Treatment $\times$ Urban = 0" "cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_treaturban.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{Rural/urban dummy generated based on population density raster data. It assumes the value of 1 if the police station is urban}."
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Malaria Atlas Project, baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
	// Define file paths
	local original "regression_table_`i'_treaturban.tex"
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

**# Bookmark #7
********Regression for transfer-treatment interaction for clean sample  of officers (dum_bothsurveys == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el i.treatment_bl##i.dum_transfer, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_transfer == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 2
eststo model2: reghdfe `i'_el i.treatment_bl##i.dum_transfer `i'_bl `sds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_transfer == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 3
eststo model3: reghdfe `i'_el i.treatment_bl##i.dum_transfer `i'_bl `sds' /// baseline controls
`stationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_transfer == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 4
eststo model4: reghdfe `i'_el i.treatment_bl##i.dum_transfer `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
test 1.treatment_bl + 1.treatment_bl#1.dum_transfer == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_treattransfer.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment_bl 1.dum_transfer 1.treatment_bl#1.dum_transfer) ///
	title("Interaction of transfer-treatment on `: var lab `i'_el' (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("pvalue p-value: Treatment + Treatment $\times$ Transferred" "cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_treattransfer.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{Transfer dummy generated based on reported baseline, intermediate, and endline police stations of the police officer}."
	file write myfile " \textbf{It assumes the value of 1 if the officer has been transferred anytime between baseline and endline}."
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
	// Define file paths
	local original "regression_table_`i'_treattransfer.tex"
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

**# Bookmark #8
********Regression for training-treatment interaction for clean sample  of officers (dum_bothsurveys == 1) (reghdfe)*************

foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el i.treatment_bl##i.dum_officerstrained, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_officerstrained == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 2
eststo model2: reghdfe `i'_el i.treatment_bl##i.dum_officerstrained `i'_bl `sds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_officerstrained == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 3
eststo model3: reghdfe `i'_el i.treatment_bl##i.dum_officerstrained `i'_bl `sds' /// baseline controls
`stationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"
test 1.treatment_bl + 1.treatment_bl#1.dum_officerstrained == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

// Estimation 4
eststo model4: reghdfe `i'_el i.treatment_bl##i.dum_officerstrained `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
test 1.treatment_bl + 1.treatment_bl#1.dum_officerstrained == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_treattraining.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment_bl 1.dum_officerstrained 1.treatment_bl#1.dum_officerstrained) ///
	title("Interaction of training-treatment on `: var lab `i'_el' (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("pvalue p-value: Treatment + Treatment $\times$ Trained" "cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_treattraining.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{Training dummy assumes the value of 1 if more than 50\% of officers in a police station have received training}."
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discrimination_And index_Truth_And index_Openness_And index_Combined_And index_Combined_disag_And { 	
	// Define file paths
	local original "regression_table_`i'_treattraining.tex"
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


**# Bookmark #9
********Regression for combined index for clean sample of officers (dum_bothsurveys == 1) (reghdfe)*************
rename index_Discrimination_And_bl index_Discr_And_bl
rename index_Discrimination_And_el index_Discr_And_el

eststo clear // Clear any previously stored estimation results
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discr_And index_Truth_And index_Openness_And index_Combined_And {
// Estimation 1
eststo model`i': reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
}

esttab model* using "$MO_endline_tables\regression_table_combined.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment effects on indices (clean sample)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_combined.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (1) - victim blaming, Col (2) - technical skills, Col (3) - empathy, Col (4) - flexibility, Col (5) - attitudes towards GBV, Col (6) - externalising police responsibilites, Col (7) - discrimination, Col (8) - truthfulness of complaints, Col (9) - openness, \textbf{Col (10) - GBV skills index}."
	file write myfile " \textbf{GBV skills index aggregates and normalises by control mean all the indices, \textit{except technical skills (column 2)}}."
	file write myfile " All regressions include the baseline value of the outcome of interest and social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$MO_endline_tables\"	
	// Define file paths
	local original "regression_table_combined.tex"
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


**# Bookmark #10
********Regression for combined index for clean sample of officers - disaggregated (dum_bothsurveys == 1) (reghdfe)*************
rename index_Combined_disag_And_bl index_Combineddisag_bl
rename index_Combined_disag_And_el index_Combineddisag_el

eststo clear // Clear any previously stored estimation results
foreach i in index_VictimBlame_And index_Techskills_And index_Empathy_And index_Flexibility_And index_AttitudeGBV_And index_ExtPol_And index_Discr_And index_Truth_And index_Openness_And index_Combineddisag {
// Estimation 1
eststo model`i': reghdfe `i'_el treatment_bl `i'_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"
}

esttab model* using "$MO_endline_tables\regression_table_combined2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment effects on indices (clean sample) (II)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_combined2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (1) - victim blaming, Col (2) - technical skills, Col (3) - empathy, Col (4) - flexibility, Col (5) - attitudes towards GBV, Col (6) - externalising police responsibilites, Col (7) - discrimination, Col (8) - truthfulness of complaints, Col (9) - openness, \textbf{Col (10) - GBV skills index}."
	file write myfile " \textbf{GBV skills index aggregates and normalises by control mean all the variables comprising the indices, \textit{except technical skills (column 2)}}."
	file write myfile " All regressions include the baseline value of the outcome of interest and social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$MO_endline_tables\"	
	// Define file paths
	local original "regression_table_combined2.tex"
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


**# Bookmark #11
********Regression for clean sample  of officers using officers trained as x variable (dum_bothsurveys == 1) (reghdfe)*************

foreach i in swindex_VictimBlame_tr swindex_TechSkills_tr swindex_Empathy_tr swindex_Flexibility_tr swindex_AttitudeGBV_tr swindex_ExtPol_tr swindex_Discrimination_tr swindex_Truth_tr swindex_Openness_tr swindex_Combined_tr swindex_Combined_disag_tr { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el dum_training, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & dum_training == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 2
eststo model2: reghdfe `i'_el dum_training `i'_bl `swsds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & dum_training == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 3
eststo model3: reghdfe `i'_el dum_training `i'_bl `swsds' /// baseline controls
`swstationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & dum_training == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

// Estimation 4
eststo model4: reghdfe `i'_el dum_training `i'_bl `swsds' /// baseline controls
`swstationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & dum_training == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_usingtraining.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (dum_training) ///
	title("Training effects on `: var lab `i'_el' ") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_usingtraining.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " \textbf{All regressions use the training dummy (1 if officer attended training) as the independent variable}."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in swindex_VictimBlame_tr swindex_TechSkills_tr swindex_Empathy_tr swindex_Flexibility_tr swindex_AttitudeGBV_tr swindex_ExtPol_tr swindex_Discrimination_tr swindex_Truth_tr swindex_Openness_tr swindex_Combined_tr swindex_Combined_disag_tr { 	
	// Define file paths
	local original "regression_table_`i'_usingtraining.tex"
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

**# Bookmark #12
********Regression for clean sample  of officers using swindex (dum_bothsurveys == 1) (reghdfe)*************

foreach i in swindex_VictimBlame swindex_TechSkills swindex_Empathy swindex_Flexibility swindex_AttitudeGBV swindex_ExtPol swindex_Discrimination swindex_Truth swindex_Openness swindex_Combined swindex_Combined_disag { 
eststo clear // Clear any previously stored estimation results

// Estimation 1
eststo model1: reghdfe `i'_el treatment_bl, absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "No"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 2
eststo model2: reghdfe `i'_el treatment_bl `i'_bl `swsds', absorb(`stratafe') cluster (ps_dist_id_bl)
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "No"
estadd local Secondary "No"

// Estimation 3
eststo model3: reghdfe `i'_el treatment_bl `i'_bl `swsds' /// baseline controls
`swstationcontrols', /// station controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "No"

// Estimation 4
eststo model4: reghdfe `i'_el treatment_bl `i'_bl `swsds' /// baseline controls
`swstationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) 
sum `i'_el if e(sample) == 1 & treatment_el == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Secondary "Yes"

esttab model1 model2 model3 model4 using "$MO_endline_tables\regression_table_`i'_approach2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_bl) ///
	title("Treatment effects on `: var lab `i'_el' (using swindex)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Baseline Baseline controls" "Control Station controls" "Secondary Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$MO_endline_tables\regression_table_`i'_approach2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{footnotesize}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions are for officers who completed both surveys (clean sample)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting (swindex), and normalised for control group mean.}"
	file write myfile " Col (2) includes the baseline value of the outcome of interest and social desirability."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, rank, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Baseline and endline surveys, police station facility survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{footnotesize}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$MO_endline_tables\"
foreach i in swindex_VictimBlame swindex_TechSkills swindex_Empathy swindex_Flexibility swindex_AttitudeGBV swindex_ExtPol swindex_Discrimination swindex_Truth swindex_Openness swindex_Combined swindex_Combined_disag { 	
	// Define file paths
	local original "regression_table_`i'_approach2.tex"
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
