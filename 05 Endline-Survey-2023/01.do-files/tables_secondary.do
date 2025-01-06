/*==============================================================================
File Name: Baseline+Endline Officers' Survey Data - Generating balance tables for secondary outcomes
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	24/05/2023
Created by: Dibyajyoti Basak
Updated on: 24/05/2023
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to create balance tables for secondary outcomes 

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
	global dropbox "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\"
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


/* ----------------Female Constables Survey---------------*/


//Append all datasets
use "${intermediate_dta}femaleconstables_indices.dta"

*############### Generating global variables ####################################


//Var list for Baseline Indices
global fem_indices_bl "index_Perception_Integ_And index_Workenv_Rel_And index_Workenv_Rep_And index_Workenv_Male_And index_WorkDistr_And index_TrainingLearning_And index_harassment_And index_Desirability_And_fem index_Anxiety_fem index_Depression_fem" 

la var index_Perception_Integ_And "Perception towards workplace integration"
la var index_Workenv_Rel_And "Work environment (relationships)"
la var index_Workenv_Rep_And "Work environment (representation)"
la var index_Workenv_Male_And "Work environment (perception towards male officers)"
la var index_WorkDistr_And "Work distribution"
la var index_TrainingLearning_And "Training learnings"
la var index_harassment_And "Harassment"


*############ Balance on Female Constable Indices ################

balancetable (mean if treatment_bl == 0)(mean if treatment_bl == 1) ///
(diff treatment_bl) ///
$fem_indices_bl using "${tables}balance_fem_indices.xlsx", covariates(n5) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w T & C") varla ///

balancetable (mean if treatment_bl == 0)(mean if treatment_bl == 1) ///
(diff treatment_bl) ///
$fem_indices_bl using "${tables}balance_fem_indices.tex", covariates(n5) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w T & C") varla ///




/* ----------------Decoy Survey---------------*/

//Append all datasets
use "${intermediate_dta}decoy_indices.dta", clear

*############### Generating global variables ####################################


//Var list for Baseline Indices
global decoy_indices_bl "empathy_And_decoy VB_And_decoy Ext_And_decoy" 

la var empathy_And_decoy "Empathy index"
la var VB_And_decoy "Victim-blaming index"
la var Ext_And_decoy "Externalising responsibilites index"

*############ Balance on Decoy Indices ################

balancetable (mean if treatment_station_decoy == 0)(mean if treatment_station_decoy == 1) ///
(diff treatment_station_decoy) ///
$decoy_indices_bl using "${tables}balance_decoy_indices.xlsx", covariates(ps_dist_decoy) vce(cluster ps_dist_id_decoy) replace ///
ctitles("Control" "Treatment" "Diff b/w T & C") varla ///

balancetable (mean if treatment_station_decoy == 0)(mean if treatment_station_decoy == 1) ///
(diff treatment_station_decoy) ///
$decoy_indices_bl using "${tables}balance_decoy_indices.tex", covariates(ps_dist_decoy) vce(cluster ps_dist_id_decoy) replace ///
ctitles("Control" "Treatment" "Diff b/w T & C") varla ///


/* ----------------Wives Survey---------------*/

//Append all datasets
use "${clean_dta}endline_secondaryoutcomes.dta", clear

*############### Generating global variables ####################################


//Var list for Baseline Indices
global wives_indices_bl "index_Comm_And index_Spouse_Atti_And index_Spouse_Empathy_And index_Belief_And" 

la var index_Comm_And "Communication & conflict resolution"
la var index_Spouse_Atti_And "Spousal attitudes towards GBV"
la var index_Spouse_Empathy_And "Perceived empathy"
la var index_Belief_And "Beliefs on gender equality"

*############ Balance on Wives Indices ################

balancetable (mean if treatment_bl == 0 & index_Comm_And!=.)(mean if treatment_bl == 1 & index_Comm_And!=.) ///
(diff treatment_bl if treatment_bl !=. & index_Comm_And!=.) ///
$wives_indices_bl using "${tables}balance_wives_indices.xlsx", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w T & C") varla ///

balancetable (mean if treatment_bl == 0 & index_Comm_And!=.)(mean if treatment_bl == 1 & index_Comm_And!=.) ///
(diff treatment_bl if treatment_bl !=. & index_Comm_And!=.) ///
$wives_indices_bl using "${tables}balance_wives_indices.tex", covariates(ps_dist_bl) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w T & C") varla ///

clear