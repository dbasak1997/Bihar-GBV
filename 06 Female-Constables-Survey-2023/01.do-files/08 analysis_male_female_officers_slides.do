/*==============================================================================
File Name: Male Constables Survey - Merging with female constables data (collapsed) and analysing
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	26/09/2024
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

log using "$FC_survey_log_files\analysis_male_female_officers_slides.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

************Reading the endline+baseline clean sample (n=2571)
use "$MO_endline_clean_dta\combined_FINAL_indices.dta", clear

gen count = 1
bysort ps_dist_id_el: egen number_officers_male = total(count)
drop count

rename ps_dist_id_el ps_dist_id

//generating and recoding dummies for additional questions in endline that are relevant for Technical Skills

gen q801m_el_dum = q801m_el // It is useful to have female police officers to work on cases such as domestic violence
recode q801m_el_dum 1=1 2=0 3=0 4=0 5=0

gen q801r_el_dum = q801r_el //GBV vignette - female constable accompany
recode q801r_el_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen q801s_el_dum = q801s_el //non-GBV vignette - female constable accompany
recode q801s_el_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen q801t_el_dum = q801t_el //alcohol-related vignette - female constable accompany
recode q801t_el_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1


merge m:1 ps_dist_id using "${clean_dta}femaleconstables_ps_avg.dta" //merging with collapsed female constables data
drop if _m == 2 //_m == 1 is 197, meaning 197 officers were posted in police stations that had no female officers assigned (at endline)

rename ps_dist_id ps_dist_id_el




//generating a flag for missing obs in the merged variables from female constables
gen missing_flag = .
foreach var of varlist q2008_ps_dum q2009_ps_dum q2010_ps_dum /*q2003_ps_dum*/ workdistr_ps_dum workdistr2_ps_dum fem_typical_ps_dum q3411_ps_dum q4003_ps_dum {
	replace missing_flag = 1 if `var' ==.
	replace missing_flag = 0 if `var' !=. & missing_flag != 1
}

//generating a new technical skills index with the additional questions identified above - method used is swindex, similar to Anderson
recode treatment_bl 0=1 1=0
swindex dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el q801m_el_dum q801r_el_dum q801s_el_dum q801t_el_dum if missing_flag == 0, g(techindex_mergedonly) normby(treatment_bl) displayw

//generating a new technical skills index
swindex sdb_1_bl_dum sdb_2_bl_dum sdb_3_bl_dum sdb_4_bl_dum sdb_5_bl_dum sdb_6_bl_dum sdb_7_bl_dum sdb_8_bl_dum sdb_9_bl_dum sdb_10_bl_dum sdb_11_bl_dum sdb_12_bl_dum sdb_13_bl_dum if missing_flag == 0, g(SDB_mergedonly) normby(treatment_bl) displayw
recode treatment_bl 0=1 1=0
summ techindex_mergedonly SDB_mergedonly if treatment_bl == 0

******setting up macros
macro drop stratafe sds stationcontrols officercontrols

local stratafe ps_dist_bl strata_bl // ps_dist - district

local sds index_Desirability_And_bl

local stationcontrols index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And

local officercontrols ///
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
/*po_caste_dum_refuse_bl*/ po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank


//1. Regression for new technical skills index - no baseline measure since this index has new questions
reghdfe techindex_mergedonly treatment_bl /*index_Techskills_And_bl*/ `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl) // ps_dist_id_bl - station id
summ techindex_mergedonly if e(sample) == 1 & treatment_bl == 0


//2. Regression for interaction of treatment term with female constable variables
foreach var in q2008_ps_dum q2009_ps_dum q2010_ps_dum /*q2003_ps_dum*/ workdistr_ps_dum workdistr2_ps_dum fem_typical_ps_dum q3411_ps_dum q4003_ps_dum {
reghdfe index_Techskills_And_el i.treatment_bl##i.`var' index_Techskills_And_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl)
summ index_Techskills_And_el if e(sample) == 1 & treatment_el == 0
}


//3. Reporting for joint-significance - same model as in (2) but we add test 1.x1 1.x2 after equation to check for joint significance
foreach var in q2008_ps_dum q2009_ps_dum q2010_ps_dum q2003_ps_dum workdistr_ps_dum workdistr2_ps_dum fem_typical_ps_dum q3411_ps_dum q4003_ps_dum {
reghdfe index_Techskills_And_el i.treatment_bl##i.`var' index_Techskills_And_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl)
summ index_Techskills_And_el if e(sample) == 1 & treatment_el == 0
test 1.treatment_bl 1.`var'
}

//4. Reporting for joint-significance - this time, instead of using index_Techskills_And_el as the y variable, we use questions common to both male and female surveys
// Mapping (Male variable - Female variable): q801r_el_dum = q2008_ps_dum, q801s_el_dum = q2009_ps_dum, q801t_el_dum = q2010_ps_dum, q801m_el = q2003_ps_dum

reghdfe q801r_el_dum i.treatment_bl##i.q2008_ps_dum `sds' `stationcontrols' `officercontrols' , absorb(`stratafe') cluster (ps_dist_id_bl) // GBV vignette
summ q801r_el_dum if e(sample) == 1 & treatment_el == 0
test 1.treatment_bl 1.q2008_ps_dum

reghdfe q801s_el_dum i.treatment_bl##i.q2009_ps_dum `sds' `stationcontrols' `officercontrols' , absorb(`stratafe') cluster (ps_dist_id_bl) // Non-GBV vignette
summ q801s_el_dum if e(sample) == 1 & treatment_el == 0
test 1.treatment_bl 1.q2009_ps_dum

reghdfe q801t_el_dum i.treatment_bl##i.q2010_ps_dum `sds' `stationcontrols' `officercontrols' , absorb(`stratafe') cluster (ps_dist_id_bl) // Alcohol incident
summ q801t_el_dum if e(sample) == 1 & treatment_el == 0
test 1.treatment_bl 1.q2010_ps_dum

reghdfe q801m_el_dum i.treatment_bl##i.q2003_ps_dum `sds' `stationcontrols' `officercontrols' , absorb(`stratafe') cluster (ps_dist_id_bl) // useful to have females work on GBV cases
summ q801m_el if e(sample) == 1 & treatment_el == 0
test 1.treatment_bl 1.q2003_ps_dum

la define treatment_bl 0"Control" 1"Treatment"
la values treatment_bl treatment_bl

eststo clear
local count = 1
gen variable = 0
la define variable 0"Addl variable" 1"Addl variable"
la values variable variable
//5. Regression for joint-significance - using MO variables for interaction instead of FC variables
foreach var in /*q801m_el_dum*/ q801r_el_dum q801s_el_dum q801t_el_dum {
replace variable = `var' 
eststo model`count': reghdfe index_Techskills_And_el i.treatment_bl##i.variable index_Techskills_And_bl `sds' /// baseline controls
`stationcontrols' /// station controls
`officercontrols', /// officer controls
absorb(`stratafe') cluster (ps_dist_id_bl)
summ index_Techskills_And_el if e(sample) == 1 & treatment_el == 0
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
test 1.treatment_bl 1.variable
estadd scalar fvalue = r(p)

	local ++count
	
}



esttab model* using "$FC_survey_tables\table_jointsig_MO_Techskills_slides.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment_bl 1.variable 1.treatment_bl#1.variable) ///
	title("Joint significance for additional variables on technical skills of male officers") ///
	nonotes nonote ///
	mtitles ("GBV incident - Accompany" "Non-GBV incident - Accompany" "Alcohol incident - Accompany") ///
	scalars("cgmean Control mean" "fvalue Joint Significance" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_jointsig_MO_Techskills_slides.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{tiny}"
	file write myfile "\raggedright"
	file write myfile "  Source: Male officers' survey. \\"
	file write myfile "\end{tiny}"
	file write myfile "\end{flushleft}"
	file close myfile	

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_jointsig_MO_Techskills_slides.tex"
	local modified "modified_mytable_slides.tex"

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
        file write newfile "\caption{Joint significance for additional variables on technical skills of male officers}" _n
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






// Collapsing the male officers dataset to PS-level average - exploratory

use "$MO_endline_clean_dta\combined_FINAL_indices.dta", clear

//generating and recoding dummies for additional questions in endline that are relevant for Technical Skills

gen q801m_el_dum = q801m_el // It is useful to have female police officers to work on cases such as domestic violence
recode q801m_el_dum 1=1 2=0 3=0 4=0 5=0

gen q801r_el_dum = q801r_el //GBV vignette - female constable accompany
recode q801r_el_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen q801s_el_dum = q801s_el //non-GBV vignette - female constable accompany
recode q801s_el_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen q801t_el_dum = q801t_el //alcohol-related vignette - female constable accompany
recode q801t_el_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

ren index_Techskills_And_el ind_Tech_And_el
ren index_Techskills_And_bl ind_Tech_And_bl
ren index_Desirability_And_bl ind_Desir_And_bl


collapse (mean) q801r_el_dum q801s_el_dum q801t_el_dum q801m_el_dum ind_Tech_And_bl ind_Tech_And_el ind_Desir_And_bl, by(ps_dist_id_el) //collapsing to PS-level

//generating mean variables
foreach var of varlist q801r_el_dum q801s_el_dum q801t_el_dum q801m_el_dum ind_Tech_And_bl ind_Tech_And_el ind_Desir_And_bl {
	rename `var' mean_`var'_male
}


rename ps_dist_id_el ps_dist_id

ren index_psfs_gen_And ind_psfs_gen_And 
ren index_psfs_fem_infra_And ind_psfs_fem_infra_And 
ren index_psfs_m_f_seg_And ind_psfs_m_f_seg_And

merge m:1 ps_dist_id using "${clean_dta}femaleconstables_ps_avg.dta" //merging with collapsed female constables data
drop if _m == 2 //_m == 1 is 51, meaning 51 police stations that had no female officers assigned (at endline)


*Simple correlation

summ mean_q801r_el_dum_male q2008_ps_dum
corr mean_q801r_el_dum_male q2008_ps_dum // GBV vignette

summ mean_q801s_el_dum_male q2009_ps_dum
corr mean_q801s_el_dum_male q2009_ps_dum // Non-GBV vignette

summ mean_q801t_el_dum_male q2010_ps_dum 
corr mean_q801t_el_dum_male q2010_ps_dum // Alcohol incident

summ mean_q801m_el_dum_male q2003_ps_dum
corr mean_q801m_el_dum_male q2003_ps_dum // useful to have females work on GBV cases


******setting up macros
macro drop stratafe sds stationcontrols

local stratafe ps_dist strata // ps_dist - district

*local sds mean_ind_Desir_And_bl_male

local stationcontrols ind_psfs_gen_And ind_psfs_fem_infra_And ind_psfs_m_f_seg_And

*local officercontrols ///
po_age_bl bp_yearsofservice_bl ps_yearsofservice_bl po_marital_dum_bl /// age, years of service, and marital status
/*po_caste_dum_refuse_bl*/ po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl /// officer caste
po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl /// officer education
po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl /// officer rank


********Joint significance testing for PS-level averages - no desirability & officer controls and no clustering at PS-level (does not make sense because it is already at PS-level)
gen common_variable = 0
la define common_variable 0"Common variable" 1"Common variable"
la values common_variable common_variable
la define treatment 0"Control" 1"Treatment"
la values treatment treatment
eststo clear

replace common_variable = q2008_ps_dum
eststo model1: reghdfe mean_q801r_el_dum_male i.treatment##i.common_variable /*`sds'*/ `stationcontrols' /*`officercontrols'*/, absorb(`stratafe') /*cluster (ps_dist_id)*/ // GBV vignette
sum mean_q801r_el_dum_male if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "Yes"
test 1.treatment 1.common_variable
estadd scalar fvalue = r(p)

replace common_variable = q2009_ps_dum 
eststo model2: reghdfe mean_q801s_el_dum_male i.treatment##i.common_variable /*`sds'*/ `stationcontrols' /*`officercontrols'*/, absorb(`stratafe') /*cluster (ps_dist_id)*/ // Non-GBV vignette
sum mean_q801s_el_dum_male if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "Yes"
test 1.treatment 1.common_variable
estadd scalar fvalue = r(p)

replace common_variable = q2010_ps_dum
eststo model3: reghdfe mean_q801t_el_dum_male i.treatment##i.common_variable /*`sds'*/ `stationcontrols' /*`officercontrols'*/, absorb(`stratafe') /*cluster (ps_dist_id)*/ // Alcohol incident
sum mean_q801t_el_dum_male if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "Yes"
test 1.treatment 1.common_variable
estadd scalar fvalue = r(p)

/*
replace common_variable = q2003_ps_dum
eststo model4: reghdfe mean_q801m_el_dum_male i.treatment##i.common_variable /*`sds'*/ `stationcontrols' /*`officercontrols'*/, absorb(`stratafe') /*cluster (ps_dist_id)*/ // useful to have females work on GBV cases
sum mean_q801m_el_dum_male if e(sample) == 1 & treatment == 0
estadd scalar cgmean = r(mean)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local stationcontrol "Yes"
test 1.treatment 1.common_variable
estadd scalar fvalue = r(p)
*/

esttab model* using "$FC_survey_tables\table_ps_commonvars_slides.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (1.treatment 1.common_variable 1.treatment#1.common_variable) ///
	title("Treatment effects on common questions in MO and FC surveys (PS-level)") ///
	nonotes nonote ///
	mtitles ("GBV incident - Accompany" "Non-GBV incident - Accompany" "Alcohol incident - Accompany") ///
	scalars("cgmean Control mean" "fvalue Joint Significance" "FE Strata FE" "stationcontrol Station controls" "obs Number of stations") ///
	sfmt(2)

	cap file close _all
	file open myfile using "$FC_survey_tables\table_ps_commonvars_slides.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{tiny}"
	file write myfile "\raggedright"
	file write myfile " In each column, the dependent variable and the 'common' variable refer to the same variable in the MO and FC surveys respectively."
	file write myfile "  Source: Male officers' survey, female constables' survey. \\"
	file write myfile "\end{tiny}"
	file write myfile "\end{flushleft}"
	file close myfile	

	// Formatting Latex tables
cd "$tables" 	
	// Define file paths
	local original "table_ps_commonvars_slides.tex"
	local modified "modified_mytable_slides.tex"

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
        file write newfile "\caption{Treatment effects on common questions in MO and FC surveys (PS-level)}" _n
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

glu

******on index of technical skills
foreach var in q2008_ps_dum q2009_ps_dum q2010_ps_dum q2003_ps_dum workdistr_ps_dum workdistr2_ps_dum fem_typical_ps_dum q3411_ps_dum q4003_ps_dum {
reghdfe mean_ind_Tech_And_el_male i.treatment_bl##i.`var' mean_ind_Tech_And_bl_male, absorb(`stratafe') cluster (ps_dist_id_bl)
summ mean_ind_Tech_And_el_male if e(sample) == 1 & treatment_el == 0
test 1.treatment_bl 1.`var'
}
