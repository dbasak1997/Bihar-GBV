/*==============================================================================
File Name: Female Constables Survey 2022 - Indices do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	22/11/2024
Created by: Giovanni D'Ambrosio
Updated on: 27/11/2024
Updated by:	Giovanni D'Ambrosio

*Notes READ ME:
*This is the Do file to create the indices for the female constables survey

==============================================================================*/

clear all
set more off
cap log close

* Log file

log using "$log_files\femaleconstable_indices_gd.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

****************************INDEX CONSTRUCTION**********************************

* Load data

use "$clean_dta/female_constables_clean.dta", clear

***Integration in the workplace

/*
I am using the command swindex. See https://journals.sagepub.com/doi/full/10.1177/1536867X20976325

Anderson (2008) proposes constructing a summary index using a generalized 
least-squares (GLS) weighting procedure.
Indices can be constructed using a mix of continuous and binary indicators, and 
combinations of the two are commonly used. The researcher is simply required to
assign each variable with a direction (that is, polarity)—positive or negative. 
For variables with answers on agreement scale, We could either allow the variable 
to enter as a continuous variable with values ranging from 1 to 5 or create a 
binary variable for a negative response (1 or 2) that enters negatively into the
index and a binary variable for a positive response (4 or 5) that enters positively
into the index.

By default, the program rescales the calculated index to the mean and standard
deviation of the sample used for the standardization in the GLS weighting procedure.
This rescaling results in an "effect size" interpretation where the index is
distributed mean zero with standard deviation one within the sample used.  
The fullrescale option allows the user to rescale the calculated index using the 
full sample, even if normby() has been invoked for the GLS weighting procedure. Further, the
user can opt not to rescale at all by specifying norescale.
WHICH OPTION SHOULD WE USE HERE?
*/

/*
In our case, we use the following variables for the index construction:
2001--> needs to be recoded;
2002--> does not need recoding;
2003--> needs to be recoded;
2004--> needs to be recoded;
2005--> needs to be recoded;
2006--> needs to be recoded;
2007--> needs to be recoded;
2008--> does not need recoding;
2009--> does not need recoding;
2010--> does not need recoding;
*/

cap gen stdgroup = treatment == 0 // setting stdgroup = 1 if control group

swindex q2001 q2002 q2003 q2004 q2005 q2006 q2007 q2008 q2009 q2010, gen(work_integration_index_and) flip(q2001 q2003 q2004 q2005 q2006 q2007) normby(stdgroup) displayw

label var work_integration_index_and "Integration in the Workplace Index (Anderson)"
summ work_integration_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var of varlist q2001 q2003 q2004 q2005 q2006 q2007 {
    gen `var'_rec = 6 - `var'
}
foreach var in q2001_rec q2002 q2003_rec q2004_rec q2005_rec q2006_rec q2007_rec q2008 q2009 q2010 {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen work_integration_index_kling=rowmean(q2001_rec_std q2002_std q2003_rec_std q2004_rec_std q2005_rec_std q2006_rec_std q2007_rec_std q2008_std q2009_std q2010_std)
drop *std
drop *_rec
label var work_integration_index_kling "Integration in the Workplace Index (Kling)"


* Generate histogram for the Integration in the workplace indices (Anderson + Kling)
histogram work_integration_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P1)
histogram work_integration_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P2)

********************************************************************************

* Relationship with other officers

/*
We use the following variables for the index construction:
3100--> does not need recoding;
3101--> needs to be recoded;
3102--> does not need recoding;
3103--> needs to be recoded;
3104--> needs to be recoded;
*/

codebook q3100_val q3101_val q3102_val q3103_val q3104_val

foreach var of varlist q3100_val q3101_val q3102_val q3103_val q3104_val {
	destring `var', replace
}

swindex q3100_val q3101_val q3102_val q3103_val q3104_val, gen(relation_officers_index_and) flip(q3101_val q3103_val q3104_val) normby(stdgroup) displayw

label var relation_officers_index_and "Relationship with Other Officers Index (Anderson)"
summ relation_officers_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var of varlist q3101_val q3103_val q3104_val {
    gen `var'_rec = 10 - `var'
}

foreach var in q3100_val q3101_val_rec q3102_val q3103_val_rec q3104_val_rec {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen relation_officers_index_kling=rowmean(q3100_val_std q3101_val_rec_std q3102_val_std q3103_val_rec_std q3104_val_rec_std)
drop *std
drop *_rec
label var relation_officers_index_kling "Relationship with Other Officers Index (Kling)"


* Generate histogram for the Relationship with Other Officers indices (Anderson + Kling)
histogram relation_officers_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P3)
histogram relation_officers_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P4)

********************************************************************************

* Female representation in the Bihar Police 

/*
We use the following variables for the index construction:
3201--> does not need recoding;
3202--> does not need recoding;
3203--> does not need recoding;
3204--> does not need recoding;
*/

codebook q3201_val q3202_val q3203_val q3204_val

foreach var of varlist q3201_val q3202_val q3203_val q3204_val {
	destring `var', replace
}

swindex q3201_val q3202_val q3203_val q3204_val, gen(fem_representation_index_and) normby(stdgroup) displayw

label var fem_representation_index_and "Female Representation Index (Anderson)"
summ fem_representation_index_and

* Create index following Kling et al. (2017)

foreach var in q3201_val q3202_val q3203_val q3204_val {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen fem_representation_index_kling=rowmean(q3201_val_std q3202_val_std q3203_val_std q3204_val_std)
drop *std
label var fem_representation_index_kling "Female Representation Index (Kling)"


* Generate histogram for the Female Representation indices (Anderson + Kling)
histogram fem_representation_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P5)
histogram fem_representation_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P6)

********************************************************************************

* Perceptions towards male officers 

/*
We use the following variables for the index construction:
3301--> needs to be recoded;
3302--> not using this;
3303--> does not need recoding;
3304--> does not need recoding;
3305--> does not need recoding;
*/

codebook q3301_val q3302_val q3303_val q3304_val q3305_val
replace q3302_val=. if q3302_val==-666

swindex q3301_val q3303_val q3304_val q3305_val, gen(perceptions_moff_index_and) flip(q3301_val) normby(stdgroup) displayw

label var perceptions_moff_index_and "Perceptions Towards Male Officers Index (Anderson)"
summ perceptions_moff_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var of varlist q3301_val q3302_val {
    gen `var'_rec = 6 - `var' if `var'!=.
}

foreach var in q3301_val_rec q3303_val q3304_val q3305_val {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen perceptions_moff_index_kling=rowmean(q3301_val_rec_std q3303_val_std q3304_val_std q3305_val_std)
drop *std
drop *_rec
label var perceptions_moff_index_kling "Perceptions Towards Male Officers Index (Kling)"


* Generate histogram for the Perceptions Towards Male Officers indices (Anderson + Kling)
histogram perceptions_moff_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P7)
histogram perceptions_moff_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P8)

********************************************************************************

* Work environment: Distribution of work at the PS

/* 
Questions:
1) Is it about being involved in more gender specific cases or about being involved
in better tasks/tasks that are supposed to be more difficult/that are more
important?

The objective of this index is understanding if after the training female 
officers are assigned to tasks that are higher quality and improve reputation. 
Therefore we can divide the 22 options into low quality, medium quality, high quality. 
We can generate a variable that counts number of tasks selected and weights more 
if high quality. 
*/

/*
Generate a variable that counts number of tasks weighing low quality tasks 0.2,
medium quality tasks 0.3, and high quality tasks 0.5
*/

gen count_tasks_weighted=.
replace count_tasks_weighted=0.2*q3402_4+0.2*q3402_5+0.2*q3402_12+0.2*q3402_13+0.2*q3402_14+ 0.2*q3402_18+ ///
0.2*q3402_19+0.3*q3402_6+0.3*q3402_8+0.3*q3402_9+0.3*q3402_11+0.3*q3402_17+0.3*q3402_20+0.3*q3402_21+0.3*q3402_22+ ///
0.5*q3402_1+0.5*q3402_2+0.5*q3402_3+0.5*q3402_7+0.5*q3402_10+0.5*q3402_15+0.5*q3402_16

* Fixing question q3403_val


/*
Generate a variable that counts number of cases weighing low quality cases 0.2,
and high quality cases 0.5, and equal distribution of cases 0.3. 
If officers claim they are more likely to be involved in cases that are considered 
high stakes and complex, such as murders, land disputes, domestic violence, sexual
assault/rape, eve-teasing, dowry death we use 0,.5; if they claim to be equally likely to 
be a part of any case we use 0.3. The weight will be equal to 0.2 if the officer
claims to be more likely to be involved in cases that are considered to be low 
stakes, such as chain snatching, theft, illegal alcohol. 
*/

* Generate a variable that counts high stakes tasks officers claim to be likely to be a part of
gen count_high_stake_tasks_fem=0.2*q3403_1+0.2*q3403_2+0.2*q3403_3+0.5*q3403_4+ ///
0.5*q3403_5+0.5*q3403_6+0.5*q3403_7+0.5*q3403_8+0.5*q3403_9+0.3*q3403_10

/*
Is question 3404 and 3405 about junior male officers being assigned to different cases?
If yes, we want to check if male officers are now switching to non-gbv cases?
Or to lower stake cases?
Or is it about senior male officers (treated) changing their own assignment?
*/

/* 
Generate a variable to look at if the training leads to junior male officers 
being assigned to less important cases.
Thw weight is 0.5 if they change to low quality tasks, zero if they do not change tasks, 
and -0.2 if they change to high quality tasks.
*/


gen count_low_stake_tasks_men=.
replace count_low_stake_tasks_men=0.5*q3405_1+0.5*q3405_2+0.5*q3405_3-0.2*q3405_4- ///
0.2*q3405_5-0.2*q3405_6-0.2*q3405_7-0.2*q3405_8-0.2*q3405_9-0.3*q3405_10


/*
We use the following variables for the index construction:
3401--> needs recoding
count_tasks_weighted--> does not need recoding
count_high_stake_tasks_fem--> does not need recoding
count_low_stake_tasks_men--> does not need recoding
3406--> does not need recoding
3407--> do not include
3408--> does not need recoding
3409--> needs recoding
3410-->does not need recoding
3411--> does not need recoding
3412-->does not need recoding
3413-->does not need recoding
3414-->does not need recoding
*/

codebook q3401_val count_tasks_weighted count_high_stake_tasks_fem count_low_stake_tasks_men ///
q3406_val q3408_val q3409_val q3410_val q3411_val q3412_val q3413_val q3414_val

swindex q3401_val count_tasks_weighted count_high_stake_tasks_fem count_low_stake_tasks_men ///
q3406_val q3408_val q3409_val q3410_val q3411_val q3412_val q3413_val q3414_val, ///
gen(work_distrib_index_and) flip(q3401_val q3409_val) normby(stdgroup) displayw

label var work_distrib_index_and "Distribution of Work Index (Anderson)"
summ work_distrib_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var of varlist q3401_val q3409_val {
    gen `var'_rec = 10 - `var' if `var'!=.
}

foreach var in q3401_val_rec count_tasks_weighted count_high_stake_tasks_fem count_low_stake_tasks_men ///
q3406_val q3408_val q3409_val_rec q3410_val q3411_val q3412_val q3413_val q3414_val {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen work_distrib_index_kling=rowmean(q3401_val_rec_std count_tasks_weighted_std ///
count_high_stake_tasks_fem_std count_low_stake_tasks_men_std q3406_val_std q3408_val_std ///
q3409_val_rec_std q3410_val_std q3411_val_std q3412_val_std q3413_val_std q3414_val_std)
drop *std
drop *_rec
label var work_distrib_index_kling "Distribution of Work Index (Kling)"


* Generate histogram for the Perceptions Towards Male Officers indices (Anderson + Kling)
histogram work_distrib_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P9)
histogram work_distrib_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P10)

********************************************************************************

* Transmission of Training Learnings to the PS

/*
We use the following variables for the index construction:
4001-->does not need recoding
4002-->does not need recoding
4003-->does not need recoding
4004-->does not need recoding, but should we exclude it? If the index is about sensitivity towards females.
Seems like this variable has the highest weight when running swindex. So I'd not include it
q9002-->does not need recoding
*/

swindex q4001 q4002 q4003 q4004 q9002, gen(sensitivity_index_and) normby(stdgroup) displayw

label var sensitivity_index_and "Sensitivity towards female officers/complainants Index (Anderson)"
summ sensitivity_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var in q4001 q4002 q4003 q4004 q9002 {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen sensitivity_index_kling=rowmean(q4001_std q4002_std q4003_std q4004_std q9002_std)
drop *std
label var sensitivity_index_kling "Sensitivity towards female officers/complainants Index (Kling)"


* Generate histogram for the Perceptions Towards Male Officers indices (Anderson + Kling)
histogram sensitivity_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P11)
histogram sensitivity_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P12)

********************************************************************************

* Workplace wellbeing - Incidence of harassment 

/*
Here I would include only episodes of harassment from a male officer to a female
officer, and I would not include the reporting variables in this index.
I would then build a separate index for reporting.  
What do you think?
*/

* Recode don't know and refused to answer to missing

foreach var of varlist h1 h2 h3 h4 h5 h6 {
	replace `var'=. if `var'==-999 | `var'==-666
}

* Generate dummy variable = 1 if episode of harassment with male perpetrator

foreach var of varlist h1 h2 h3 h4 h5 h6 {
	gen `var'_male=0
	replace `var'_male=1 if `var'==1 &  `var'b_1==1
	replace `var'_male=. if `var'==.
}

swindex h1_male h2_male h3_male h4_male h5_male h6_male, gen(harassment_index_and) normby(stdgroup) displayw

label var harassment_index_and "Harassment from senior male officers Index (Anderson)"
summ harassment_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var in h1_male h2_male h3_male h4_male h5_male h6_male {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen harassment_index_kling=rowmean(h1_male_std h2_male_std h3_male_std h4_male_std h5_male_std h6_male_std)
drop *std
label var harassment_index_kling "Harassment from senior male officers Index (Kling)"


* Generate histogram for the Perceptions Towards Male Officers indices (Anderson + Kling)
histogram harassment_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P13)
histogram harassment_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P14)

********************************************************************************

* Workplace wellbeing - Reporting of harassment

* Generate dummy variable = 1 if episode of harassment with male perpetrator and if it has been reported

foreach var of varlist h1 h2 h3 h4 h5 h6 {
	gen `var'_male_reported=0
	replace `var'_male_reported=1 if `var'==1 &  `var'b_1==1 & `var'c==1
	replace `var'_male_reported=. if `var'==.
}

swindex h1_male_reported h2_male_reported h3_male_reported h4_male_reported h5_male_reported h6_male_reported, gen(harassment_report_index_and) normby(stdgroup) displayw

label var harassment_report_index_and "Reported harassment from senior male officers Index (Anderson)"
summ harassment_report_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var in h1_male_reported h2_male_reported h3_male_reported h4_male_reported h5_male_reported h6_male_reported {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen harassment_report_index_kling=rowmean(h1_male_reported_std h2_male_reported_std h3_male_reported_std h4_male_reported_std h5_male_reported_std h6_male_reported_std)
drop *std
label var harassment_report_index_kling "Reported harassment from senior male officers Index (Kling)"


* Generate histogram for the Perceptions Towards Male Officers indices (Anderson + Kling)
histogram harassment_report_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P15)
histogram harassment_report_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P16)


********************************************************************************

* Marlowe Crowne Social Desirability Scale (Reynolds Abridged 13-item version)

/* 
Compute the score 
To score the MC, assign values of T=1 F=2, then reverse score the following items: 5, 7, 9, 10, 13,
where, T=2, F=1. Sum the items.
*/

local mcsds_recode q6005 q6007 q6009 q6010 q6013  
foreach var of varlist `mcsds_recode' {
	replace `var'=0 if `var'==2
	replace `var'=2 if `var'==1
	replace `var'=1 if `var'==0
}

egen mcsds_score = rowtotal(q6001 q6002 q6003 q6004 q6005 q6006 q6007 q6008 q6009 q6010 q6011 q6012 q6013), missing

label var mcsds_score "Marlowe Crowne Social Desirability score"

********************************************************************************

* Generalized Anxiety Disorder Screener (GAD-7)

* Assign correct labels to the recoded variables
label define GAD 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"

foreach var of varlist q8001 q8002 q8003 q8004 q8005 q8006 q8007 {
	replace `var'=. if `var'==-666 | `var'==-999
	replace `var'=`var'-1 if `var'!=. // converting from 1-4 to 0-3
	lab val `var' GAD
}

egen gad_score = rowtotal(q8001 q8002 q8003 q8004 q8005 q8006 q8007), missing

label var gad_score "GAD-7 score"

* GAD-7 categories

/* 
Total score of 7 represents cutpoint for probable anxiety disorder. 
*/

gen probable_anxiety_disorder=.
replace probable_anxiety_disorder=0 if gad_score<=7 & gad_score!=.
replace probable_anxiety_disorder=1 if gad_score>7 & gad_score!=.
la var probable_anxiety_disorder "GAD-7 Probable anxiety disorder"

********************************************************************************

*** PHQ-9

* Assign correct labels to the recoded variables
label define PHQ 0 "Not at all" 1 "Several Days" 2 "More than half the days" 3 "Nearly every day"

foreach var of varlist q8008 q8009 q8010 q8011 q8012 q8013 q8014 q8015 q8016 {
	replace `var'=. if `var'==-666 | `var'==-999
	replace `var'=`var'-1 if `var'!=. // converting from 1-4 to 0-3
	lab val `var' PHQ
}

egen phq_score = rowtotal(q8008 q8009 q8010 q8011 q8012 q8013 q8014 q8015 q8016), missing

label var phq_score "PHQ-9 score"

* PHQ-9 categories

/* 
Total scores of 5, 10, 15, and 20 represent cutpoints for 
mild, moderate,moderately severe and severe depression, respectively. 
*/

egen phq_cat = cut(phq_score), at(0,5,10,15,20,28) icodes

label var phq_cat "PHQ-9 Depression Severity Categories"
label def phq_cat 0 "Minimal depression" 1 "Mild depression" 2 "Moderate depression" ///
3 "Moderately severe depression" 4 "Severe depression" 
label val phq_cat phq_cat

tab phq_cat, gen(phq_cat)

rename phq_cat1 phq_cat_minimal
rename phq_cat2 phq_cat_mild
rename phq_cat3 phq_cat_moderate
rename phq_cat4 phq_cat_modsevere
rename phq_cat5 phq_cat_severe

label var phq_cat_minimal "PHQ-9 Minimal depression"
label var phq_cat_mild "PHQ-9 Mild depression"
label var phq_cat_moderate "PHQ-9 Moderate depression"
label var phq_cat_modsevere "PHQ-9 Moderately severe depression"
label var phq_cat_severe"PHQ-9 Severe depression"

********************************************************************************

* Job Satisfaction

/*
We use the following variables for the index construction:
7001-->needs recoding
7002-->needs recoding
7003-->needs recoding
7004-->needs recoding
7005-->needs recoding
*/

swindex q7001 q7002 q7003 q7004 q7005, gen(job_satisfaction_index_and) flip(q7001 q7002 q7003 q7004 q7005) normby(stdgroup) displayw

label var job_satisfaction_index_and "Job Satisfaction Index (Anderson)"
summ job_satisfaction_index_and

* Create index following Kling et al. (2017)

* Generate variables recoded such that they enter the index in a positive manner

foreach var of varlist q7001 q7002 q7003 q7004 q7005 {
    gen `var'_rec = 6 - `var' if `var'!=.
}

foreach var in q7001_rec q7002_rec q7003_rec q7004_rec q7005_rec {
	sum `var' if stdgroup==1
	g `var'_std=(`var'-`r(mean)')/`r(sd)'
}
egen job_satisfaction_index_kling=rowmean(q7001_rec_std q7002_rec_std q7003_rec_std q7004_rec_std q7005_rec_std)
drop *std
label var job_satisfaction_index_kling "Job Satisfaction Index (Kling)"


* Generate histogram for the Perceptions Towards Male Officers indices (Anderson + Kling)
histogram sensitivity_index_and, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P17)
histogram sensitivity_index_kling, xlabel(,labsize(small)) xtitle(,margin(small)) normal lcolor(eltblue) fcolor(eltblue%80) name(P18)


********************************************************************************
/*

**********generating PSFS indices*************

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

*/

save "$clean_dta/female_constables_clean_indices.dta", replace

********averaging at the station-level for select variables*************

/*

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

save "${clean_dta}femaleconstables_ps_avg_selectvars", replace

*/

/*
collapse (mean) index_Perception_Integ_And index_Perception_Integ_Reg index_Workenv_Rel_And index_Workenv_Rel_Reg index_Workenv_Rep_And index_Workenv_Rep_Reg index_Workenv_Male_And index_Workenv_Male_Reg index_WorkDistr_And index_WorkDistr_Reg index_TrainingLearning_And index_TrainingLearning_Reg index_harassment_And index_harassment_Reg index_Desirability_And_fem index_Desirability_Reg_fem index_Anxiety_fem index_Depression_fem, by (ps_dist_id)

save "${clean_dta}femaleconstables_indices_collapsed", replace
*/