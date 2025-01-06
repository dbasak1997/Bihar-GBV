/*==============================================================================
File Name: Baseline+Endline Officers' Survey Data - Generating balance tables
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	28/02/2023
Created by: Dibyajyoti Basak
Updated on: 28/02/2023
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

**File Directory

*Acer -- username for Shubhro.
*dibbo -- username for Dibyajyoti 
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 

else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-v3-2023"
	}
	
	else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Endline-Survey-2023"
	}
	
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}
	
di "`dropbox'"
	
*File Path

global raw "$dropbox\00.raw-data"
global do_files "$dropbox\01.do-files"
global intermediate_dta "$dropbox\02.intermediate-data\"
global tables "$dropbox\03.tables\"
global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\05.log-files\"
global clean_dta "$dropbox\06.clean-data\"


* We will log in
capture log close 

*log using "${log_files}officersurveyv3_errorcheck.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

//Append all datasets
use "${intermediate_dta}endline_intermediate.dta"

*############### Generating global variables ####################################


//Var list for Baseline Indices
global po_indices_bl "index_VictimBlame_And_bl index_Techskills_And_bl index_Empathy_And_bl index_Flexibility_And_bl index_Desirability_And_bl index_AttitudeGBV_And_bl index_ExtPol_And_bl index_Discrimination_And_bl index_Truth_And_bl index_Openness_And_bl" 

//Var list for Officer Characteristics
label variable po_age_bl "Officer Age (baseline)"
global characteristics_bl "po_age_bl po_caste_dum_sc_bl po_caste_dum_st_bl po_caste_dum_obc_bl po_caste_dum_general_bl po_marital_dum_bl po_highest_educ_10th_bl po_highest_educ_12th_bl po_highest_educ_diploma_bl po_highest_educ_college_bl po_highest_educ_ba_bl po_highest_educ_ma_bl po_rank_asi_bl po_rank_si_bl po_rank_psi_bl po_rank_insp_bl po_rank_sho_bl  bp_yearsofservice_bl ps_yearsofservice_bl"


*############ Balance on Officer Transfer ################

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 1)(mean if dum_bothsurveys == 1 & treatment_bl == 0 & dum_transfer == 1) (mean if dum_bothsurveys == 1 & treatment_bl == 1 & dum_transfer == 1) (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_bothsurveys == 1 & treatment_bl == 0 & dum_transfer == 0) (mean if dum_bothsurveys == 1 & treatment_bl == 1 & dum_transfer == 0) ///
(diff dum_notransfer_control if dum_notransfer_control !=.)(diff dum_notransfer_treatment if dum_notransfer_treatment !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_attrition_main.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Transferred Officers-Within Sample" "Transferred Officers-Control" "Transferred Officers-Treatment" "Non-Transferred Officers" "Non-Transferred Officers-Control" "Non-Transferred Officers-Treatment" "Diff b/w (2) and (5)" "Diff b/w (3) and (6)") varla ///

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 1)(mean if dum_bothsurveys == 1 & treatment_bl == 0 & dum_transfer == 1) (mean if dum_bothsurveys == 1 & treatment_bl == 1 & dum_transfer == 1) (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_bothsurveys == 1 & treatment_bl == 0 & dum_transfer == 0) (mean if dum_bothsurveys == 1 & treatment_bl == 1 & dum_transfer == 0) ///
(diff dum_notransfer_control if dum_notransfer_control !=.)(diff dum_notransfer_treatment if dum_notransfer_treatment !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_attrition_main.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Transferred Officers-Within Sample" "Transferred Officers-Control" "Transferred Officers-Treatment" "Non-Transferred Officers" "Non-Transferred Officers-Control" "Non-Transferred Officers-Treatment" "Diff b/w (2) and (5)" "Diff b/w (3) and (6)") varla ///


*############ Balance on Officer Turnover ################

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_transfer_ctoc == 1) (mean if dum_transfer_ttot == 1) (mean if dum_transfer_ctot == 1) (mean if dum_transfer_ttoc == 1) ///
(diff dum_ctoc_transfer if dum_ctoc_transfer !=.) (diff dum_ttot_transfer if dum_ttot_transfer !=.) (diff dum_ctot_transfer if dum_ctot_transfer !=.) (diff dum_ttoc_transfer if dum_ttoc_transfer !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_transfers.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Non-Transferred Officers" "Transferred from C to C" "Transferred from T to T" "Transferred from C to T" "Transferred from T to C" "Diff b/w (1) and (2)" "Diff b/w (1) and (3)" "Diff b/w (1) and (4)" "Diff b/w (1) and (5)") varla ///

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_transfer_ctoc == 1) (mean if dum_transfer_ttot == 1) (mean if dum_transfer_ctot == 1) (mean if dum_transfer_ttoc == 1) ///
(diff dum_ctoc_transfer if dum_ctoc_transfer !=.) (diff dum_ttot_transfer if dum_ttot_transfer !=.) (diff dum_ctot_transfer if dum_ctot_transfer !=.) (diff dum_ttoc_transfer if dum_ttoc_transfer !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_transfers.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Non-Transferred Officers" "Transferred from C to C" "Transferred from T to T" "Transferred from C to T" "Transferred from T to C" "Diff b/w (1) and (2)" "Diff b/w (1) and (3)" "Diff b/w (1) and (4)" "Diff b/w (1) and (5)") varla ///


*############ Balance on Officer Attrition ################

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_baselineonly == 1) ///
(diff dum_baseline_transfer_out if dum_baseline_transfer_out !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_transfers_outsample.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Non-Transferred Officers" "Officers Transferred out of Sample" "Diff b/w (1) and (2)") varla ///

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_baselineonly == 1) ///
(diff dum_baseline_transfer_out if dum_baseline_transfer_out !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_transfers_outsample.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Non-Transferred Officers" "Officers Transferred out of Sample" "Diff b/w (1) and (2)") varla ///


*############ Balance on Officer Replacements ################

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_endlineonly == 1) ///
(diff dum_outsample if dum_outsample !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_transfers_replacement.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Non-Transferred Officers" "Officers Transferred into the Sample" "Diff b/w (1) and (2)") varla ///

balancetable (mean if dum_bothsurveys == 1 & dum_transfer == 0) (mean if dum_endlineonly == 1) ///
(diff dum_outsample if dum_outsample !=.) ///
$characteristics_bl $po_indices_bl using "${tables}balance_transfers_replacement.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Non-Transferred Officers" "Officers Transferred into the Sample" "Diff b/w (1) and (2)") varla ///

*############ Balance on Indices ################

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$po_indices_bl using "${tables}balance_indices.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$po_indices_bl using "${tables}balance_indices.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

*############ Balance on Demographic and Socio-economic Variables ################

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$characteristics_bl using "${tables}balance_demography.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$characteristics_bl using "${tables}balance_demography.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///


*******************Generating tables for variables within indices***********************

la var dv2_goes_without_informing_bl "It is justified for a husband to hit his wife if she goes out without telling him"
la var dv2_neglects_children_bl "It is justified for a husband to hit his wife if she neglects the children"
la var dv2_burns_food_bl "It is justified for a husband to hit his wife if she burns the food"
la var dv2_argues_bl "It is justified for a husband to hit his wife if she argues with the husband"
la var dv2_refuses_sex_bl "It is justified for a husband to hit his wife if she refuses to have sex with the husband"
la var psu_dum_bl "(Referring to vignette) Out of 10 such cases, in how many cases the woman faced such a situation because she did not behave in a socially acceptable manner?"
la var non_gbv_fem_fault_dum_bl "(Referring to vignette) To what extent do you agree that this incident happened because Anita was traveling alone?"

la var dv_complaint_relative_dum_bl "Can the relatives of a victim who has experienced domestic violence file a police complaint on her behalf?"
la var sa_burden_proof_dum_bl "(Referring to vignette) With whom does the burden of proof lie?"
la var eviction_dv_dum_bl "If a married woman is evicted from her `matrimonial house' but has not been subjected to any other physical abuse, does that constitute domestic violence?"
la var fem_shelter_dum_bl "Should the police assist the victim in finding shelter if she does not feel safe at her place?"
la var verbal_abuse_public_dum_bl "A woman accuses an unknown man of having verbally abused her in a public space. Is this a chargeable offense?"
la var verbal_abuse_ipc_dum_bl "If yes, under what section of the IPC will you book him?"
la var sa_identity_leaked_dum_bl "Your colleague, another police officer has voluntarily revealed the name and the whereabouts of a rape victim to a local media outlet. Is this a chargeable offence?"
la var sa_identity_ipc_dum_bl "If the answer to the above question is yes, will you book him? If yes, under which section of the IPC shall you book him?"

la var eq_1_dum_bl "I tend to have very strong opinions about morality"
la var eq_2_dum_bl "I find it easy to put myself in somebody else's shoes"
la var eq_3_dum_bl "I am good at predicting how someone will feel"
la var eq_4_dum_bl "I am able to make decisions without being influenced by others' feelings"
la var eq_5_dum_bl "I can tune into how someone else feels rapidly and intuitively"
la var eq_6_dum_bl "I can usually appreciate the other person's viewpoint, even if I don't agree with it"
la var gbv_empathy_dum_bl "(Referring to vignette) I can imagine what it must be like to be in Radha's place"
la var non_gbv_empathy_dum_bl "(Referring to vignette) I can imagine what it must be like to be in Anita's place"

la var land_compromise_dum_bl "(Referring to vignette) Out of 10 such cases, in how many cases is recommending a compromise enough and there is no need to file an FIR?"
la var fem_cases_overattention_dum_bl "Cases related to women receive too much attention by the police, relative to other crime and law and order issues"
la var gbv_abusive_beh_new_dum_bl "(Referring to vignette) Thinking about the story, do you think that this consists of abusive behavior by Bablu?"
la var gbv_fem_fault_dum_bl "The independence enjoyed by women these days is causing such problems"

la var dv1_internal_matter_bl "The woman does not report to the police because the police cannot help her and it is an internal matter between the husband and the wife"
la var dv1_common_incident_bl "The woman does not report to the police because such incidents are very common and happen too often"
la var dv1_fears_beating_bl "The woman does not report to the police because she fears being beaten up by her husband again if she reports to the police"
la var gbv_police_help_new_dum_bl "Do you think this is a problem that the police can help with?"
la var non_gbv_fir_new_dum_bl "Do you think the police can register a case against this man based on the complaint?"
la var caste_police_help_new_dum_bl "Do you think this is a problem that the police can help with?"

la var land_false_dum_bl "(Referring to vignette) Out of 10 cases how many such complaints are false?"
la var premarital_false_dum_bl "(Referring to vignette) Out of 10 cases how many such complaints are false?"
la var believable_with_relative_dum_bl "The complaint is usually more believable if the woman is also accompanied by her relatives rather than when she comes alone"
la var gbv_true_dum_bl "(Referring to vignette) The complaint filed by Radha is true"
la var non_gbv_true_dum_bl "(Referring to vignette) The complaint filed by Reena is true"

global VB index_VictimBlame_And_bl dv2_goes_without_informing_bl dv2_neglects_children_bl dv2_burns_food_bl dv2_argues_bl dv2_refuses_sex_bl psu_dum_bl non_gbv_fem_fault_dum_bl
global TS index_Techskills_And_bl dv_complaint_relative_dum_bl sa_burden_proof_dum_bl eviction_dv_dum_bl fem_shelter_dum_bl verbal_abuse_public_dum_bl verbal_abuse_ipc_dum_bl sa_identity_leaked_dum_bl sa_identity_ipc_dum_bl
global Emp index_Empathy_And_bl eq_1_dum_bl eq_2_dum_bl eq_3_dum_bl eq_4_dum_bl eq_5_dum_bl eq_6_dum_bl gbv_empathy_dum_bl non_gbv_empathy_dum_bl
global Atti index_AttitudeGBV_And_bl land_compromise_dum_bl fem_cases_overattention_dum_bl gbv_abusive_beh_new_dum_bl gbv_fem_fault_dum_bl
global Ext index_ExtPol_And_bl dv1_internal_matter_bl dv1_common_incident_bl dv1_fears_beating_bl gbv_police_help_new_dum_bl non_gbv_fir_new_dum_bl caste_police_help_new_dum_bl
global Truth index_Truth_And_bl land_false_dum_bl premarital_false_dum_bl believable_with_relative_dum_bl gbv_true_dum_bl non_gbv_true_dum_bl

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$VB $TS using "${tables}balance_victimblaming.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$VB $TS using "${tables}balance_victimblaming.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$Emp $Atti using "${tables}balance_empathy.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$Emp $Atti using "${tables}balance_empathy.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$Ext $Truth using "${tables}balance_externalising.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$Ext $Truth using "${tables}balance_externalising.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

**************************************************************


use "${intermediate_dta}pslist_intermediate.dta", clear
label variable ps_fir_bl "Number of FIRs registered in 2021"
global psfs_indices "index_psfs_gen_And index_psfs_fem_infra_And index_psfs_m_f_seg_Reg"

*############ Balance on Treatment v Control PS ################
balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$psfs_indices using "${tables}balance_psfs.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///

balancetable (mean if treatment_bl == 0) (mean if treatment_bl == 1) ///
(diff treatment_bl if treatment_bl !=.) ///
$psfs_indices using "${tables}balance_psfs.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (1) and (2)") varla ///


*############ Balance on Decoy v Non-Decoy PS ################
balancetable (mean if dum_decoy == 1 & treatment_bl == 0) (mean if dum_decoy == 1 & treatment_bl == 1) (mean if dum_decoy == 0 & treatment_bl == 0) (mean if dum_decoy == 0 & treatment_bl == 1) ///
(diff dum_decoy_control if treatment_bl == 0) (diff dum_decoy_treatment if treatment_bl == 1) ///
$psfs_indices using "${tables}balance_decoy.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Decoy - Control" "Decoy - Treatment" "Non-decoy - Control" "Non-decoy - Treatment" "Diff b/w (1) and (3)" "Diff b/w (2) and (4)" ) varla ///

balancetable (mean if dum_decoy == 1 & treatment_bl == 0) (mean if dum_decoy == 1 & treatment_bl == 1) (mean if dum_decoy == 0 & treatment_bl == 0) (mean if dum_decoy == 0 & treatment_bl == 1) ///
(diff dum_decoy_control if treatment_bl == 0) (diff dum_decoy_treatment if treatment_bl == 1) ///
$psfs_indices using "${tables}balance_decoy.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Decoy - Control" "Decoy - Treatment" "Non-decoy - Control" "Non-decoy - Treatment" "Diff b/w (1) and (3)" "Diff b/w (2) and (4)" ) varla ///

