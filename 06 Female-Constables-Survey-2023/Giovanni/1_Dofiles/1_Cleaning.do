/*==============================================================================
File Name: Female Constables Survey 2022 - Cleaning do file
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	27/11/2024
Created by: Giovanni D'Ambrosio
Updated on: 22/11/2024
Updated by:	Giovanni D'Ambrosio

*Notes READ ME:
*This is the Do file to create the indices for the female constables survey

==============================================================================*/

clear all
set more off
cap log close

* Log file

log using "$log_files\femaleconstable_cleaning_gd.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

* Survey CTO cleaning do file

* initialize form-specific parameters
local csvfile "$raw/Female Constable Survey_WIDE.csv"
local dtafile "$intermediate_dta/female_constables_interm.dta"
local corrfile "$raw/Female Constable Survey_corrections.csv"
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
	label define q0a 1 "Too busy with work and do not have much time" 2 "Doesn't think this is an important exercise" 3 "Has privacy issues" 4 "Scared about action being taken against the officer for the answers given during" -888 "Others Specify"
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

	label variable q6005 "Q6005. No matter who I'm talking to, I'm always a good listener."
	note q6005: "Q6005. No matter who I'm talking to, I'm always a good listener."
	label define q6005 1 "TRUE" 2 "FALSE"
	label values q6005 q6005

	label variable q6006 "Q6006. There have been occasions when I took advantage of someone."
	note q6006: "Q6006. There have been occasions when I took advantage of someone."
	label define q6006 1 "TRUE" 2 "FALSE"
	label values q6006 q6006

	label variable q6007 "Q6007. I'm always willing to admit it when I make a mistake."
	note q6007: "Q6007. I'm always willing to admit it when I make a mistake."
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

	label variable q6013 "Q6013. I have never deliberately said something that hurt someone's feelings."
	note q6013: "Q6013. I have never deliberately said something that hurt someone's feelings."
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

	label variable q8005 "Q8005. Being so restless that it's hard to sit still"
	note q8005: "Q8005. Being so restless that it's hard to sit still"
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
			label variable `rgvar' "Q3411. Female constables work on more women's related cases than male constables"
			note `rgvar': "Q3411. Female constables work on more women's related cases than male constables"
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


********************************************************************************

*Load the dataset 

use "$intermediate_dta/female_constables_interm.dta", clear

* Variables that can be dropped from the dataset

drop deviceid devicephonenum username device_info caseid q0a q0a_os q4p1_os q4p2_os ///
q4p3_district q4p3_district_os q4p3_station q4p3_station_os q1005a_8 q1005a_12 ///
q1005a_14 s3draw_1 randomsec3_count s3scale_1 s3draw_2 s3scale_2 s3draw_3 s3scale_3 ///
s3draw_4 s3scale_4 s3draw_5 s3scale_5 s3draw_6 s3scale_6 s3draw_7 s3scale_7 s3draw_8 ///
s3scale_8 s3draw_9 s3scale_9 s3draw_10 s3scale_10 s3draw_11 s3scale_11 s3draw_12 ///
s3scale_12 s3draw_13 s3scale_13 s3draw_14 s3scale_14 s3draw_15 s3scale_15 s3draw_16 ///
s3scale_16 s3draw_17 s3scale_17 s3draw_18 s3scale_18 s3draw_19 s3scale_19 s3draw_20 ///
s3scale_20 s3draw_21 s3scale_21 s3draw_22 s3scale_22 s3draw_23 s3scale_23 s3draw_24 ///
s3scale_24 s3draw_25 s3scale_25 s3draw_26 s3scale_26 s3draw_27 s3scale_27 s3draw_28 ///
s3scale_28 s3draw_29 s3scale_29 s3unique sec3roster_count se3id_1 q3100_1 q3100_2 ///
q3100_3 q3100_4 q3201_1 q3201_2 q3201_3 q3201_4 q3202_1 q3202_2 q3202_3 q3202_4 ///
q3203_1 q3203_2 q3203_3 q3203_4 q3204_1 q3204_2 q3204_3 q3204_4 q3104_4 q3103_4 ///
q3102_4 q3101_4 q3104_3 q3103_3 q3102_3 q3101_3 q3104_2 q3103_2 q3102_2 q3101_2 ///
q3104_1 q3103_1 q3102_1 q3101_1 q3301_1 q3301_2 q3301_3 q3301_4 q3302_1 q3302_2 ///
q3302_3 q3302_4 q3303_1 q3303_2 q3303_3 q3303_4 q3304_1 q3304_2 q3304_3 q3304_4 ///
q3305_2 q3305_3 q3305_4 q3401_1 q3401_2 q3401_3 q3401_4 q3404_1 q3404_2 q3404_3 ///
q3404_4 q3406_1 q3406_2 q3406_3 q3406_4 q3407_1 q3407_2 q3407_3 q3407_4 q3408_1 ///
q3408_2 q3408_3 q3408_4 q3409_1 q3409_2 q3409_3 q3409_4 q3410_1 q3410_2 q3410_3 ///
q3410_4 q3411_1 q3411_2 q3411_3 q3411_4 q3412_1 q3412_2 q3412_3 q3412_4 q3413_1 ///
q3413_2 q3413_3 q3413_4 q3414_1 q3414_2 q3414_3 q3414_4 q3402_1 q3402_1_1 q3402_2_1 ///
q3402_3_1 q3402_4_1 q3402_5_1 q3402_6_1 q3402_7_1 q3402_8_1 q3402_9_1 q3402_10_1 ///
q3402_11_1 q3402_12_1 q3402_13_1 q3402_14_1 q3402_15_1 q3402_16_1 q3402_17_1 ///
q3402_19_1 q3402_18_1 q3402_20_1 q3402_21_1 q3402_22_1 q3402__888_1 q3402_os_1 ///
q3402_2 q3402_1_2 q3402_2_2 q3402_3_2 q3402_4_2 q3402_5_2 q3402_6_2 q3402_7_2 ///
q3402_8_2 q3402_9_2 q3402_10_2 q3402_11_2 q3402_12_2 q3402_13_2 q3402_14_2 q3402_15_2 ///
q3402_16_2 q3402_17_2 q3402_18_2 q3402_19_2 q3402_20_2 q3402_21_2 q3402_22_2 ///
q3402__888_2 q3402_3 q3402_1_3 q3402_2_3 q3402_3_3 q3402_4_3 q3402_5_3 q3402_6_3 ///
q3402_7_3 q3402_8_3 q3402_9_3 q3402_10_3 q3402_11_3 q3402_12_3 q3402_13_3 q3402_14_3 ///
q3402_15_3 q3402_16_3 q3402_17_3 q3402_18_3 q3402_19_3 q3402_20_3 q3402_21_3 q3402_22_3 ///
q3402__888_3 q3402_4 q3402_1_4 q3402_2_4 q3402_3_4 q3402_4_4 q3402_5_4 q3402_6_4 ///
q3402_7_4 q3402_8_4 q3402_9_4 q3402_11_4 q3402_12_4 q3402_13_4 q3402_14_4 q3402_15_4 ///
q3402_16_4 q3402_17_4 q3402_18_4 q3402_19_4 q3402_20_4 q3402_22_4 q3402__888_4 ///
q3402_os_2 q3402_os_3 q3402_os_4 q3402_10_4 q3402_21_4 q3403_1* q3403_2* q3403_3* ///
q3403_4* q3403_5* q3403_6* q3403_7* q3403_8* q3403_9* q3405_1* q3405_2* q3405_3* ///
q3405_4* q3405_5* q3405_6* q3405_7* q3405_8* q3405_9* q3305_1 networkid_* network_check_* ///
uploadstamp q1005a se3id_2 se3id_3 se3id_4 network_count q9006_os q9006__888 q9006 ///
c3 hs6b hs6d h1b h2b h3b h4b h5b h6b instancename formdef_version

********************************************************************************

**** Cleaning variables

* Variables to destring

foreach var of varlist networkroster_count duration q3100_val q3101_val q3102_val ///
q3103_val q3104_val q3201_val q3202_val q3203_val q3204_va q3301_val q3302_val ///
q3303_val q3304_val q3305_val q3401_val q3404_val q3406_val q3407_val q3408_val q3409_val ///
q3410_val q3411_val q3412_val q3413_val q3414_val c5total {
	destring `var', replace
}

* Converting don't know and refused to answer


* Survey date

gen survey_date = date(n1, "YMD")
format %td survey_date
drop n1
la var survey_date "Date of survey"

* Survey start time

gen double survey_start_time = clock(substr(n2, 1, 8), "hms") 
format survey_start_time %tcHH:MM:ss
drop n2
la var survey_start_time "Survey start time"

* Duration variables

replace duration = duration/60 // Total time a form was open actively on screen. 

* Fixing question q3402_val

*** Why are we replacing them to option 11 (Police training activity)?

replace q3402_val = subinstr(q3402_val, "-888", "11", .) //observed OS options, they are patrol/court/VIP duty

* Generating item-wise dummies

forvalues i = 1/22 {
    gen q3402_`i' = regexm(q3402_val, "(^| )`i'($| )") // all these variables need to be renamed and labelled
}

drop q3402_val

* Fixing question q3403_val

* Generating item-wise dummies

forvalues i = 1/10 {
    gen q3403_`i' = regexm(q3403_val, "(^| )`i'($| )")
}

drop q3403_val

* Fixing question q3405_val

* Generating item-wise dummies

forvalues i = 1/10 {
    gen q3405_`i' = regexm(q3405_val, "(^| )`i'($| )")
}

drop q3405_val

********************************************************************************

* Renaming variables

rename n3 enumerator_id
rename n4 survey_location
rename n5 police_district
rename n6 police_station
rename n6_os police_station_oth
rename intvar1 police_station_id
rename n6label police_station_name
rename n7 officer_unique_id
rename q0 consent
rename q1 name
rename q2 confirm_constable
rename q2a subrank
rename q3 confirm_ps
rename q4p1 current_posting
rename q4p2 current_station
rename q5_day start_day_ps
rename q5_month start_month_ps
rename q5_year start_year_ps
rename q6 transferred_6mo
rename q7 previous_ps_where
rename q7_os previous_ps_where_oth
rename q7p1 previous_ps
rename q7p1_os previous_ps_oth
rename q7p2_district previous_ps_district
rename q7p2_district_os previous_ps_district_oth
rename q7p2_station previous_ps_2
rename q7p2_station_os previosu_ps_2_oth
rename q8 accommodation
rename q8_os accommodation_oth
rename q10 phone_number
rename q11 alternative_number
rename q1001 birth_year
rename q1002 highest_educ
rename q1002_os highest_educ_oth
rename q1003_year year_joined_police
rename q1003_month month_joined_police
rename q1004_year year_joined_ps
rename q1004_month month_joined_ps
rename q1005 family_member_police
rename q1005a_1 police_mother
rename q1005a_2 police_father
rename q1005a_3 police_brother
rename q1005a_4 police_sister
rename q1005a_5 police_husband
rename q1005a_6 police_bil
rename q1005a_7 police_sil
rename q1005a_9 police_fil
rename q1005a_10 police_uncle
rename q1005a_11 police_aunt
rename q1005a_13 police_daughter
rename q1005a_15 police_dil
rename q1005a__888 police_fam_oth
rename q1006 aware_training


********************************************************************************

*** Other cleaning taken from Dibya's do file

* Replacing blank police station ids
replace police_station_id = "1007_99" if key == "uuid:126b9189-1a5a-4371-a0a8-20ac6c7a3a29"
replace police_station_id = "1007_99" if key == "uuid:52ce7c67-155b-4090-8419-3b4568ece6c9"
replace police_station_id = "1007_99" if key == "uuid:932c2443-9aeb-4564-b45b-853702afab98"
replace police_station_id = "1007_99" if key == "uuid:9a757af3-06b6-4f25-8478-8acef5272f76"
replace police_station_id = "1002_12" if key == "uuid:95a1f908-eff9-4bc3-b16c-da7e9ab16731"
replace police_station_id = "1006_29" if key == "uuid:f026e3d1-d953-43e0-8859-95f2c3b90816"
replace police_station_id = "1008_42" if police_station_id == "1008_41"
replace police_station_id = "1008_65" if police_station_id == "1008_63"
drop if police_station_id == ""

*rename sv_date fem_sv_date

* Cleaning highest level of education variable from Others Specify
replace highest_educ = 5 if key == "uuid:dda1a95e-863e-4dec-90b2-e9d21438bd82"
replace highest_educ = 1 if key == "uuid:db863bd7-3d55-471f-a353-3dcd37f0dff2"
replace highest_educ = 5 if key == "uuid:68cc4e8b-8a07-4f31-930a-4b13d757410b"
replace highest_educ = 5 if key == "uuid:de0892f7-d430-422c-be43-3605b48d0de6"
replace highest_educ = 6 if key == "uuid:b6583291-acab-4f90-b49a-65a1328c23f9"
replace highest_educ = 5 if key == "uuid:b31c588e-7859-469c-aebb-af38893f9142"
replace highest_educ = 5 if key == "uuid:c8bfcfa6-3ead-4f81-ad12-36a2075feca6"
replace highest_educ = 5 if key == "uuid:b67d33c3-9931-47e2-8d01-d42af829c7ce"
replace highest_educ = 1 if key == "uuid:4cfb9b32-6621-49c5-9327-fc8789a77864"
replace highest_educ = 5 if key == "uuid:7cf0f493-68dd-422c-b19e-42dc00d960ab"
replace highest_educ = 1 if key == "uuid:67661fac-aae1-4fe3-9d81-e8cbd6ef5355"
replace highest_educ = 1 if key == "uuid:f16223f6-57f4-4455-bd08-1c63cb0f970b"

drop highest_educ_oth

* Generating submission date variable
gen submission_date_only = dofc(submissiondate)
format submission_date_only %td

gen submission_year = year(submission_date_only)
gen submission_month = month(submission_date_only)

gen submissiondate_final = ym(submission_year, submission_month)
format submissiondate_final %tm

* Generating variable for joining date in Bihar Police
gen bp_combined = ym(year_joined_police, month_joined_police)
format bp_combined %tm

* Generating variable for joining date in current PS
gen ps_combined =  ym(year_joined_ps, month_joined_ps)
format ps_combined %tm

* Generating variable for time in current PS (weeks)
gen fem_bpservice_weeks = (submissiondate_final - bp_combined)*4
gen fem_psservice_weeks = (submissiondate_final - ps_combined)*4
la var fem_bpservice_weeks "Time since joining Bihar Police (weeks)"
la var fem_psservice_weeks "Time since joining current PS (weeks)"

* Generating variable for time in current PS (months)
gen fem_bpservice_months = submissiondate_final - bp_combined
gen fem_psservice_months = submissiondate_final - ps_combined
la var fem_bpservice_months "Time since joining Bihar Police (months)"
la var fem_psservice_months "Time since joining current PS (months)"

* Generating variable for time in current PS (years)
gen fem_bpservice_years = (submissiondate_final - bp_combined)/12
gen fem_psservice_years = (submissiondate_final - ps_combined)/12
la var fem_bpservice_years "Time since joining Bihar Police (years)"
la var fem_psservice_years "Time since joining current PS (years)"

foreach var of varlist fem_bpservice_weeks fem_psservice_weeks fem_bpservice_months fem_psservice_months fem_bpservice_years fem_psservice_years {
	replace `var' =. if `var' < 0 // 6 obs, constables reported their joining in the PS as later than submission date of survey, replacing them as missing
}

* Recoding officer caste
tab c6, gen (fem_po_caste_dum)
rename fem_po_caste_dum1 fem_po_caste_dum_refuse
rename fem_po_caste_dum2 fem_po_caste_dum_sc
rename fem_po_caste_dum3 fem_po_caste_dum_st
rename fem_po_caste_dum4 fem_po_caste_dum_obc
rename fem_po_caste_dum5 fem_po_caste_dum_general

* Generating and renaming higher education variables
tab highest_educ, gen(fem_po_highest_educ)
rename fem_po_highest_educ1 fem_po_highest_educ_10th
rename fem_po_highest_educ2 fem_po_highest_educ_12th
rename fem_po_highest_educ3 fem_po_highest_educ_diploma
rename fem_po_highest_educ4 fem_po_highest_educ_college
rename fem_po_highest_educ5 fem_po_highest_educ_ba
rename fem_po_highest_educ6 fem_po_highest_educ_ma

* Generating marital status dummy
gen fem_po_married =.
replace fem_po_married = 1 if c4 == 2 | c4 == 3
replace fem_po_married = 0 if c4 == 1 | c4 == 6 | c4 == -666

* Dropping duplicate entries
drop if key == "uuid:20f383b7-e923-4e86-abed-c82377dc1e93"

******************************MALE OFFICERS DATA********************************
/*
NOTE: We have tracked police station at baseline (ps_dist_id_bl) and police station at endline (ps_dist_id_el).
For collapsing the officer data to station level, we use the endline police station id - ps_dist_id_el
*/

preserve
	use "$MO_endline\06.clean-data\endline_secondaryoutcomes.dta", clear
	drop if dum_endline == 0
	sort ps_dist_id_el, stable
	by ps_dist_id_el: egen count_maleofficers_el = total(dum_endline) // count of male officers in police station at endline
	by ps_dist_id_el: egen count_maleofficers_trained_el = total(dum_training) // count of trained male officers in police station at endline
	collapse (mean) count_maleofficers_el count_maleofficers_trained_el, by (ps_dist_id_el) // collapsing to PS-level dataset
	gen share_trainedofficers_el = count_maleofficers_trained_el/count_maleofficers_el
	rename ps_dist_id_el ps_dist_id
	la var count_maleofficers_el "Count of male officers in PS (endline)"
	la var count_maleofficers_trained_el "Count of male officers who received training in PS (endline)"
	la var share_trainedofficers_el "Share of male officers who received training in PS (endline)"
	tempfile endline_count
	save `endline_count'
restore

******************************PSFS DATA*****************************************
/*
Generate a count for female constables in each station according to PSFS
reporting, then we generate a dummy that takes value if the PS has above median
strength of female constables.

*/
preserve
	use "$psfs\PSFS-2022\06.clean-data\psfs_combined.dta", clear
	drop psfs_count_femofficers dum_fem
	egen psfs_count_femofficers = rowtotal(po_f_headconstable po_f_wtconstable po_f_constable po_f_asi po_f_si po_f_ins po_f_sho)
	summ psfs_count_femofficers, detail
	local fem_p50 = r(p50)
	gen dum_fem = (psfs_count_femofficers > `fem_p50')
	la var dum_fem "Female officer strength"
	cap la define dum_fem 0"Below median strength" 1"Above median strength"
	la values dum_fem dum_fem
	tempfile psfs_clean
	save `psfs_clean'
restore

********************************************************************************
rename police_station_id ps_dist_id

merge m:1 ps_dist_id using `endline_count' // merging with endline count
drop if _m != 3
drop _m

merge m:1 ps_dist_id using `psfs_clean' // merging with PSFS data
drop if _m != 3
drop _m

********************************************************************************

* Get the data on when the training was conducted in each police station

preserve
	use "$MO_endline/06.clean-data/endline_baseline_training.dta", clear
	keep date_firsttraining_ps trainingdate_officer trainingdays_officer ///
	dum_trainingcompleted ps_dist_id_el po_unique_id_el treatment_bl
	drop if ps_dist_id_el==""
	drop if treatment_bl!=1
	* Verify that for each police station the start date of training is unique
	sort ps_dist_id_el date_firsttraining_ps, stable
    by ps_dist_id_el date_firsttraining_ps: gen nvals = _n == 1 
    by ps_dist_id_el: replace nvals = sum(nvals)
    by ps_dist_id_el: replace nvals = nvals[_N] 
	cap assert nvals==1
	drop nvals
	collapse (first) date_firsttraining_ps, by(ps_dist_id_el)
	drop if date_firsttraining_ps==.
	ren ps_dist_id_el ps_dist_id
	tempfile date_training
	save `date_training'
restore

* Merge the data

merge m:1 ps_dist_id using `date_training'
drop if _merge==2
drop _merge

/* Generate a variable that tells us the number of days female officers have been interacting
with treated senior police officers. This variable will be generated as date of survey
- day of training if the female officer was already working at the station when 
the training happened. It will be generated as survey day-day of joining the police
station if she reached the police station after the training took place. 
*/
replace start_month_ps=month_joined_ps if start_month_ps==.
replace start_year_ps=year_joined_ps if start_year_ps==.
/* 
For cases where date of joining police station is missing, we suppose the officer
joined the station at the end of the month to be conservative. 
*/
replace start_day_ps=27 if start_day_ps==. & start_month_ps!=. & start_year_ps!=.

gen date_join_ps = mdy(start_month_ps, start_day_ps, start_year_ps) // 1 missing value, check why
format date_join_ps %td

gen days_treatment_exposure=.
replace days_treatment_exposure=(survey_date-date_firsttraining_ps) if date_join_ps<=date_firsttraining_ps
replace days_treatment_exposure=(survey_date-date_join_ps) if date_join_ps>date_firsttraining_ps & date_join_ps!=.
replace days_treatment_exposure=0 if treatment==0
replace days_treatment_exposure=. if days_treatment_exposure<0

********************************************************************************

* Generate alternative treatment variable based on networks 

preserve
	keep network_officer_name_1 network_officer_name_2 network_officer_name_3 ///
	network_officer_name_4 network_officer_name_5 network_officer_name_6 officer_unique_id key
	cap isid key
	reshape long network_officer_name_, i(key) j(num)
	rename network_officer_name_ po_unique_id_el
	drop if po_unique_id_el=="" | po_unique_id_el=="-888"
	tempfile female_network
	save `female_network'
restore

preserve 
	use "$MO_endline\06.clean-data\endline_secondaryoutcomes.dta", clear
	drop if dum_endline == 0
	keep dum_training po_unique_id_el
	drop if po_unique_id_el==""
    sort po_unique_id_el, stable
    quietly by po_unique_id_el:  gen dup = cond(_N==1,0,_n)
	drop if dup!=0	
	isid po_unique_id_el
	tempfile treated_male_officers
	save `treated_male_officers'
restore

preserve
	use `female_network', clear
	merge m:1 po_unique_id_el using `treated_male_officers'
	drop if _merge==2
	drop _m
	sort key, stable
	by key: egen count_treated_officers_network=total(dum_training)
	collapse (mean) count_treated_officers_network, by(key)
	tempfile network_treated
	save `network_treated'
restore

merge 1:1 key using `network_treated'
replace count_treated_officers_network=0 if treatment==0
drop _merge

replace count_treated_officers_network=0 if count_treated_officers_network==.

la var count_treated_officers_network "Num treated in network"
********************************************************************************


* Labelling values

la def yesno 0 "No" 1 "Yes"
foreach var of varlist police_mother police_father police_brother police_husband ///
police_bil police_sil police_fil police_uncle police_aunt police_daughter ///
police_dil police_fam_oth q3402_1-q3402_22 q3403_1-q3403_10 q3405_1-q3405_10 q3404_val ///
q9006_1 q9006_2 q9006_3 c3_0 c3_1 c3_2 c3_3 c3__888 hs6b_1 hs6b_2 hs6b_3 hs6b_4 ///
hs6b_5 hs6b__999 hs6d_1 hs6d_2 hs6d_3 hs6d_4 hs6d_5 hs6d_6 hs6d_7 hs6d_8 hs6d_9 ///
hs6d_10 hs6d__888 h1b_1 h1b_2 h1b__999 h1b__666 h2b_2 h2b__999 h2b__666 h3b_1 ///
h3b_2 h3b__999 h3b__666 h4b_1 h4b_2 h4b__999 h4b__666 h5b_1 h5b_2 h5b__999 h5b__666 ///
h6b_1 h6b_2 h6b__999 h6b__666 fem_po_caste_dum_refuse fem_po_caste_dum_sc ///
fem_po_caste_dum_st fem_po_caste_dum_obc fem_po_caste_dum_general ///
fem_po_highest_educ_10th fem_po_highest_educ_12th fem_po_highest_educ_diploma ///
fem_po_highest_educ_college fem_po_highest_educ_ba fem_po_highest_educ_ma ///
fem_po_married {
	la val `var' yesno
}

la def agreement 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
foreach var of varlist q3301_val q3302_val q3303_val q3304_val q3305_val {
	la val `var' agreement
}

la define treatment 0 "Control" 1"Treatment"
la values treatment treatment

* highest_educ_oth why is this variable not =. if nobody selected other specify in highest_educ?


* Labelling variables

la var duration "Survey duration in minutes"
la var treatment "Treatment"
la var days_treatment_exposure "Days Exposed to T"
la var share_trainedofficers_el "Share Trained Officers"
********************************************************************************

* Order variables 


* Save clean dataset

save "$clean_dta/female_constables_clean.dta", replace


cap log close
