/*==============================================================================
File Name: Female Constables Survey 2022 - Indices do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	16/05/2024
Created by: Dibyajyoti Basak
Updated on: 16/05/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to perform the error and logical consistency checks on the Baseline Officer's Survey 2022. 

*	Inputs: 02.intermediate-data  "02.ren-officersurvey_intermediate"
*	Outputs: 06.clean-data  "01.officersurvey_clean_PII"

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

log using "$Wives_survey_log_files\wivessurvey_regression.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$Wives_survey_clean_dta\wivessurvey_clean.dta"

recode treatment 0=1 1=0

swindex q2001_dum q2002_dum q2003_dum q2004_dum q2006_dum q2007_dum q2008_dum q2009_dum, g(swindex_Communication) normby(treatment) displayw

swindex q3001_dum q3002_dum q3003_dum q3004_dum /*q3005_dum*/, g(swindex_Atti_GBV_Spouse) normby(treatment) displayw

swindex rsbec2_dum rsbec4_dum rsbec9_dum rsbec14_dum rsbec18_dum rsbec20_dum rsbec22_dum, g(swindex_Perc_Empathy_Spouse) normby(treatment) displayw

swindex q6001 q6002 q6003 q6004 q6005 q6006 q6007 q6008, g(swindex_Belief_Eq_Spouse) normby(treatment) displayw

swindex q7001 q7002 q7003 q7004 q7005 q7006 q7007 q7008 q7009 q7010 q7011 q7012 q7013, g(swindex_Desirability_wiv) normby(treatment) displayw

recode treatment 0=1 1=0

label variable swindex_Communication "Communication and conflict resolution"
label variable swindex_Atti_GBV_Spouse "Attitudes towards GBV (of spouse)"
label variable swindex_Perc_Empathy_Spouse "Perceived empathy (of spouse)"
label variable swindex_Belief_Eq_Spouse "Beliefs on gender equality (of spouse)"
label variable swindex_Desirability_wiv "Social Desirability"


foreach i of varlist swindex_Communication swindex_Atti_GBV_Spouse swindex_Perc_Empathy_Spouse swindex_Belief_Eq_Spouse {
	
eststo clear // Clear any previously stored estimation results

//Estimation 1
eststo model1: reghdfe `i' treatment, absorb(ps_dist strata) cluster (ps_dist_id)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "No"

//Estimation 2
eststo model2: reghdfe `i' treatment swindex_Desirability_wiv, /// Baseline Controls
absorb(ps_dist strata) cluster (ps_dist_id) //including strata variables
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
estadd local Control "Yes"


esttab model1 model2 using "$Wives_survey_tables\regression_table_`i'.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on `: var lab `i'' (Officer wives)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "Control Controlled for SDB" "obs Number of officers") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\regression_table_`i'.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the district level (in parantheses)."
	file write myfile " All regressions include district fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	}

// Formatting Latex tables
cd "$Wives_survey_tables\"
foreach i of varlist swindex_Communication swindex_Atti_GBV_Spouse swindex_Perc_Empathy_Spouse swindex_Belief_Eq_Spouse {	
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

//Regression for Communication and Conflict Resolution Index (Pt 1)
foreach i in q2001_dum q2002_dum q2003_dum q2004_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_Communication1.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Communication & Conflict Resolution (1)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_Communication1.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) My partner showed respect for my feelings about an issue. \\"
	file write myfile "(2) Sought help by bringing in someone to settle the issue. \\"
	file write myfile "(3) My partner showed respect for, or showed that he cared about my feelings about an issue we disagreed on. \\"
	file write myfile "(4) Does he get impatient when you talk to him about household repairs/chores/upkeep?. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results

//Regression for Communication and Conflict Resolution Index (Pt 2)
foreach i in q2006_dum q2007_dum q2008_dum q2009_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_Communication2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Communication & Conflict Resolution (2)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_Communication2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Does your husband calmly listen to you when you share your problems with him? \\"
	file write myfile "(2) Stomped out of the room or house or yard during a disagreement. \\"
	file write myfile "(3) Refused to talk about an issue. \\"
	file write myfile "(4) My partner explains his side or suggests a compromise for a disagreement with me. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	

//Regression for Attitudes towards GBV Index
foreach i in q3001_dum q3002_dum q3003_dum q3004_dum q3005_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_Atti_GBV_wives.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Attitudes towards GBV") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_Atti_GBV_wives.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) \textless{}GBV incident\textgreater{} If you read this in today's paper, would you discuss this with your partner? \\"
	file write myfile "(2) Imagine that this case was being handled by your partner's thana, would you feel comfortable in asking about the progress of the case? \\"
	file write myfile "(3) Do you think your partner is likely to believe or feel that the boy was justified in his actions in this situation? \\"
	file write myfile "(4) How likely do you think it is that your partner will say or feel that to some extent the girl and her family were also at fault for not meeting the demands of the boy and his family? \\"
	file write myfile "(5) How likely is it that your husband would file this case if it happened in his thana? \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	

//Regression for Perceived Empathy Index (Pt 1)
foreach i in rsbec2_dum rsbec4_dum rsbec9_dum rsbec14_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_PerceivedEmpathy1.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Perceived Empathy (1)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_PerceivedEmpathy1.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) My husband has tender, concerned feelings for people less fortunate than him. \\"
	file write myfile "(2) Sometimes my husband does not feel very sorry for other people when they are having problems. \\"
	file write myfile "(3) When my husband sees someone being taken advantage of, he feels kind of protective towards them. \\"
	file write myfile "(4) Other people's misfortunes does not usually disturb my husband a great deal. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	

//Regression for Perceived Empathy Index (Pt 2)
foreach i in rsbec18_dum rsbec20_dum rsbec22_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_PerceivedEmpathy2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Perceived Empathy (2)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_PerceivedEmpathy2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) When my husband sees someone being treated unfairly, he sometimes does not feel very much pity for them. \\"
	file write myfile "(2) My husband is often quite touched by things that he sees happening. \\"
	file write myfile "(3) I would describe my husband as a a pretty soft-hearted person. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile	

	
eststo clear // Clear any previously stored estimation results	

//Regression for Gender Equality Index (Pt 1)
foreach i in q6001_dum q6002_dum q6003_dum q6004_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_GenderEquality_1.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Beliefs about Gender Equality (1)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_GenderEquality_1.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) My spouse believes that male and female constables do the same work in a police station. \\"
	file write myfile "(2) My spouse believes that male and female constables have the same capability when it comes to their job. \\"
	file write myfile "(3) My spouse treats all his children equally. \\"
	file write myfile "(4) My spouse believes a woman can do the same work as a man. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	

//Regression for Gender Equality Index (Pt 2)
foreach i in q6005_dum q6006_dum q6007_dum q6008_dum{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_GenderEquality_2.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Beliefs about Gender Equality (2)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_GenderEquality_2.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) My spouse believes that a woman's place is inside the home. \\"
	file write myfile "(2) My spouse believes that childcare is primarily a woman's responsibility. \\"
	file write myfile "(3) My spouse is okay with me working outside the home for pay. \\"
	file write myfile "(4) My spouse lets me have an equal say in decision-making. \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile

eststo clear // Clear any previously stored estimation results	


rename index_Spouse_Empathy_And ind_Empathy_And
//Regression for Indices
foreach i in index_Comm_And /*index_Spouse_Atti_And*/ ind_Empathy_And index_Belief_And{
// Export regression results to LaTeX table
local count = 0
// Estimation 1
eststo model`count': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
local ++count
}
esttab model* using "$Wives_survey_tables\table_Wives_Indices_And.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Indices (Anderson)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_Wives_Indices_And.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Communication and Conflict Resolution \\"
	file write myfile "(2) Attitudes toward GBV (spouse) \\"
	file write myfile "(3) Perceived empathy (spouse) \\"
	file write myfile "(4) Beliefs about gender equality (spouse) \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
	
eststo clear // Clear any previously stored estimation results	

rename index_Spouse_Empathy_Reg ind_Empathy_Reg
//Regression for Indices
foreach i in index_Comm_Reg index_Spouse_Atti_Reg ind_Empathy_Reg index_Belief_Reg{
// Export regression results to LaTeX table

// Estimation 1
eststo model`i': reghdfe `i' treatment, absorb(ps_dist po_grandtotal)
sum `i' if e(sample) == 1 & treatment == 0
local control_mean = r(mean)
estadd scalar cgmean = `control_mean'
estadd local obs = string(e(N))
estadd local FE "Yes"
}
esttab model* using "$Wives_survey_tables\table_Wives_Indices_Reg.tex" , replace ///
	b(2) se(2)  label noconstant booktabs ///
	star(* 0.10 ** 0.05 *** 0.01) r2 ///
	noobs ///
	keep (treatment) ///
	title("Treatment Effects on Indices (Regular)") ///
	nonotes nomtitles nonote ///
	scalars("cgmean Control mean" "FE Strata FE" "obs Number of wives") ///
	sfmt(2)
	
	
cap file close _all
	file open myfile using "$Wives_survey_tables\table_Wives_Indices_Reg.tex", write append
	file write myfile "\vspace{-\baselineskip}"
	file write myfile "\begin{flushleft}"
	file write myfile "\begin{small}"
	file write myfile "\raggedright"
	file write myfile "\textit{Notes}: Standard errors clustered at the station level (in parentheses)."
	file write myfile " All regressions include district and officer strength (at the station level) fixed effects."
	file write myfile "  All the columns use survey data."
	file write myfile " $^* p<0.10$, $^{**} p<0.05$, $^{***} p<0.01.$ \\"
	file write myfile "(1) Communication and Conflict Resolution \\"
	file write myfile "(2) Attitudes toward GBV (spouse) \\"
	file write myfile "(3) Perceived empathy (spouse) \\"
	file write myfile "(4) Beliefs about gender equality (spouse) \\"
	file write myfile "\end{small}"
	file write myfile "\end{flushleft}"
	file close myfile
