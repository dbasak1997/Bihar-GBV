/*==============================================================================
File Name: FIR Data - Regressions
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/05/2024
Created by: Dibyajyoti Basak
Updated on: 03/05/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to run regressions on the FIR Data. 


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

log using "$fir_data_log_files\firdata_tables.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


use "$fir_data_clean_dta\ps_fir_stationmonth", clear

order ps_dist ps_dist_id ps_name treatment modate po_grandtotal
drop wgt stdgroup

drop index_psfs_gen_And index_psfs_gen_Reg index_psfs_fem_infra_And index_psfs_fem_infra_Reg index_psfs_m_f_seg_And index_psfs_m_f_seg_Reg dum_petty
gen wgt = 1
gen stdgroup = 1
 **creating the PSFS (General) index (Anderson)
qui do "$fir_data_do_files\make_index_gr.do" //Execute Anderson index do file
local psfs_gen ps_bathroom  ps_confidential ps_electricity dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv 
make_index_gr psfs_gen_And wgt stdgroup `psfs_gen' if key != ""
egen std_index_psfs_gen_And = std(index_psfs_gen_And)
label var index_psfs_gen_And "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_And

**creating the PSFS (General) index (Regular)
egen index_psfs_gen_Reg = rowmean(ps_bathroom ps_confidential ps_electricity dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv)
label var index_psfs_gen_Reg "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_Reg

 **creating the PSFS (Fem Infra) index (Anderson)

local psfs_fem_infra ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter 
make_index_gr psfs_fem_infra_And wgt stdgroup `psfs_fem_infra' if key != ""
egen std_index_psfs_fem_infra_And = std(index_psfs_fem_infra_And)
label var index_psfs_fem_infra_And "Police Station Gender Facilities Index (Anderson)"
summ index_psfs_fem_infra_And

**creating the PSFS (Fem Infra) index (Regular)
egen index_psfs_fem_infra_Reg = rowmean(ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter)
label var index_psfs_fem_infra_Reg "Police Station Gender Facilities Index (Regular)"
summ index_psfs_fem_infra_Reg

**creating the PSFS (Male-Female Segregation) index (Anderson)

local psfs_m_f_seg_1 dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho
make_index_gr psfs_m_f_seg_And wgt stdgroup `psfs_m_f_seg_1' if key != ""
egen std_index_psfs_m_f_seg_And = std(index_psfs_m_f_seg_And)
label var index_psfs_m_f_seg_And "PSFS (Male-Female Segregation) Index (Anderson)"
summ index_psfs_m_f_seg_And 

**creating the PSFS (Male-Female Segregation) index (Regular)
egen index_psfs_m_f_seg_Reg = rowmean(dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho)
label var index_psfs_m_f_seg_Reg "PSFS (Male-Female Segregation) Index (Regular)"
summ index_psfs_m_f_seg_Reg

****swindex - PSFS

recode treatment 0=1 1=0

swindex ps_bathroom ps_confidential dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv, g(swindex_psfs_gen) normby(treatment) displayw

swindex ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter, g(swindex_psfs_fem_infra) normby(treatment) displayw

swindex dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho, g(swindex_psfs_m_f_seg) normby(treatment) displayw

recode treatment 0=1 1=0

************

*reghdfe dum_femalecomplainant treatment, absorb(ps_dist po_grandtotal)
*reghdfe dum_femalecomplainant treatment index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg, absorb(ps_dist po_grandtotal)

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

tempfile temp
save `temp'.dta, replace

use "$decoy_clean_dta\decoy_indices.dta", clear
drop key-psfs_m_f_seg_Reg
drop wgt stdgroup empathy_And_decoy empathy_Reg_decoy VB_And_decoy VB_Reg_decoy Ext_And_decoy Ext_Reg_decoy swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy swindex_Empathy_decoy1 swindex_VictimBlame_decoy1 swindex_ExtPol_decoy1 swindex_Empathy_decoy2 swindex_VictimBlame_decoy2 swindex_ExtPol_decoy2 swindex_Empathy_decoy3 swindex_VictimBlame_decoy3 swindex_ExtPol_decoy3 swindex_psfs_gen swindex_psfs_fem_infra swindex_psfs_m_f_seg
save "$decoy_intermediate_dta\decoy_indices_clean.dta", replace

use `temp'.dta, clear
rename ps_dist_id ps_dist_id_decoy
merge m:1 ps_dist_id_decoy using "$decoy_intermediate_dta\decoy_indices_clean.dta"
rename ps_dist_id_decoy ps_dist_id

*******swindex - Decoy
recode treatment 0=1 1=0

swindex d1a_visit1_dum-d1e_visit3_dum d1d* if _m == 3, g(swindex_Empathy_decoy) normby(treatment) displayw

swindex d2a_visit1_dum-d2c_visit3_dum if _m == 3, g(swindex_VictimBlame_decoy) normby(treatment) displayw

swindex d4a_visit1_dum-d4c_visit3_dum if _m == 3, g(swindex_ExtPol_decoy) normby(treatment) displayw

***Visit 1
swindex d1a_visit1_dum-d1e_visit1_dum d1d_visit1 if _m == 3, g(swindex_Empathy_decoy1) normby(treatment) displayw
swindex d2a_visit1_dum-d2c_visit1_dum if _m == 3, g(swindex_VictimBlame_decoy1) normby(treatment) displayw
swindex d4a_visit1_dum-d4c_visit1_dum if _m == 3, g(swindex_ExtPol_decoy1) normby(treatment) displayw

***Visit 2
swindex d1a_visit2_dum-d1e_visit2_dum d1d_visit2 if _m == 3, g(swindex_Empathy_decoy2) normby(treatment) displayw
swindex d2a_visit2_dum-d2c_visit2_dum if _m == 3, g(swindex_VictimBlame_decoy2) normby(treatment) displayw
swindex d4a_visit2_dum-d4c_visit2_dum, g(swindex_ExtPol_decoy2) normby(treatment) displayw

***Visit 3
swindex d1a_visit3_dum-d1e_visit3_dum d1d_visit3 if _m == 3, g(swindex_Empathy_decoy3) normby(treatment) displayw
swindex d2a_visit3_dum-d2c_visit3_dum if _m == 3, g(swindex_VictimBlame_decoy3) normby(treatment) displayw
swindex d4a_visit3_dum-d4c_visit3_dum if _m == 3, g(swindex_ExtPol_decoy3) normby(treatment) displayw

recode treatment 0=1 1=0

***************************

***********Regression for station-months (reghdfe)***********

foreach i in dum_femalecomplainant dum_gbv dum_female_gbv dum_malecomplainant dum_male_gbv count_cases dum_375 dum_376 dum_511 dum_rape_attempt dum_unnatural dum_362 dum_363 dum_kidnapping dum_302 dum_304b dum_306 dum_murder dum_cruelty dum_354 dum_298 dum_harassment dum_modesty dum_418 dum_420 dum_cheating dum_503 dum_506 dum_intimidation dum_66 dum_67 dum_292 dum_onlineharassment pct_gbv pct_femalecomplainant pct_female_gbv_totalcases pct_female_gbv_totalgbv pct_malecomplainant pct_male_gbv_totalcases pct_male_gbv_totalgbv std_pct_femalecomplainant std_pct_gbv std_pct_female_gbv_totalcases std_pct_female_gbv_totalgbv std_pct_malecomplainant std_pct_male_gbv_totalcases std_pct_male_gbv_totalgbv {

eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' treatment, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "No"
estadd local Control "No"
estadd local Control_2 "No"
estadd local Decoy "No"

//Estimation 2
eststo model2: reghdfe `i' treatment index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Control_2 "No"
estadd local Decoy "No"

//Estimation 3
eststo model3: reghdfe `i' treatment index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And ///
swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy, /// decoy indices
 absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
estadd local Control "Yes"
estadd local Control_2 "No"
estadd local Decoy "Yes"

//Estimation 4
eststo model4: reghdfe `i' treatment index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg, absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
estadd local Control "No"
estadd local Control_2 "Yes"
estadd local Decoy "No"

//Estimation 5
eststo model5: reghdfe `i' treatment index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg ///
swindex_Empathy_decoy swindex_VictimBlame_decoy swindex_ExtPol_decoy, /// decoy indices
absorb(ps_dist strata) cluster(ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
*estadd local Baseline "Yes"
estadd local Control "No"
estadd local Control_2 "Yes"
estadd local Decoy "Yes"

esttab model1 model2 model3 model4 model5 using "$decoy_tables\regression_table_`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on `: var lab `i''") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Control Station controls (Anderson)" "Control_2 Station controls (Regular)" "Decoy Decoy controls" "obs Number of station-months") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$decoy_tables\regression_table_`i'.tex", write append
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
	}

// Formatting Latex tables
cd "$decoy_tables\"
foreach i in dum_femalecomplainant dum_gbv dum_female_gbv dum_malecomplainant dum_male_gbv count_cases dum_375 dum_376 dum_511 dum_rape_attempt dum_unnatural dum_362 dum_363 dum_kidnapping dum_302 dum_304b dum_306 dum_murder dum_cruelty dum_354 dum_298 dum_harassment dum_modesty dum_418 dum_420 dum_cheating dum_503 dum_506 dum_intimidation dum_66 dum_67 dum_292 dum_onlineharassment pct_gbv pct_femalecomplainant pct_female_gbv_totalcases pct_female_gbv_totalgbv pct_malecomplainant pct_male_gbv_totalcases pct_male_gbv_totalgbv std_pct_femalecomplainant std_pct_gbv std_pct_female_gbv_totalcases std_pct_female_gbv_totalgbv std_pct_malecomplainant std_pct_male_gbv_totalcases std_pct_male_gbv_totalgbv {	
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

