/*==============================================================================
File Name: Decoy Survey 2023 - Tables do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	24/06/2024
Created by: Dibyajyoti Basak
Updated on: 24/06/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to create tables for Decoy  Survey 2023 


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

log using "$decoy_log_files\decoysurvey_tables.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$decoy_clean_dta\decoy_indices.dta"

drop treatment_bl*

gen po_strength = .
replace po_strength = 1 if po_grandtotal <= 10
replace po_strength = 2 if po_grandtotal > 10 & po_grandtotal <= 20
replace po_strength = 3 if po_grandtotal > 20 & po_grandtotal <= 30
replace po_strength = 4 if po_grandtotal > 30 & po_grandtotal <= 40
replace po_strength = 5 if po_grandtotal > 40 & po_grandtotal <= 50
replace po_strength = 6 if po_grandtotal > 50
tab po_strength

label define po_strength 1 "0-10" 2 "10-20" 3 "20-30" 4 "30-40" 5 "40-50" 6 ">50"
label values po_strength po_strength

label variable swindex_Empathy_decoy1 "Empathy (Visit 1)"
label variable swindex_Empathy_decoy2 "Empathy (Visit 2)"
label variable swindex_Empathy_decoy3 "Empathy (Visit 3)"

label variable swindex_VictimBlame_decoy1 "Victim-blaming (Visit 1)"
label variable swindex_VictimBlame_decoy2 "Victim-blaming (Visit 2)"
label variable swindex_VictimBlame_decoy3 "Victim-blaming (Visit 3)"

label variable swindex_ExtPol_decoy1 "Externalising police responsibilites (Visit 1)"
label variable swindex_ExtPol_decoy2 "Externalising police responsibilites (Visit 2)"
label variable swindex_ExtPol_decoy3 "Externalising police responsibilites (Visit 3)"

label variable treatment_station_decoy "Treatment"
label define treatment_station_decoy 0 "Control" 1 "Treatment"
label values treatment_station_decoy treatment_station_decoy

**********Estimation of indices (all visits combined)
foreach i of varlist swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy {
	
eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' treatment_station_decoy, absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy)
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "No"
estadd local Anderson "No"
estadd local Regular "No"


//Estimation 2
eststo model2: reghdfe `i' treatment_station_decoy /// Baseline Controls
swindex_psfs_gen_bl swindex_psfs_fem_infra_bl swindex_psfs_m_f_seg_bl, ///station controls
absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy) //including strata variables
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"
estadd local Anderson "No"
estadd local Regular "No"

//Estimation 3
eststo model3: reghdfe `i' treatment_station_decoy /// Baseline Controls
psfs_gen_And psfs_fem_infra_And psfs_m_f_seg_And, ///station controls (Anderson)
absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy) //including strata variables
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"
estadd local Anderson "Yes"
estadd local Regular "No"

//Estimation 4
eststo model4: reghdfe `i' treatment_station_decoy /// Baseline Controls
psfs_gen_Reg psfs_fem_infra_Reg psfs_m_f_seg_Reg, ///station controls (Regular)
absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy) //including strata variables
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"
estadd local Anderson "No"
estadd local Regular "Yes"

esttab model1 model2 model3 model4 using "$decoy_tables\regression_table_`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_station_decoy) ///
	title("Treatment Effects on `: var lab `i'' (Decoy)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Control Station controls" "Anderson Station controls (Anderson)" "Regular Station controls (Regular)" "obs Number of stations") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$decoy_tables\regression_table_`i'.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$decoy_tables\"
foreach i of varlist swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy { 	
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


**********Estimation of indices (visit-wise)
foreach i of varlist swindex_Empathy_decoy1 swindex_Empathy_decoy2 swindex_Empathy_decoy3 swindex_VictimBlame_decoy1 swindex_VictimBlame_decoy2 swindex_VictimBlame_decoy3 swindex_ExtPol_decoy1 swindex_ExtPol_decoy2 swindex_ExtPol_decoy3 {
	
eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' treatment_station_decoy, absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy)
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "No"
estadd local Anderson "No"
estadd local Regular "No"


//Estimation 2
eststo model2: reghdfe `i' treatment_station_decoy /// Baseline Controls
swindex_psfs_gen_bl swindex_psfs_fem_infra_bl swindex_psfs_m_f_seg_bl, ///station controls
absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy) //including strata variables
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"
estadd local Anderson "No"
estadd local Regular "No"

//Estimation 3
eststo model3: reghdfe `i' treatment_station_decoy /// Baseline Controls
psfs_gen_And psfs_fem_infra_And psfs_m_f_seg_And, ///station controls (Anderson)
absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy) //including strata variables
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"
estadd local Anderson "Yes"
estadd local Regular "No"

//Estimation 4
eststo model4: reghdfe `i' treatment_station_decoy /// Baseline Controls
psfs_gen_Reg psfs_fem_infra_Reg psfs_m_f_seg_Reg, ///station controls (Regular)
absorb(ps_dist_decoy strata) cluster(ps_dist_id_decoy) //including strata variables
sum `i' if e(sample) == 1 & treatment_station_decoy == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"
estadd local Anderson "No"
estadd local Regular "Yes"

esttab model1 model2 model3 model4 using "$decoy_tables\regression_table_`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment_station_decoy) ///
	title("Treatment Effects on `: var lab `i'' (Decoy)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Control Station controls" "Anderson Station controls (Anderson)" "Regular Station controls (Regular)" "obs Number of stations") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$decoy_tables\regression_table_`i'.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parantheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$decoy_tables\"
foreach i of varlist swindex_Empathy_decoy1 swindex_Empathy_decoy2 swindex_Empathy_decoy3 swindex_VictimBlame_decoy1 swindex_VictimBlame_decoy2 swindex_VictimBlame_decoy3 swindex_ExtPol_decoy1 swindex_ExtPol_decoy2 swindex_ExtPol_decoy3 { 	
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

eststo clear