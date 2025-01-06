/*==============================================================================
File Name: Coefficient Plots
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	04/12/2024
Created by: Dibyajyoti Basak
Updated on: 04/12/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to create coefficient plots for the regression models


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

log using "$MO_endline_log_files\graphs_coefficientplots.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\combined_FINAL_indices.dta", clear

// * #1 Coefficient plot with 3 MO outcomes - Combined (Technical+Soft), Technical, Soft
// NOTE: ALL FIGURES REPORTED ARE A) FOR OFFICERS WHO WERE NOT TRANSFERRED and B) WITH NO CONTROLS INCLUDED
****************************************************************************************

eststo clear
local count = 1
foreach var in index_Combined_And2 index_Techskills_And index_Combined_And  {
    eststo model`count': reghdfe `var'_el treatment_bl if dum_transfer == 0, absorb(ps_dist_bl strata_bl) cluster(ps_dist_id_bl)
    local ++count
}

* #1 Coefficient plot with 3 MO outcomes - Combined (Technical+Soft), Technical, Soft
coefplot (model1, label("Gender and GBV Skills")) /// adding the combined skills model
         (model2, label("Technical GBV Skills")) /// adding the technical skills model
         (model3, label("Soft Gender and GBV Skills")), /// adding the soft skills model
		 ciopts(recast(rcap)) /// adding confidence interval caps
		 mlabpos(2.1) /// setting label position
		 mlabel(cond(@pval<.001, "<0.001" + "***", /// printing p-values
		 cond(@pval<.01, string(@pval,"%9.3f") + "**", ///
		 cond(@pval<.05, string(@pval,"%9.3f") + "*", ///
		 string(@pval,"%9.3f"))))) ///
		 keep(treatment_bl) /// keeping only coefficient of treatment variable
		 xline(0) /// setting a vertical line at x=0
		 xtick(-0.4 0 0.4) /// extending the x-range of the plot
		 xlabel (-0.4 "-.4" -0.3 "-.3" -0.25 "-.25" -0.2 "-.2" -0.15 "-.15" -0.1 "-.1" -0.05 "-.05" 0 "0" 0.4 ".4", add) ///labelling the x-axis
		 xlabel(,labsize(small))
		 
		 
graph save "$MO_endline_graphs\Coefficient Plots_3Outcomes.gph", replace
graph export "$MO_endline_graphs\Coefficient Plots_3Outcomes.png", replace

// * #2 Coefficient plot with 4 MO outcomes - Same as #1 with Reflection Scales
// NOTE: Same as #1 but for Reflection scales, we did not track transfers at that time
****************************************************************************************

use "$reflection\06.clean-data\reflection_clean_merged.dta", clear

rename treatment treatment_bl
eststo model4: reghdfe swindex_Reflection treatment_bl, absorb(ps_dist strata) cluster(ps_dist_id)

* #1 Coefficient plot with 3 MO outcomes - Combined (Technical+Soft), Technical, Soft
coefplot (model1, label("Gender and GBV Skills")) /// adding the combined skills model
         (model2, label("Technical GBV Skills")) /// adding the technical skills model
         (model3, label("Soft Gender and GBV Skills")) /// adding the soft skills model
		 (model4, label("Reflection Scales")), /// adding the Reflection scales model
		 ciopts(recast(rcap)) /// adding confidence interval caps
		 mlabpos(2.1) /// setting label position
		 mlabel(cond(@pval<.001, "<0.001" + "***", /// printing p-values
		 cond(@pval<.01, string(@pval,"%9.3f") + "**", ///
		 cond(@pval<.05, string(@pval,"%9.3f") + "*", ///
		 string(@pval,"%9.3f"))))) ///
		 keep(treatment_bl) /// keeping only coefficient of treatment variable
		 xline(0) /// setting a vertical line at x=0
		 xtick(-0.4 0 0.4) /// extending the x-range of the plot
		 xlabel (-0.4 "-.4" -0.3 "-.3" -0.2 "-.2" -0.1 "-.1" 0 "0" 0.4 ".4", add) //labelling the x-axis		 
		 
		 
graph save "$MO_endline_graphs\Coefficient Plots_4Outcomes.gph", replace
graph export "$MO_endline_graphs\Coefficient Plots_4Outcomes.png", replace
		 
// * #3 Coefficient plot with indices within Soft skills index
// NOTE: ALL FIGURES REPORTED ARE A) FOR OFFICERS WHO WERE NOT TRANSFERRED and B) WITH NO CONTROLS INCLUDED
****************************************************************************************

use "$clean_dta\combined_FINAL_indices.dta", clear

eststo clear
local count = 1
foreach var in index_Empathy_And index_Discrimination_And index_Truth_And index_VictimBlame_And index_AttitudeGBV_And index_ExtPol_And index_Flexibility_And {
    eststo model`count': reghdfe `var'_el treatment_bl if dum_transfer == 0, absorb(ps_dist_bl strata_bl) cluster(ps_dist_id_bl)
    local ++count
}

coefplot (model1, label("Empathy")) /// adding the Empathy model
		 (model2, label("Discrimination")) /// adding the Discrimination model
         (model3, label("Truthfulness of complaints")) /// adding the Truthfulness model
		 (model4, label("Victim-blaming")) /// adding the Victim-blaming model
		 (model5, label("Attitudes towards GBV")) /// adding the Attitudes towards GBV model
		 (model6, label("Externalising responsibilities")) /// adding the Externalising responsibilities skills model
		 (model7, label("Flexibility")), /// adding the Flexibility model
		 keep(treatment_bl) /// keeping only coefficient of treatment variable
		 ciopts(recast(rcap)) /// adding confidence interval caps
		 mlabpos(2.1) /// setting label position
		 mlabel(cond(@pval<.001, "<0.001" + "***", /// printing p-values
		 cond(@pval<.01, string(@pval,"%9.3f") + "**", ///
		 cond(@pval<.05, string(@pval,"%9.3f") + "*", ///
		 string(@pval,"%9.3f"))))) ///
		 xline(0) /// setting a vertical line at x=0
		 xtick(-0.4 0 0.4) /// extending the x-range of the plot
		 xlabel (-0.4 "-.4" -0.3 "-.3" -0.2 "-.2" -0.1 "-.1" 0 "0" 0.4 ".4", add) //labelling the x-axis		 

		 
graph save "$MO_endline_graphs\Coefficient Plots_SoftSkills.gph", replace
graph export "$MO_endline_graphs\Coefficient Plots_SoftSkills.png", replace
		
// * #4 Coefficient plot of variables within Technical skills index
// NOTE: ALL FIGURES REPORTED ARE A) FOR OFFICERS WHO WERE NOT TRANSFERRED and B) WITH NO CONTROLS INCLUDED
****************************************************************************************

eststo clear
local count = 1
foreach var in dv_compl_rel_dum sa_burden_proof_dum eviction_dv_dum fem_shelter_dum verbal_abuse_public_dum verbal_abuse_ipc_dum sa_identity_leaked_dum sa_identity_ipc_dum {
    eststo Question`count': reghdfe `var'_el treatment_bl if dum_transfer == 0, absorb(ps_dist_bl strata_bl) cluster(ps_dist_id_bl)
    local ++count
}

coefplot Question*, ///
		 keep(treatment_bl) /// keeping only coefficient of treatment variable
		 ciopts(recast(rcap)) /// adding confidence interval caps
		 mlabpos(2.1) /// setting label position
		 mlabel(cond(@pval<.001, "<0.001" + "***", /// printing p-values
		 cond(@pval<.01, string(@pval,"%9.3f") + "**", ///
		 cond(@pval<.05, string(@pval,"%9.3f") + "*", ///
		 string(@pval,"%9.3f"))))) ///
		 xline(0) /// setting a vertical line at x=0
		 xtick(-0.4 0 0.4) /// extending the x-range of the plot
		 xlabel (-0.4 "-.4" -0.15 "-.15" -0.1 "-.1"  0 "0" 0.4 ".4", add) ///labelling the start and end of the x-axis
		 note("#1 - <GBV vignette> Can a relative of the victim file complaint?" "#2 - <GBV vignette> With whom does the burden of proof lie?" "#3 - <Eviction from matrimonial house> Does this constitute GBV?" "#4 - Should the police offer shelter to a GBV victim?" "#5 - <Verbal abuse> Is this a chargeable offense?" "#6 - If yes, which section of IPC is applicable?" "#7 - <Colleague reveals identity of severe GBV victim> Is this a chargeable offense?" "#8 - If yes, which section of IPC is applicable?")
		 
graph save "$MO_endline_graphs\Coefficient Plots_TechSkills.gph", replace
graph export "$MO_endline_graphs\Coefficient Plots_TechSkills.png", replace


