/*==============================================================================
File Name: Female Constables Survey 2022 - Import do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	16/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
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
	

* We will log in
capture log close 

log using "$FC_survey_log_files\femaleconstable_import.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 02.intermediate-data  "02.ren-officersurvey_intermediate"
* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "$FC_survey_raw/Female Constable Survey_WIDE.csv"
local dtafile "$FC_survey_intermediate_dta/Female Constable Survey.dta"
local corrfile "$FC_survey_raw/Female Constable Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid uploadstamp n1 n2 n4 n6 n6_os intvar1 n6label n7 q0a_os q1 q4p1_os q4p2 q4p2_os q4p3_district_os q4p3_station q4p3_station_os q7_os q7p1"
local text_fields2 "q7p1_os q7p2_district_os q7p2_station q7p2_station_os q8_os q10 q11 q1002_os q1005a randomsec3_count s3draw_* s3scale_* s3unique sec3roster_count se3id_* q3402_* q3402_os_* q3403_* q3405_* q3100_val"
local text_fields3 "q3101_val q3102_val q3103_val q3104_val q3201_val q3202_val q3203_val q3204_val q3301_val q3302_val q3303_val q3304_val q3305_val q3401_val q3402_val q3402_os_val q3403_val q3404_val q3405_val"
local text_fields4 "q3406_val q3407_val q3408_val q3409_val q3410_val q3411_val q3412_val q3413_val q3414_val networkroster_count networkid_* network_officer_name_* network_officer_name_os_* network_count hs1h_os hs5b_2"
local text_fields5 "hs5b_os hs6b hs6b_os hs6d hs6d_os q9006 q9006_os c3 c3_os h1b h2b h3b h4b h5b h6b c5total c7 r1 r3 instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

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


	label variable n3 "N3. Surveyor ID"
	note n3: "N3. Surveyor ID"
	label define n3 1 "Anjali" 2 "Nisha" 3 "Alka" 4 "Lalita" 5 "Sarita" 6 "Shabnam" 7 "Madhuri" 8 "Lilavati Kumari" 9 "Namita" 10 "Rishu Kumari" 11 "Tara Gupta" 12 "Pratima Kumari" 13 "Nilu Kumari" 14 "Shashikala" 15 "Indu" 16 "Anima" 17 "Manshi Kumari" 18 "Laxmi Kumari" 19 "Lilu Chakarbarty" 20 "Gunja Kumari" 21 "Poonam Sonwani" 22 "Renu Kumari Prabha" 23 "Rajni Kumari" 24 "Bhanamatee" 25 "Rina Kumari"
	label values n3 n3

	label variable n4 "N4. Survey location Note to surveyor:Please note down as accurate a location as "
	note n4: "N4. Survey location Note to surveyor:Please note down as accurate a location as possible (Example. PS Sadar, Vaishali)"

	label variable n5 "N5. Select the police district"
	note n5: "N5. Select the police district"
	label define n5 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali" -888 "Others Specify"
	label values n5 n5

	label variable n6 "N6. Select the Police Station"
	note n6: "N6. Select the Police Station"

	label variable n6_os "N6. Select the Police Station: Others Specify"
	note n6_os: "N6. Select the Police Station: Others Specify"

	label variable q0 "Q0. Verbal Consent: Do you agree to participate in this interview?"
	note q0: "Q0. Verbal Consent: Do you agree to participate in this interview?"
	label define q0 1 "Yes" 0 "No"
	label values q0 q0

	label variable q0a "Q0a. If No, what are your reasons to not participate in this survey?"
	note q0a: "Q0a. If No, what are your reasons to not participate in this survey?"
	label define q0a 1 "Too busy with work and do not have much time" 2 "Doesn’t think this is an important exercise" 3 "Has privacy issues" 4 "Scared about action being taken against the officer for the answers given during" -888 "Others Specify"
	label values q0a q0a

	label variable q1 "Q1. Name of Respondent"
	note q1: "Q1. Name of Respondent"

	label variable q2 "Q2. Do you confirm that you are a constable in the Bihar Police?"
	note q2: "Q2. Do you confirm that you are a constable in the Bihar Police?"
	label define q2 1 "Yes" 0 "No"
	label values q2 q2

	label variable q2a "Q2A. ADD SUB-RANK of CONSTABLE"
	note q2a: "Q2A. ADD SUB-RANK of CONSTABLE"
	label define q2a 1 "Head Constable (Havildar)" 2 "Senior Constable" 3 "Police Constable" 4 "Home Guard"
	label values q2a q2a

	label variable q3 "Q3. Do you confirm that you are stationed in \${n6label}?"
	note q3: "Q3. Do you confirm that you are stationed in \${n6label}?"
	label define q3 1 "Yes" 0 "No"
	label values q3 q3

	label variable q4p1 "Q4.1 If no, where is your current posting?"
	note q4p1: "Q4.1 If no, where is your current posting?"
	label define q4p1 1 "Within the same district" 2 "To a different district" -888 "Others Specify"
	label values q4p1 q4p1

	label variable q4p2 "Q4.2 If '1-within the same district', please state station"
	note q4p2: "Q4.2 If '1-within the same district', please state station"

	label variable q4p2_os "Q4.2. Select the Police Station: Others Specify"
	note q4p2_os: "Q4.2. Select the Police Station: Others Specify"

	label variable q4p3_district "Q4.3 District"
	note q4p3_district: "Q4.3 District"
	label define q4p3_district 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali" -888 "Others Specify"
	label values q4p3_district q4p3_district

	label variable q4p3_station "Q4.3. Select the Police Station"
	note q4p3_station: "Q4.3. Select the Police Station"

	label variable q4p3_station_os "Q4.3. Select the Police Station: Others Specify"
	note q4p3_station_os: "Q4.3. Select the Police Station: Others Specify"

	label variable q5_day "Day"
	note q5_day: "Day"

	label variable q5_month "Month"
	note q5_month: "Month"
	label define q5_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label values q5_month q5_month

	label variable q5_year "Year"
	note q5_year: "Year"

	label variable q6 "Q6. In the past 6 months, have you been transferred?"
	note q6: "Q6. In the past 6 months, have you been transferred?"
	label define q6 1 "Yes" 0 "No"
	label values q6 q6

	label variable q7 "Q7. If yes, where was your previous posting?"
	note q7: "Q7. If yes, where was your previous posting?"
	label define q7 1 "Within the same district" 2 "To a different district" -888 "Others Specify"
	label values q7 q7

	label variable q7p1 "Q7.1 If '1-within the same district', please state station"
	note q7p1: "Q7.1 If '1-within the same district', please state station"

	label variable q7p1_os "Others Specify"
	note q7p1_os: "Others Specify"

	label variable q7p2_district "Q7.2 District"
	note q7p2_district: "Q7.2 District"
	label define q7p2_district 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali" -888 "Others Specify"
	label values q7p2_district q7p2_district

	label variable q7p2_station "Q7.2. Select the Police Station"
	note q7p2_station: "Q7.2. Select the Police Station"

	label variable q7p2_station_os "Q7.2. Select the Police Station: Others Specify"
	note q7p2_station_os: "Q7.2. Select the Police Station: Others Specify"

	label variable q8 "Q8. Where do you live?"
	note q8: "Q8. Where do you live?"
	label define q8 1 "Rented accommodation" 2 "Police barrack" 3 "Own house" -888 "Others Specify"
	label values q8 q8

	label variable q10 "Q10. Mobile number of respondents"
	note q10: "Q10. Mobile number of respondents"

	label variable q11 "Q11. Alternative mobile number (if applicable) Instruction: If the respondent do"
	note q11: "Q11. Alternative mobile number (if applicable) Instruction: If the respondent does not have a contact number in the previous question, ask if they can provide the contact details of a close relative or a friend that we can reach later on."

	label variable q1001 "Q1001. What is your year of birth?"
	note q1001: "Q1001. What is your year of birth?"

	label variable q1002 "Q1002. What is the highest level of education you received?"
	note q1002: "Q1002. What is the highest level of education you received?"
	label define q1002 1 "10th" 2 "Plus 2" 3 "Diploma after Plus 2" 4 "Started college, did not complete/currently attending" 5 "College completed (B.A)" 6 "Post Graduate (M.A.)" -888 "Others Specify"
	label values q1002 q1002

	label variable q1003_year "Year"
	note q1003_year: "Year"

	label variable q1003_month "Month"
	note q1003_month: "Month"
	label define q1003_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label values q1003_month q1003_month

	label variable q1004_year "Year"
	note q1004_year: "Year"

	label variable q1004_month "Month"
	note q1004_month: "Month"
	label define q1004_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label values q1004_month q1004_month

	label variable q1005 "Q1005. Do you have any family members enrolled in the police?"
	note q1005: "Q1005. Do you have any family members enrolled in the police?"
	label define q1005 1 "Yes" 0 "No"
	label values q1005 q1005

	label variable q1005a "Q1005.a If yes, what is their relationship to you?"
	note q1005a: "Q1005.a If yes, what is their relationship to you?"

	label variable q1006 "Q1006. Are you aware of the training program that was held for your seniors?"
	note q1006: "Q1006. Are you aware of the training program that was held for your seniors?"
	label define q1006 1 "Yes" 0 "No"
	label values q1006 q1006

	label variable q2001 "Q2001. Reservation for women in the police force is beneficial for Bihar Police."
	note q2001: "Q2001. Reservation for women in the police force is beneficial for Bihar Police."
	label define q2001 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2001 q2001

	label variable q2002 "Q2002. Female and male constables should not share equal workload in your police"
	note q2002: "Q2002. Female and male constables should not share equal workload in your police station."
	label define q2002 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2002 q2002

	label variable q2003 "Q2003. It is useful to have female police officers to work on cases of crimes ag"
	note q2003: "Q2003. It is useful to have female police officers to work on cases of crimes against women."
	label define q2003 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2003 q2003

	label variable q2004 "Q2004. It is useful to have female police officers to work on routine cases such"
	note q2004: "Q2004. It is useful to have female police officers to work on routine cases such as theft, street -violence or road rage?"
	label define q2004 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2004 q2004

	label variable q2005 "Q2005. Having more women in the Bihar Police improves the workplace environment."
	note q2005: "Q2005. Having more women in the Bihar Police improves the workplace environment."
	label define q2005 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2005 q2005

	label variable q2006 "Q2006. Having fewer more female officers improves the productivity of your polic"
	note q2006: "Q2006. Having fewer more female officers improves the productivity of your police station."
	label define q2006 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2006 q2006

	label variable q2007 "Q2007. According to you, do the senior male officers (of rank ASI and above) mak"
	note q2007: "Q2007. According to you, do the senior male officers (of rank ASI and above) make efforts to address/understand challenges faced by women police officers in your Police Station?"
	label define q2007 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q2007 q2007

	label variable q2008 "Q2008. Your police station gets a tip that a female has been found lying unconsc"
	note q2008: "Q2008. Your police station gets a tip that a female has been found lying unconscious on the side of the road, a suspected rape victim. Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station?"
	label define q2008 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10"
	label values q2008 q2008

	label variable q2009 "Q2009. Your police station receives news of an unidentified person found unconsc"
	note q2009: "Q2009. Your police station receives news of an unidentified person found unconscious in a cowshed. It is unclear whether the individual is a male or a female. Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station?"
	label define q2009 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10"
	label values q2009 q2009

	label variable q2010 "Q2010. Your police station receives a call about illegal alcohol in the middle o"
	note q2010: "Q2010. Your police station receives a call about illegal alcohol in the middle of the night and is ordered to conduct a raid. Based on your experiences, how likely is it that a female police personnel accompanies a male officer from your police station?"
	label define q2010 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10"
	label values q2010 q2010

	label variable q4001 "Q4001. On the scale of 0 to 10, how sensitive are senior male officers (ASI and "
	note q4001: "Q4001. On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards female constables?"
	label define q4001 0 "Completely insensitive" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely sensitive"
	label values q4001 q4001

	label variable q4002 "Q4002. On the scale of 0 to 10, how sensitive are senior male officers towards s"
	note q4002: "Q4002. On the scale of 0 to 10, how sensitive are senior male officers towards senior female officers? (both ASI and above rank)"
	label define q4002 0 "Completely insensitive" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely sensitive"
	label values q4002 q4002

	label variable q4003 "Q4003. On the scale of 0 to 10, how sensitive are senior male officers (ASI and "
	note q4003: "Q4003. On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards female complainants?"
	label define q4003 0 "Completely insensitive" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely sensitive"
	label values q4003 q4003

	label variable q4004 "Q4004. On the scale of 0 to 10, how sensitive are senior male officers (ASI and "
	note q4004: "Q4004. On the scale of 0 to 10, how sensitive are senior male officers (ASI and above rank) towards male complainants?"
	label define q4004 0 "Completely insensitive" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely sensitive"
	label values q4004 q4004

	label variable q6001 "Q6001. It is sometimes hard for me to go on with my work if I am not encouraged."
	note q6001: "Q6001. It is sometimes hard for me to go on with my work if I am not encouraged."
	label define q6001 1 "TRUE" 2 "FALSE"
	label values q6001 q6001

	label variable q6002 "Q6002. I sometimes feel resentful when I don't get my own way."
	note q6002: "Q6002. I sometimes feel resentful when I don't get my own way."
	label define q6002 1 "TRUE" 2 "FALSE"
	label values q6002 q6002

	label variable q6003 "Q6003. On a few occasions, I have given up doing something because I thought too"
	note q6003: "Q6003. On a few occasions, I have given up doing something because I thought too little of my ability."
	label define q6003 1 "TRUE" 2 "FALSE"
	label values q6003 q6003

	label variable q6004 "Q6004. There have been times when I felt like rebelling against people in author"
	note q6004: "Q6004. There have been times when I felt like rebelling against people in authority even though I knew they were right."
	label define q6004 1 "TRUE" 2 "FALSE"
	label values q6004 q6004

	label variable q6005 "Q6005. No matter who I’m talking to, I’m always a good listener."
	note q6005: "Q6005. No matter who I’m talking to, I’m always a good listener."
	label define q6005 1 "TRUE" 2 "FALSE"
	label values q6005 q6005

	label variable q6006 "Q6006. There have been occasions when I took advantage of someone."
	note q6006: "Q6006. There have been occasions when I took advantage of someone."
	label define q6006 1 "TRUE" 2 "FALSE"
	label values q6006 q6006

	label variable q6007 "Q6007. I’m always willing to admit it when I make a mistake."
	note q6007: "Q6007. I’m always willing to admit it when I make a mistake."
	label define q6007 1 "TRUE" 2 "FALSE"
	label values q6007 q6007

	label variable q6008 "Q6008. I sometimes try to get even, rather than forgive and forget."
	note q6008: "Q6008. I sometimes try to get even, rather than forgive and forget."
	label define q6008 1 "TRUE" 2 "FALSE"
	label values q6008 q6008

	label variable q6009 "Q6009. I am always courteous, even to people who are disagreeable."
	note q6009: "Q6009. I am always courteous, even to people who are disagreeable."
	label define q6009 1 "TRUE" 2 "FALSE"
	label values q6009 q6009

	label variable q6010 "Q6010. I have never been irked when people expressed ideas very different from m"
	note q6010: "Q6010. I have never been irked when people expressed ideas very different from my own."
	label define q6010 1 "TRUE" 2 "FALSE"
	label values q6010 q6010

	label variable q6011 "Q6011. There have been times when I was quite jealous of the good fortune of oth"
	note q6011: "Q6011. There have been times when I was quite jealous of the good fortune of others."
	label define q6011 1 "TRUE" 2 "FALSE"
	label values q6011 q6011

	label variable q6012 "Q6012. I am sometimes irritated by people who ask favours of me."
	note q6012: "Q6012. I am sometimes irritated by people who ask favours of me."
	label define q6012 1 "TRUE" 2 "FALSE"
	label values q6012 q6012

	label variable q6013 "Q6013. I have never deliberately said something that hurt someone’s feelings."
	note q6013: "Q6013. I have never deliberately said something that hurt someone’s feelings."
	label define q6013 1 "TRUE" 2 "FALSE"
	label values q6013 q6013

	label variable q7001 "Q7001. In most ways my work life is close to my ideal"
	note q7001: "Q7001. In most ways my work life is close to my ideal"
	label define q7001 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q7001 q7001

	label variable q7002 "Q7002. The conditions of my work life are excellent"
	note q7002: "Q7002. The conditions of my work life are excellent"
	label define q7002 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q7002 q7002

	label variable q7003 "Q7003. I am satisfied with my work life"
	note q7003: "Q7003. I am satisfied with my work life"
	label define q7003 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q7003 q7003

	label variable q7004 "Q7004. So far I have gotten the important things I want in my work life"
	note q7004: "Q7004. So far I have gotten the important things I want in my work life"
	label define q7004 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q7004 q7004

	label variable q7005 "Q7005. If I could live my work life over, I would change almost nothing"
	note q7005: "Q7005. If I could live my work life over, I would change almost nothing"
	label define q7005 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q7005 q7005

	label variable q8001 "Q8001. Feeling nervous, anxious or tensed/worried"
	note q8001: "Q8001. Feeling nervous, anxious or tensed/worried"
	label define q8001 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8001 q8001

	label variable q8002 "Q8002. Not being able to stop or control worrying"
	note q8002: "Q8002. Not being able to stop or control worrying"
	label define q8002 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8002 q8002

	label variable q8003 "Q8003. Worrying too much about different things"
	note q8003: "Q8003. Worrying too much about different things"
	label define q8003 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8003 q8003

	label variable q8004 "Q8004. Trouble relaxing"
	note q8004: "Q8004. Trouble relaxing"
	label define q8004 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8004 q8004

	label variable q8005 "Q8005. Being so restless that it’s hard to sit still"
	note q8005: "Q8005. Being so restless that it’s hard to sit still"
	label define q8005 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8005 q8005

	label variable q8006 "Q8006. Becoming easily annoyed or irritable"
	note q8006: "Q8006. Becoming easily annoyed or irritable"
	label define q8006 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8006 q8006

	label variable q8007 "Q8007. Feeling afraid as if something awful might happen"
	note q8007: "Q8007. Feeling afraid as if something awful might happen"
	label define q8007 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8007 q8007

	label variable q8008 "Q8008. In the past 2 weeks did you Have little interest or pleasure in doing thi"
	note q8008: "Q8008. In the past 2 weeks did you Have little interest or pleasure in doing things"
	label define q8008 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8008 q8008

	label variable q8009 "Q8009. In the past 2 weeks did you Feeling down, unhappy/miserable, or hopeless"
	note q8009: "Q8009. In the past 2 weeks did you Feeling down, unhappy/miserable, or hopeless"
	label define q8009 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8009 q8009

	label variable q8010 "Q8010. In the past 2 weeks did you Trouble falling or staying asleep (i.e. due t"
	note q8010: "Q8010. In the past 2 weeks did you Trouble falling or staying asleep (i.e. due to nightmares), or sleeping too much"
	label define q8010 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8010 q8010

	label variable q8011 "Q8011. In the past 2 weeks did you Feeling tired or having little energy"
	note q8011: "Q8011. In the past 2 weeks did you Feeling tired or having little energy"
	label define q8011 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8011 q8011

	label variable q8012 "Q8012. In the past 2 weeks did you Poor appetite or overeating"
	note q8012: "Q8012. In the past 2 weeks did you Poor appetite or overeating"
	label define q8012 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8012 q8012

	label variable q8013 "Q8013. In the past 2 weeks did you Feeling bad about yourself – or that you are "
	note q8013: "Q8013. In the past 2 weeks did you Feeling bad about yourself – or that you are a failure or have let yourself or your family down"
	label define q8013 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8013 q8013

	label variable q8014 "Q8014. In the past 2 weeks did you Trouble concentrating on things, such as read"
	note q8014: "Q8014. In the past 2 weeks did you Trouble concentrating on things, such as reading the newspaper"
	label define q8014 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8014 q8014

	label variable q8015 "Q8015. In the past 2 weeks did you Moving or speaking so slowly that other peopl"
	note q8015: "Q8015. In the past 2 weeks did you Moving or speaking so slowly that other people could have noticed; or the opposite—being so anxious or restless that you have been moving around a lot more than usual"
	label define q8015 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8015 q8015

	label variable q8016 "Q8016. In the past 2 weeks did you Thoughts that you would be better off dead or"
	note q8016: "Q8016. In the past 2 weeks did you Thoughts that you would be better off dead or of hurting yourself in some way"
	label define q8016 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refused to answer" -999 "Do not know"
	label values q8016 q8016

	label variable hs1a "Diabetes"
	note hs1a: "Diabetes"
	label define hs1a 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1a hs1a

	label variable hs1b "High Blood Pressure (Hypertension)"
	note hs1b: "High Blood Pressure (Hypertension)"
	label define hs1b 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1b hs1b

	label variable hs1c "Asthma"
	note hs1c: "Asthma"
	label define hs1c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1c hs1c

	label variable hs1d "High Cholesterol"
	note hs1d: "High Cholesterol"
	label define hs1d 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1d hs1d

	label variable hs1e "Gastrointestinal Issues (e.g., Gastritis, Ulcers)"
	note hs1e: "Gastrointestinal Issues (e.g., Gastritis, Ulcers)"
	label define hs1e 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1e hs1e

	label variable hs1f "Arthritis, Joint-pain, Back-pain"
	note hs1f: "Arthritis, Joint-pain, Back-pain"
	label define hs1f 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1f hs1f

	label variable hs1g "Sleep disorder"
	note hs1g: "Sleep disorder"
	label define hs1g 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1g hs1g

	label variable hs1h "Any other medical condition"
	note hs1h: "Any other medical condition"
	label define hs1h 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values hs1h hs1h

	label variable hs3a "HS.3.a Do you know your blood sugar?"
	note hs3a: "HS.3.a Do you know your blood sugar?"
	label define hs3a 1 "Yes" 0 "No"
	label values hs3a hs3a

	label variable hs3a_low "Low"
	note hs3a_low: "Low"

	label variable hs3a_high "High"
	note hs3a_high: "High"

	label variable hs3b "HS.3.b When was the last time you measured your blood sugar?"
	note hs3b: "HS.3.b When was the last time you measured your blood sugar?"
	label define hs3b 1 "Within one week" 2 "A month ago" 3 "In the past 6 months" 4 "Do not recall"
	label values hs3b hs3b

	label variable hs4a "HS.4.a How often has poor sleep troubled you in the last month?"
	note hs4a: "HS.4.a How often has poor sleep troubled you in the last month?"
	label define hs4a 1 "Always" 2 "Very often" 3 "Sometimes" 4 "Rarely" 5 "Never"
	label values hs4a hs4a

	label variable hs4b "HS.4.b How many hours of sleep could you manage last night? (Surveyor Instructio"
	note hs4b: "HS.4.b How many hours of sleep could you manage last night? (Surveyor Instructions: If the Officer was working on a night shift, ask him/her to enter the hours of sleep in the previous occassion)"

	label variable hs5a "HS.5.a When was the last time you visited a doctor for yourself?"
	note hs5a: "HS.5.a When was the last time you visited a doctor for yourself?"
	label define hs5a 1 "Within one week" 2 "A month ago" 3 "In the past 6 months" 4 "In the past 1 year" 5 "More than a year ago" 6 "Never visited a doctor" 7 "Only visited a traditional or local doctor" 8 "Do not recall"
	label values hs5a hs5a

	label variable hs5b "HS.5.b What was the purpose of your visit?"
	note hs5b: "HS.5.b What was the purpose of your visit?"
	label define hs5b 1 "Routine Checkup" 2 "Illness or Symptoms" 3 "Follow-up on a Previous Condition (Please specify________)" 4 "Vaccination or Immunization" 5 "Preventive Health Advice" 6 "Injury or Accident" 7 "Mental Health Concerns" 8 "Dental or Oral Health" -888 "Others Specify"
	label values hs5b hs5b

	label variable hs5b_2 "HS.5.b What was the purpose of your visit?: Follow-up on a Previous Condition (P"
	note hs5b_2: "HS.5.b What was the purpose of your visit?: Follow-up on a Previous Condition (Please specify________)"

	label variable hs5b_os "HS.5.b What was the purpose of your visit?: Others Specify"
	note hs5b_os: "HS.5.b What was the purpose of your visit?: Others Specify"

	label variable hs6a "HS.6.a Do you have a health insurance?"
	note hs6a: "HS.6.a Do you have a health insurance?"
	label define hs6a 1 "Yes" 0 "No"
	label values hs6a hs6a

	label variable hs6b "HS.6.b If yes, which health insurance do you have?"
	note hs6b: "HS.6.b If yes, which health insurance do you have?"

	label variable hs6c "HS.6.c When was the last time you used the health insurance?"
	note hs6c: "HS.6.c When was the last time you used the health insurance?"
	label define hs6c 1 "Within one week" 2 "A month ago" 3 "In the past 6 months" 4 "In the past 1 year" 5 "More than a year ago" 6 "Never used the insurance" 7 "Do not recall"
	label values hs6c hs6c

	label variable hs6d "HS.6.d If you have never used the insurance, what are the reasons for not using?"
	note hs6d: "HS.6.d If you have never used the insurance, what are the reasons for not using?"

	label variable q9001 "Q9001. Did you hear about the 3-day training on Gender Sensitization that was he"
	note q9001: "Q9001. Did you hear about the 3-day training on Gender Sensitization that was held in this district for the senior male officers in your Police Station?"
	label define q9001 1 "Yes" 0 "No"
	label values q9001 q9001

	label variable q9002 "Q9002. In your perception, have you seen any changes in their behavior towards y"
	note q9002: "Q9002. In your perception, have you seen any changes in their behavior towards you or other female constables or victims since the training? Enumerator: Remind the female constable about the training date depending on the district"
	label define q9002 1 "Yes" 0 "No"
	label values q9002 q9002

	label variable q9003 "Q9003. Do you know whether your seniors received a booklet of GBV related laws d"
	note q9003: "Q9003. Do you know whether your seniors received a booklet of GBV related laws during the Gender Sensitization training? Enumerator: Remind the female constable about the training date depending on the district"
	label define q9003 1 "Yes" 0 "No"
	label values q9003 q9003

	label variable q9004 "Q9004. Do you know whether they still have that booklet in their possession?"
	note q9004: "Q9004. Do you know whether they still have that booklet in their possession?"
	label define q9004 1 "Yes" 0 "No" -999 "Do not know"
	label values q9004 q9004

	label variable q9005 "Q9005. Have you ever seen them consulting this GBV booklet since the training?"
	note q9005: "Q9005. Have you ever seen them consulting this GBV booklet since the training?"
	label define q9005 1 "Yes" 0 "No" -999 "Do not know"
	label values q9005 q9005

	label variable q9006 "Q9006. If yes, for what types of cases have they used it for? (Select Multiple O"
	note q9006: "Q9006. If yes, for what types of cases have they used it for? (Select Multiple Options)"

	label variable c1 "C1. How effective do you think the Bihar Police is, in general, in handling case"
	note c1: "C1. How effective do you think the Bihar Police is, in general, in handling cases of crimes against women? (Read choices out loud, and select one)"
	label define c1 1 "Very effective" 2 "Effective" 3 "Neither effective nor ineffective" 4 "Ineffective" 5 "Very ineffective" -666 "Refused to answer" -999 "Do not know"
	label values c1 c1

	label variable c2 "C2. How equipped do you feel to carry out the duties in your role?"
	note c2: "C2. How equipped do you feel to carry out the duties in your role?"
	label define c2 0 "Not equipped at all" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Completely equipped"
	label values c2 c2

	label variable c3 "C3. What are the major constraints that you face while handling the GBV cases"
	note c3: "C3. What are the major constraints that you face while handling the GBV cases"

	label variable h0 "H0. Do we have your consent to ask these questions?"
	note h0: "H0. Do we have your consent to ask these questions?"
	label define h0 1 "Yes" 0 "No"
	label values h0 h0

	label variable h1 "H1. Made you feel threatened or unsafe by shouting, scolding or reprimanding lou"
	note h1: "H1. Made you feel threatened or unsafe by shouting, scolding or reprimanding loudly"
	label define h1 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h1 h1

	label variable h1b "H1b. Who did this to you?"
	note h1b: "H1b. Who did this to you?"

	label variable h1c "H1c. Have you shared or reported this to anyone?"
	note h1c: "H1c. Have you shared or reported this to anyone?"
	label define h1c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h1c h1c

	label variable h2 "h2. Made you feel intimidated or threatened that he/she could physically harm yo"
	note h2: "h2. Made you feel intimidated or threatened that he/she could physically harm you by pushing or hitting you?"
	label define h2 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h2 h2

	label variable h2b "h2b. Who did this to you?"
	note h2b: "h2b. Who did this to you?"

	label variable h2c "h2c. Have you shared or reported this to anyone?"
	note h2c: "h2c. Have you shared or reported this to anyone?"
	label define h2c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h2c h2c

	label variable h3 "h3. Hit, slapped, or punched you, tripped you or otherwise intentionally caused "
	note h3: "h3. Hit, slapped, or punched you, tripped you or otherwise intentionally caused you physical harm."
	label define h3 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h3 h3

	label variable h3b "h3b. Who did this to you?"
	note h3b: "h3b. Who did this to you?"

	label variable h3c "h3c. Have you shared or reported this to anyone?"
	note h3c: "h3c. Have you shared or reported this to anyone?"
	label define h3c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h3c h3c

	label variable h4 "h4. Made any sexual advances such as touching inappropriately"
	note h4: "h4. Made any sexual advances such as touching inappropriately"
	label define h4 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h4 h4

	label variable h4b "h4b. Who did this to you?"
	note h4b: "h4b. Who did this to you?"

	label variable h4c "h4c. Have you shared or reported this to anyone?"
	note h4c: "h4c. Have you shared or reported this to anyone?"
	label define h4c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h4c h4c

	label variable h5 "h5. Requested you to meet alone with an officer that made you feel uncomfortable"
	note h5: "h5. Requested you to meet alone with an officer that made you feel uncomfortable"
	label define h5 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h5 h5

	label variable h5b "h5b. Who did this to you?"
	note h5b: "h5b. Who did this to you?"

	label variable h5c "h5c. Have you shared or reported this to anyone?"
	note h5c: "h5c. Have you shared or reported this to anyone?"
	label define h5c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h5c h5c

	label variable h6 "h6. Made remarks about you in a sexual manner or shown you inappropriate picture"
	note h6: "h6. Made remarks about you in a sexual manner or shown you inappropriate pictures/videos"
	label define h6 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h6 h6

	label variable h6b "h6b. Who did this to you?"
	note h6b: "h6b. Who did this to you?"

	label variable h6c "h6c. Have you shared or reported this to anyone?"
	note h6c: "h6c. Have you shared or reported this to anyone?"
	label define h6c 1 "Yes" 0 "No" -999 "Do not know" -666 "Refused to answer"
	label values h6c h6c

	label variable c4 "C4. Madam, if we may ask, what is your marital status?"
	note c4: "C4. Madam, if we may ask, what is your marital status?"
	label define c4 1 "Never married" 2 "Married and lives together" 3 "Married but Lives Separately" 4 "Divorced" 5 "Separated" 6 "Widower" -666 "Refuse to answer"
	label values c4 c4

	label variable c5 "C5. Madam, do you have children?"
	note c5: "C5. Madam, do you have children?"
	label define c5 1 "Yes" 0 "No"
	label values c5 c5

	label variable c5_sons "Sons"
	note c5_sons: "Sons"

	label variable c5_daughters "Daughter"
	note c5_daughters: "Daughter"

	label variable c6 "C6. Madam, would you be comfortable sharing which Category you belong to?"
	note c6: "C6. Madam, would you be comfortable sharing which Category you belong to?"
	label define c6 1 "SC" 2 "ST" 3 "OBC" 4 "General" -666 "Refuse to answer"
	label values c6 c6

	label variable c7 "C7. If you are willing to share, may I ask what is your sub-caste or jati?"
	note c7: "C7. If you are willing to share, may I ask what is your sub-caste or jati?"

	label variable r2latitude "R2. Record GPS location (latitude)"
	note r2latitude: "R2. Record GPS location (latitude)"

	label variable r2longitude "R2. Record GPS location (longitude)"
	note r2longitude: "R2. Record GPS location (longitude)"

	label variable r2altitude "R2. Record GPS location (altitude)"
	note r2altitude: "R2. Record GPS location (altitude)"

	label variable r2accuracy "R2. Record GPS location (accuracy)"
	note r2accuracy: "R2. Record GPS location (accuracy)"

	label variable r3 "R3. Surveyor Comment"
	note r3: "R3. Surveyor Comment"



	capture {
		foreach rgvar of varlist q3100_* {
			label variable `rgvar' "Q3100. On a scale of 0-10 please rate your comfort level working with male const"
			note `rgvar': "Q3100. On a scale of 0-10 please rate your comfort level working with male constables Enumerator Instructions: Please explain that 0 means most uncomfortable and 10 means most comfortable. The respondent can choose any value between 0 to 10."
			label define `rgvar' 0 "uncomfortable" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "very comfortable"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3101_* {
			label variable `rgvar' "Q3101. On a scale of 0-10 how much discomfort do you have working with female co"
			note `rgvar': "Q3101. On a scale of 0-10 how much discomfort do you have working with female constables Enumerator Instructions: Please explain that 0 means No Discomfort at all and 10 means most discomfort. The respondent can choose any value between 0 to 10."
			label define `rgvar' 0 "no discomfort" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "a lot of discomfort"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3102_* {
			label variable `rgvar' "Q3102. On a scale of 0-10 please rate your comfort level working with senior fem"
			note `rgvar': "Q3102. On a scale of 0-10 please rate your comfort level working with senior female officers (ASI and above rank) Enumerator Instructions: Please explain that 0 means most uncomfortable and 10 means most comfortable. The respondent can choose any value between 0 to 10."
			label define `rgvar' 0 "uncomfortable" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "very comfortable"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3103_* {
			label variable `rgvar' "Q3103. On a scale of 0-10 how much discomfort do you have working with senior ma"
			note `rgvar': "Q3103. On a scale of 0-10 how much discomfort do you have working with senior male officers (ASI and above rank) Enumerator Instructions: Please explain that 0 means most uncomfortable and 10 means most comfortable. The respondent can choose any value between 0 to 10."
			label define `rgvar' 0 "uncomfortable" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "very comfortable"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3104_* {
			label variable `rgvar' "Q3104. I feel I have to constantly 'prove myself' to gain acceptance and respect"
			note `rgvar': "Q3104. I feel I have to constantly 'prove myself' to gain acceptance and respect from male co-workers"
			label define `rgvar' 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3201_* {
			label variable `rgvar' "More females have been recruited in the Bihar Police in the last few years. Q320"
			note `rgvar': "More females have been recruited in the Bihar Police in the last few years. Q3201. This policy has a positive impact on policing in Bihar."
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3202_* {
			label variable `rgvar' "More females have been recruited in the Bihar Police in the last few years. Q320"
			note `rgvar': "More females have been recruited in the Bihar Police in the last few years. Q3202. The environment of the police station has changed to be more gender sensitive as a result of this policy"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3203_* {
			label variable `rgvar' "More females have been recruited in the Bihar Police in the last few years. Q320"
			note `rgvar': "More females have been recruited in the Bihar Police in the last few years. Q3203. This policy has made the police more accessible to the public"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3204_* {
			label variable `rgvar' "More females have been recruited in the Bihar Police in the last few years. Q320"
			note `rgvar': "More females have been recruited in the Bihar Police in the last few years. Q3204. Reservation of the seats is a fair means to increase the representation of women in the department"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3301_* {
			label variable `rgvar' "Q3301. Male officers (of rank ASI and above) in the station are understanding of"
			note `rgvar': "Q3301. Male officers (of rank ASI and above) in the station are understanding of my family responsibilities."
			label define `rgvar' 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3302_* {
			label variable `rgvar' "Q3302. I had no problems taking maternity leave when I was expecting."
			note `rgvar': "Q3302. I had no problems taking maternity leave when I was expecting."
			label define `rgvar' 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -666 "Not Applicable (Never got pregnant or had a child)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3303_* {
			label variable `rgvar' "Q3303. Male officers (of rank ASI and above) in the station have expressed they "
			note `rgvar': "Q3303. Male officers (of rank ASI and above) in the station have expressed they do not like to work with female officers."
			label define `rgvar' 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3304_* {
			label variable `rgvar' "Q3304. Male officers (of rank ASI and above) in the station make it difficult fo"
			note `rgvar': "Q3304. Male officers (of rank ASI and above) in the station make it difficult for me to conduct my job."
			label define `rgvar' 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3305_* {
			label variable `rgvar' "Q3305. Male officers (of rank ASI and above) in the station are unaware of the c"
			note `rgvar': "Q3305. Male officers (of rank ASI and above) in the station are unaware of the challenges female officers face when joining the force."
			label define `rgvar' 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3401_* {
			label variable `rgvar' "Q3401. Please indicate your agreement with the following statement on a scale of"
			note `rgvar': "Q3401. Please indicate your agreement with the following statement on a scale of 0-10 The roles of a male constable and a female constable are very different in a police station."
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3402_* {
			label variable `rgvar' "Q3402. In the past 7 days, can you tell us the three activities in which you wer"
			note `rgvar': "Q3402. In the past 7 days, can you tell us the three activities in which you were the most involved? Please select from the list given."
		}
	}

	capture {
		foreach rgvar of varlist q3402_os_* {
			label variable `rgvar' "Q3402. In the past 7 days, can you tell us the three activities in which you wer"
			note `rgvar': "Q3402. In the past 7 days, can you tell us the three activities in which you were the most involved? Please select from the list given. : Others Specify"
		}
	}

	capture {
		foreach rgvar of varlist q3403_* {
			label variable `rgvar' "Q3403. What type of cases are you more likely to be a part of?"
			note `rgvar': "Q3403. What type of cases are you more likely to be a part of?"
		}
	}

	capture {
		foreach rgvar of varlist q3404_* {
			label variable `rgvar' "Q3404. Have you noticed male officers (ranks ASI and above) change their work as"
			note `rgvar': "Q3404. Have you noticed male officers (ranks ASI and above) change their work assignment in the past one month?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3405_* {
			label variable `rgvar' "Q3405. If Yes, what kind of cases did they switch to?"
			note `rgvar': "Q3405. If Yes, what kind of cases did they switch to?"
		}
	}

	capture {
		foreach rgvar of varlist q3406_* {
			label variable `rgvar' "Q3406. Male constables do more paperwork than female constables"
			note `rgvar': "Q3406. Male constables do more paperwork than female constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3407_* {
			label variable `rgvar' "Q3407. Female constables have higher education then male constables"
			note `rgvar': "Q3407. Female constables have higher education then male constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3408_* {
			label variable `rgvar' "Q3408. Male constables have less responsibilities than female constables"
			note `rgvar': "Q3408. Male constables have less responsibilities than female constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3409_* {
			label variable `rgvar' "Q3409. Female constables do more organizing work in the police station"
			note `rgvar': "Q3409. Female constables do more organizing work in the police station"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3410_* {
			label variable `rgvar' "Q3410. Male constables go fewer times on patrolling than female constables"
			note `rgvar': "Q3410. Male constables go fewer times on patrolling than female constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3411_* {
			label variable `rgvar' "Q3411. Female constables work on more women’s related cases than male constables"
			note `rgvar': "Q3411. Female constables work on more women’s related cases than male constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3412_* {
			label variable `rgvar' "Q3412. Male constables work on fewer property crime cases cases than female cons"
			note `rgvar': "Q3412. Male constables work on fewer property crime cases cases than female constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3413_* {
			label variable `rgvar' "Q3413. Male constables work on fewer dispute over property ownership cases than "
			note `rgvar': "Q3413. Male constables work on fewer dispute over property ownership cases than female constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist q3414_* {
			label variable `rgvar' "Q3414. Male constables work on fewer dispute over property boundary cases than f"
			note `rgvar': "Q3414. Male constables work on fewer dispute over property boundary cases than female constables"
			label define `rgvar' 0 "Completely disagree" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "completely agree"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist network_officer_name_* {
			label variable `rgvar' "Officer \${networkid}: Are there other officers who you look up to in your polic"
			note `rgvar': "Officer \${networkid}: Are there other officers who you look up to in your police station when thinking about getting advice over what to do or making a decision?"
		}
	}

	capture {
		foreach rgvar of varlist network_officer_name_os_* {
			label variable `rgvar' "Others Specify"
			note `rgvar': "Others Specify"
		}
	}

	capture {
		foreach rgvar of varlist network_officer_rank_* {
			label variable `rgvar' "Rank of Officer"
			note `rgvar': "Rank of Officer"
			label define `rgvar' 1 "Assistant Sub Inspector of Police (ASI)" 2 "Sub-Inspector of Police (SI)" 3 "Police Sub-Inspector (PSI - In training for Inspector)" 4 "Inspector of Police, but not SHO" 5 "Station Head Officer (SHO)" -666 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist network_check_* {
			label variable `rgvar' "Do you want to add another name to this list?"
			note `rgvar': "Do you want to add another name to this list?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}




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
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  D:/Dropbox_SB/Dropbox/RA-GBV-2023/005-Data-and-analysis-2022/Female_Constables-2023/00.raw-data/Female Constable Survey_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
