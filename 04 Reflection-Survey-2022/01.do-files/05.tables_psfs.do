/*==============================================================================
File Name: PSFS - Tables do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	25/06/2024
Created by: Dibyajyoti Basak
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Tables Do file for tables of Reflection Survey

*	Inputs:  06.clean-data "01.reflectionsurvey_clean"
*	Outputs:  
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
	
*File Path

    global raw "$reflection\00.raw-data"
	global do_files "$reflection\01.do-files"
	global intermediate_dta "$reflection\02.intermediate-data\"
	global tables "$reflection\03.tables\"
	global graphs "$reflection\04.graphs\"
	global log_files "$reflection\05.log-files\"
	global clean_dta "$reflection\06.clean-data\"


/* Install packages:
ssc install estout
*/


* We will log in
capture log close 

log using "${log_files}psfs_tables.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


use "$psfs\PSFS-2022\06.clean-data\03.PSFS_clean_deidentified_new.dta", clear
foreach i of varlist ps_bathroom  ps_confidential ps_electricity ps_fourwheeler ps_twowheeler ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_suffbarrack ps_storage ps_evidence ps_phone ps_lockup ps_shelter ps_cctv ps_new_cctv ps_fir ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter po_m_headconstable po_f_headconstable po_tot_headconstable po_m_wtconstable ///
po_f_wtconstable po_tot_wtconstable po_m_constable po_f_constable po_tot_constable ///
po_m_asi po_f_asi po_tot_asi po_m_si po_f_si po_tot_si po_m_ins po_f_ins po_tot_ins po_m_sho po_f_sho po_tot_sho po_grandtotal {
replace `i' =0 if `i' == -777
replace `i' =0 if `i' == -888
replace `i' =0 if `i' == -999
}

gen dum_ps_fourwheeler = 0
replace dum_ps_fourwheeler = 1 if ps_fourwheeler > 0

gen dum_ps_twowheeler = 0
replace dum_ps_twowheeler = 1 if ps_twowheeler > 0

gen dum_ps_computer = 0
replace dum_ps_computer = 1 if ps_computer > 0

gen dum_ps_cctv = 0
replace dum_ps_cctv = 1 if ps_cctv > 0

gen dum_lockup = 0
replace dum_lockup = 1 if ps_lockup > 0

gen ratio_headconstable = po_f_headconstable/po_m_headconstable
gen ratio_wtconstable = po_f_wtconstable/po_m_wtconstable
gen ratio_constable = po_f_constable/po_m_constable
gen ratio_asi = po_f_asi/po_m_asi
gen ratio_si = po_f_si/po_m_si
gen ratio_ins = po_f_ins/po_m_ins
gen ratio_sho = po_f_sho/po_m_sho

gen dum_headconstable = 0
replace dum_headconstable = 1 if ratio_headconstable >= 0.33
gen dum_wtconstable = 0
replace dum_wtconstable = 1 if ratio_wtconstable >= 0.33
gen dum_constable = 0
replace dum_constable = 1 if ratio_constable >= 0.33
gen dum_asi = 0
replace dum_asi = 1 if ratio_asi >= 0.33
gen dum_si = 0
replace dum_si = 1 if ratio_si >= 0.33
gen dum_ins = 0
replace dum_ins = 1 if ratio_ins >= 0.33
gen dum_sho = 0
replace dum_sho = 1 if ratio_sho >= 0.33
drop sv_id sv_location _new
*rename ps_dist_id_bl ps_dist_id
merge 1:1 ps_dist_id using "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\06.clean-data\pooled_randomisation.dta"
drop if _m != 3

gen wgt=1
gen stdgroup= (treatment==0)
 **creating the PSFS (General) index (Anderson)
qui do "${do_files}\make_index_gr.do" //Execute Anderson index do file
local psfs_gen ps_bathroom  ps_confidential ps_electricity dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv 
make_index_gr psfs_gen_And wgt stdgroup `psfs_gen'
label var index_psfs_gen_And "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_And

**creating the PSFS (General) index (Regular)
egen index_psfs_gen_Reg = rowmean(ps_bathroom ps_confidential ps_electricity dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv)
label var index_psfs_gen_Reg "Police Station Facilities (Infrastructure) Index (Regular)"
summ index_psfs_gen_Reg

 **creating the PSFS (Fem Infra) index (Anderson)

local psfs_fem_infra ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter 
make_index_gr psfs_fem_infra_And wgt stdgroup `psfs_fem_infra'
label var index_psfs_fem_infra_And "Police Station Gender Facilities Index (Anderson)"
summ index_psfs_fem_infra_And

**creating the PSFS (Fem Infra) index (Regular)
egen index_psfs_fem_infra_Reg = rowmean(ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter)
label var index_psfs_fem_infra_Reg "Police Station Gender Facilities Index (Regular)"
summ index_psfs_fem_infra_Reg

**creating the PSFS (Male-Female Segregation) index (Anderson)

local psfs_m_f_seg_1 dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho
make_index_gr psfs_m_f_seg_And wgt stdgroup `psfs_m_f_seg_1'
label var index_psfs_m_f_seg_And "PSFS (Male-Female Segregation) Index (Anderson)"
summ index_psfs_m_f_seg_And 

**creating the PSFS (Male-Female Segregation) index (Regular)
egen index_psfs_m_f_seg_Reg = rowmean(dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho)
label var index_psfs_m_f_seg_Reg "PSFS (Male-Female Segregation) Index (Regular)"
summ index_psfs_m_f_seg_Reg 

egen total_fem_officers = rowmean(po_f_headconstable po_f_wtconstable po_f_constable po_f_asi po_f_si po_f_ins po_f_sho)
label variable total_fem_officers "Female police members" 

drop _merge
merge 1:1 ps_dist_id using "$addl_controls\06.clean-data\PS_variables.dta"
drop if _m != 3
drop _merge

egen psfs_count_femofficers = rowtotal(po_f_headconstable po_f_wtconstable po_f_constable po_f_asi po_f_si po_f_ins po_f_sho)
summ psfs_count_femofficers, detail
local fem_p50 = r(p50)
gen dum_fem = (psfs_count_femofficers > `fem_p50')
*gen treatment_femofficers = treatment_bl*dum_fem
la var dum_fem "Female officer strength"
la define dum_fem 0"Below median strength" 1"Above median strength"
la values dum_fem dum_fem

tempfile psfs_combined
save `psfs_combined'

save "$psfs\PSFS-2022\06.clean-data\psfs_combined.dta", replace

recode treatment 0=1 1=0

****swindex - PSFS

swindex ps_bathroom ps_confidential dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv, g(swindex_psfs_gen_bl) normby(treatment) displayw

swindex ps_fembathroom ps_femconfidential ps_fembarrack ps_femlockup ps_femshelter, g(swindex_psfs_fem_infra_bl) normby(treatment) displayw

swindex dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho, g(swindex_psfs_m_f_seg_bl) normby(treatment) displayw

recode treatment 0=1 1=0

label variable treatment "Treatment"

label variable swindex_psfs_gen_bl "Facilities (general)"
label variable swindex_psfs_fem_infra_bl "Facilities (gender)"
label variable swindex_psfs_m_f_seg_bl "Gender segregation"

label variable index_psfs_gen_Reg "Facilities (general)"
label variable index_psfs_fem_infra_Reg "Facilities (gender)"
label variable index_psfs_m_f_seg_Reg "Gender segregation"

label variable ps_fir "FIRs in last year (reported)"
label variable po_tot_asi "ASI officers"
label variable po_tot_si "SI officers"
label variable po_tot_constable "Constables"
************
rename ps_dist_id ps_dist_id_bl

********Balance Tables

*############### Generating global variables ####################################


//Var list for Indices
global ps_indices "index_psfs_gen_Reg index_psfs_fem_infra_Reg index_psfs_m_f_seg_Reg" 


//Var list for  Characteristics
global ps_characteristics "ps_fir po_tot_asi po_tot_si po_tot_constable total_fem_officers ruralurban_dum"


*############ Balance on PSFS Indices ################

balancetable (mean if treatment == 0) (mean if treatment == 1) ///
(diff treatment) ///
$ps_indices using "${tables}balance_psfs_indices.xlsx", covariates(ps_dist strata) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (2) and (1)") varla ///

balancetable (mean if treatment == 0) (mean if treatment == 1) ///
(diff treatment) ///
$ps_indices using "${tables}balance_psfs_indices.tex", covariates(ps_dist strata) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (2) and (1)") varla ///

*############ Balance on characteristics ################
balancetable (mean if treatment == 0) (mean if treatment == 1) ///
(diff treatment) ///
$ps_characteristics using "${tables}balance_psfs_char.xlsx", covariates(ps_dist strata) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (2) and (1)") varla ///

balancetable (mean if treatment == 0) (mean if treatment == 1) ///
(diff treatment) ///
$ps_characteristics using "${tables}balance_psfs_char.tex", covariates(ps_dist strata) vce(cluster ps_dist_id_bl) replace ///
ctitles("Control" "Treatment" "Diff b/w (2) and (1)") varla ///


