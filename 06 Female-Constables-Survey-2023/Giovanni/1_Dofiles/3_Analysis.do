/*==============================================================================
File Name: Female Constables Survey 2022 - Analysis do file
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	04/12/2024
Created by: Giovanni D'Ambrosio
Updated on: 04/12/2024
Updated by:	Giovanni D'Ambrosio

*Notes READ ME:
*This is the analysis Do file to see if the training had any effect on female
police officers.

==============================================================================*/

clear all
set more off
cap log close

* Log file

log using "$log_files\femaleconstable_analysis_gd.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

* Load dataset

use "$clean_dta/female_constables_clean_indices.dta", clear


**# Regressions using Anderson Indeces

***********(Regression for female officers) (reghdfe)***********

foreach i in work_integration_index_and relation_officers_index_and fem_representation_index_and ///
perceptions_moff_index_and work_distrib_index_and sensitivity_index_and harassment_index_and ///
harassment_report_index_and gad_score phq_score job_satisfaction_index_and phq_score gad_score {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' treatment, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 2
eststo model2: reghdfe `i' treatment mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 3
eststo model3: reghdfe `i' days_treatment_exposure, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 4
eststo model4: reghdfe `i' days_treatment_exposure mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 5
eststo model5: reghdfe `i' share_trainedofficers_el, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 6
eststo model6: reghdfe `i' share_trainedofficers_el mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 7
eststo model7: reghdfe `i' count_treated_officers_network, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 8
eststo model8: reghdfe `i' count_treated_officers_network mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

/*

//Estimation 3
eststo model3: reghdfe `i' treatment ind_Desirability_And_fem /// including SDB 
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg, /// PSFS indices
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "No"

//Estimation 4
eststo model4: reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"

*/

esttab model1 model2 model3 model4 model5 model6 model7 model8 using "$tables/`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment days_treatment_exposure share_trainedofficers_el count_treated_officers_network) ///
	title("Treatment effects on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$tables/`i'.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (2) controls for social desirability of the female officers."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$tables/"
foreach i in work_integration_index_and relation_officers_index_and fem_representation_index_and ///
perceptions_moff_index_and work_distrib_index_and sensitivity_index_and harassment_index_and ///
harassment_report_index_and gad_score phq_score job_satisfaction_index_and {	
	// Define file paths
	local original "`i'.tex"
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


eststo clear // Clear any previously stored estimation results

**# Regressions using Kling Indeces

***********(Regression for female officers) (reghdfe)***********

foreach i in work_integration_index_kling relation_officers_index_kling fem_representation_index_kling ///
perceptions_moff_index_kling work_distrib_index_kling sensitivity_index_kling harassment_index_kling ///
harassment_report_index_kling job_satisfaction_index_kling {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' treatment, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 2
eststo model2: reghdfe `i' treatment mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 3
eststo model3: reghdfe `i' days_treatment_exposure, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 4
eststo model4: reghdfe `i' days_treatment_exposure mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 5
eststo model5: reghdfe `i' share_trainedofficers_el, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 6
eststo model6: reghdfe `i' share_trainedofficers_el mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 7
eststo model7: reghdfe `i' count_treated_officers_network, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"

//Estimation 8
eststo model8: reghdfe `i' count_treated_officers_network mcsds_score, /// including SDB 
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"

/*

//Estimation 3
eststo model3: reghdfe `i' treatment ind_Desirability_And_fem /// including SDB 
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg, /// PSFS indices
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "No"

//Estimation 4
eststo model4: reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"

*/

esttab model1 model2 model3 model4 model5 model6 model7 model8 using "$tables/`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment days_treatment_exposure share_trainedofficers_el count_treated_officers_network) ///
	title("Treatment effects on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$tables/`i'.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " Col (2) controls for social desirability of the female officers."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$tables/"
foreach i in work_integration_index_kling relation_officers_index_kling fem_representation_index_kling ///
perceptions_moff_index_kling work_distrib_index_kling sensitivity_index_kling harassment_index_kling ///
harassment_report_index_kling job_satisfaction_index_kling {	
	// Define file paths
	local original "`i'.tex"
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


eststo clear // Clear any previously stored estimation results


cap log close