/*==============================================================================
File Name: Victim Survey 2024 - Import do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	27/11/2024
Created by: Dibyajyoti Basak
Updated on: 27/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to import the data for the Victim Survey 2024


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

log using "$Victim_survey_log_files\victimsurvey_import.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"
* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "$Victim_survey_raw/Victim Survey_WIDE.csv"
local dtafile "$Victim_survey_intermediate_dta\Victim Survey.dta"
local corrfile "$Victim_survey_raw/Victim Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid s1 s2 a1 a3village a3block a3district a5 a6_os a7 a8_os a12_os a13_os genbase b1 b1_os c5b c5b_os d1 d1_os d2_os d5a d5a_os"
local text_fields2 "victimroster_count e3_* e4_* e5_* e7_* e8_* e9_* instanceid"
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


	label variable a0 "A0. Surveyor name"
	note a0: "A0. Surveyor name"
	label define a0 3 "Amarjeet Bahadur" 7 "Anup Kumar Shukla" 11 "Chanda Kumari" 12 "Chintu Kumar" 15 "Madhu Rani" 20 "Nawnit Kumar Singh" 21 "Nikita Kumari" 25 "Ranjeet Kumar" 26 "Sanjumal Kumari"
	label values a0 a0

	label variable consent "Do we have your consent to proceed with the survey?"
	note consent: "Do we have your consent to proceed with the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable s1 "(For surveyor only) S1. District"
	note s1: "(For surveyor only) S1. District"

	label variable s2 "(For surveyor only) S2. Police Station"
	note s2: "(For surveyor only) S2. Police Station"

	label variable a1 "A1. Enter full Name"
	note a1: "A1. Enter full Name"

	label variable a2 "A2. What is your age?"
	note a2: "A2. What is your age?"

	label variable a3village "Village/town"
	note a3village: "Village/town"

	label variable a3block "Block"
	note a3block: "Block"

	label variable a3district "District"
	note a3district: "District"

	label variable a4 "A4. What is your gender?"
	note a4: "A4. What is your gender?"
	label define a4 1 "Male" 2 "Female" -777 "Prefer not to say"
	label values a4 a4

	label variable a5 "A5. Which police station do people in your community/village go to?"
	note a5: "A5. Which police station do people in your community/village go to?"

	label variable a6 "A6. What religion do you follow?"
	note a6: "A6. What religion do you follow?"
	label define a6 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Buddhism" 6 "Jainism" 7 "Don’t follow/believe in any religion" -888 "Others Specify" -777 "Refuse to answer"
	label values a6 a6

	label variable a7 "A7. Which caste do you belong to?"
	note a7: "A7. Which caste do you belong to?"

	label variable a8 "A8. What category do you fall in?"
	note a8: "A8. What category do you fall in?"
	label define a8 1 "OBC" 2 "Scheduled Caste" 3 "Scheduled Tribe" 4 "General Caste" -888 "Others Specify (write the name of caste if woman doesn’t know the category)" -777 "Refuse to answer" -999 "Do not know"
	label values a8 a8

	label variable a9 "A9. What is your marital status?"
	note a9: "A9. What is your marital status?"
	label define a9 1 "Single" 2 "Married" 3 "Separated" 4 "Divorced" 5 "Widowed" -777 "Refuse to Answer"
	label values a9 a9

	label variable a10 "A10. Can you read and write?"
	note a10: "A10. Can you read and write?"
	label define a10 1 "Yes" 2 "No, read only" 3 "No"
	label values a10 a10

	label variable a11 "A11. Are you currently working for pay?"
	note a11: "A11. Are you currently working for pay?"
	label define a11 1 "Yes" 0 "No"
	label values a11 a11

	label variable a12 "A12. What is your primary occupation?"
	note a12: "A12. What is your primary occupation?"
	label define a12 1 "Self-employed (agriculture)" 2 "Self-employed (non-agriculture)" 3 "Agricultural labor" 4 "Non-Agricultural labor" 5 "Casual wage labor" 6 "Independent/Skilled work" 7 "Own shop/business" 8 "Household work, such as family care" 9 "Pension" 10 "Rental Income" 11 "Regular wage/salary earning" 12 "Government job" 13 "Seasonal labor" -888 "Others Specify" -777 "Refuse to answer" -999 "Do not know"
	label values a12 a12

	label variable a13 "A13. What is the primary occupation of your father or guardian (if unmarried)/hu"
	note a13: "A13. What is the primary occupation of your father or guardian (if unmarried)/husband (if married)"
	label define a13 1 "Self-employed (agriculture)" 2 "Self-employed (non-agriculture)" 3 "Agricultural labor" 4 "Non-Agricultural labor" 5 "Casual wage labor" 6 "Independent/Skilled work" 7 "Own shop/business" 8 "Household work, such as family care" 9 "Pension" 10 "Rental Income" 11 "Regular wage/salary earning" 12 "Government job" 13 "Seasonal labor" -888 "Others Specify" -777 "Refuse to answer" -999 "Do not know"
	label values a13 a13

	label variable b0 "B0. Do you remember the name of the officer you spoke to?"
	note b0: "B0. Do you remember the name of the officer you spoke to?"
	label define b0 1 "Yes" 0 "No"
	label values b0 b0

	label variable b3 "B3. What was the gender of the Officer?"
	note b3: "B3. What was the gender of the Officer?"
	label define b3 1 "Male" 2 "Female" -777 "Prefer not to say"
	label values b3 b3

	label variable b1 "B1. Name of the Officer that you spoke to"
	note b1: "B1. Name of the Officer that you spoke to"

	label variable b2 "B2. Rank of the Officer in the Bihar Police?"
	note b2: "B2. Rank of the Officer in the Bihar Police?"
	label define b2 1 "Assistant Sub Inspector of Police (ASI)" 2 "Sub-Inspector of Police (SI)" 3 "Police Sub-Inspector (PSI - In training for Inspector)" 4 "Inspector of Police, but not SHO" 5 "Station Head Officer (SHO)" 6 "Constable" -999 "Do not Know"
	label values b2 b2

	label variable b2a "ADD SUB-RANK of CONSTABLE"
	note b2a: "ADD SUB-RANK of CONSTABLE"
	label define b2a 1 "Head Constable (Havildar)" 2 "Senior Constable" 3 "Police Constable" 4 "Home Guard" -999 "Do not Know"
	label values b2a b2a

	label variable c1a "C1a. What was the attitude of the officer to whom you spoke?"
	note c1a: "C1a. What was the attitude of the officer to whom you spoke?"
	label define c1a 1 "Very rude" 2 "Slightly rude" 3 "Neither polite nor rude" 4 "Slightly polite" 5 "Very polite"
	label values c1a c1a

	label variable c1b "C1b. Did the Officer exhibit empathy towards you or appeared to be concerned abo"
	note c1b: "C1b. Did the Officer exhibit empathy towards you or appeared to be concerned about your well-being?"
	label define c1b 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c1b c1b

	label variable c1c "C1c. Did the Officer patiently hear about your version of the story and tried to"
	note c1c: "C1c. Did the Officer patiently hear about your version of the story and tried to understand your perspective?"
	label define c1c 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c1c c1c

	label variable c1d "C1d. Did the police officer use any curses or foul language when speaking to you"
	note c1d: "C1d. Did the police officer use any curses or foul language when speaking to you?"
	label define c1d 1 "Yes" 0 "No"
	label values c1d c1d

	label variable c1e "C1e. Did you feel that the officer was respectful towards you?"
	note c1e: "C1e. Did you feel that the officer was respectful towards you?"
	label define c1e 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c1e c1e

	label variable c2a "C2a. Did the Officer blame you instead or said that you were at fault?"
	note c2a: "C2a. Did the Officer blame you instead or said that you were at fault?"
	label define c2a 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c2a c2a

	label variable c2b "C2b. Did the officer try to explain how you could have done things differently t"
	note c2b: "C2b. Did the officer try to explain how you could have done things differently to avoid the situation?"
	label define c2b 1 "Yes" 0 "No"
	label values c2b c2b

	label variable c2c "C2c. Did the officer blame you for not reporting the case earlier?"
	note c2c: "C2c. Did the officer blame you for not reporting the case earlier?"
	label define c2c 1 "Yes" 0 "No"
	label values c2c c2c

	label variable c2d "C2d. Did the Officer ask you unnecessary questions, which were not relevant to t"
	note c2d: "C2d. Did the Officer ask you unnecessary questions, which were not relevant to the case? Examples: 'what were you wearing?' or 'whom were you going with?' or 'why did you need to go outside?'"
	label define c2d 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c2d c2d

	label variable c3a "C3a. Did the officer believe in the truthfulness of your complaint?"
	note c3a: "C3a. Did the officer believe in the truthfulness of your complaint?"
	label define c3a 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c3a c3a

	label variable c4a "C4a. Did the officer tell you to visit a Mahila Thana for this case? (For female"
	note c4a: "C4a. Did the officer tell you to visit a Mahila Thana for this case? (For female victims only)"
	label define c4a 1 "Yes" 0 "No"
	label values c4a c4a

	label variable c4b "C4b. Did the officer ask you to come back some other day to register the complai"
	note c4b: "C4b. Did the officer ask you to come back some other day to register the complaint?"
	label define c4b 1 "Yes" 0 "No"
	label values c4b c4b

	label variable c4c "C4c. Did the officer keep making different excuses instead of paying full attent"
	note c4c: "C4c. Did the officer keep making different excuses instead of paying full attention to the case?"
	label define c4c 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c4c c4c

	label variable c5a "C5a. Did the Officer appear to be dismissive towards your case?"
	note c5a: "C5a. Did the Officer appear to be dismissive towards your case?"
	label define c5a 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values c5a c5a

	label variable c5b "C5b. Did the Officer pass any of the following remarks:"
	note c5b: "C5b. Did the Officer pass any of the following remarks:"

	label variable d1 "D1. For which of the following reasons/incidents did you go to the police to fil"
	note d1: "D1. For which of the following reasons/incidents did you go to the police to file a FIR/complaint recently?"

	label variable d2 "D2. How did the visit to the Police Station end?"
	note d2: "D2. How did the visit to the Police Station end?"
	label define d2 1 "FIR was successfully lodged" 2 "FIR was not successfully lodged" 3 "General Diary was lodged, FIR may/may not be registered after preliminary invest" 4 "On-duty officer asked to come back later" 5 "Came to a mutual understanding on encouragement from the police." -888 "Others Specify"
	label values d2 d2

	label variable d4 "D4. How long did you have to wait before speaking to the duty officer? (please e"
	note d4: "D4. How long did you have to wait before speaking to the duty officer? (please enter in minutes)"

	label variable d5 "D5. Do you think there was an unusual amount of delay that you had to face?"
	note d5: "D5. Do you think there was an unusual amount of delay that you had to face?"
	label define d5 1 "Yes" 0 "No"
	label values d5 d5

	label variable d5a "D5a. If Yes, what were the reasons for the delay?"
	note d5a: "D5a. If Yes, what were the reasons for the delay?"

	label variable d6 "D6. Did the any police officer ask for money or suggest that the FIR would not b"
	note d6: "D6. Did the any police officer ask for money or suggest that the FIR would not be registered without some payment?"
	label define d6 1 "Yes" 0 "No"
	label values d6 d6

	label variable d6a "D6a. If Yes, for how much money did the Officer ask for?"
	note d6a: "D6a. If Yes, for how much money did the Officer ask for?"

	label variable d8 "D8. How nervous did you feel during your interaction?"
	note d8: "D8. How nervous did you feel during your interaction?"
	label define d8 1 "Very nervous" 2 "Slightly nervous" 3 "Neither nervous nor normal" 4 "Slightly normal" 5 "Very normal"
	label values d8 d8

	label variable d9 "D9. Did you feel threatened at any moment?"
	note d9: "D9. Did you feel threatened at any moment?"
	label define d9 1 "Strongly disagree" 2 "Slightly disagree" 3 "Neither agree nor disagree" 4 "Slightly agree" 5 "Strongly agree"
	label values d9 d9

	label variable e1 "E1. Can you help us in identifying other victims from this police station?"
	note e1: "E1. Can you help us in identifying other victims from this police station?"
	label define e1 1 "Yes" 0 "No"
	label values e1 e1

	label variable e2 "E2. How many people can you help us contact?"
	note e2: "E2. How many people can you help us contact?"



	capture {
		foreach rgvar of varlist e3_* {
			label variable `rgvar' "E3. Block"
			note `rgvar': "E3. Block"
		}
	}

	capture {
		foreach rgvar of varlist e4_* {
			label variable `rgvar' "E4. Gram Panchayat"
			note `rgvar': "E4. Gram Panchayat"
		}
	}

	capture {
		foreach rgvar of varlist e5_* {
			label variable `rgvar' "E5. Name of victim"
			note `rgvar': "E5. Name of victim"
		}
	}

	capture {
		foreach rgvar of varlist e6_* {
			label variable `rgvar' "E6. Gender of victim"
			note `rgvar': "E6. Gender of victim"
			label define `rgvar' 1 "Male" 2 "Female" -777 "Prefer not to say"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist e7_* {
			label variable `rgvar' "E7. Mobile Number"
			note `rgvar': "E7. Mobile Number"
		}
	}

	capture {
		foreach rgvar of varlist e8_* {
			label variable `rgvar' "E8. Alternate mobile number (if available)"
			note `rgvar': "E8. Alternate mobile number (if available)"
		}
	}

	capture {
		foreach rgvar of varlist e9_* {
			label variable `rgvar' "E9. Any other information"
			note `rgvar': "E9. Any other information"
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
*   Corrections file path and filename:  C:/Users/dibbo/Dropbox/Debiasing Police in India/005-Data-and-analysis-2022/12 Victim Survey-2024/00.raw-data/Victim Survey_corrections.csv
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
