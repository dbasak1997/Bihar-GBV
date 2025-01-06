/*==============================================================================
File Name: Endline Officer's Survey 2023 - Rename do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	19/09/2023
Created by: Dibyajyoti Basak
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Renaming and Labelling Do file for the Endline Officer's Survey 2023. 

*	Inputs:  02.intermediate-data "01.import-officersurveybihar_intermediate"
*	Outputs: 02.intermediate-data "02.ren-officersurvey_intermediate"

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

log using "$MO_endline_log_files\officersurvey_rename.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 02.intermediate-data  "01.import-officersurveybihar_intermediate"

use "$MO_endline_intermediate_dta\01.import-endlinesurvey.dta" , clear

/*================Dropping Superfluous Variables===================================*/

*Text Audit Data and Survey CTO internal variables are dropped here

cap drop deviceid devicephonenum username ///
device_info duration caseid ///
a1 a2 var_comment uploadstamp ///
d1 instancename



/*====================Renaming and Labeling Round===========================*/

/*Abbreviations:

sv: Survey 
ps: Police Station
po: Police Officer
dist: District 
uid: Unique Identifier 
tr: Training
fem: female
suff: sufficient
tot: total
wtconstable: writer constable (munshi)
ins: Inspector
si: Sub-Inspector
asi: Assistant Sub-Inspector
sho: Station House Officer
bp: Bihar Police
dv: Domestic violence
sa: Sexual assault
beh: Behaviour
gbv: Gender-Based Violence crime
non_gbv: Non-Gender-Based Violence crime
fir: FIR or First Information Report
pri: Personality Rigidity Index
openness: Openness Index 
eq: Empathy Quotient
sdb: Social Desirability Bias
gad: Generalised Anxiety Disorder (GAD-7)
phq: atient Health Questionnaire (PHQ-9)
*/

rename submissiondate sv_date
la var  sv_date "Survey Date"

rename starttime sv_start
la var sv_start "Survey Start Time"

rename endtime sv_stop
la var sv_stop "Survey Stop Time"

rename a3 sv_name
la var sv_name "Surveyor Name"

rename a4 sv_location
la var sv_location "Location of the Survey"

rename a5 ps_dist
la var ps_dist "District of the Police Station"

rename a6 ps_series
la var ps_series "Serial Number Assigned to the Police Station in the district"

rename a7 po_unique_id


/*Notes:
1. The following variable "ps_dist_id" is an ID variable created by merging the District ID and the PS Series variable generated for the respective district.

2. Please ensure that the variable name is uniform across all the datasets, since this is the unique id for a PS for our purposes and would be used as a merging variable. 
*/

rename police_district_station ps_dist_id
la var ps_dist_id "Police Station ID in the District"

rename a6label ps_name
la var ps_name "Name of the Police Station"

rename b0 consent
la var consent "Consent to participate in the survey"

rename b0a consent_refused
la var consent_refused "Reason for refusal"

rename b0a_os consent_refused_os
la var consent_refused_os "Other Specify: Reason for refusal (Not Listed) "

rename b1 po_name
la var po_name "Name of the respondent"

rename b2 po_rank
la var po_rank "Rank of the respondent"

rename b3 ps_confirm
la var ps_confirm "Confirm that you are in the same police station?"

rename b5 po_mobnum
la var po_mobnum "Primary mobile number of the respondent"

rename b5a po_mobnum_alt
la var po_mobnum_alt " Alternate mobile number of the respondent, if applicable"

*The labelling for the below variables seem to be fine from the Round 1.0 hence there is no need for a fresh round. 

rename comment sv_comment

rename q101 po_age

rename q102 po_highest_educ

rename q102_os po_highest_educ_os

rename q105_years bp_years_of_service

rename q105_months bp_months_of_service

rename q104 if_children
rename q104_sons num_sons
rename q104_daughters num_daughters
rename q104_total tot_num_children
rename q105a_years ps_years_of_service
rename q105a_months ps_months_of_service
rename q106 po_caste
rename q106a po_subcaste

rename q107_state po_birth_state

rename q107_district po_birth_district

rename q107_village po_birth_village

rename q108 time_to_last_training

rename q109 tr_topic

rename q109_1 tr_investigation
la var tr_investigation "Tr: Investigation skills (including forensics)"

rename q109_2 tr_communication
la var tr_communication "Tr: Communication skills"

rename q109_3 tr_personal_dev
la var tr_personal_dev "Tr: Personal development"

rename q109_4 tr_mediation
la var tr_mediation "Tr: Mediation skills"

rename q109_5 tr_computer_technical
la var tr_computer_technical "Tr: Computer or other non-investigation related technical skills"

rename q109_6 tr_physical
la var tr_physical "Tr: Physical, field, or drill training"

rename q109_7 tr_legal
la var tr_legal "Tr: Regarding legal procedures"

rename q109_8 tr_gender
la var tr_gender "Tr: Any gender focused training (including sensitization)"

rename q109_9 tr_covid
la var tr_covid "Tr: Covid-19 related training"

rename q109__666 tr_dont_know
la var tr_dont_know "Tr: Don't know"

rename q109__999 tr_refused_ans
la var tr_refused_ans "Tr: Refused to answer"

rename q109_os tr_os /// also 'others specify'

rename q109__888 tr__os /// also 'others specify'

rename q110 tr_agency

rename q110_policeaca_oth tr_other_state_police

rename q110_os tr_agency_os

rename q111 tr_duration

**rename q111filter 

rename q111_unit tr_days_weeks_months


* Note: Section-2 of the Officers' Survey asks questions based on hypothetical situations.

/* Series 201: Let’s start by thinking about the situation of a woman from a nearby village who is getting beaten up by
her husband.
We use the abbreviation dv1 to denote this case of domestic violence.
*/

rename q201a dv1_internal_matter

rename q201b dv1_common_incident

rename q201c dv1_fears_beating

/* Series 202: It is justified for a husband to hit his
wife if…
We use the abbreviation dv2 to denote this case of domestic violence.
*/

rename q202a dv2_goes_without_informing

rename q202b dv2_neglects_children

rename q202c dv2_burns_food

rename q202d dv2_argues

rename q202e dv2_refuses_sex


* Note: Section-3 of the Officers' Survey asks questions on hypothetical situations that often occur in police stations. 

rename q301 dv_complaint_relative

*rename q301_fewcases dv_fewcases

rename q302 sa_burden_proof

rename q303 eviction_dv

rename q304 fem_shelter

rename q305 verbal_abuse_public

rename q305a verbal_abuse_ipc
rename q305a_os verbal_abuse_ipc_os
rename q306 sa_identity_leaked

rename q306a sa_identity_ipc


*Note: Section-4 of the Officers' Survey puts forth 2 situations and asks some questionas on them.

/* Situation 1: A woman comes to the police station with a complaint related to a land dispute. She complains that the man with whom she has the dispute mentally harasses and threatens her.
We use the abbreviation land to denote this case of land dispute.
*/

rename q401 land_false

rename q402 land_compromise

rename q403 land_false_sa


/* Situation-2: A man and a woman are in a romantic relationship but not married. The woman comes to the police station saying that she has been raped by the man.
We use the abbreviation premarital to denote this case.
*/

rename q404 premarital_false

rename q405 premarital_socially_unacceptable

rename q406 premarital_framing


* Note: The next two questions ask the respondent to indicate agreement with two statements.

/* Statement 407: The complaint is usually more believable if the woman is also accompanied by her relatives rather than when she comes alone.
*/

rename q407 believable_with_relative

/* Statement 408: Cases related to women receive too much attention by the police, relative to other crime and law and order issues.
*/

rename q408 fem_cases_overattention


* Note: Section-5 of the Officers' Survey is the Empathy Quotient (EQ). We use the abbreviation eq to denote statements from this index. 

rename q501 eq_1

rename q502 eq_2

rename q503 eq_3

rename q504 eq_4

rename q505 eq_5

rename q506 eq_6


* Note: Section-6 of the Officers' Survey uses two vignettes- one GBV and one non-GBV.

* Vignette-1: GBV case. We use the abbreviation gbv to denote questions on this case.

rename q601a gbv_abusive_beh

*Note: The scale for q601a was altered from Yes/No to a 5-point likert scale to capture variation in responses. 

*rename q601a_new gbv_abusive_beh_new

rename q601b gbv_police_help

*Note: The scale for q601b was altered from Yes/No to a 5-point likert scale to capture variation in responses. 

*rename q601b_new gbv_police_help_new

rename q601c gbv_true

rename q601d gbv_fem_fault

rename q601e gbv_empathy

* Vignette-2: GBV case. We us the abbreviation non_gbv to denote questions on this case.

rename q602a non_gbv_true

rename q602b non_gbv_fem_fault

rename q602c non_gbv_empathy

rename q602d non_gbv_fir

*Note: The scale for q602d was altered from Yes/No to a 5-point likert scale to capture variation in responses. 

*rename q602d_new non_gbv_fir_new


* Note: Section-7 of the Officers' Survey uses five indices. 

/* Series 701 and 702 measure Flexibility.
*/

/* Series 701 is the Personality Rigidity Index of Flexibility.
We use the abbreviation pri to indicate questions from this index.
*/

rename q701a pri_1

rename q701b pri_2

rename q701c pri_3

rename q701d pri_4

rename q701e pri_5

rename q701f pri_6
 
rename q701g pri_7

rename q701h pri_8

rename q701i pri_9

/* Series 702 is the Openness Index of Flexibility. 
We use the abbreviation openness to indicate questions from this index.
*/

rename q702a openness_1

rename q702b openness_2

rename q702c openness_3

rename q702d openness_4

rename q702e openness_5

rename q702f openness_6

rename q702g openness_7

rename q702h openness_8

rename q702i openness_9


/* Series 703 is Social Desirability Index. <ref>
We use the abbreviation sdb to indicate questions from this index.
*/

rename q703a sdb_1

rename q703b sdb_2

rename q703c sdb_3

rename q703d sdb_4

rename q703e sdb_5

rename q703f sdb_6

rename q703g sdb_7

rename q703h sdb_8

rename q703i sdb_9

rename q703j sdb_10

rename q703k sdb_11

rename q703l sdb_12

rename q703m sdb_13

/* Series 704 is the index for anxiety. We use the the Generalised Anxiety Disorder Assessment (GAD-7), a seven-item instrument that is used to measure or assess the severity of generalised anxiety disorder (GAD), to capture an initial measure of anxiety in respondents. 
We use the abbreviation gad to indicate questions from this index.
*/

rename q704a gad_1

rename q704b gad_2

rename q704c gad_3

rename q704d gad_4

rename q704e gad_5

rename q704f gad_6

rename q704g gad_7

/* Series 705 is the index for depression. We use the Patient Health Questionnaire (PHQ-9), a self-administered version of the PRIME-MD diagnostic instrument for common mental disorders, to capture an initial measure of depression in respondents. 
We use the abbreviation phq to indicate questions from this index.
*/

rename q705a phq_1

rename q705b phq_2

rename q705c phq_3

rename q705d phq_4

rename q705e phq_5

rename q705f phq_6

rename q705g phq_7

rename q705h phq_8

rename q705i phq_9


/*Note: Section-8 of the Officers' Survey uses a GBV crime vignette with a victim name randomisation based on caste. 
Babita Manjhi is the name for low-caste. Priya Gupta is the name for high-caste.
The abbreviation _new denotes the instance where the options were changed from Yes/No to a 5-point likert scale.
*/

rename q801a caste_fault

*rename q801a_new caste_fault_new

rename q801b caste_police_help

*rename q801b_new caste_police_help_new

rename q801c caste_true

rename q801d caste_framing_man

rename q801e caste_empathy


**Labelling new variables in the endline survey
la var marital_status "Marital status of the police officer"
la var key_baseline "Baseline key"

la var cs1_1 "Major constraints_GBV cases (Time constraints)"
la var cs1_2 "Major constraints_GBV cases (Resource constraints)"
la var cs1_3 "Major constraints_GBV cases (senior officers do not prioritise)"
la var cs1_4 "Major constraints_GBV cases (Alcohol related crimes)"
la var cs1__888 "Major constraints_GBV cases (Others Specify)"
la var cs1_os "Major constraints_GBV cases (Others Specify)"
la var cs1_0 "Major constraints_GBV cases (None of the Above)"

la var cs8_1 "GBV booklet used for cases (Domestic Violence)"
la var cs8_2 "GBV booklet used for cases (Sexual Harrassment)"
la var cs8_3 "GBV booklet used for cases (Serious Offenses (Rape, POSCO))"
la var cs8__888 "GBV booklet used for cases (Others Specify)"
la var cs8_os "GBV booklet used for cases (Others Specify)"
    
la var marital_bl "Marital status as per baseline"
la var if_children "If the officer has children"
la var num_sons "Number of sons"
la var num_daughters "Number of daughters"
la var tot_num_children "Total number of children"
la var po_caste "Caste of the officer"
la var po_subcaste "Sub-caste of the officer"

la var i1_name "Name of police officer"
la var i1_phno "Phone number of police officer"
la var po_new_station "New PS"
la var l1p1_name "Name of police officer"
la var l1p1_phno "Phone number of police officer"
la var l1p1_marital "Marital status of police officer"
la var l1p1_blkey "Baseline Key"
la var po_unique_id "Unique ID of police officer"
la var b2text "Rank of police officer"
la var b3b_os "Police Station_Other Specify"
la var b3d_os "Police Station_Other Specify"
la var b3h_os "Police Station_Other Specify"
la var b3j_os "Police Station_Other Specify"
la var tr__os "Training Other Specify"
la var verbal_abuse_ipc_os "Verbal Abuse IPC - Other Specify"
la var s8name "Victim Name in Vignette (English)"
la var s8name_hindi "Victim Name in Vignette (Hindi)"
la var random_dptext "Enumerator Instructions (English)"
la var random_dptext_hindi "Enumerator Instructions (Hindi)"
la var networkroster_count "Count of officers selected in network roster"
la var networkid_1 "Network officer 1"
la var networkid_2 "Network officer 2"
la var networkid_3 "Network officer 3"
la var networkid_4 "Network officer 4"
la var networkid_5 "Network officer 5"
la var networkid_6 "Network officer 6"
la var networkid_7 "Network officer 7"
la var networkid_8 "Network officer 8"
la var networkid_9 "Network officer 9"
la var networkid_10 "Network officer 10"
la var network_count "Count of officers selected in network roster"
la var ntwrkid1 "UID Officer 1"
la var ntwrkid2 "UID Officer 2"
la var ntwrkid3 "UID Officer 3"
la var ntwrkid4 "UID Officer 4"
la var ntwrkid5 "UID Officer 5"
la var activityroster_count "Count of activities in roster"
la var actcount "Count of activities in roster"
la var hs1h_os "Any other medical condition - Other Specify"
la var hs6b_1 "Central Government Health Scheme (CGHS)"
la var hs6b_2 "State Government Health Insurance"
la var hs6b_3 "Private Health Insurance"
la var hs6b_4 "Pradhan Mantri Jan Arogya Yojana (PM-JAY) - Ayushman Bharat"
la var hs6b_5 "Other Government Health Insurance (Specify: ________)"
la var hs6b__999 "I don't know the type"
la var hs6b_os "Other Government Health Insurance"
la var hs6d_1 "I have not faced any significant health issues or medical expenses"
la var hs6d_2 "Lack of awareness about the coverage and benefits"
la var hs6d_3 "Concerns about high deductibles or out-of-pocket expenses"
la var hs6d_4 "The insurance doesn't cover the specific treatments or services I need"
la var hs6d_5 "Difficulty in finding healthcare providers that accept my insurance"
la var hs6d_6 "Long waiting times or difficulties in accessing healthcare services"
la var hs6d_7 "Condition or treatment was not covered by insurance"
la var hs6d_8 "Preference for alternative or traditional healthcare methods"
la var hs6d_9 "Concerns about the insurance claiming process being too complex"
la var hs6d_10 "Unwillingness to deal with paperwork and administrative hassles"
la var hs6d__888 "Others Specify"
la var hs6d_os "Others Specify"
la var hs6e "How many night shifts have you done in the last one week?"

preserve

* Note: The section on Officers' Time Use of the Officers' Survey captures time use for respondents using pre-coded activities. We do not need to change the codes for this set of variables.*/

* We will import the Endline Revisit Data and merge that with the endline data
clear
import delimited "$MO_endline_raw\OS Endline Revisit_WIDE.csv"
drop if key == ""
drop key
rename key_baseline key
rename a3 sv_name
rename a4 sv_location
rename a5 ps_dist
rename a6 ps_series
rename police_district_station ps_dist_id
rename a6label ps_name
rename b2 po_rank
rename q104 if_children
rename q104_sons num_sons
rename q104_daughters num_daughters
rename q104_total tot_num_children
rename q105a_years ps_years_of_service
rename q105a_months ps_months_of_service
rename q106 po_caste
rename q106a po_subcaste
rename a7_el a7_el_2
tostring a7_el_2, gen(a7_el) format("%12.0f")
drop submissiondate-var_comment d1-formdef_version a1 a2 a7_el_2 marital_status b0a b0a_os
foreach var of varlist i1_phno ps_dist ps_series po_rank {
	tostring `var', replace
}

tempfile OS_endline_revisit
save `OS_endline_revisit'

restore
merge 1:1 key using `OS_endline_revisit.dta'
drop _m

* Save the dataset in the Intermediate Folder. We would now conduct all the error and logical consistency checks on the saved intermediate dta file.

save "$MO_endline_intermediate_dta\02.ren-officerendline_intermediate.dta", replace

