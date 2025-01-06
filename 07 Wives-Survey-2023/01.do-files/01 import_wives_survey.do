/*==============================================================================
File Name: Wives' Survey 2023 - Import do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	21/05/2024
Created by: Dibyajyoti Basak
Updated on: 22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to import the data for the Wives' Survey 2023

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

log using "$Wives_survey_log_files\wivessurvey_import.log", replace text

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
local csvfile "$Wives_survey_raw/Wives Survey_WIDE.csv"
local dtafile "$Wives_survey_intermediate_dta/Wives Survey.dta"
local corrfile "$Wives_survey_raw/Wives Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid uploadstamp a1 a2 a3name a4 a5 a6 a7 officername wifename endlinekey psname officephone b0a_os q1002_os q1005_os q1006_village q1006_state"
local text_fields2 "q1006_district rsbec2 rsbec4 rsbec9 rsbec14 rsbec18 rsbec20 rsbec22 q5001 r1 r3 r5 r5_os instanceid"
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


	label variable a3 "A3. Surveyor ID"
	note a3: "A3. Surveyor ID"
	label define a3 1 "Anjali" 2 "Nisha" 3 "Alka" 4 "Lalita" 5 "Sarita" 6 "Shabnam" 7 "Madhuri" 8 "Lilavati Kumari" 9 "Namita" 10 "Rishu Kumari" 11 "Tara Gupta" 12 "Pratima Kumari" 13 "Nilu Kumari" 14 "Shashikala" 15 "Indu" 16 "Anima" 17 "Manshi Kumari" 18 "Laxmi Kumari" 19 "Lilu Chakarbarty" 20 "Gunja Kumari" 21 "Poonam Sonwani" 22 "Renu Kumari Prabha" 23 "Rajni Kumari" 24 "Bhanamatee" 25 "Rina Kumari"
	label values a3 a3

	label variable a4 "A4. Survey location Note to surveyor:Please note down as accurate a location as "
	note a4: "A4. Survey location Note to surveyor:Please note down as accurate a location as possible (Example. PS Sadar, Vaishali)"

	label variable a5 "A5. Select the district of Officer's (husband's) posting"
	note a5: "A5. Select the district of Officer's (husband's) posting"

	label variable a6 "A6. Select the Police Station of husband's posting"
	note a6: "A6. Select the Police Station of husband's posting"

	label variable a7 "A7. Officer Unique ID"
	note a7: "A7. Officer Unique ID"

	label variable a8 "A8. Do you confirm these are the details of your husband? Officer Name: \${offic"
	note a8: "A8. Do you confirm these are the details of your husband? Officer Name: \${officername} Phone Number: \${officephone} Police Station: \${psname}"
	label define a8 1 "Yes" 0 "No"
	label values a8 a8

	label variable b0 "B0. Verbal Consent: Do you agree to participate in this interview?"
	note b0: "B0. Verbal Consent: Do you agree to participate in this interview?"
	label define b0 1 "Yes" 0 "No"
	label values b0 b0

	label variable b0a "B0a. If No, what are your reasons to not participate in this survey?"
	note b0a: "B0a. If No, what are your reasons to not participate in this survey?"
	label define b0a 1 "Too busy with work and do not have much time" 2 "Doesn’t think this is an important exercise" 3 "Has privacy issues" -888 "Others Specify"
	label values b0a b0a

	label variable q1001 "1001. What is your year of birth?"
	note q1001: "1001. What is your year of birth?"
	label define q1001 1950 "1950" 1951 "1951" 1952 "1952" 1953 "1953" 1954 "1954" 1955 "1955" 1956 "1956" 1957 "1957" 1958 "1958" 1959 "1959" 1960 "1960" 1961 "1961" 1962 "1962" 1963 "1963" 1964 "1964" 1965 "1965" 1966 "1966" 1967 "1967" 1968 "1968" 1969 "1969" 1970 "1970" 1971 "1971" 1972 "1972" 1973 "1973" 1974 "1974" 1975 "1975" 1976 "1976" 1977 "1977" 1978 "1978" 1979 "1979" 1980 "1980" 1981 "1981" 1982 "1982" 1983 "1983" 1984 "1984" 1985 "1985" 1986 "1986" 1987 "1987" 1988 "1988" 1989 "1989" 1990 "1990" 1991 "1991" 1992 "1992" 1993 "1993" 1994 "1994" 1995 "1995" 1996 "1996" 1997 "1997" 1998 "1998" 1999 "1999" 2000 "2000" 2001 "2001" 2002 "2002" 2003 "2003" 2004 "2004" 2005 "2005" 2006 "2006" 2007 "2007" 2008 "2008" 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" -999 "Do not know"
	label values q1001 q1001

	label variable q1002 "Q1002. What is the highest level of education you received?"
	note q1002: "Q1002. What is the highest level of education you received?"
	label define q1002 1 "10th" 2 "Plus 2" 3 "Diploma after Plus 2" 4 "Started college, did not complete/currently attending" 5 "College completed (B.A)" 6 "Post Graduate (M.A.)" -888 "Others Specify"
	label values q1002 q1002

	label variable q1003_years "Years"
	note q1003_years: "Years"

	label variable q1003_months "Months"
	note q1003_months: "Months"

	label variable q1004 "Q1004. Do you work outside the home?"
	note q1004: "Q1004. Do you work outside the home?"
	label define q1004 1 "Yes" 0 "No"
	label values q1004 q1004

	label variable q1005 "Q1005. If yes, what kind of work do you do?"
	note q1005: "Q1005. If yes, what kind of work do you do?"
	label define q1005 1 "Local/Informal Business" 2 "School Teacher" 3 "ASHA Worker" 4 "Local NGO/Community Work" 5 "Other Govt. Job (apart from options 2. and 3.)" -888 "Others Specify"
	label values q1005 q1005

	label variable q1006_village "Village/City"
	note q1006_village: "Village/City"

	label variable q1006_state "State"
	note q1006_state: "State"

	label variable q1006_district "District"
	note q1006_district: "District"

	label variable q2001 "Q2001. My partner showed respect for my feelings about an issue."
	note q2001: "Q2001. My partner showed respect for my feelings about an issue."
	label define q2001 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2001 q2001

	label variable q2002 "Q2002. Sought help by bringing in someone to settle the issue"
	note q2002: "Q2002. Sought help by bringing in someone to settle the issue"
	label define q2002 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2002 q2002

	label variable q2003 "Q2003. My partner showed respect for, or showed that he cared about my feeling a"
	note q2003: "Q2003. My partner showed respect for, or showed that he cared about my feeling about an issue we disagreed on"
	label define q2003 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2003 q2003

	label variable q2004 "Q2004. Does he get impatient when you talk to him about Household repairs/chores"
	note q2004: "Q2004. Does he get impatient when you talk to him about Household repairs/chores/upkeep?"
	label define q2004 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2004 q2004

	label variable q2005 "Q2005. Does your husband patiently listen to your child(ren) when they share the"
	note q2005: "Q2005. Does your husband patiently listen to your child(ren) when they share their problems with him?"
	label define q2005 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" 888 "Not Applicable (Do not have children)"
	label values q2005 q2005

	label variable q2006 "Q2006. Does your husband calmly listen to you when you share your problems with "
	note q2006: "Q2006. Does your husband calmly listen to you when you share your problems with him?"
	label define q2006 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2006 q2006

	label variable q2007 "Q2007. Stomped out of the room or house or yard during a disagreement."
	note q2007: "Q2007. Stomped out of the room or house or yard during a disagreement."
	label define q2007 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2007 q2007

	label variable q2008 "Q2008. Refused to talk about an issue"
	note q2008: "Q2008. Refused to talk about an issue"
	label define q2008 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2008 q2008

	label variable q2009 "Q2009. My partner explains his side or suggests a compromise for a disagreement "
	note q2009: "Q2009. My partner explains his side or suggests a compromise for a disagreement with me"
	label define q2009 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q2009 q2009

	label variable q3001 "Q3001. If you read this in today’s paper, would you discuss this with your partn"
	note q3001: "Q3001. If you read this in today’s paper, would you discuss this with your partner?"
	label define q3001 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q3001 q3001

	label variable q3002 "Q3002. Imagine that this case was being handled by your partner’s thana, would y"
	note q3002: "Q3002. Imagine that this case was being handled by your partner’s thana, would you feel comfortable in asking about the progress of the case?"
	label define q3002 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q3002 q3002

	label variable q3003 "Q3003. Do you think your partner is likely to believe or feel that the boy was j"
	note q3003: "Q3003. Do you think your partner is likely to believe or feel that the boy was justified in his actions in this situation?"
	label define q3003 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q3003 q3003

	label variable q3004 "Q3004. How likely do you think it is that your partner will say or feel that to "
	note q3004: "Q3004. How likely do you think it is that your partner will say or feel that to some extent the girl and her family were also at fault for not meeting the demands of the boy and his family?"
	label define q3004 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q3004 q3004

	label variable q3005 "Q3005. How likely is it that your husband would file this case if it happened in"
	note q3005: "Q3005. How likely is it that your husband would file this case if it happened in his thana?"
	label define q3005 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q3005 q3005

	label variable rsbec2 "RS.B.EC.2 My husband has tender, concerned feelings for people less fortunate th"
	note rsbec2: "RS.B.EC.2 My husband has tender, concerned feelings for people less fortunate than him. (EC)/"

	label variable rsbec4 "RS.B.EC.4 Sometimes my husband does not feel very sorry for other people when th"
	note rsbec4: "RS.B.EC.4 Sometimes my husband does not feel very sorry for other people when they are having problems. (EC)"

	label variable rsbec9 "RS.B.EC.9 When my husband sees someone being taken advantage of, he feels kind o"
	note rsbec9: "RS.B.EC.9 When my husband sees someone being taken advantage of, he feels kind of protective towards them. (EC)"

	label variable rsbec14 "RS.B.EC.14 Other people's misfortunes does not usually disturb my husband a grea"
	note rsbec14: "RS.B.EC.14 Other people's misfortunes does not usually disturb my husband a great deal. (EC)"

	label variable rsbec18 "RS.B.EC.18 When my husband sees someone being treated unfairly, he sometimes doe"
	note rsbec18: "RS.B.EC.18 When my husband sees someone being treated unfairly, he sometimes does not feel very much pity for them. (EC)"

	label variable rsbec20 "RS.B.EC.20 My husband is often quite touched by things that he sees happening. ("
	note rsbec20: "RS.B.EC.20 My husband is often quite touched by things that he sees happening. (EC)"

	label variable rsbec22 "RS.B.EC.22 I would describe my husband as a a pretty soft-hearted person. (EC)"
	note rsbec22: "RS.B.EC.22 I would describe my husband as a a pretty soft-hearted person. (EC)"

	label variable q5001 "Q5001. What are the topics/issues from his workplace that your spouse has discus"
	note q5001: "Q5001. What are the topics/issues from his workplace that your spouse has discussed with you over the past one year?"

	label variable q5002 "Q5002. How frequently has your spouse discussed workplace issues with you in the"
	note q5002: "Q5002. How frequently has your spouse discussed workplace issues with you in the last 30 days?"
	label define q5002 1 "Never" 2 "Rarely" 3 "Sometimes" 4 "Often" 5 "Always" -999 "DNK" -666 "Refused"
	label values q5002 q5002

	label variable q6001 "Q6001. My spouse believes that male and female constables do the same work in a "
	note q6001: "Q6001. My spouse believes that male and female constables do the same work in a police station"
	label define q6001 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6001 q6001

	label variable q6002 "Q6002. My spouse believes that male and female constables have the same capabili"
	note q6002: "Q6002. My spouse believes that male and female constables have the same capability when it comes to their job"
	label define q6002 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6002 q6002

	label variable q6003 "Q6003. My spouse treats all his children equally"
	note q6003: "Q6003. My spouse treats all his children equally"
	label define q6003 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6003 q6003

	label variable q6004 "Q6004. My spouse believes a woman can do the same work as a man"
	note q6004: "Q6004. My spouse believes a woman can do the same work as a man"
	label define q6004 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6004 q6004

	label variable q6005 "Q6005. My spouse believes that a woman’s place is inside the home"
	note q6005: "Q6005. My spouse believes that a woman’s place is inside the home"
	label define q6005 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6005 q6005

	label variable q6006 "Q6006. My spouse believes that childcare is primarily a woman’s responsibility"
	note q6006: "Q6006. My spouse believes that childcare is primarily a woman’s responsibility"
	label define q6006 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6006 q6006

	label variable q6007 "Q6007. My spouse is okay with me working outside the home for pay"
	note q6007: "Q6007. My spouse is okay with me working outside the home for pay"
	label define q6007 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6007 q6007

	label variable q6008 "Q6008. My spouse lets me have an equal say in decision-making"
	note q6008: "Q6008. My spouse lets me have an equal say in decision-making"
	label define q6008 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -999 "DNK" -666 "Refused"
	label values q6008 q6008

	label variable q7001 "Q7001. It is sometimes hard for me to go on with my work if I am not encouraged."
	note q7001: "Q7001. It is sometimes hard for me to go on with my work if I am not encouraged."
	label define q7001 1 "TRUE" 2 "FALSE"
	label values q7001 q7001

	label variable q7002 "Q7002. I sometimes feel resentful when I don't get my own way."
	note q7002: "Q7002. I sometimes feel resentful when I don't get my own way."
	label define q7002 1 "TRUE" 2 "FALSE"
	label values q7002 q7002

	label variable q7003 "Q7003. On a few occasions, I have given up doing something because I thought too"
	note q7003: "Q7003. On a few occasions, I have given up doing something because I thought too little of my ability."
	label define q7003 1 "TRUE" 2 "FALSE"
	label values q7003 q7003

	label variable q7004 "Q7004. There have been times when I felt like rebelling against people in author"
	note q7004: "Q7004. There have been times when I felt like rebelling against people in authority even though I knew they were right."
	label define q7004 1 "TRUE" 2 "FALSE"
	label values q7004 q7004

	label variable q7005 "Q7005. No matter who I’m talking to, I’m always a good listener."
	note q7005: "Q7005. No matter who I’m talking to, I’m always a good listener."
	label define q7005 1 "TRUE" 2 "FALSE"
	label values q7005 q7005

	label variable q7006 "Q7006. There have been occasions when I took advantage of someone."
	note q7006: "Q7006. There have been occasions when I took advantage of someone."
	label define q7006 1 "TRUE" 2 "FALSE"
	label values q7006 q7006

	label variable q7007 "Q7007. I’m always willing to admit it when I make a mistake."
	note q7007: "Q7007. I’m always willing to admit it when I make a mistake."
	label define q7007 1 "TRUE" 2 "FALSE"
	label values q7007 q7007

	label variable q7008 "Q7008. I sometimes try to get even, rather than forgive and forget."
	note q7008: "Q7008. I sometimes try to get even, rather than forgive and forget."
	label define q7008 1 "TRUE" 2 "FALSE"
	label values q7008 q7008

	label variable q7009 "Q7009. I am always courteous, even to people who are disagreeable."
	note q7009: "Q7009. I am always courteous, even to people who are disagreeable."
	label define q7009 1 "TRUE" 2 "FALSE"
	label values q7009 q7009

	label variable q7010 "Q7010. I have never been irked when people expressed ideas very different from m"
	note q7010: "Q7010. I have never been irked when people expressed ideas very different from my own."
	label define q7010 1 "TRUE" 2 "FALSE"
	label values q7010 q7010

	label variable q7011 "Q7011. There have been times when I was quite jealous of the good fortune of oth"
	note q7011: "Q7011. There have been times when I was quite jealous of the good fortune of others."
	label define q7011 1 "TRUE" 2 "FALSE"
	label values q7011 q7011

	label variable q7012 "Q7012. I am sometimes irritated by people who ask favours of me."
	note q7012: "Q7012. I am sometimes irritated by people who ask favours of me."
	label define q7012 1 "TRUE" 2 "FALSE"
	label values q7012 q7012

	label variable q7013 "Q7013. I have never deliberately said something that hurt someone’s feelings."
	note q7013: "Q7013. I have never deliberately said something that hurt someone’s feelings."
	label define q7013 1 "TRUE" 2 "FALSE"
	label values q7013 q7013

	label variable c1 "C1. How effective do you think the Bihar Police is, in general, in handling case"
	note c1: "C1. How effective do you think the Bihar Police is, in general, in handling cases of crimes against women? (Read choices out loud, and select one)"
	label define c1 1 "Very effective" 2 "Effective" 3 "Neither effective nor ineffective" 4 "Ineffective" 5 "Very ineffective" -666 "Refused to answer" -999 "Do not know"
	label values c1 c1

	label variable r2latitude "R2. Record GPS location (latitude)"
	note r2latitude: "R2. Record GPS location (latitude)"

	label variable r2longitude "R2. Record GPS location (longitude)"
	note r2longitude: "R2. Record GPS location (longitude)"

	label variable r2altitude "R2. Record GPS location (altitude)"
	note r2altitude: "R2. Record GPS location (altitude)"

	label variable r2accuracy "R2. Record GPS location (accuracy)"
	note r2accuracy: "R2. Record GPS location (accuracy)"

	label variable r3 "R3. सर्वेयर की कोई टिप्पणी"
	note r3: "R3. सर्वेयर की कोई टिप्पणी"

	label variable r4 "R4. Did anyone interfere during the survey?"
	note r4: "R4. Did anyone interfere during the survey?"
	label define r4 1 "Yes" 0 "No"
	label values r4 r4

	label variable r5 "R5. If yes, which family member?"
	note r5: "R5. If yes, which family member?"






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
*   Corrections file path and filename:  C:/Users/dibbo/Dropbox/Debiasing Police in India/005-Data-and-analysis-2022/Wives-Survey-2023/00.raw-data/Wives Survey_corrections.csv
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
