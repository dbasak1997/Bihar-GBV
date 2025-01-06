/*==============================================================================
File Name: Endline Survey - Graphs
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	10/07/2024
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

log using "$MO_endline_log_files\graphs_dummy_data.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$MO_endline_clean_dta\combined_FINAL_analysis.dta", clear

*************Generating graphs for variables******************

///Baseline
local keyvar dv2_without_informing_dum_bl dv2_neglects_children_dum_bl dv2_burns_food_dum_bl dv2_argues_dum_bl dv2_refuses_sex_dum_bl psu_dum_bl non_gbv_fem_fault_dum_bl dv_compl_rel_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl pri_1_dum_bl pri_2_dum_bl pri_3_dum_bl pri_4_dum_bl pri_5_dum_bl pri_6_dum_bl pri_7_dum_bl pri_8_dum_bl pri_9_dum_bl sdb_1_dum_bl sdb_2_dum_bl sdb_3_dum_bl sdb_4_dum_bl sdb_5_dum_bl sdb_6_dum_bl sdb_7_dum_bl sdb_8_dum_bl sdb_9_dum_bl sdb_10_dum_bl sdb_11_dum_bl sdb_12_dum_bl sdb_13_dum_bl land_compromise_dum_bl fem_cases_over_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl dv1_internal_matter_dum_bl dv1_common_incident_dum_bl dv1_fears_beating_dum_bl gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl castepolicehelpnewdum_bl caste_empathy_dum_bl caste_fault_new_dum_bl caste_framing_man_dum_bl caste_true_dum_bl land_false_dum_bl land_false_sa_dum_bl premarital_false_dum_bl premarital_framing_dum_bl believe_w_relat_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl

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
title("`var'", size(small)) ///
saving("$MO_endline_graphs\combined_graph_`var'.gph", replace)
}

graph combine "$MO_endline_graphs\combined_graph_dv2_without_informing_dum_bl.gph" "$MO_endline_graphs\combined_graph_dv2_neglects_children_dum_bl.gph" "$MO_endline_graphs\combined_graph_dv2_burns_food_dum_bl.gph" "$MO_endline_graphs\combined_graph_dv2_argues_dum_bl.gph" "$MO_endline_graphs\combined_graph_dv2_refuses_sex_dum_bl.gph" "$MO_endline_graphs\combined_graph_psu_dum_bl.gph" "$MO_endline_graphs\combined_graph_non_gbv_fem_fault_dum_bl.gph", ///
title("Victim blaming (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Victim Blaming_baseline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_dv_compl_rel_dum_bl.gph" "$MO_endline_graphs\combined_graph_sa_burden_proof_dum_bl.gph" "$MO_endline_graphs\combined_graph_eviction_dv_dum_bl.gph" "$MO_endline_graphs\combined_graph_fem_shelter_dum_bl.gph" "$MO_endline_graphs\combined_graph_verbal_abuse_public_dum_bl.gph"  "$MO_endline_graphs\combined_graph_verbal_abuse_ipc_dum_bl.gph"  "$MO_endline_graphs\combined_graph_sa_identity_leaked_dum_bl.gph"  "$MO_endline_graphs\combined_graph_sa_identity_ipc_dum_bl.gph", ///
title("Technical skills (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Technical skills_baseline.gph", replace)
     
graph combine "$MO_endline_graphs\combined_graph_eq_1_dum_bl.gph" "$MO_endline_graphs\combined_graph_eq_2_dum_bl.gph" "$MO_endline_graphs\combined_graph_eq_3_dum_bl.gph" "$MO_endline_graphs\combined_graph_eq_4_dum_bl.gph" "$MO_endline_graphs\combined_graph_eq_5_dum_bl.gph"  "$MO_endline_graphs\combined_graph_eq_6_dum_bl.gph"  "$MO_endline_graphs\combined_graph_gbv_empathy_dum_bl.gph"  "$MO_endline_graphs\combined_graph_non_gbv_empathy_dum_bl.gph", ///
title("Empathy (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Empathy_baseline.gph", replace)
  
graph combine "$MO_endline_graphs\combined_graph_pri_1_dum_bl.gph" "$MO_endline_graphs\combined_graph_pri_2_dum_bl.gph" "$MO_endline_graphs\combined_graph_pri_3_dum_bl.gph" "$MO_endline_graphs\combined_graph_pri_4_dum_bl.gph" "$MO_endline_graphs\combined_graph_pri_5_dum_bl.gph"  "$MO_endline_graphs\combined_graph_pri_6_dum_bl.gph"  "$MO_endline_graphs\combined_graph_pri_7_dum_bl.gph"  "$MO_endline_graphs\combined_graph_pri_8_dum_bl.gph" "$MO_endline_graphs\combined_graph_pri_9_dum_bl.gph", ///
title("Flexibility (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Flexibility_baseline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_sdb_1_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_2_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_3_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_4_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_5_dum_bl.gph"  "$MO_endline_graphs\combined_graph_sdb_6_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_7_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_8_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_9_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_10_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_11_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_12_dum_bl.gph" "$MO_endline_graphs\combined_graph_sdb_13_dum_bl.gph", ///
title("Social desirability (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\SDB_baseline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_land_compromise_dum_bl.gph" "$MO_endline_graphs\combined_graph_fem_cases_over_dum_bl.gph" "$MO_endline_graphs\combined_graph_gbv_abusive_beh_new_dum_bl.gph" "$MO_endline_graphs\combined_graph_gbv_fem_fault_dum_bl.gph", ///
title("Attitudes towards GBV (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\AttitudeGBV_baseline.gph", replace)

     
graph combine "$MO_endline_graphs\combined_graph_dv1_internal_matter_dum_bl.gph" "$MO_endline_graphs\combined_graph_dv1_common_incident_dum_bl.gph" "$MO_endline_graphs\combined_graph_dv1_fears_beating_dum_bl.gph" "$MO_endline_graphs\combined_graph_gbv_police_help_new_dum_bl.gph" "$MO_endline_graphs\combined_graph_non_gbv_fir_new_dum_bl.gph"  "$MO_endline_graphs\combined_graph_castepolicehelpnewdum_bl.gph", ///
title("Externalising police responsibilities (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\ExtPol_baseline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_caste_empathy_dum_bl.gph" "$MO_endline_graphs\combined_graph_caste_fault_new_dum_bl.gph" "$MO_endline_graphs\combined_graph_caste_framing_man_dum_bl.gph" "$MO_endline_graphs\combined_graph_caste_true_dum_bl.gph", ///
title("Discrimination (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Discrimination_baseline.gph", replace)

      
graph combine "$MO_endline_graphs\combined_graph_land_false_dum_bl.gph" "$MO_endline_graphs\combined_graph_land_false_sa_dum_bl.gph" "$MO_endline_graphs\combined_graph_premarital_false_dum_bl.gph" "$MO_endline_graphs\combined_graph_premarital_framing_dum_bl.gph" "$MO_endline_graphs\combined_graph_believe_w_relat_dum_bl.gph"  "$MO_endline_graphs\combined_graph_gbv_true_dum_bl.gph" "$MO_endline_graphs\combined_graph_non_gbv_true_dum_bl.gph", ///
title("Truthfulness of complaints (Baseline)", size(medium)) ///
saving("$MO_endline_graphs\Truth_baseline.gph", replace)

///Endline
local keyvar2 dv2_without_informing_dum_el dv2_neglects_children_dum_el dv2_burns_food_dum_el dv2_argues_dum_el dv2_refuses_sex_dum_el psu_dum_el non_gbv_fem_fault_dum_el dv_compl_rel_dum_el sa_burden_proof_dum_el eviction_dv_dum_el fem_shelter_dum_el verbal_abuse_public_dum_el verbal_abuse_ipc_dum_el sa_identity_leaked_dum_el sa_identity_ipc_dum_el eq_1_dum_el eq_2_dum_el eq_3_dum_el eq_4_dum_el eq_5_dum_el eq_6_dum_el gbv_empathy_dum_el non_gbv_empathy_dum_el pri_1_el_dum pri_2_el_dum pri_3_el_dum pri_4_el_dum pri_5_el_dum pri_6_el_dum pri_7_el_dum pri_8_el_dum pri_9_el_dum sdb_1_el_dum sdb_2_el_dum sdb_3_el_dum sdb_4_el_dum sdb_5_el_dum sdb_6_el_dum sdb_7_el_dum sdb_8_el_dum sdb_9_el_dum sdb_10_el_dum sdb_11_el_dum sdb_12_el_dum sdb_13_el_dum land_compromise_dum_el fem_cases_over_dum_el gbv_abusive_beh_dum_el gbv_fem_fault_dum_el dv1_internal_matter_el_dum dv1_common_incident_el_dum dv1_fears_beating_el_dum gbv_police_help_dum_el non_gbv_fir_dum_el caste_police_help_dum_el caste_empathy_dum_el caste_fault_dum_el caste_framing_man_dum_el caste_true_dum_el land_false_dum_el land_false_sa_dum_el premarital_false_dum_el premarital_framing_dum_el believe_w_relat_dum_el gbv_true_dum_el non_gbv_true_dum_el

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
title("`var'", size(small)) ///
saving("$MO_endline_graphs\combined_graph_`var'.gph", replace)
}

graph combine "$MO_endline_graphs\combined_graph_dv2_without_informing_dum_el.gph" "$MO_endline_graphs\combined_graph_dv2_neglects_children_dum_el.gph" "$MO_endline_graphs\combined_graph_dv2_burns_food_dum_el.gph" "$MO_endline_graphs\combined_graph_dv2_argues_dum_el.gph" "$MO_endline_graphs\combined_graph_dv2_refuses_sex_dum_el.gph" "$MO_endline_graphs\combined_graph_psu_dum_el.gph" "$MO_endline_graphs\combined_graph_non_gbv_fem_fault_dum_el.gph", ///
title("Victim blaming (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Victim Blaming_endline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_dv_compl_rel_dum_el.gph" "$MO_endline_graphs\combined_graph_sa_burden_proof_dum_el.gph" "$MO_endline_graphs\combined_graph_eviction_dv_dum_el.gph" "$MO_endline_graphs\combined_graph_fem_shelter_dum_el.gph" "$MO_endline_graphs\combined_graph_verbal_abuse_public_dum_el.gph"  "$MO_endline_graphs\combined_graph_verbal_abuse_ipc_dum_el.gph"  "$MO_endline_graphs\combined_graph_sa_identity_leaked_dum_el.gph"  "$MO_endline_graphs\combined_graph_sa_identity_ipc_dum_el.gph", ///
title("Technical skills (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Technical skills_endline.gph", replace)
     
graph combine "$MO_endline_graphs\combined_graph_eq_1_dum_el.gph" "$MO_endline_graphs\combined_graph_eq_2_dum_el.gph" "$MO_endline_graphs\combined_graph_eq_3_dum_el.gph" "$MO_endline_graphs\combined_graph_eq_4_dum_el.gph" "$MO_endline_graphs\combined_graph_eq_5_dum_el.gph"  "$MO_endline_graphs\combined_graph_eq_6_dum_el.gph"  "$MO_endline_graphs\combined_graph_gbv_empathy_dum_el.gph"  "$MO_endline_graphs\combined_graph_non_gbv_empathy_dum_el.gph", ///
title("Empathy (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Empathy_endline.gph", replace)
  
graph combine "$MO_endline_graphs\combined_graph_pri_1_el_dum.gph" "$MO_endline_graphs\combined_graph_pri_2_el_dum.gph" "$MO_endline_graphs\combined_graph_pri_3_el_dum.gph" "$MO_endline_graphs\combined_graph_pri_4_el_dum.gph" "$MO_endline_graphs\combined_graph_pri_5_el_dum.gph"  "$MO_endline_graphs\combined_graph_pri_6_el_dum.gph"  "$MO_endline_graphs\combined_graph_pri_7_el_dum.gph"  "$MO_endline_graphs\combined_graph_pri_8_el_dum.gph" "$MO_endline_graphs\combined_graph_pri_9_el_dum.gph", ///
title("Flexibility (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Flexibility_endline.gph", replace)

graph combine "$MO_endline_graphs\combined_graph_sdb_1_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_2_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_3_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_4_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_5_el_dum.gph"  "$MO_endline_graphs\combined_graph_sdb_6_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_7_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_8_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_9_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_10_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_11_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_12_el_dum.gph" "$MO_endline_graphs\combined_graph_sdb_13_el_dum.gph", ///
title("Social desirability (Endline)", size(medium)) ///
saving("$MO_endline_graphs\SDB_endline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_land_compromise_dum_el.gph" "$MO_endline_graphs\combined_graph_fem_cases_over_dum_el.gph" "$MO_endline_graphs\combined_graph_gbv_abusive_beh_dum_el.gph" "$MO_endline_graphs\combined_graph_gbv_fem_fault_dum_el.gph", ///
title("Attitudes towards GBV (Endline)", size(medium)) ///
saving("$MO_endline_graphs\AttitudeGBV_endline.gph", replace)

     
graph combine "$MO_endline_graphs\combined_graph_dv1_internal_matter_el_dum.gph" "$MO_endline_graphs\combined_graph_dv1_common_incident_el_dum.gph" "$MO_endline_graphs\combined_graph_dv1_fears_beating_el_dum.gph" "$MO_endline_graphs\combined_graph_gbv_police_help_dum_el.gph" "$MO_endline_graphs\combined_graph_non_gbv_fir_dum_el.gph"  "$MO_endline_graphs\combined_graph_caste_police_help_dum_el.gph", ///
title("Externalising police responsibilities (Endline)", size(medium)) ///
saving("$MO_endline_graphs\ExtPol_endline.gph", replace)

   
graph combine "$MO_endline_graphs\combined_graph_caste_empathy_dum_el.gph" "$MO_endline_graphs\combined_graph_caste_fault_dum_el.gph" "$MO_endline_graphs\combined_graph_caste_framing_man_dum_el.gph" "$MO_endline_graphs\combined_graph_caste_true_dum_el.gph", ///
title("Discrimination (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Discrimination_endline.gph", replace)

      
graph combine "$MO_endline_graphs\combined_graph_land_false_dum_el.gph" "$MO_endline_graphs\combined_graph_land_false_sa_dum_el.gph" "$MO_endline_graphs\combined_graph_premarital_false_dum_el.gph" "$MO_endline_graphs\combined_graph_premarital_framing_dum_el.gph" "$MO_endline_graphs\combined_graph_believe_w_relat_dum_el.gph"  "$MO_endline_graphs\combined_graph_gbv_true_dum_el.gph" "$MO_endline_graphs\combined_graph_non_gbv_true_dum_el.gph", ///
title("Truthfulness of complaints (Endline)", size(medium)) ///
saving("$MO_endline_graphs\Truth_endline.gph", replace)
