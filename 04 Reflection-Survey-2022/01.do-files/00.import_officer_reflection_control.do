/*==============================================================================
File Name:	Reflection Survey (Control) - Import do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	19/11/2022
Created by: Shubhro Bhattacharya
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Import Do file for the Reflection Survey implemented for the Control Group. 
 
*There were two seperate versions of the Reflection Survey which were administered for each district -- The Treatment Reflection Survey also captures additional outcomes based on the training outcomes, while the Control Reflection Survey only captures the Interpersonal Reactivity Index (IRI). 

Reference for the IRI:

Davis, M. H. (1980). A multidimensional approach to individual differences in empathy.
JSAS Catalog of Selected Documents in Psychology, 10, 85

Access the paper from the following link:
https://www.dropbox.com/home/Debiasing%20Police%20in%20India/003-Survey-Instruments-2022/007_Reflection_Survey_2022/References_reflection

We are using the following sub-scales from the IRI:
1. Empathic Concern (EC) – assesses "other-oriented" feelings of sympathy and concern for unfortunate others

2. Perspective Taking (PT) – the tendency to spontaneously adopt the psychological point of view of others


* 	Imports and aggregates "Officer Reflection Survey Treatment" (ID: officer_reflection_control) data.

*Inputs:  "Officer Reflection Survey Control_WIDE.csv"
*Outputs: "Officer Reflection Survey Control.dta"

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

log using "$reflection_log_files\00.reflection_import_C.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "Officer Reflection Survey Control_WIDE.csv"
local dtafile "Officer Reflection Survey Control.dta"
local corrfile "Officer Reflection Survey Control_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid uploadstamp var_comment k1 k2 k4 k5 k6 police_district_station k6label l1_uid i1_name i1_phno k5p1_os k6p1 po_new_station l1p1 l1p1_name"
local text_fields2 "l1p1_phno i1_nonlistedname displayname phonenumber l3a_os l3b l3b_os uinternal l3bname l3cpolicestation l3cpolicestation_os l3ddate l4a_os l4b l4bcode l4bname l4b_os l4cdistrict_os l4cpolicestation"
local text_fields3 "l4cpolicestation_os l5 l5a rsrandomize_count rsdraw_* rsscale_* rsunique englishv1 englishv2 englishv3 englishv4 englishv5 englishv6 englishv7 englishv8 englishv9 englishv10 englishv11 englishv12"
local text_fields4 "englishv13 englishv14 hindiv1 hindiv2 hindiv3 hindiv4 hindiv5 hindiv6 hindiv7 hindiv8 hindiv9 hindiv10 hindiv11 hindiv12 hindiv13 hindiv14 myvar1 myvar2 myvar3 myvar4 myvar5 myvar6 myvar7 myvar8"
local text_fields5 "myvar9 myvar10 myvar11 myvar12 myvar13 myvar14 rsbec2 rsbpt3 rsbec4 rsbpt8 rsbec9 rsbpt11 rsbec14 rsbpt15 rsbec18 rsbec20 rsbpt21 rsbec22 rsbpt25 rsbpt28 e1 e3 instanceid"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp


* import data from primary .csv file
insheet using "$reflection_raw\Officer Reflection Survey Control_WIDE.csv", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable k3 "K3. Surveyor ID"
	note k3: "K3. Surveyor ID"
	label define k3 01 "Devendra Singh" 02 "Nityanand Pandey" 03 "Vivek Singh" 04 "Manjesh Kumar" 05 "Braham Prakash Sharma" 06 "Vikas Ranjan" 07 "Ashutosh Kumar" 08 "Navjeet Kumar" 09 "Guru Dayal Singh" 10 "Sudhir Kumar Dixit" 11 "Jaswant Singh" 12 "Sonu Kumar-1" 13 "Amit Kumar Shukla" 14 "Anshul Kumar" 15 "Anuj Kumar Pal" 16 "Arti Devi" 17 "Chandan Kumar Singh" 18 "JayKant Kumar" 19 "Kaushal Kumar" 20 "Pappu Kumar" 21 "Rajesh Kumar" 22 "Ranjeet Kumar Verma" 23 "Ranjeet Singh" 24 "Ratnaker Singh" 25 "Shailesh Kumar Singh" 26 "Sitesh Kumar" 27 "Sonu Kumar" 28 "Sunny Kumar" 29 "Tribhuwan Kumar" 30 "Veerendra Singh" 31 "Vivek Kumar"
	label values k3 k3

	label variable k4 "K4. Survey location Note to surveyor: Please note down as accurate a location as"
	note k4: "K4. Survey location Note to surveyor: Please note down as accurate a location as possible (Example. PS Sadar, Vaishali)."

	label variable k5 "K5. Select the police district"
	note k5: "K5. Select the police district"

	label variable k6 "K6. Select the Police Station"
	note k6: "K6. Select the Police Station"

	label variable l1_uid "L1. Name of Respondent"
	note l1_uid: "L1. Name of Respondent"

	label variable k5p1 "In which other district you were posted from 8th September to today?"
	note k5p1: "In which other district you were posted from 8th September to today?"
	label define k5p1 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali" -888 "Others Specify"
	label values k5p1 k5p1

	label variable k5p1_os "In which other district you were posted from 8th September to today?: Others Spe"
	note k5p1_os: "In which other district you were posted from 8th September to today?: Others Specify"

	label variable k6p1 "In which other Police Station you were posted from 8th September to today?"
	note k6p1: "In which other Police Station you were posted from 8th September to today?"

	label variable l1p1 "Name of Respondent"
	note l1p1: "Name of Respondent"

	label variable i1_nonlistedname "L1. Name of Respondent"
	note i1_nonlistedname: "L1. Name of Respondent"

	label variable l0 "Name: \${displayname} Phone Number: \${phonenumber} L0. Do you agree to particip"
	note l0: "Name: \${displayname} Phone Number: \${phonenumber} L0. Do you agree to participate in this interview? Instructions for the enumerator: If the respondent does not provide consent, proceed to B0a and end the survey. Proceed to the next questions starting from B1 only if the answer to this question is Yes."
	label define l0 1 "Yes" 0 "No"
	label values l0 l0

	label variable l0a "L0a. If No, what are your reasons to not participate in this survey?"
	note l0a: "L0a. If No, what are your reasons to not participate in this survey?"
	label define l0a 1 "Too busy with work and do not have much time" 2 "Doesn't think this is an important exercise" 3 "Has privacy issues" 4 "Scared about action being taken against the officer for the answers given during" -888 "Others Specify"
	label values l0a l0a

	label variable l2 "L2. What is your current position in the Bihar Police? Instructions for the Enum"
	note l2: "L2. What is your current position in the Bihar Police? Instructions for the Enumerator: This Survey should be administered only to the ASI, SI, Inspector and SHO rank Police Officers. If the respondent does not belong to any of the above categories, this survey should not be continued."
	label define l2 01 "Assistant Sub Inspector of Police (ASI)" 02 "Sub-Inspector of Police (SI)" 03 "Police Sub-Inspector (PSI - In training for Inspector)" 04 "Inspector of Police, but not SHO" 05 "Station Head Officer (SHO)" 06 "Constable (Munshi)" -666 "Refused to answer"
	label values l2 l2

	label variable l3 "L3. Do you confirm that you are stationed in \${k6label}?"
	note l3: "L3. Do you confirm that you are stationed in \${k6label}?"
	label define l3 1 "Yes" 0 "No"
	label values l3 l3

	label variable l3a "L3a. where is your current posting?"
	note l3a: "L3a. where is your current posting?"
	label define l3a 1 "Within the same district" 2 "To a different district"
	label values l3a l3a

	label variable l3a_os "L3a. where is your current posting?: Others Specify"
	note l3a_os: "L3a. where is your current posting?: Others Specify"

	label variable l3b "L3b. please state station"
	note l3b: "L3b. please state station"

	label variable l3b_os "L3b. please state station: Others Specify"
	note l3b_os: "L3b. please state station: Others Specify"

	label variable l3cdistrict "Select the police district"
	note l3cdistrict: "Select the police district"
	label define l3cdistrict 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali" -888 "Others Specify"
	label values l3cdistrict l3cdistrict

	label variable l3cpolicestation "Police Station"
	note l3cpolicestation: "Police Station"

	label variable l3cpolicestation_os "Police Station: Others Specify"
	note l3cpolicestation_os: "Police Station: Others Specify"

	label variable l3d_day "Day"
	note l3d_day: "Day"

	label variable l3d_month "Month"
	note l3d_month: "Month"
	label define l3d_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label values l3d_month l3d_month

	label variable l3d_year "Year"
	note l3d_year: "Year"

	label variable l4 "L4. In the past 6 months have you been transferred?"
	note l4: "L4. In the past 6 months have you been transferred?"
	label define l4 1 "Yes" 0 "No"
	label values l4 l4

	label variable l4a "L4a. where was your previous posting?"
	note l4a: "L4a. where was your previous posting?"
	label define l4a 1 "Within the same district" 2 "To a different district"
	label values l4a l4a

	label variable l4a_os "L4a. where was your previous posting?: Others Specify"
	note l4a_os: "L4a. where was your previous posting?: Others Specify"

	label variable l4b "L4b. please state station"
	note l4b: "L4b. please state station"

	label variable l4b_os "L4b. please state station: Others Specify"
	note l4b_os: "L4b. please state station: Others Specify"

	label variable l4cdistrict "Select the police district"
	note l4cdistrict: "Select the police district"
	label define l4cdistrict 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali" -888 "Others Specify"
	label values l4cdistrict l4cdistrict

	label variable l4cdistrict_os "Select the police district: Others Specify"
	note l4cdistrict_os: "Select the police district: Others Specify"

	label variable l4cpolicestation "Police Station"
	note l4cpolicestation: "Police Station"

	label variable l4cpolicestation_os "Police Station: Others Specify"
	note l4cpolicestation_os: "Police Station: Others Specify"

	label variable l5 "L5. Mobile number of respondents Instruction: Move to B2a if the respondent does"
	note l5: "L5. Mobile number of respondents Instruction: Move to B2a if the respondent does not have a contact number."

	label variable l5a "L5a. Alternative mobile number (if applicable) Instruction: If the respondent do"
	note l5a: "L5a. Alternative mobile number (if applicable) Instruction: If the respondent does not have a contact number in the previous question, ask if they can provide the contact details of a close relative or a friend that we can reach later on."

	label variable myvar1 "\${englishv1}"
	note myvar1: "\${englishv1}"

	label variable myvar2 "\${englishv2}"
	note myvar2: "\${englishv2}"

	label variable myvar3 "\${englishv3}"
	note myvar3: "\${englishv3}"

	label variable myvar4 "\${englishv4}"
	note myvar4: "\${englishv4}"

	label variable myvar5 "\${englishv5}"
	note myvar5: "\${englishv5}"

	label variable myvar6 "\${englishv6}"
	note myvar6: "\${englishv6}"

	label variable myvar7 "\${englishv7}"
	note myvar7: "\${englishv7}"

	label variable myvar8 "\${englishv8}"
	note myvar8: "\${englishv8}"

	label variable myvar9 "\${englishv9}"
	note myvar9: "\${englishv9}"

	label variable myvar10 "\${englishv10}"
	note myvar10: "\${englishv10}"

	label variable myvar11 "\${englishv11}"
	note myvar11: "\${englishv11}"

	label variable myvar12 "\${englishv12}"
	note myvar12: "\${englishv12}"

	label variable myvar13 "\${englishv13}"
	note myvar13: "\${englishv13}"

	label variable myvar14 "\${englishv14}"
	note myvar14: "\${englishv14}"

	label variable e3 "Surveyor comments, if any"
	note e3: "Surveyor comments, if any"

	label variable e2latitude "Record GPS location (latitude)"
	note e2latitude: "Record GPS location (latitude)"

	label variable e2longitude "Record GPS location (longitude)"
	note e2longitude: "Record GPS location (longitude)"

	label variable e2altitude "Record GPS location (altitude)"
	note e2altitude: "Record GPS location (altitude)"

	label variable e2accuracy "Record GPS location (accuracy)"
	note e2accuracy: "Record GPS location (accuracy)"






	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "$reflection_intermediate_dta\C_reflection-survey_sitamarhi", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp


/*===================== Dropping superfluous variables ============================================================*/
*Text Audit Data and Survey CTO internal variables are dropped here


drop deviceid devicephonenum username device_info var_comment ///
rsrandomize_count rsdraw_* rsscale_* ///
k1 k2 e1 e3 /// 
rsunique englishv* hindiv* myvar*  duration caseid



/*====================Renaming and Labeling Round 2.0===========================*/

/*Abbreviations:

sv: Survey 
ps: Police Station
po: Police Officer
dist: District 
uid: Unique Identifier 
tr: Training
*/

rename submissiondate sv_date
la var  sv_date "Survey Date"

rename starttime sv_start
la var sv_start "Survey Start Time"

rename endtime sv_stop
la var sv_stop "Survey Stop Time"

rename k3 sv_name
la var sv_name "Surveyor Name"

rename k4 sv_location
la var sv_location "Location of the Survey"

rename k5 ps_dist
la var ps_dist "District of the Police Station"

rename k6 ps_series
la var ps_series "Serial Number Assigned to the Police Station in the district"

gen treatment=0
la var treatment "whether the Officer is in the treatment PS"
label define treatment 1 "Yes" 0 "No"

/*Notes:
1. The following variable "ps_dist_id" is an ID variable created by merging the District ID and the PS Series variable generated for the respective district.

2. Please ensure that the variable name is uniform across all the datasets, since this is the unique id for a PS for our purposes and would be used as a merging variable. 

*/

rename police_district_station ps_dist_id
la var ps_dist_id "Police Station ID in the District"

rename k6label ps_name
la var ps_name "Name of the Police Station"

rename l1_uid gbv_uid  
la var gbv_uid "Unique Identifier for Bihar GBV Project" 

/*Notes: 
1. The gbv_uid is a unique id which was assigned to all the officers during the Officer's baseline survey.
2. The gbv_uid is a common identifier which is carried forward for all the surveys/activities in the Bihar GBV Project.
3. This uid is generated by using a combination of the District id, Police Station id, Police Station Rank and a randomly Generated Serial Number.
*/


rename i1_name po_listname
la var po_listname "Name of the Officer from the Police Station List"

rename i1_nonlistedname po_nolistname
la var po_nolistname "Name of the Officer not from the Police Station List (for In-Transfer Officers)"

rename l0 consent
la var consent "Whether there is consent for the Survey"

rename l0a reason_refuse
la var reason_refuse "Reason for Refusal of Consent"

rename l2 po_rank
la var po_rank "Rank of the Police Officer"

rename l3 ps_confirm  /* Helps us to track Transfers or Errors in the Data */
la var ps_confirm "Confirmation of the Police Station" 

rename l5 po_mobile
la var po_mobile "Mobile Number of the Police Officer"

rename l5a po_altmobile
la var po_altmobile "Alternate Mobile Number of the Police Officer"

/*=======Renaming and Labeling of the Interpersonal Reactivity Index===================

Reference: Davis, M.H (1980) 

We are using two sub-scales from the IRI:

1. Empathic Concern (EC) – assesses "other-oriented" feelings of sympathy and concern for unfortunate others

variable code: rsbec`i'


2. Perspective Taking (PT) – the tendency to spontaneously adopt the psychological point of view of others

variable code: rsbpt`i' 
  */

  
*Empathy Concern (EC) Variables -- Encode and Label  

encode rsbec2, gen(rs_bec2)
label drop rs_bec2
label define rs_bec2 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec2
la var rs_bec2 "q.rsbec2 Have tender, concerned feelings for less fortunate people"

encode rsbec4, gen(rs_bec4)
label drop rs_bec4
label define rs_bec4 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec4
la var rs_bec4 "q.rsbec4 Do not feel sorry when other people have problems"


encode rsbec9, gen(rs_bec9)
label drop rs_bec9
label define rs_bec9 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec9
la var rs_bec9 "q.rsbec9 Feel protective when someone is being taken advantage of"

encode rsbec14, gen(rs_bec14)
label drop rs_bec14
label define rs_bec14 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec14
la var rs_bec14 "q.rsbec14 Other people's misfortune do not disturb be a great deal"

encode rsbec18, gen(rs_bec18)
label drop rs_bec18
label define rs_bec18 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec18
la var rs_bec18 "q.rsbec18 Do not feel pity for people who are being treated unfairly"

encode rsbec20, gen(rs_bec20)
label drop rs_bec20
label define rs_bec20 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec20
la var rs_bec20 "q.rsbec20 Quite touched by things that I see happening"

encode rsbec22, gen(rs_bec22)
label drop rs_bec22
label define rs_bec22 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbec22
la var rs_bec22 "q.rsbec22 Describe self as a soft-hearted person"



*Perspective Taking (PT) -- Encode and Label  


encode rsbpt3, gen(rs_bpt3)
label drop rs_bpt3
label define rs_bpt3 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt3
la var rs_bpt3 "q.rsbpt3 Find it difficult to see things from other's point of view'"


encode rsbpt8, gen(rs_bpt8)
label drop rs_bpt8
label define rs_bpt8 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt8
la var rs_bpt8 "q.rsbpt8 Look at everybody's side of disagreement before making a decision'"


encode rsbpt11, gen(rs_bpt11)
label drop rs_bpt11
label define rs_bpt11 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt11
la var rs_bpt11 "q.rsbpt11 Try to understand my friends better by imagining their perspective"


encode rsbpt15, gen(rs_bpt15)
label drop rs_bpt15
label define rs_bpt15 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt15
la var rs_bpt15 "q.rsbpt15 Don't waste time listening to others if I know I am right"


encode rsbpt21, gen(rs_bpt21)
label drop rs_bpt21
label define rs_bpt21 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt21
la var rs_bpt21 "q.rsbpt21 Believes there are two sides to every question and Looks at both"


encode rsbpt25, gen(rs_bpt25)
label drop rs_bpt25
label define rs_bpt25 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt25
la var rs_bpt25 "q.rsbpt25 When I am upset at someone I try to myself in his shoes"



encode rsbpt28, gen(rs_bpt28)
label drop rs_bpt28
label define rs_bpt28 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 
drop rsbpt28
la var rs_bpt28 "q.rsbpt28 Try to imagine how they would feel before criticizing someone"




save "$reflection_intermediate_dta\C_reflection-survey", replace


