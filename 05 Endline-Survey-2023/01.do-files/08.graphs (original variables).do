/*==============================================================================
File Name: Endline Survey - Graphs
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to generate graphs for preliminary analysis


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

log using "$MO_endline_log_files\graphs_data.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\combined_FINAL_analysis.dta", clear

*************Generating graphs for variables******************

///Baseline
local keyvar dv2_goes_wo_informing_bl dv2_neglects_children_bl dv2_burns_food_bl dv2_argues_bl dv2_refuses_sex_bl psu_bl non_gbv_fem_fault_bl dv_complaint_relative_bl sa_burden_proof_bl eviction_dv_bl fem_shelter_bl verbal_abuse_public_bl verbal_abuse_ipc_bl sa_identity_leaked_bl sa_identity_ipc_bl eq_1_bl eq_2_bl eq_3_bl eq_4_bl eq_5_bl eq_6_bl gbv_empathy_bl non_gbv_empathy_bl pri_1_bl pri_2_bl pri_3_bl pri_4_bl pri_5_bl pri_6_bl pri_7_bl pri_8_bl pri_9_bl sdb_1_bl sdb_2_bl sdb_3_bl sdb_4_bl sdb_5_bl sdb_6_bl sdb_7_bl sdb_8_bl sdb_9_bl sdb_10_bl sdb_11_bl sdb_12_bl sdb_13_bl land_compromise_bl fem_cases_overattention_bl gbv_abusive_beh_new_bl gbv_fem_fault_bl dv1_internal_matter_bl dv1_common_incident_bl dv1_fears_beating_bl gbv_police_help_new_bl non_gbv_fir_new_bl caste_police_help_new_bl caste_empathy_bl caste_fault_new_bl caste_framing_man_bl caste_true_bl land_false_bl land_false_sa_bl premarital_false_bl premarital_framing_bl believable_with_relative_bl gbv_true_bl non_gbv_true_bl

foreach var of varlist `keyvar' {
	local i `var'
	local varlabel : variable label `i'
	* Create and save the graph for Control group
graph bar (percent) if treatment_bl == 0 & `var' >= 0, over(`var', label(labsize(vsmall))) ///
title("Control", size(small))  ///
ytitle("Proportion (%)") ///
blabel(bar) ///
saving(graph_control.gph, replace)

* Create and save the graph for Treatment group
graph bar (percent) if treatment_bl == 1 & `var' >= 0, over(`var', label(labsize(vsmall))) ///
title("Treatment", size(small)) ///
ytitle("Proportion (%)") ///
blabel(bar) ///
saving(graph_treatment.gph, replace)

* Combine the graphs with a single main title
graph combine graph_control.gph graph_treatment.gph, ///
title("`varlabel'", size(small)) ///
saving("$MO_endline_graphs\combined_graph_`var'.gph", replace)
}

graph combine "$MO_endline_graphs\combined_graph_dv2_goes_wo_informing_bl.gph" "$MO_endline_graphs\combined_graph_dv2_neglects_children_bl.gph" "$MO_endline_graphs\combined_graph_dv2_burns_food_bl.gph" "$MO_endline_graphs\combined_graph_dv2_argues_bl.gph" "$MO_endline_graphs\combined_graph_dv2_refuses_sex_bl.gph" "$MO_endline_graphs\combined_graph_psu_bl.gph" "$MO_endline_graphs\combined_graph_non_gbv_fem_fault_bl.gph", ///
title("Victim blaming (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Victim Blaming_baseline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_dv_complaint_relative_bl.gph" "$MO_endline_graphs\combined_graph_sa_burden_proof_bl.gph" "$MO_endline_graphs\combined_graph_eviction_dv_bl.gph" "$MO_endline_graphs\combined_graph_fem_shelter_bl.gph" "$MO_endline_graphs\combined_graph_verbal_abuse_public_bl.gph"  "$MO_endline_graphs\combined_graph_verbal_abuse_ipc_bl.gph"  "$MO_endline_graphs\combined_graph_sa_identity_leaked_bl.gph"  "$MO_endline_graphs\combined_graph_sa_identity_ipc_bl.gph", ///
title("Technical skills (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Technical skills_baseline.gph", replace)
     
graph combine "$MO_endline_graphs\combined_graph_eq_1_bl.gph" "$MO_endline_graphs\combined_graph_eq_2_bl.gph" "$MO_endline_graphs\combined_graph_eq_3_bl.gph" "$MO_endline_graphs\combined_graph_eq_4_bl.gph" "$MO_endline_graphs\combined_graph_eq_5_bl.gph"  "$MO_endline_graphs\combined_graph_eq_6_bl.gph"  "$MO_endline_graphs\combined_graph_gbv_empathy_bl.gph"  "$MO_endline_graphs\combined_graph_non_gbv_empathy_bl.gph", ///
title("Empathy (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Empathy_baseline.gph", replace)
  
graph combine "$MO_endline_graphs\combined_graph_pri_1_bl.gph" "$MO_endline_graphs\combined_graph_pri_2_bl.gph" "$MO_endline_graphs\combined_graph_pri_3_bl.gph" "$MO_endline_graphs\combined_graph_pri_4_bl.gph" "$MO_endline_graphs\combined_graph_pri_5_bl.gph"  "$MO_endline_graphs\combined_graph_pri_6_bl.gph"  "$MO_endline_graphs\combined_graph_pri_7_bl.gph"  "$MO_endline_graphs\combined_graph_pri_8_bl.gph" "$MO_endline_graphs\combined_graph_pri_9_bl.gph", ///
title("Flexibility (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Flexibility_baseline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_sdb_1_bl.gph" "$MO_endline_graphs\combined_graph_sdb_2_bl.gph" "$MO_endline_graphs\combined_graph_sdb_3_bl.gph" "$MO_endline_graphs\combined_graph_sdb_4_bl.gph" "$MO_endline_graphs\combined_graph_sdb_5_bl.gph"  "$MO_endline_graphs\combined_graph_sdb_6_bl.gph" "$MO_endline_graphs\combined_graph_sdb_7_bl.gph" "$MO_endline_graphs\combined_graph_sdb_8_bl.gph" "$MO_endline_graphs\combined_graph_sdb_9_bl.gph" "$MO_endline_graphs\combined_graph_sdb_10_bl.gph" "$MO_endline_graphs\combined_graph_sdb_11_bl.gph" "$MO_endline_graphs\combined_graph_sdb_12_bl.gph" "$MO_endline_graphs\combined_graph_sdb_13_bl.gph", ///
title("Social desirability (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\SDB_baseline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_land_compromise_bl.gph" "$MO_endline_graphs\combined_graph_fem_cases_overattention_bl.gph" "$MO_endline_graphs\combined_graph_gbv_abusive_beh_new_bl.gph" "$MO_endline_graphs\combined_graph_gbv_fem_fault_bl.gph", ///
title("Attitudes towards GBV (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\AttitudeGBV_baseline.gph", replace)

     
graph combine "$MO_endline_graphs\combined_graph_dv1_internal_matter_bl.gph" "$MO_endline_graphs\combined_graph_dv1_common_incident_bl.gph" "$MO_endline_graphs\combined_graph_dv1_fears_beating_bl.gph" "$MO_endline_graphs\combined_graph_gbv_police_help_new_bl.gph" "$MO_endline_graphs\combined_graph_non_gbv_fir_new_bl.gph"  "$MO_endline_graphs\combined_graph_caste_police_help_new_bl.gph", ///
title("Externalising police responsibilities (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\ExtPol_baseline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_caste_empathy_bl.gph" "$MO_endline_graphs\combined_graph_caste_fault_new_bl.gph" "$MO_endline_graphs\combined_graph_caste_framing_man_bl.gph" "$MO_endline_graphs\combined_graph_caste_true_bl.gph", ///
title("Discrimination (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Discrimination_baseline.gph", replace)

      
graph combine "$MO_endline_graphs\combined_graph_land_false_bl.gph" "$MO_endline_graphs\combined_graph_land_false_sa_bl.gph" "$MO_endline_graphs\combined_graph_premarital_false_bl.gph" "$MO_endline_graphs\combined_graph_premarital_framing_bl.gph" "$MO_endline_graphs\combined_graph_believable_with_relative_bl.gph"  "$MO_endline_graphs\combined_graph_gbv_true_bl.gph" "$MO_endline_graphs\combined_graph_non_gbv_true_bl.gph", ///
title("Truthfulness of complaints (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Truth_baseline.gph", replace)

///Endline
local keyvar2 dv2_goes_wo_informing_el dv2_neglects_children_el dv2_burns_food_el dv2_argues_el dv2_refuses_sex_el psu_el non_gbv_fem_fault_el dv_complaint_relative_el sa_burden_proof_el eviction_dv_el fem_shelter_el verbal_abuse_public_el verbal_abuse_ipc_el sa_identity_leaked_el sa_identity_ipc_el eq_1_el eq_2_el eq_3_el eq_4_el eq_5_el eq_6_el gbv_empathy_el non_gbv_empathy_el pri_1_el pri_2_el pri_3_el pri_4_el pri_5_el pri_6_el pri_7_el pri_8_el pri_9_el sdb_1_el sdb_2_el sdb_3_el sdb_4_el sdb_5_el sdb_6_el sdb_7_el sdb_8_el sdb_9_el sdb_10_el sdb_11_el sdb_12_el sdb_13_el land_compromise_el fem_cases_overattention_el gbv_abusive_beh_el gbv_fem_fault_el dv1_internal_matter_el dv1_common_incident_el dv1_fears_beating_el gbv_police_help_el non_gbv_fir_el caste_police_help_el caste_empathy_el caste_fault_el caste_framing_man_el caste_true_el land_false_el land_false_sa_el premarital_false_el premarital_framing_el believable_with_relative_el gbv_true_el non_gbv_true_el

foreach var of varlist `keyvar2' {
	local i `var'
	local varlabel : variable label `i'
	* Create and save the graph for Control group
graph bar (percent) if treatment_el == 0 & `var' >= 0, over(`var', label(labsize(vsmall))) ///
title("Control", size(small))  ///
ytitle("Proportion (%)") ///
blabel(bar) ///
saving(graph_control.gph, replace)

* Create and save the graph for Treatment group
graph bar (percent) if treatment_el == 1 & `var' >= 0, over(`var', label(labsize(vsmall))) ///
title("Treatment", size(small)) ///
ytitle("Proportion (%)") ///
blabel(bar) ///
saving(graph_treatment.gph, replace)

* Combine the graphs with a single main title
graph combine graph_control.gph graph_treatment.gph, ///
title("`varlabel'", size(small)) ///
saving("$MO_endline_graphs\combined_graph_`var'.gph", replace)
}

graph combine "$MO_endline_graphs\combined_graph_dv2_goes_wo_informing_el.gph" "$MO_endline_graphs\combined_graph_dv2_neglects_children_el.gph" "$MO_endline_graphs\combined_graph_dv2_burns_food_el.gph" "$MO_endline_graphs\combined_graph_dv2_argues_el.gph" "$MO_endline_graphs\combined_graph_dv2_refuses_sex_el.gph" "$MO_endline_graphs\combined_graph_psu_el.gph" "$MO_endline_graphs\combined_graph_non_gbv_fem_fault_el.gph", ///
title("Victim blaming (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Victim Blaming_endline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_dv_complaint_relative_el.gph" "$MO_endline_graphs\combined_graph_sa_burden_proof_el.gph" "$MO_endline_graphs\combined_graph_eviction_dv_el.gph" "$MO_endline_graphs\combined_graph_fem_shelter_el.gph" "$MO_endline_graphs\combined_graph_verbal_abuse_public_el.gph"  "$MO_endline_graphs\combined_graph_verbal_abuse_ipc_el.gph"  "$MO_endline_graphs\combined_graph_sa_identity_leaked_el.gph"  "$MO_endline_graphs\combined_graph_sa_identity_ipc_el.gph", ///
title("Technical skills (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Technical skills_endline.gph", replace)
     
graph combine "$MO_endline_graphs\combined_graph_eq_1_el.gph" "$MO_endline_graphs\combined_graph_eq_2_el.gph" "$MO_endline_graphs\combined_graph_eq_3_el.gph" "$MO_endline_graphs\combined_graph_eq_4_el.gph" "$MO_endline_graphs\combined_graph_eq_5_el.gph"  "$MO_endline_graphs\combined_graph_eq_6_el.gph"  "$MO_endline_graphs\combined_graph_gbv_empathy_el.gph"  "$MO_endline_graphs\combined_graph_non_gbv_empathy_el.gph", ///
title("Empathy (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Empathy_endline.gph", replace)
  
graph combine "$MO_endline_graphs\combined_graph_pri_1_el.gph" "$MO_endline_graphs\combined_graph_pri_2_el.gph" "$MO_endline_graphs\combined_graph_pri_3_el.gph" "$MO_endline_graphs\combined_graph_pri_4_el.gph" "$MO_endline_graphs\combined_graph_pri_5_el.gph"  "$MO_endline_graphs\combined_graph_pri_6_el.gph"  "$MO_endline_graphs\combined_graph_pri_7_el.gph"  "$MO_endline_graphs\combined_graph_pri_8_el.gph" "$MO_endline_graphs\combined_graph_pri_9_el.gph", ///
title("Flexibility (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Flexibility_endline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_sdb_1_el.gph" "$MO_endline_graphs\combined_graph_sdb_2_el.gph" "$MO_endline_graphs\combined_graph_sdb_3_el.gph" "$MO_endline_graphs\combined_graph_sdb_4_el.gph" "$MO_endline_graphs\combined_graph_sdb_5_el.gph"  "$MO_endline_graphs\combined_graph_sdb_6_el.gph" "$MO_endline_graphs\combined_graph_sdb_7_el.gph" "$MO_endline_graphs\combined_graph_sdb_8_el.gph" "$MO_endline_graphs\combined_graph_sdb_9_el.gph" "$MO_endline_graphs\combined_graph_sdb_10_el.gph" "$MO_endline_graphs\combined_graph_sdb_11_el.gph" "$MO_endline_graphs\combined_graph_sdb_12_el.gph" "$MO_endline_graphs\combined_graph_sdb_13_el.gph", ///
title("Social desirability (Endline)", size(medium)) ///
saving("$MO_endline_graphs\SDB_endline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_land_compromise_el.gph" "$MO_endline_graphs\combined_graph_fem_cases_overattention_el.gph" "$MO_endline_graphs\combined_graph_gbv_abusive_beh_el.gph" "$MO_endline_graphs\combined_graph_gbv_fem_fault_el.gph", ///
title("Attitudes towards GBV (Endline)", size(medium)) ///
saving("$MO_endline_graphs\AttitudeGBV_endline.gph", replace)

     
graph combine "$MO_endline_graphs\combined_graph_dv1_internal_matter_el.gph" "$MO_endline_graphs\combined_graph_dv1_common_incident_el.gph" "$MO_endline_graphs\combined_graph_dv1_fears_beating_el.gph" "$MO_endline_graphs\combined_graph_gbv_police_help_el.gph" "$MO_endline_graphs\combined_graph_non_gbv_fir_el.gph"  "$MO_endline_graphs\combined_graph_caste_police_help_el.gph", ///
title("Externalising police responsibilities (Endline)", size(medium)) ///
saving("$MO_endline_graphs\ExtPol_endline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_caste_empathy_el.gph" "$MO_endline_graphs\combined_graph_caste_fault_el.gph" "$MO_endline_graphs\combined_graph_caste_framing_man_el.gph" "$MO_endline_graphs\combined_graph_caste_true_el.gph", ///
title("Discrimination (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Discrimination_endline.gph", replace)

      
graph combine "$MO_endline_graphs\combined_graph_land_false_el.gph" "$MO_endline_graphs\combined_graph_land_false_sa_el.gph" "$MO_endline_graphs\combined_graph_premarital_false_el.gph" "$MO_endline_graphs\combined_graph_premarital_framing_el.gph" "$MO_endline_graphs\combined_graph_believable_with_relative_el.gph"  "$MO_endline_graphs\combined_graph_gbv_true_el.gph" "$MO_endline_graphs\combined_graph_non_gbv_true_el.gph", ///
title("Truthfulness of complaints (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Truth_endline.gph", replace)
