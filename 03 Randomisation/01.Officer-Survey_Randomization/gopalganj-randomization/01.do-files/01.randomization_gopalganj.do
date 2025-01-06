/*==============================================================================
File Name:	Randomization: Gopalganj Baseline-Survey-2022
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	02/02/2023
Created by: Aadya Gupta
Updated on:	--
Updated by:	--


*Notes READ ME:
*This is a staggerd implementation project and the randomization
 is done phase wise by district as the baseline is complete. 
 
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


/* Installing packages
ssc install unique
ssc install outreg2
*/

**File Directory

/*dibbo -- username for Dibyajyoti. 
Acer -- username for Shubhro. 
For others, please enter your PC Name as username and copy the file path of your DB Desktop. 
*/ 

else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\03 Randomisation\01.Officer-Survey_Randomization\gopalganj-randomization"
	}
	
else if "`c(username)'"=="Acer"{
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization-2022\01.Officer-Survey_Randomization\gopalganj-randomization"
	}
		
else if "`c(username)'"=="User2"{
	global dropbox "File-Path"
	}
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}
	
di "`dropbox'"

* File path
global raw "$dropbox\00.raw-data"
global do_files "$dropbox\01.do-files"
global intermediate_dta "$dropbox\02.intermediate-data\"
global tables "$dropbox\03.tables\"
global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\05.log-files\"
global clean_dta "$dropbox\06.clean-data\"


//Global File Path for using data from the source -- PSFS and Officer's survey clean data

if "`c(username)'"=="HP"{
	global source "C:\Users\HP\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data\psfs-officer_merged"
	} 
	
else if "`c(username)'"=="dibbo"{
	global source "C:\Users\dibbo\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\02 Baseline-Survey-2022\Baseline Survey_versions 1-3\Officer-Survey-2022\06.clean-data\psfs-officer_merged"
	} 

else if "`c(username)'"=="Acer"{
	global source "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Baseline-Survey-2022\Officer-Survey-2022\06.clean-data\psfs-officer_merged"
	}  
		
else if "`c(username)'"=="User2"{
	global source "File-Path"
	}
else if "`c(username)'"=="User3"{
	global source "File-Path"
	}
	
di "`source'"


	

* We will log in
capture log close 

log using "${log_files}randomisation_gopalganj.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME


**Preparing the Dataset 

* Loading the merged baseline for Gopalganj
use "$source\1004_gopalganj-merged.dta"

tab po_grandtotal, missing // No missing values

egen mean_officers = mean(po_grandtotal)
egen median_officers = median(po_grandtotal)
gen above_median_officers=(po_grandtotal>=median_officers)
* We have on average 19.33 officers per station. The median is 19 officers. 
* We have 20 stations. 10 PS should fall above the median, 10 should fall below the median.

unique ps_dist_id if above_median_officers == 1
unique ps_dist_id if above_median_officers == 0 
//We have 9 PS with above median number of Police Officers and 11 PS with below median Police Officers strength. 

save "${intermediate_dta}1004_gopalganj-merged_prep.dta", replace

collapse (mean) above_median_officers, by ( ps_dist_id)
rename  above_median_officers strata


*2. Randomization of stations
set seed 68200923
gen random = uniform()
egen ordem = rank(random), by (strata) unique 
egen n_obs = count(random), by (strata)
gen cutoff = n_obs*(1/2)
gen cutoffA = round(cutoff)
gen T = (ordem<= cutoffA)

save "${intermediate_dta}randomization_gopalganj.dta", replace

tab T strata
/*

           |        (mean)
           | above_median_officers
         T |         0          1 |     Total
-----------+----------------------+----------
         0 |         5          4 |         9 
         1 |         6          5 |        11 
-----------+----------------------+----------
     Total |        11          9 |        20 

*/


*********************************************
* Verify balance based on raw data by PSFS and individual officers
*********************************************
use "${intermediate_dta}1004_gopalganj-merged_prep.dta", clear

merge m:1 ps_dist_id using "${intermediate_dta}randomization_gopalganj.dta", gen(mergeT) // Complete match

drop activity*
tab po_marital_status, gen(marital_status)
tab po_caste, gen(caste)
tab po_subcaste, gen(po_subcaste)


* Generating police station facilities index psfs

global psfs ps_bathroom ps_fembathroom ps_confidential ps_femconfidential ps_electricity ps_fourwheeler ps_twowheeler ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_fembarrack ps_suffbarrack ps_storage ps_evidence ps_phone ps_lockup ps_femlockup ps_shelter ps_femshelter ps_cctv ps_new_cctv ps_fir po_m_headconstable po_f_headconstable po_tot_headconstable po_m_wtconstable po_f_wtconstable po_tot_wtconstable po_m_constable po_f_constable po_tot_constable po_m_asi po_f_asi po_tot_asi po_m_si po_f_si po_tot_si po_m_ins po_f_ins po_tot_ins po_m_sho po_f_sho po_tot_sho e2latitude e2longitude e2altitude e2accuracy po_grandtotal median_officers above_median_officers // To be replaced by the aprropriate indices


*Generating police officer index officer_Y 

global officer_Y po_rank ps_confirm ps_type uniqueid po_mobnum po_mobnum_alt po_age po_highest_educ po_highest_educ_os bp_years_of_service bp_months_of_service ps_years_of_service ps_months_of_service po_birth_state po_birth_district po_birth_village time_to_last_training tr_topic tr_investigation tr_communication tr_personal_dev tr_mediation tr_computer_technical tr_physical tr_legal tr_gender tr_covid q109__888 tr_dont_know tr_refused_ans tr_os tr_agency tr_other_state_police tr_agency_os q111filter tr_days_weeks_months tr_duration dv1_internal_matter dv1_common_incident dv1_fears_beating dv2_goes_without_informing dv2_neglects_children dv2_burns_food dv2_argues dv2_refuses_sex dv_complaint_relative dv_fewcases sa_burden_proof eviction_dv fem_shelter verbal_abuse_public verbal_abuse_ipc sa_identity_leaked sa_identity_ipc land_false land_compromise land_false_sa premarital_false premarital_socially_unacceptable premarital_framing believable_with_relative fem_cases_overattention eq_1 eq_2 eq_3 eq_4 eq_5 eq_6 gbv_abusive_beh gbv_police_help gbv_abusive_beh_new gbv_police_help_new gbv_true gbv_fem_fault gbv_empathy non_gbv_true non_gbv_fem_fault non_gbv_empathy non_gbv_fir non_gbv_fir_new pri_1 pri_2 pri_3 pri_4 pri_5 pri_6 pri_7 pri_8 pri_9 openness_1 openness_2 openness_3 openness_4 openness_5 openness_6 openness_7 openness_8 openness_9 sdb_1 sdb_2 sdb_3 sdb_4 sdb_5 sdb_6 sdb_7 sdb_8 sdb_9 sdb_10 sdb_11 sdb_12 sdb_13 gad_1 gad_2 gad_3 gad_4 gad_5 gad_6 gad_7 random_s8 s8name s8name_hindi caste_fault caste_police_help caste_fault_new caste_police_help_new caste_true caste_framing_man caste_empathy random_dp random_dptext random_dptext_hindi phq_1 phq_2 phq_3 phq_4 phq_5 phq_6 phq_7 phq_8 phq_9 discuss_spouse discuss_topics discuss_topics_os bp_effectiveness transfer_request same_home_district actcount po_marital_status if_children num_sons num_daughters tot_num_children po_caste po_subcaste marital_status1 marital_status2 marital_status3 marital_status4 marital_status5 caste1 caste2 caste3 caste4 caste5 po_subcaste1 po_subcaste2 po_subcaste3 po_subcaste4 po_subcaste5 po_subcaste6 po_subcaste7 po_subcaste8 po_subcaste9 po_subcaste10 po_subcaste11 po_subcaste12 po_subcaste13 po_subcaste14 po_subcaste15 po_subcaste16 po_subcaste17 po_subcaste18 po_subcaste19 po_subcaste20 po_subcaste21 po_subcaste22 po_subcaste23 po_subcaste24 po_subcaste25 po_subcaste26 po_subcaste27 po_subcaste28 po_subcaste29 po_subcaste30 po_subcaste31 po_subcaste32 po_subcaste33 po_subcaste34 po_subcaste35 po_subcaste36 po_subcaste37 po_subcaste38 po_subcaste39 po_subcaste40 po_subcaste41 po_subcaste42 po_subcaste43 po_subcaste44 po_subcaste45 po_subcaste46 po_subcaste47 po_subcaste48 po_subcaste49 po_subcaste50 po_subcaste51 po_subcaste52 po_subcaste53 po_subcaste54 po_subcaste55 po_subcaste56 po_subcaste57 po_subcaste58 po_subcaste59 po_subcaste60 po_subcaste61 po_subcaste62 po_subcaste63 po_subcaste64 po_subcaste65 po_subcaste66 po_subcaste67 po_subcaste68 po_subcaste69 po_subcaste70 po_subcaste71 po_subcaste72 po_subcaste73 po_subcaste74 po_subcaste75 po_subcaste76 po_subcaste77 po_subcaste78 po_subcaste79 po_subcaste80 po_subcaste81 po_subcaste82 po_subcaste83 po_subcaste84 po_subcaste85 po_subcaste86 po_subcaste87 po_subcaste88 po_subcaste89 po_subcaste90 // To be replaced by the appropriate indices

/* It is possible that some variables do not exist for a district. 
For Gopalganj, we don't have variables from po_subcaste90 to po_subcaste213 are not applicable.
*/

*cap n erase "${tables}randomization_gopalganj.xls"

foreach var of varlist $psfs $officer_Y{
	
cap n		xi: areg `var' T  , absorb(strata) cluster(ps_dist_id)
cap n			sum `var' if e(sample) == 1 & T==0 //mean control group
cap n			local meanY : display %4.3f `r(mean)'
cap n			sum `var' if e(sample) == 1 & T==1 //mean treatment group
cap n			local meanYT : display %4.3f `r(mean)'
cap n			local pvalue : display `r(p)'
cap n			outreg2  using "${tables}randomization_gopalganj.xls" , label excel dec(3) drop() append addtext(Mean of control, `meanY', Mean of treatment, `meanYT', Strata FE, Yes, Cluster Station, Yes) ctitle ("`var'") nocons 

	
}
*replace code above with balancetable code but some vars need to be fixed otherwise it does not run. 

* Exporting the treatment stations list
export excel ps_dist_id ps_name ps_confirm  T using "${clean_dta}treatment-stations_gopalganj.xls", firstrow(variables) replace

