/*==============================================================================
File Name: Female Constables Survey 2022 - Analysis File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	26/09/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to perform the analysis on the female constables survey 

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
	

******************MALE OFFICERS DATA******************
use "$MO_endline_clean_dta\combined_FINAL_indices.dta", clear

*****NOTE: We have tracked police station at baseline (ps_dist_id_bl) and police station at endline (ps_dist_id_el)
*****For collapsing the officer data to station level and to get average index value (in this case for technical skills) for each station, we use the endline police station id - ps_dist_id_el

bysort ps_dist_id_el: egen techskills_ps = mean(index_Techskills_And_el) //generating average index value at PS-level
duplicates drop ps_dist_id_el, force
keep ps_dist_id_el treatment_bl techskills_ps
*collapse techskills_ps, by(ps_dist_id_el) //collapsing to PS-level dataset
summ techskills_ps, detail
gen median_techskills_ps = r(p50) //creating a variable that stores median value of index
gen dum_techskills = 0
replace dum_techskills = 1 if techskills_ps > median_techskills_ps //creating dummy that takes value if the average index value at the PS-level is greater than the median value
la define dum_techskills 0"Below Median" 1"Above Median"
label values dum_techskills dum_techskills
la define treatment_bl 0"Control" 1"Treatment"
label values treatment_bl treatment_bl
rename ps_dist_id_el ps_dist_id
tempfile techskills_endline
save `techskills_endline'

******************FEMALE CONSTABLES******************

use "$FC_survey_clean_dta\femaleconstables_indices.dta", clear

merge m:1 ps_dist_id using `techskills_endline' //merging female constables data with techskills dummy
drop if _m != 3 //all data merged from female constables data, _merge == 1 has 0 observations
drop _m

la define treatment 0"Control" 1"Treatment"
label values treatment treatment

******generating dummy for variable C3 - "What are the major constraints that you face while handling the GBV cases?"
gen c3_dum = regexm(c3, "(^| )3($| )")

*****generating female officer age
gen fem_po_age = 2023 - q1001
replace fem_po_age = . if fem_po_age > 60 // 1 observation with age above 60 years

*********imputing age (other control variables in continuous form can also be imputed here)
levelsof ps_dist, local (district) 
levelsof ps_dist_id, local (policestation)
						
						foreach i of local district  {
							foreach j of local  policestation {
								foreach k of varlist fem_po_age  {
									su `k' if ps_dist ==`i' & ps_dist_id =="`j'"
									replace `k' = r(mean) if ps_dist==`i' & ps_dist_id =="`j'" & `k'==.
								}
							}
						}
					
****Creating simple index using egen = rowmean() for selected variables
egen index_reg_femconstables = rowmean(q2008_dum q2009_dum q2010_dum workdistr_dum fem_typical_dum q3411_dum q2003_dum q4003_dum /*c3_dum*/)
										
****setting up macros for running regressions
global stationcontrols index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_And //station level controls

global officercontrols fem_po_age fem_bpservice_years fem_psservice_years fem_po_marital_dum /// officer age, years of service in BP and current PS, and marital status
fem_po_caste_dum_sc fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general ///officer caste
fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma //officer education

global fem_sdb index_Desirability_And_fem //officer social desirability

global stratafe ps_dist strata //strata variables

global additionalcontrols road_length_km policestrength_perlakhpop elevation_mean tri_mean avgdistance_healthfacility

/*
****Approach 1
foreach var of varlist q2008_dum q2009_dum q2010_dum workdistribution fem_typical_case q3411_dum q2003_dum q4003_dum c3_dum {
	gen interaction_`var' = treatment * `var'
	reghdfe dum_techskills interaction_`var' $fem_sdb $stationcontrols /*$additionalcontrols*/ $officercontrols if treatment == 1, absorb($stratafe) cluster(ps_dist_id)
}

gen interaction_techindex = treatment * index_femaleconstables
reghdfe dum_techskills interaction_techindex $fem_sdb $stationcontrols /*$additionalcontrols*/ $officercontrols if treatment == 1, absorb($stratafe) cluster(ps_dist_id)

glu

****Approach 2

foreach var of varlist q2008_dum q2009_dum q2010_dum workdistribution fem_typical_case q3411_dum q2003_dum q4003_dum c3_dum {
	reghdfe dum_techskills i.treatment##i.`var' $fem_sdb $stationcontrols /*$additionalcontrols*/ $officercontrols if treatment == 1, absorb($stratafe) cluster(ps_dist_id)
}

reghdfe dum_techskills i.treatment##c.index_femaleconstables $fem_sdb $stationcontrols /*$additionalcontrols*/ $officercontrols if treatment == 1, absorb($stratafe) cluster(ps_dist_id)
*/

drop q2008_dum q2009_dum q2010_dum

gen q2008_dum = q2008
recode q2008_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
gen q2009_dum = q2009
recode q2009_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
gen q2010_dum = q2010
recode q2010_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

eststo clear

local count = 1
//Regression for linked variables
foreach var in q2008_dum q2009_dum q2010_dum /*workdistribution fem_typical_case q3411_dum q2003_dum q4003_dum c3_dum*/{
// Export regression results to LaTeX table
gen interaction_`var' = treatment * `var'
rename interaction_`var' interaction
// Estimation 1
eststo model`count': reghdfe dum_techskills interaction $fem_sdb $stationcontrols $officercontrols, absorb($stratafe) cluster(ps_dist_id)
sum `var' if e(sample) == 1 & treatment == 1
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"
local count = `count' + 1
drop interaction
}

gen interaction = treatment * index_reg_femconstables
la var interaction "TechSkills x Interaction"

eststo model10: reghdfe dum_techskills interaction $fem_sdb $stationcontrols $officercontrols if treatment == 1, absorb($stratafe) cluster(ps_dist_id)
sum index_reg_femconstables if e(sample) == 1 & treatment == 1
estadd scalar cgmean =  r(mean)
estadd local clusters = e(N_clust)
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local SDB "Yes"
estadd local stationcontrol "Yes"
estadd local fem_officer "Yes"

esttab model* using "$FC_survey_tables\table_linkedvariables.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (interaction) ///
	title("Treatment effects on linked variables") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Treatment mean" "FE Strata FE" "SDB Desirability" "stationcontrol Station controls" "fem_officer Officer controls" "clusters Number of clusters" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$FC_survey_tables\table_linkedvariables.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile " The regression sample is restricted to the treatment group."
	file write myfile " TechSkills refers to a station-level dummy which takes value if the average index value for technical skills \textit{male officers} in that PS is greater than the median value. Interaction refers to interaction of treatment and the variable of interest." 
	file write myfile " All regressions include social desirability, station-level indices on general infrastructure, facilities for female officers, and ratio of male-female officers, and officer age, caste, years of service in Bihar Police and in current police station, educational qualification, and marital status."
	file write myfile "  Source: Female constables' survey."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) \textless{}GBV incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(2) \textless{}non-GBV incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(3) \textless{}alcohol-related incident\textgreater{} Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station? \\"
	file write myfile "(4) Work distribution of female officers (= 1 if involved in GBV-related case in past 7 days). \\"
	file write myfile "(5) Typical case assigned to female officers (= 1 if GBV-related case). \\"
	file write myfile "(6) Female constables work on more women's related cases than male constables. \\"
	file write myfile "(7) It is useful to have female police officers to work on cases of crimes against women. \\"  
	file write myfile "(8) On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards female complainants? \\"
	file write myfile "*(9) (direction change) Major constraints that female officers face while handling GBV cases (= 1 if senior officer does not prioritise the case). \\"
	file write myfile "(10) Regular index of items 1-8. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

// Define file paths
cd "$FC_survey_tables\"
local original "table_linkedvariables.tex"  // Original LaTeX file
local modified "modified_table.tex"  // Modified file to be written

// Open the original LaTeX file for reading
file open myfile using "`original'", read text

// Open a new file for writing the modified content
file open newfile using "`modified'", write text replace

// Read the first line from the original file
file read myfile line

// Loop through the file until the end is reached
while r(eof) == 0 {
    // Check if the line contains the \begin{table} command
    if strpos("`line'", "\begin{table}[htbp]\centering") {
        // Write the \begin{table} line to the new file
        file write newfile "`line'" _n
        
        // Write the resizebox command right after
        file write newfile "\resizebox{\textwidth}{!}{" _n
    }
    // Check if the line contains the \end{tabular} command
    else if strpos("`line'", "\end{tabular}") {
        // Write the \end{tabular} line to the new file
        file write newfile "`line'" _n
        
        // Write the closing brace `}` on the next line
        file write newfile "}" _n
    } 
	else {
        // Write the original line as is to the new file if no modification is needed
        file write newfile "`line'" _n
    }

    // Read the next line for the loop
    file read myfile line
}

// Close the original and new files
file close myfile
file close newfile

// Replace the original file with the modified one
capture confirm file "`original'"
if !_rc {
    erase "`original'"
}

shell move "`modified'" "`original'"


eststo clear // Clear any previously stored estimation results	


