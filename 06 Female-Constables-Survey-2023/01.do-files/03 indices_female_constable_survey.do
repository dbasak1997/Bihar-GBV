/*==============================================================================
File Name: Female Constables Survey 2022 - Indices do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	16/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to create the indices for the female constables survey

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

log using "$FC_survey_log_files\femaleconstable_indices.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"


******************MALE OFFICERS DATA******************
use "$MO_endline_clean_dta\endline_secondaryoutcomes.dta", clear

*****NOTE: We have tracked police station at baseline (ps_dist_id_bl) and police station at endline (ps_dist_id_el)
*****For collapsing the officer data to station level, we use the endline police station id - ps_dist_id_el

drop if dum_endline == 0
bysort ps_dist_id_el: egen count_maleofficers_el = total(dum_endline) // count of male officers in police station at endline
bysort ps_dist_id_el: egen count_maleofficers_trained_el = total(dum_training) // count of trained male officers in police station at endline
collapse (mean) count_maleofficers_el count_maleofficers_trained_el, by (ps_dist_id_el) // collapsing to PS-level dataset
gen share_trainedofficers_el = count_maleofficers_trained_el/count_maleofficers_el
rename ps_dist_id_el ps_dist_id
la var count_maleofficers_el "Count of male officers in PS (endline)"
la var count_maleofficers_trained_el "Count of male officers who received training in PS (endline)"
la var share_trainedofficers_el "Share of male officers who received training in PS (endline)"
tempfile endline_count
save `endline_count'

******************PSFS DATA******************

use "$psfs_clean_dta\psfs_combined.dta", clear

*****Here we generate a count for female constables in each station according to PSFS reporting, then we generate a dummy that takes value if the PS has above median strength of female constables
drop psfs_count_femofficers dum_fem
egen psfs_count_femofficers = rowtotal(po_f_headconstable po_f_wtconstable po_f_constable po_f_asi po_f_si po_f_ins po_f_sho)
summ psfs_count_femofficers, detail
local fem_p50 = r(p50)
gen dum_fem = (psfs_count_femofficers > `fem_p50')
la var dum_fem "Female officer strength"
la define dum_fem 0"Below median strength" 1"Above median strength", modify
la values dum_fem dum_fem

tempfile psfs_clean
save `psfs_clean'

******************FEMALE CONSTABLES DATA**********************

use "$FC_survey_clean_dta\femaleconstables_clean.dta", clear

rename intvar1 ps_dist_id

merge m:1 ps_dist_id using `endline_count' // merging with endline count
drop if _m != 3
drop _m


merge m:1 ps_dist_id using `psfs_clean' // merging with PSFS data
drop if _m != 3
drop _m


**************INDEX CONSTRUCTION**********************

// Perception towards Workplace Integration
codebook q2001 q2002 q2003 q2004 q2005 q2006 q2007 q2008 q2009 q2010

gen q2001_dum = q2001
recode q2001_dum 1=1 2=0 3=0 4=0 5=0
gen q2002_dum = q2002
recode q2002_dum 1=0 2=0 3=0 4=0 5=1 //reversing

gen q2003_dum = q2003
recode q2003_dum 1=1 2=0 3=0 4=0 5=0

gen q2004_dum = q2004
recode q2004_dum 1=1 2=0 3=0 4=0 5=0
gen q2005_dum = q2005
recode q2005_dum 1=1 2=0 3=0 4=0 5=0
gen q2006_dum = q2006
recode q2006_dum 1=1 2=0 3=0 4=0 5=0
gen q2007_dum = q2007
recode q2007_dum 1=1 2=0 3=0 4=0 5=0

gen q2008_dum = q2008
recode q2008_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen q2009_dum = q2009
recode q2009_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen q2010_dum = q2010
recode q2010_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1 

drop wgt stdgroup
gen wgt = 1
gen stdgroup = treatment == 0 // setting stdgroup = 1 if control group

**creating the Perception towards Workplace Integration index (Anderson)
qui do "$FC_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Perception q2001_dum q2002_dum q2003_dum q2004_dum q2005_dum /*q2006_dum*/ q2007_dum q2008_dum q2009_dum q2010_dum

make_index_gr Perception_Integ_And wgt stdgroup `Perception'
label var index_Perception_Integ_And "Perception towards Workplace Integration Index (Anderson)"
summ index_Perception_Integ_And

**creating the Perception towards Workplace Integration index (Regular)
egen index_Perception_Integ_Reg = rowmean(q2001_dum q2002_dum q2003_dum q2004_dum q2005_dum /*q2006_dum*/ q2007_dum q2008_dum q2009_dum q2010_dum)
label var index_Perception_Integ_Reg "Perception towards Workplace Integration Index (Regular)"
summ index_Perception_Integ_Reg

*generating histogram for the Work Environment (Relationships) indices (Anderson + Regular)
histogram index_Perception_Integ_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P1)
histogram index_Perception_Integ_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P2)


// Work Environment (Relationships)
codebook q3100_val q3101_val q3102_val q3103_val q3104_val
destring q3100_val, gen (q3100_dum)
destring q3101_val, gen (q3101_dum)
destring q3102_val, gen (q3102_dum)
destring q3103_val, gen (q3103_dum)
destring q3104_val, gen (q3104_dum)

recode q3100_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
recode q3101_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0 //reversing
recode q3102_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
recode q3103_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
recode q3104_dum 0=0 1=0 2=0 3=0 4=0 5=1 6=1 //reversing

local Workenv_Rel q3100_dum q3101_dum q3102_dum q3103_dum q3104_dum

make_index_gr Workenv_Rel_And wgt stdgroup `Workenv_Rel'
label var index_Workenv_Rel_And "Work Environment (Relationships) Index (Anderson)"
summ index_Workenv_Rel_And

**creating the Work Environment (Relationships) index (Regular)
egen index_Workenv_Rel_Reg = rowmean(q3100_dum q3101_dum q3102_dum q3103_dum q3104_dum)
label var index_Workenv_Rel_Reg "Work Environment (Relationships) Index (Regular)"
summ index_Workenv_Rel_Reg

*generating histogram for the Work Environment (Relationships) indices (Anderson + Regular)
histogram index_Workenv_Rel_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(W1)
histogram index_Workenv_Rel_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(W2)

// Work Environment (Representation)
codebook q3201_val q3202_val q3203_val q3204_val

destring q3201_val, gen (q3201_dum)
destring q3202_val, gen (q3202_dum)
destring q3203_val, gen (q3203_dum)
destring q3204_val, gen (q3204_dum)

recode q3201_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
recode q3202_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
recode q3203_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
recode q3204_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

local Workenv_Rep q3201_dum q3202_dum q3203_dum q3204_dum

make_index_gr Workenv_Rep_And wgt stdgroup `Workenv_Rep'
label var index_Workenv_Rep_And "Work Environment (Representation) Index (Anderson)"
summ index_Workenv_Rep_And

**creating the Work Environment (Representation) index (Regular)
egen index_Workenv_Rep_Reg = rowmean(q3201_dum q3202_dum q3203_dum q3204_dum)
label var index_Workenv_Rep_Reg "Work Environment (Representation) Index (Regular)"
summ index_Workenv_Rep_Reg

*generating histogram for the Work Environment (Representation) indices (Anderson + Regular)
histogram index_Workenv_Rep_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(WP1)
histogram index_Workenv_Rep_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(WP2)


// Work Environment (Perception towards male officers)
codebook q3301_val q3302_val q3303_val q3304_val q3305_val

destring q3301_val, gen (q3301_dum)
destring q3302_val, gen (q3302_dum)
destring q3303_val, gen (q3303_dum)
destring q3304_val, gen (q3304_dum)
destring q3305_val, gen (q3305_dum)

recode q3301_dum 1=1 2=0 3=0 4=0 5=0
recode q3302_dum 1=1 2=0 3=0 4=0 5=0 -666=0
recode q3303_dum 1=0 2=0 3=0 4=0 5=1
recode q3304_dum 1=0 2=0 3=0 4=0 5=1
recode q3305_dum 1=0 2=0 3=0 4=0 5=1

local Workenv_Male q3301_dum /*q3302_dum*/ q3303_dum q3304_dum q3305_dum

make_index_gr Workenv_Male_And wgt stdgroup `Workenv_Male'
label var index_Workenv_Male_And "Work Environment (Perception towards male officers) Index (Anderson)"
summ index_Workenv_Male_And

**creating the Work Environment (Perception towards male officers) index (Regular)
egen index_Workenv_Male_Reg = rowmean(q3301_dum q3302_dum /*q3302_dum*/ q3304_dum q3305_dum)
label var index_Workenv_Male_Reg "Work Environment (Perception towards male officers) Index (Regular)"
summ index_Workenv_Male_Reg

*generating histogram for the Work Environment (Perception towards male officers) indices (Anderson + Regular)
histogram index_Workenv_Male_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(WM1)
histogram index_Workenv_Male_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(WM2)


// Work Environment (Distribution of work)
destring q3401_val, gen(q3401_dum)
destring q3406_val, gen(q3406_dum)
destring q3407_val, gen(q3407_dum)
destring q3408_val, gen(q3408_dum)
destring q3409_val, gen(q3409_dum)
destring q3410_val, gen(q3410_dum)
destring q3411_val, gen(q3411_dum)
destring q3412_val, gen(q3412_dum)
destring q3413_val, gen(q3413_dum)
destring q3414_val, gen(q3414_dum)


recode q3401_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0


//generating variable for work distribution for female constables
replace q3402_val = subinstr(q3402_val, "-888", "11", .) //observed OS options, they are patrol/court/VIP duty
gen workdistribution = 0
gen workdistribution_2 = 0

//generating item-wise dummies
forvalues i = 1/22 {
    gen dummy_3402_`i' = regexm(q3402_val, "(^| )`i'($| )")
}

//replacing workdistribution variable as 1 if GBV-related tasks are assigned
foreach i of numlist 1 2 8 9 10 17 20{
	replace workdistribution = 1 if dummy_3402_`i' == 1
}

//replacing workdistribution variable as 1 if GBV-related tasks + counselling activity (item no 21) are assigned
foreach i of numlist 1 2 8 9 10 17 20 21{
	replace workdistribution_2 = 1 if dummy_3402_`i' == 1
}

//generating variable for typical cases for female constables
gen fem_typical_case = 0

//generating item-wise dummies
forvalues i = 1/10 {
    gen dummy_3403_`i' = regexm(q3403_val, "(^| )`i'($| )")
}

//replacing fem_typical_case variable as 1 if the typical case is a GBV-related case
forvalues i = 6/9{
	replace fem_typical_case = 1 if dummy_3403_`i' == 1
}

//generating variable for change in assignment for male officers
gen change_assignment_male = 0

//generating item-wise dummies
forvalues i = 1/10 {
    gen dummy_3405_`i' = regexm(q3405_val, "(^| )`i'($| )")
}

//replacing change_assignment_male variable as 1 if male officer changed assignment to GBV-related case
forvalues i = 6/9{
	replace change_assignment_male = 1 if dummy_3405_`i' == 1
}

recode q3406_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3407_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3408_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3409_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3410_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3411_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1 // reversing
recode q3412_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3413_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0
recode q3414_dum 0=1 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=0


local WorkDistr q3401_dum workdistribution fem_typical_case change_assignment_male q3406_dum q3407_dum q3408_dum q3409_dum q3410_dum q3411_dum q3412_dum q3413_dum q3414_dum

make_index_gr WorkDistr_And wgt stdgroup `WorkDistr'
label var index_WorkDistr_And "Work Distribution Index (Anderson)"
summ index_WorkDistr_And

**creating the Work Distribution index (Regular)
egen index_WorkDistr_Reg = rowmean(q3401_dum workdistribution fem_typical_case change_assignment_male q3406_dum q3407_dum q3408_dum q3409_dum q3410_dum q3411_dum q3412_dum q3413_dum q3414_dum)
label var index_WorkDistr_Reg "Work Distribution Index (Regular)"
summ index_WorkDistr_Reg

*generating histogram for the Work Distribution Index (Anderson + Regular)
histogram index_WorkDistr_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(WD1)
histogram index_WorkDistr_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(WD2)


// Male Officer - Sensitivity towards females
codebook q4001 q4002 q4003 q4004 q9002

gen q4001_dum = q4001
recode q4001_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
gen q4002_dum = q4002
recode q4002_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
gen q4003_dum = q4003
recode q4003_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1
gen q4004_dum = q4004
recode q4004_dum 0=0 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0 10=1

gen trainingaware_dum = 0
replace trainingaware_dum = 1 if q9002 == 1 | q9005 == 1 // we will not use this variable since this question was only answered by female constables in treatment stations

local Sensitivity q4001_dum q4002_dum q4003_dum q4004_dum /*trainingaware_dum*/

make_index_gr Sensitivity_And wgt stdgroup `Sensitivity'
label var index_Sensitivity_And "Male officers' sensitivity towards females (Anderson)"
summ index_Sensitivity_And

**creating the Training Learnings index (Regular)
egen index_Sensitivity_Reg = rowmean(q4001_dum q4002_dum q4003_dum q4004_dum /*trainingaware_dum*/)
label var index_Sensitivity_Reg "Male officers' sensitivity towards females (Regular)"
summ index_Sensitivity_Reg

*generating histogram for the Training Learnings Index (Anderson + Regular)
histogram index_Sensitivity_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(TL1)
histogram index_Sensitivity_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(TL2)


//Sexual Harassment (Note: 1 indicates less severity/probability of incidence of sexual harassment, 0 indicates more severity/probability)

foreach i in h1 h2 h3 h4 h5 h6 {
	
	gen `i'_dum = `i'
	recode `i'_dum -999=0 -666=0
	gen `i'_who_dum = 0
	replace `i'_who_dum = 1 if `i'b_1 == 1
	gen `i'_incident_dum = 0
	replace `i'_incident_dum = 1 if `i'_dum == 1 & `i'_who_dum == 1
	gen `i'_reported_dum = 0
	replace `i'_reported_dum = 1 if `i'c == 0
	
	replace `i'_incident_dum = 0 if `i'_incident_dum ==.
	replace `i'_reported_dum = 0 if `i'_reported_dum ==.
}

local harassment h1_incident_dum h1_reported_dum h2_incident_dum h2_reported_dum h3_incident_dum h3_reported_dum h4_incident_dum h4_reported_dum h5_incident_dum h5_reported_dum h6_incident_dum h6_reported_dum

make_index_gr harassment_And wgt stdgroup `harassment'
label var index_harassment_And "Sexual Harassment Index (Anderson)"
summ index_harassment_And

**creating the Sexual Harassment index (Regular)
egen index_harassment_Reg = rowmean(h1_incident_dum h1_reported_dum h2_incident_dum h2_reported_dum h3_incident_dum h3_reported_dum h4_incident_dum h4_reported_dum h5_incident_dum h5_reported_dum h6_incident_dum h6_reported_dum)
label var index_harassment_Reg "Sexual Harassment Index (Regular)"
summ index_harassment_Reg

*generating histogram for the Sexual Harassment Index (Anderson + Regular)
histogram index_harassment_And, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(H1)
histogram index_harassment_Reg, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(H2)

// Social Desirability Index

**codebook of variables to be used for Social Desirability Index
codebook q6001 q6002 q6003 q6004 q6005 q6006 q6007 q6008 q6009 q6010 q6011 q6012 q6013

//Recoding Explanation: Given by Reynolds here https://www.dropbox.com/scl/fi/9a3f3o8k5d97xxpqc0v4l/Crowne-Marlow1960-SCORING.pdf?rlkey=h5plsyv7s2hgokcyacbtuosae&dl=0
label def SDB 0 "NEGATIVE" 1 "POSITIVE"
foreach var of varlist q6005 q6007 q6009 q6010 q6013 { 
	gen `var'_dum = `var' //for all questions, we have 2 - False , 1 - True
	recode `var'_dum 2=0 // This excludes 5,7,9,10,13 where True indicates higher SDB
	label values `var'_dum SDB
} //reversing the direction of the variables

*label def SDB_1 0 "FALSE" 1 "TRUE"
foreach var of varlist q6001 q6002 q6003 q6004 q6006 q6008 q6011 q6012 { 
	gen `var'_dum = `var' //for all questions, we have 2 - False , 1 - True
	recode `var'_dum 2=1 1=0 //recoding for all questions where False indicates higher SDB. 
	label values `var'_dum SDB
}


**creating the Social Desirability index (Anderson)
qui do "$FC_survey_do_files\make_index_gr.do" //Execute Anderson index do file

local Desir q6001_dum q6002_dum q6003_dum q6004_dum q6005_dum q6006_dum q6007_dum q6008_dum q6009_dum q6010_dum q6011_dum q6012_dum q6013_dum

make_index_gr Desirability_And_fem wgt stdgroup `Desir'
label var index_Desirability_And_fem "Desirability Index (Anderson)"
summ index_Desirability_And_fem

**creating the Social Desirability index (Regular)
gen index_Desirability_Reg_fem = q6001_dum + q6002_dum + q6003_dum + q6004_dum + q6005_dum + q6006_dum + q6007_dum + q6008_dum + q6009_dum + q6010_dum + q6011_dum + q6012_dum + q6013_dum
label var index_Desirability_Reg_fem "Desirability Index (Regular)"
summ index_Desirability_Reg_fem

*generating histogram for the Social Desirability indices (Anderson + Regular)
histogram index_Desirability_And_fem, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S1)
histogram index_Desirability_Reg_fem, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(S2)

// Anxiety Index

**codebook of variables to be used for Anxiety Index
codebook q8001 q8002 q8003 q8004 q8005 q8006 q8007
      
**recoding Refused to Answer and DN values
recode q8001 -999=1 -666=1
recode q8002 -999=1 -666=1
recode q8003 -999=1 -666=1
recode q8004 -999=1 -666=1
recode q8005 -999=1 -666=1
recode q8006 -999=1 -666=1
recode q8007 -999=1 -666=1

**converting the GAD scale from 1-4 to 0-3
replace q8001 = q8001 - 1
replace q8002 = q8002 - 1
replace q8003 = q8003 - 1
replace q8004 = q8004 - 1
replace q8005 = q8005 - 1
replace q8006 = q8006 - 1
replace q8007 = q8007 - 1

**assigning correct labels to the recoded variables
label define GAD 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values q8001 GAD
label values q8002 GAD
label values q8003 GAD
label values q8004 GAD
label values q8005 GAD
label values q8006 GAD
label values q8007 GAD

**creating the Anxiety Index
gen index_Anxiety_fem = q8001 + q8002 + q8003 + q8004 + q8005 + q8006 + q8007

label var index_Anxiety_fem "Anxiety Index"
summ index_Anxiety_fem

*generating histogram for the Anxiety Index
histogram index_Anxiety_fem, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(X1)

// Depression Index

**codebook of variables to be used for Depression Index
codebook q8008 q8009 q8010 q8011 q8012 q8013 q8014 q8015 q8016
        
recode q8008 -999=1 -666=1
recode q8009 -999=1 -666=1
recode q8010 -999=1 -666=1
recode q8011 -999=1 -666=1
recode q8012 -999=1 -666=1
recode q8013 -999=1 -666=1
recode q8014 -999=1 -666=1
recode q8015 -999=1 -666=1
recode q8016 -999=1 -666=1

**converting the PHQ scale from 1-4 to 0-3
replace q8008 = q8008 - 1
replace q8009 = q8009 - 1
replace q8010 = q8010 - 1
replace q8011 = q8011 - 1
replace q8012 = q8012 - 1
replace q8013 = q8013 - 1
replace q8014 = q8014 - 1
replace q8015 = q8015 - 1
replace q8016 = q8016 - 1

**assigning correct labels to the recoded variables
label define PHQ 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"
label values q8008 PHQ
label values q8009 PHQ
label values q8010 PHQ
label values q8011 PHQ
label values q8012 PHQ
label values q8013 PHQ
label values q8014 PHQ
label values q8015 PHQ
label values q8016 PHQ

**creating the Depression Index
gen index_Depression_fem = q8008 + q8009 + q8010 + q8011 + q8012 + q8013 + q8014 + q8015 + q8016

label var index_Depression_fem "Depression Index"
summ index_Depression_fem

*generating histogram for the Depression Index
histogram index_Depression_fem, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(D1)


**********generating PSFS indices*************
drop index_psfs_gen_And index_psfs_gen_Reg index_psfs_fem_infra_And index_psfs_fem_infra_Reg index_psfs_m_f_seg_And index_psfs_m_f_seg_Reg
gen ps_femconfid_dum = 0
replace ps_femconfid_dum = 1 if ps_femconfidential == 0

**creating the PSFS (General) index (Anderson)
local psfs_gen ps_bathroom ps_confidential ps_electricity dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv 
make_index_gr psfs_gen_And wgt stdgroup `psfs_gen'
egen std_index_psfs_gen_And = std(index_psfs_gen_And)
label var index_psfs_gen_And "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_And

**creating the PSFS (General) index (Regular)
egen index_psfs_gen_Reg = rowmean(ps_confidential ps_electricity dum_ps_fourwheeler dum_ps_twowheeler dum_ps_computer ps_seating ps_cleaning ///
ps_water ps_barrack ps_storage ps_evidence ps_phone dum_lockup ps_shelter dum_ps_cctv)
label var index_psfs_gen_Reg "Police Station Facilities (Infrastructure) Index (Anderson)"
summ index_psfs_gen_Reg

 **creating the PSFS (Fem Infra) index (Anderson)

local psfs_fem_infra ps_fembathroom ps_femconfid_dum ps_fembarrack ps_femlockup ps_femshelter 
make_index_gr psfs_fem_infra_And wgt stdgroup `psfs_fem_infra'
egen std_index_psfs_fem_infra_And = std(index_psfs_fem_infra_And)
label var index_psfs_fem_infra_And "Police Station Gender Facilities Index (Anderson)"
summ index_psfs_fem_infra_And

**creating the PSFS (Fem Infra) index (Regular)
egen index_psfs_fem_infra_Reg = rowmean(ps_fembathroom ps_femconfid_dum ps_fembarrack ps_femlockup ps_femshelter)
label var index_psfs_fem_infra_Reg "Police Station Gender Facilities Index (Regular)"
summ index_psfs_fem_infra_Reg

**creating the PSFS (Male-Female Segregation) index (Anderson)

local psfs_m_f_seg_1 dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho
make_index_gr psfs_m_f_seg_And wgt stdgroup `psfs_m_f_seg_1'
egen std_index_psfs_m_f_seg_And = std(index_psfs_m_f_seg_And)
label var index_psfs_m_f_seg_And "PSFS (Male-Female Segregation) Index (Anderson)"
summ index_psfs_m_f_seg_And 

**creating the PSFS (Male-Female Segregation) index (Regular)
egen index_psfs_m_f_seg_Reg = rowmean(dum_headconstable dum_wtconstable dum_constable dum_asi dum_si dum_ins dum_sho)
label var index_psfs_m_f_seg_Reg "PSFS (Male-Female Segregation) Index (Regular)"
summ index_psfs_m_f_seg_Reg

rename workdistribution workdistr_dum
rename workdistribution_2 workdistr2_dum
rename fem_typical_case fem_typical_dum

save "$FC_survey_clean_dta\femaleconstables_indices", replace

********averaging at the station-level for select variables*************

gen count = 1

	foreach var in q2008_dum q2009_dum q2010_dum q2003_dum workdistr_dum workdistr2_dum fem_typical_dum q3411_dum q4003_dum{
	rename `var' station_`var'
	}

	collapse (mean) station_* (sum) count, by (ps_dist_id treatment)
	rename count number_officers_female


foreach var in q2008 q2009 q2010 q2003 workdistr workdistr2 fem_typical q3411 q4003 {
	gen `var'_ps_dum = 0
	replace `var'_ps_dum = 1 if station_`var'_dum > 0.5
 }

save "$FC_survey_clean_dta\femaleconstables_ps_avg_selectvars", replace


/*
collapse (mean) index_Perception_Integ_And index_Perception_Integ_Reg index_Workenv_Rel_And index_Workenv_Rel_Reg index_Workenv_Rep_And index_Workenv_Rep_Reg index_Workenv_Male_And index_Workenv_Male_Reg index_WorkDistr_And index_WorkDistr_Reg index_TrainingLearning_And index_TrainingLearning_Reg index_harassment_And index_harassment_Reg index_Desirability_And_fem index_Desirability_Reg_fem index_Anxiety_fem index_Depression_fem, by (ps_dist_id)

save "${clean_dta}femaleconstables_indices_collapsed", replace
*/