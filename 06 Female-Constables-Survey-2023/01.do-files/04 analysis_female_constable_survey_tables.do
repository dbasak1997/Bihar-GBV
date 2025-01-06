/*==============================================================================
File Name: Female Constables Survey 2022 - Tables do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	16/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

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

log using "$FC_survey_log_files\femaleconstable_tables.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$FC_survey_clean_dta\femaleconstables_indices.dta"
drop n5
*rename change_assignment_female chg_assign_fem
rename change_assignment_male chg_assign_m
rename index_* ind_*
rename *_And *
la define treatment 0"Control" 1"Treatment"
la values treatment treatment
la var treatment "Treatment"
             
la var ind_Perception_Integ "perception of workplace integration"
la var ind_Workenv_Rel "work environment (relationships)"
la var ind_Workenv_Rep "work environment (representation)"
la var ind_Workenv_Male "work environment (perception of male officers)"
la var ind_WorkDistr "work distribution"
la var ind_Sensitivity "male officers' sensitivity towards females"
la var ind_harassment "workplace harassment"

****Creating SDB dummy and create interaction variable  with treatment
summ ind_Desirability_And_fem, detail
local sdb_p75 = r(p75)
gen dum_SDB = (ind_Desirability_And_fem > `sdb_p75')
*gen treatment_SDB = treatment_bl*dum_SDB
la var dum_SDB "High SDB"
la define dum_SDB 0"Low SDB" 1"High SDB"
la values dum_SDB dum_SDB


**# Bookmark #1
***********(Regression for female officers) (reghdfe)***********

foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male ind_WorkDistr ind_Sensitivity ind_harassment {

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
eststo model2: reghdfe `i' treatment ind_Desirability_And_fem, /// including SDB 
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


esttab model1 model2 model3 model4 using "$FC_survey_tables\regression_table_`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\regression_table_`i'.tex", write append
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
cd "$FC_survey_tables\"
foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male ind_WorkDistr ind_Sensitivity ind_harassment {	
	// Define file paths
	local original "regression_table_`i'.tex"
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

**# Bookmark #2
//Regression for perception of Workplace Integration Index (Pt 1)
foreach i in q2001_dum q2002_dum q2003_dum q2004_dum q2005_dum /*q2006_dum q2007_dum q2008_dum q2009_dum q2010_dum*/{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_Perception_Work1.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in perception of workplace integration (1)") ///
	nonotes nonote ///
	mtitles ("Reservation" "Workload" "GBV cases" "Routine cases" "Improves environment") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Perception_Work1.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Reservation for women in the police force is beneficial for Bihar Police. \\"
	file write myfile "(2) Female and male constables should not share equal workload in your police station. \\"
	file write myfile "(3) It is useful to have female police officers to work on cases of crimes against women. \\"
	file write myfile "(4) It is useful to have female police officers to work on routine cases such as theft, street-violence, or road rage. \\"
	file write myfile "(5) Having more women in the Bihar Police improves the workplace environment. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results

**# Bookmark #3
//Regression for perception of Workplace Integration Index (Pt 2)
foreach i in /*q2001_dum q2002_dum q2003_dum q2004_dum q2005_dum q2006_dum*/ q2007_dum q2008_dum q2009_dum q2010_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_Perception_Work2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in perception of workplace integration (2)") ///
	nonotes nonote ///
	mtitles ("Efforts to understand" "GBV - Accompany" "Non-GBV - Accompany" "Alcohol - Accompany") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Perception_Work2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) According to you, do the senior male officers (of rank ASI and above) make efforts to address/understand challenges faced by women police officers in your police station? \\"
	file write myfile "(2) \textless{}GBV incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(3) \textless{}non-GBV incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(4) \textless{}alcohol-related incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_Perception_Work2.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on items in perception of workplace integration (2)}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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
	
	
	
eststo clear // Clear any previously stored estimation results	

**# Bookmark #4
//Regression for Work Environment (Relationships) Index
foreach i in q3100_dum q3101_dum q3102_dum q3103_dum q3104_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_WorkEnv_Rel.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in work environment (relationships)") ///
	nonotes nonote ///
	mtitles("Comfort - Male constables" "Discomfort - Female constables" "Comfort - Senior female" "Discomfort - Senior male" "Prove myself") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_WorkEnv_Rel.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) On a scale of 0-10 please rate your comfort level working with male constables. \\"
	file write myfile "(2) On a scale of 0-10 how much discomfort do you have working with female constables. \\"
	file write myfile "(3) On a scale of 0-10 please rate your comfort level working with senior female officers (ASI and above rank). \\"
	file write myfile "(4) On a scale of 0-10 how much discomfort do you have working with senior male officers (ASI and above rank)? \\"
	file write myfile "(5) I feel I have to constantly prove myself to gain acceptance and respect from male co-workers. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_WorkEnv_Rel.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on items in work environment (relationships)}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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

eststo clear // Clear any previously stored estimation results	

**# Bookmark #5
//Regression for Work Environment (Representation) Index
foreach i in q3201_dum q3202_dum q3203_dum q3204_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_WorkEnv_Rep.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in work environment (representation)") ///
	nonotes nonote ///
	mtitles ("Positive impact on policing" "More gender-sensitive" "More accessible" "Increased representation") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_WorkEnv_Rep.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) This (reservation for women) policy has a positive impact on policing in Bihar. \\"
	file write myfile "(2) The environment of the police station has changed to be more gender sensitive as a result of this policy. \\"
	file write myfile "(3) This policy has made the police more accessible to the public. \\"
	file write myfile "(4) Reservation of the seats is a fair means to increase the representation of women in the department. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_WorkEnv_Rep.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on items in work environment (representation)}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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

eststo clear // Clear any previously stored estimation results	

**# Bookmark #6
//Regression for perception of Male Officers Index
foreach i in q3301_dum /*q3302_dum*/ q3303_dum q3304_dum q3305_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_Percep_MaleOff.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in perception of male officers") ///
	nonotes nonote ///
	mtitles ("Male officers - understanding" "Male officers - dislike" "Male officers - hinder" "Male officers - unaware") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Percep_MaleOff.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Male officers (of rank ASI and above) in the station are understanding of my family responsibilities. \\"
	file write myfile "(2) Male officers (of rank ASI and above) in the station have expressed they do not like to work with female officers. \\"
	file write myfile "(3) Male officers (of rank ASI and above) in the station make it difficult for me to conduct my job. \\"
	file write myfile "(4) Male officers (of rank ASI and above) in the station are unaware of the challenges female officers face when joining the force. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile	

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_Percep_MaleOff.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on items in perception of male officers}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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

	
eststo clear // Clear any previously stored estimation results	

/*

**# Bookmark #7
//Regression for Work Distribution Index (Pt 1)
foreach i in q3401_dum workdistr_dum fem_typical_dum chg_assign_m q3406_dum /*q3407_dum q3408_dum q3409_dum q3410_dum q3411_dum q3412_dum q3413_dum q3414_dum*/{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_WorkDistribution_1.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in work distribution (1)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_WorkDistribution_1.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) The roles of a male constable and a female constable are very different in a police station. \\"
	file write myfile "(2) In the past 7 days, can you tell us the three activities in which you were the most involved? (1 = GBV related, 0 if non-GBV related) \\"
	file write myfile "(3) What type of cases are you more likely to be a part of? (0 if non-GBV, 1 if GBV) \\"
	file write myfile "(4) Have you noticed male officers (ranks ASI and above) change their work assignment in the past one month? (1 = changed to GBV case, 0 otherwise) \\"
	file write myfile "(5) Male constables do more paperwork than female constables. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	

**# Bookmark #8
//Regression for Work Distribution Index (Pt 2)
foreach i in /*q3401_dum workdistribution chg_assign_fem chg_assign_m q3406_dum */q3407_dum q3408_dum q3409_dum q3410_dum /*q3411_dum q3412_dum q3413_dum q3414_dum*/{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_WorkDistribution_2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in work distribution (2)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_WorkDistribution_2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Female constables have higher education then male constables. \\"
	file write myfile "(2) Male constables have less responsibilities than female constables. \\"
	file write myfile "(3) Female constables do more organizing work in the police station. \\"
	file write myfile "(4) Male constables go fewer times on patrolling than female constables. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	
eststo clear // Clear any previously stored estimation results	

**# Bookmark #9
//Regression for Work Distribution Index (Pt 3)
foreach i in /*q3401_dum workdistribution chg_assign_fem chg_assign_m q3406_dum q3407_dum q3408_dum q3409_dum q3410_dum*/ q3411_dum q3412_dum q3413_dum q3414_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_WorkDistribution_3.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in work distribution (3)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_WorkDistribution_3.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Female constables work on more women's related cases than male constables. \\"
	file write myfile "(2) Male constables work on fewer property crime cases cases than female constables. \\"
	file write myfile "(3) Male constables work on fewer dispute over property ownership cases than female constables. \\"
	file write myfile "(4) Male constables work on fewer dispute over property boundary cases than female constables. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	
eststo clear // Clear any previously stored estimation results	
*/
**# Bookmark #10
//Regression for male officers' sensitivity towards females
foreach i in q4001_dum q4002_dum q4003_dum q4004_dum{
	
// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_Sensitivity.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in male officers' sensitivity") ///
	nonotes nonote ///
	mtitles ("Towards female constables" "Towards female senior officers" "Towards female complainants" "Towards male constables") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Sensitivity.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards female constables? \\"
	file write myfile "(2) On the scale of 0 to 10, how sensitive are senior male officers towards senior female officers? (both ASI and above rank) \\"
	file write myfile "(3) On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards female complainants? \\"
	file write myfile "(4) On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards male complainants? \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_Sensitivity.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on items in male officers' sensitivity}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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
	
	
eststo clear // Clear any previously stored estimation results	

**# Bookmark #11
//Regression for Harassment (Pt 1)
foreach i in h1_incident_dum h1_reported_dum h2_incident_dum h2_reported_dum /*h3_dum h3_who_dum h3_reported_dum h4_dum h4_who_dum h4_reported_dum h5_dum h5_who_dum h5_reported_dum h6_dum h6_who_dum h6_reported_dum*/{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_Harassment_1.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in workplace harassment (1)") ///
	nonotes nonote ///
	mtitles ("Shouting/scolding" "Reported" "Intimidated" "Reported") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Harassment_1.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status. \textit{For this index, 1 indicates a negative outcome.}"
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Male officer made you feel threatened or unsafe by shouting, scolding or reprimanding loudly. \\"
	file write myfile "(2) Have you shared or reported this to anyone? (1 if No, 0 if Yes) \\"
	file write myfile "(3) Male officer made you feel intimidated or threatened that he could physically harm you by pushing or hitting you. \\"
	file write myfile "(4) Have you shared or reported this to anyone? (1 if No, 0 if Yes) \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	
eststo clear // Clear any previously stored estimation results	

**# Bookmark #12
//Regression for Harassment (Pt 2)
foreach i in /*h1_dum h1_who_dum h1_reported_dum h2_dum h2_who_dum h2_reported_dum*/ h3_incident_dum h3_reported_dum h4_incident_dum h4_reported_dum /*h5_dum h5_who_dum h5_reported_dum h6_dum h6_who_dum h6_reported_dum*/{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_Harassment_2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in workplace harassment (2)") ///
	nonotes nonote ///
	mtitles ("Physical harm" "Reported" "Sexual advances" "Reported") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Harassment_2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status. \textit{For this index, 1 indicates a negative outcome.}"
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Male officer hit, slapped, or punched you, tripped you or otherwise intentionally caused you physical harm. \\"
	file write myfile "(2) Have you shared or reported this to anyone? (1 if No, 0 if Yes) \\"
	file write myfile "(3) Male officer made any sexual advances such as touching inappropriately. \\"
	file write myfile "(4) Have you shared or reported this to anyone? (1 if No, 0 if Yes) \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	
eststo clear // Clear any previously stored estimation results	

**# Bookmark #13
//Regression for Harassment (Pt 3)
foreach i in /*h1_dum h1_who_dum h1_reported_dum h2_dum h2_who_dum h2_reported_dum h3_dum h3_who_dum h3_reported_dum h4_dum h4_who_dum h4_reported_dum*/ h5_incident_dum h5_reported_dum h6_incident_dum h6_reported_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_Harassment_3.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on items in workplace harassment (3)") ///
	nonotes nonote ///
	mtitles ("Meet alone" "Reported" "Inappropriate remarks/videos" "Reported") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Harassment_3.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status. \textit{For this index, 1 indicates a negative outcome.}"
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Male officer requested you to meet alone with an officer that made you feel uncomfortable. \\"
	file write myfile "(2) Have you shared or reported this to anyone? (1 if No, 0 if Yes) \\"
	file write myfile "(3) Male officer made remarks about you in a sexual manner or shown you inappropriate pictures/videos. \\"
	file write myfile "(4) Have you shared or reported this to anyone? (1 if No, 0 if Yes) \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	

**# Bookmark #14
//Regression for Indices (Anderson)
foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_Indices_And.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	nonotes nonote ///
	title("Treatment effects on indices (Anderson)") ///
	mtitles("Integration" "Relationships" "Representation" "Working with male officers" "Male officers' sensitivity" "Harassment") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Indices_And.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Perception of workplace integration. \\"
	file write myfile "(2) Work environment (relationships). \\"
	file write myfile "(3) Work environment (representation). \\"
	file write myfile "(4) Work environment (perception of male officers). \\"
	file write myfile "(5) Male officers' sensitivity towards females. \\"
	file write myfile "(6) Harassment in the workplace. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_Indices_And.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on indices (Anderson)}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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


eststo clear // Clear any previously stored estimation results	

rename ind_Perception_Integ_Reg ind_Perc_Reg
*rename ind_TrainingLearning_Reg ind_Train

**# Bookmark #15
//Regression for Indices (Regular)
foreach i in ind_Perc_Reg ind_Workenv_Rel_Reg ind_Workenv_Rep_Reg ind_Workenv_Male_Reg /*ind_WorkDistr_Reg*/ ind_Sensitivity_Reg ind_harassment_Reg {
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_Reg_fem /// including SDB
ind_psfs_gen_Reg ind_psfs_fem_infra_Reg ind_psfs_m_f_seg_Reg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_Indices_Reg.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on indices (Regular)") ///
	nonotes nonote ///
	mtitles("Integration" "Relationships" "Representation" "Working with male officers" "Male officers' sensitivity" "Harassment") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_Indices_Reg.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using average of items within each respective index.}"
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) perception of workplace integration \\"
	file write myfile "(2) Work environment (relationships) \\"
	file write myfile "(3) Work environment (representation) \\"
	file write myfile "(4) Work environment (perception of male officers) \\"
	file write myfile "(5) Male officers' sensitivity towards females \\"
	file write myfile "(6) Harassment in the workplace \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_Indices_Reg.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on indices (Regular)}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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

eststo clear // Clear any previously stored estimation results	

**# Bookmark #16
***********(Regression for interaction of SDB-treatment) (reghdfe)***********

foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' i.treatment##i.dum_SDB, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "No"
estadd local fem_officer "No"
test 1.treatment + 1.treatment#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 2
eststo model2: reghdfe `i' i.treatment##i.dum_SDB ///
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg, /// PSFS indices
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "No"
test 1.treatment + 1.treatment#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 3
eststo model3: reghdfe `i' i.treatment##i.dum_SDB ///
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
test 1.treatment + 1.treatment#1.dum_SDB == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'


esttab model1 model2 model3 using "$FC_survey_tables\regression_table_`i'_treatSDB.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment 1.dum_SDB 1.treatment#1.dum_SDB) ///
	title("Robustness check for social desirability bias on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("pvalue Treatment + Treatment $\times$ High SDB = 0" "cgmean Control mean" "FE Strata FE" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\regression_table_`i'_treatSDB.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{High SDB indicates desirability scores above the 75th percentile}."
	file write myfile " Col (2) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (3) includes officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$FC_survey_tables\"
foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment {	
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


eststo clear // Clear any previously stored estimation results

**# Bookmark #17
***********(Regression for interaction of female officer strength-treatment) (reghdfe)***********

foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' i.treatment##i.dum_fem, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"
test 1.treatment + 1.treatment#1.dum_fem == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 2
eststo model2: reghdfe `i' i.treatment##i.dum_fem ind_Desirability_And_fem, /// including SDB 
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
test 1.treatment + 1.treatment#1.dum_fem == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 3
eststo model3: reghdfe `i' i.treatment##i.dum_fem ind_Desirability_And_fem /// including SDB 
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
test 1.treatment + 1.treatment#1.dum_fem == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 4
eststo model4: reghdfe `i' i.treatment##i.dum_fem ind_Desirability_And_fem /// including SDB
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
test 1.treatment + 1.treatment#1.dum_fem == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$FC_survey_tables\regression_table_`i'_treatfem.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment 1.dum_fem 1.treatment#1.dum_fem) ///
	title("Robustness check for female officer strength (station-level) on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("pvalue Treatment + Treatment $\times$ Above median strength = 0" "cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\regression_table_`i'_treatfem.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{Above median strength indicates female officer strength (station-level) greater than median}."
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
cd "$FC_survey_tables\"
foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment {	
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


eststo clear // Clear any previously stored estimation results


**# Bookmark #18
***********(Regression for interaction of ruralurban-treatment) (reghdfe)***********

foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' i.treatment##i.ruralurban_dum, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "No"
estadd local stationcontrol "No"
estadd local fem_officer "No"
test 1.treatment + 1.treatment#1.ruralurban_dum == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 2
eststo model2: reghdfe `i' i.treatment##i.ruralurban_dum ind_Desirability_And_fem, /// including SDB 
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
test 1.treatment + 1.treatment#1.ruralurban_dum == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 3
eststo model3: reghdfe `i' i.treatment##i.ruralurban_dum ind_Desirability_And_fem /// including SDB 
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
test 1.treatment + 1.treatment#1.ruralurban_dum == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

//Estimation 4
eststo model4: reghdfe `i' i.treatment##i.ruralurban_dum ind_Desirability_And_fem /// including SDB
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
test 1.treatment + 1.treatment#1.ruralurban_dum == 0
local pvalue = r(p)
local formatted_pvalue: display %6.3f `pvalue'
estadd local pvalue `formatted_pvalue'

esttab model1 model2 model3 model4 using "$FC_survey_tables\regression_table_`i'_treaturban.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment 1.ruralurban_dum 1.treatment#1.ruralurban_dum) ///
	title("Robustness check for rural/urban on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("pvalue Treatment + Treatment $\times$ Urban = 0" "cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\regression_table_`i'_treaturban.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " \textbf{All indices created using inverse covariance weighting, and normalised for control group mean.}"
	file write myfile " \textbf{Rural/urban dummy generated based on population density raster data. It assumes the value of 1 if the police station is urban}."
	file write myfile " Col (2) controls for social desirability of the female officers."
	file write myfile " Col (3) includes station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers."
	file write myfile " Col (4) includes officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Malaria Atlas Project, female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$FC_survey_tables\"
foreach i in ind_Perception_Integ ind_Workenv_Rel ind_Workenv_Rep ind_Workenv_Male /*ind_WorkDistr*/ ind_Sensitivity ind_harassment {	
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


eststo clear // Clear any previously stored estimation results

//Regression for direct questions
foreach i in fem_typical_dum q3411_dum q4003_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab model* using "$FC_survey_tables\table_direct.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on direct questions related to MO technical skills") ///
	nonotes nonote ///
	mtitles ("Typical case" "Work on more female-related cases" "Male officers - sensitive towards female complainants") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_direct.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) What type of cases are you more likely to be a part of? \\"
	file write myfile "(2) Female constables work on more women's related cases than male constables. \\"
	file write myfile "(3) On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards female complainants? \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_direct.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on direct questions related to MO technical skills}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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
	
eststo clear // Clear any previously stored estimation results

//Regression for indirect questions
foreach i in q2008_dum q2009_dum q2010_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment ind_Desirability_And_fem /// including SDB
ind_psfs_gen ind_psfs_fem_infra ind_psfs_m_f_seg /// PSFS indices
fem_bpservice_years fem_psservice_years fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma fem_po_marital_dum, /// female officer characteristics
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
}
esttab modelq* using "$FC_survey_tables\table_indirect.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment effects on indirect questions related to MO technical skills") ///
	nonotes nonote ///
	mtitles ("GBV incident - Accompany" "Non-GBV incident - Accompany" "Alcohol incident - Accompany") ///
	scalars("cgmean Control mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_indirect.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) \textless{}GBV incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(2) \textless{}non-GBV incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(3) \textless{}alcohol-related incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_indirect.tex"
	local modified "modified_mytable.tex"

	// Open the existing LaTeX file for reading
	file open myfile using "`original'", read text

	// Open a new file to write the modifications
	file open newfile using "`modified'", write text replace

	// Read and modify lines
	file read myfile line
while r(eof) == 0 {
    // Replace the beginning of the table and rearrange as needed
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        file write newfile "\begin{table}[htbp]\centering" _n
        file write newfile "\caption{Treatment effects on indirect questions related to MO technical skills}" _n
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Skip the original caption line to avoid duplication
    else if strpos("`line'", "\caption{") {
        // Do nothing; skip this line
    }
    // Write the \def\sym line after adding the resizebox
    else if strpos("`line'", "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}") {
        file write newfile "`line'" _n
    }
    // Detect the \end{tabular} line and append the closing brace for \resizebox
    else if strpos("`line'", "\end{tabular}") {
        file write newfile "`line'" _n
        file write newfile "}" _n
    }
    // Write the rest of the file content unchanged
    else {
        file write newfile "`line'" _n
    }
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
	
	
eststo clear // Clear any previously stored estimation results