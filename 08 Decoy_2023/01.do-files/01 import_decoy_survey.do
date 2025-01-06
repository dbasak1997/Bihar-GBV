/*==============================================================================
File Name: Decoy Survey 2023 - Import do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	21/05/2024
Created by: Dibyajyoti Basak
Updated on: 21/05/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to import the data for the Decoy Survey 2023

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

log using "$decoy_log_files\decoysurvey_import.log", replace text

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
local csvfile "$decoy_raw/Decoy Survey_WIDE.csv"
local dtafile "$decoy_intermediate_dta/Decoy Survey.dta"
local corrfile "$decoy_raw/Decoy Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid uploadstamp a4 a5 a6 police_district_station a6label b1 b1_full b1_name c2_os c5a c5a_os d5b d5b_os d6h d6h_os q1 q2 q3 q4 q5 comment"
local text_fields2 "instanceid"
local date_fields1 "a1"
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear
replace c1 = "6" if c1 == "06"
replace c1 = "6" if c1 == "Case no. 6"
destring c1, replace

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


	label variable a1 "A1. Date"
	note a1: "A1. Date"

	label variable a2 "A2. Survey start time"
	note a2: "A2. Survey start time"

	label variable a3 "A3. Surveyor name"
	note a3: "A3. Surveyor name"
	label define a3 1 "Ajeet Pandey" 2 "Alok Kumar" 3 "Amarjeet Bahadur" 4 "Amit Kumar Pandey" 5 "Anamika Kumari" 6 "Anita Kumari" 7 "Anup Kumar Shukla" 8 "Ashish Kumar Pandey" 9 "Brij Bhooshan Shukla" 10 "Brajesh Kumar Pandey" 11 "Chanda Kumari" 12 "Chintu Kumar" 13 "Kumar Nitesh" 14 "Kumar Vikash" 15 "Madhu Rani" 16 "Manisha Kumari" 17 "Menka Sahay" 18 "Mukesh Kumar" 19 "Munni Devi" 20 "Nawnit Kumar Singh" 21 "Nikita Kumari" 22 "Pratibha Kumari" 23 "Priyanka Devi" 24 "Rakesh Kumar Pandey" 25 "Ranjeet Kumar" 26 "Sanjumal Kumari" 27 "Shanti Kumari" 28 "Vinod Kumar Yadav" 29 "Arti Kumari"
	label values a3 a3

	label variable a4 "A4. Survey location Note to surveyor: Please note down as accurate a location as"
	note a4: "A4. Survey location Note to surveyor: Please note down as accurate a location as possible (Example. PS Sadar, Vaishali)."

	label variable a5 "A5. Select the district of Officer's posting"
	note a5: "A5. Select the district of Officer's posting"

	label variable a6 "A6. Select the Police Station of Officer's posting"
	note a6: "A6. Select the Police Station of Officer's posting"

	label variable b1 "B1. Name of the Officer that you spoke to"
	note b1: "B1. Name of the Officer that you spoke to"

	label variable b1_full "B1. Name of the Officer that you spoke to"
	note b1_full: "B1. Name of the Officer that you spoke to"

	label variable b1_name "B1. Name of the Officer that you spoke to: Others Specify"
	note b1_name: "B1. Name of the Officer that you spoke to: Others Specify"

	label variable b2 "B2. Rank of the Officer in the Bihar Police?"
	note b2: "B2. Rank of the Officer in the Bihar Police?"
	label define b2 01 "Assistant Sub Inspector of Police (ASI)" 02 "Sub-Inspector of Police (SI)" 03 "Police Sub-Inspector (PSI - In training for Inspector)" 04 "Inspector of Police, but not SHO" 05 "Station Head Officer (SHO)" -666 "Refused to answer"
	label values b2 b2

	label variable b2a "B2a. ADD SUB-RANK of CONSTABLE"
	note b2a: "B2a. ADD SUB-RANK of CONSTABLE"
	label define b2a 1 "Head Constable (Havildar)" 2 "Senior Constable" 3 "Police Constable" 4 "Home Guard" -999 "Do not Know"
	label values b2a b2a

	label variable b3 "B3. What was the gender of the Officer?"
	note b3: "B3. What was the gender of the Officer?"
	label define b3 1 "Male" 2 "Female"
	label values b3 b3

	label variable c1 "C1. What was the case study that you were assigned?"
	note c1: "C1. What was the case study that you were assigned?"
	label define c1 1 "Case 1 (Non-GBV)" 2 "Case 2 (Non-GBV)" 3 "Case 3 (Non-GBV)" 4 "Case 4 (GBV)" 5 "Case 5 (GBV)" 6 "Case 6 (GBV)" 7 "Case 7 (GBV)"
	label values c1 c1

	label variable c2 "C2. How did the visit to the Police Station end?"
	note c2: "C2. How did the visit to the Police Station end?"
	label define c2 1 "FIR would have been registered told true identity to officer" 2 "FIR would not have been registered – revealed true identity to officer" 3 "FIR would not have been registered – did not reveal true identity to officer" 4 "FIR was lodged but - did not reveal real identity" 5 "FIR would have been registered, preliminary investigations were ongoing, told tr" -888 "Other"
	label values c2 c2

	label variable c3 "C3. Did any of the police officers suspect that you were a decoy?"
	note c3: "C3. Did any of the police officers suspect that you were a decoy?"
	label define c3 1 "Yes" 2 "Maybe" 3 "Not at all"
	label values c3 c3

	label variable c4 "C4. How long did you have to wait before speaking to the duty officer? (ENTER MI"
	note c4: "C4. How long did you have to wait before speaking to the duty officer? (ENTER MINUTES)"

	label variable c5 "C5. Do you think there was an unusual amount of delay that you had to face?"
	note c5: "C5. Do you think there was an unusual amount of delay that you had to face?"
	label define c5 1 "Yes" 0 "No"
	label values c5 c5

	label variable c5a "C5a. If Yes, what were the reasons for the delay?"
	note c5a: "C5a. If Yes, what were the reasons for the delay?"

	label variable c6 "C6. Did the any police officer ask for money or suggest that the FIR would not b"
	note c6: "C6. Did the any police officer ask for money or suggest that the FIR would not be registered without some payment?"
	label define c6 1 "Yes" 0 "No"
	label values c6 c6

	label variable c6a "C6a. If Yes, for how much money did the Officer ask for?"
	note c6a: "C6a. If Yes, for how much money did the Officer ask for?"

	label variable c7 "C7. How were the overall facilities in the Police Station?"
	note c7: "C7. How were the overall facilities in the Police Station?"
	label define c7 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values c7 c7

	label variable c8 "C8. How nervous did you feel during your interaction?"
	note c8: "C8. How nervous did you feel during your interaction?"
	label define c8 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values c8 c8

	label variable c9 "C9. Did you feel threatened at any moment?"
	note c9: "C9. Did you feel threatened at any moment?"
	label define c9 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values c9 c9

	label variable d1a "D1a. What was the attitude of the officer to whom you spoke?"
	note d1a: "D1a. What was the attitude of the officer to whom you spoke?"
	label define d1a 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d1a d1a

	label variable d1b "D1b. Did the Officer exhibit empathy towards you or appeared to be concerned abo"
	note d1b: "D1b. Did the Officer exhibit empathy towards you or appeared to be concerned about your well-being?"
	label define d1b 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d1b d1b

	label variable d1c "D1c. Did the Officer patiently hear about your version of the story and tried to"
	note d1c: "D1c. Did the Officer patiently hear about your version of the story and tried to understand your perspective?"
	label define d1c 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d1c d1c

	label variable d1d "D1d. Did the police officer use any curses or foul language when speaking to you"
	note d1d: "D1d. Did the police officer use any curses or foul language when speaking to you?"
	label define d1d 1 "Yes" 0 "No"
	label values d1d d1d

	label variable d1e "D1e. Did you feel that the officer was respectful towards you?"
	note d1e: "D1e. Did you feel that the officer was respectful towards you?"
	label define d1e 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d1e d1e

	label variable d2a "D2a. Did the Officer blame you instead or said that you were at fault?"
	note d2a: "D2a. Did the Officer blame you instead or said that you were at fault?"
	label define d2a 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d2a d2a

	label variable d2b "D2b. Did the officer try to explain how you could have done things differently t"
	note d2b: "D2b. Did the officer try to explain how you could have done things differently to avoid the situation?"
	label define d2b 1 "Yes" 0 "No"
	label values d2b d2b

	label variable d2c "D2c. Did the officer blame you for not reporting the case earlier?"
	note d2c: "D2c. Did the officer blame you for not reporting the case earlier?"
	label define d2c 1 "Yes" 0 "No"
	label values d2c d2c

	label variable d2d "D2d. Did the Officer ask you unnecessary questions which were not relevant to th"
	note d2d: "D2d. Did the Officer ask you unnecessary questions which were not relevant to the case? Examples: 'what were you wearing?' or 'whom were you going with?' or 'why did you need to go outside?'"
	label define d2d 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d2d d2d

	label variable d3a "D3a. Did the officer believe in the truthfulness of your complaint?"
	note d3a: "D3a. Did the officer believe in the truthfulness of your complaint?"
	label define d3a 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d3a d3a

	label variable d4a "D4a. Did the officer tell you to visit a Mahila Thana for this case? (For female"
	note d4a: "D4a. Did the officer tell you to visit a Mahila Thana for this case? (For female decoy visits only)"
	label define d4a 1 "Yes" 0 "No"
	label values d4a d4a

	label variable d4b "D4b. Did the officer ask you to come back some other day to register the complai"
	note d4b: "D4b. Did the officer ask you to come back some other day to register the complaint?"
	label define d4b 1 "Yes" 0 "No"
	label values d4b d4b

	label variable d4c "D4c. Did the officer keep making different excuses instead of paying full attent"
	note d4c: "D4c. Did the officer keep making different excuses instead of paying full attention to the case?"
	label define d4c 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d4c d4c

	label variable d5a "D5a. Did the Officer appear to be dismissive towards your case?"
	note d5a: "D5a. Did the Officer appear to be dismissive towards your case?"
	label define d5a 1 "1" 2 "2" 3 "3" 4 "4" 5 "5"
	label values d5a d5a

	label variable d5b "D5b. Did the Officer pass any of the following remarks:"
	note d5b: "D5b. Did the Officer pass any of the following remarks:"

	label variable d6 "D6. Were you able observe any other female victims in the Police Station?"
	note d6: "D6. Were you able observe any other female victims in the Police Station?"
	label define d6 1 "Yes" 0 "No"
	label values d6 d6

	label variable d6a "D6a. If yes, how would you describe the behaviour of the Officers towards this v"
	note d6a: "D6a. If yes, how would you describe the behaviour of the Officers towards this victim?"
	label define d6a 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 0 "Could not observe properly"
	label values d6a d6a

	label variable d6b "D6b. Did the Officer exhibit empathy towards the victim or appeared to be concer"
	note d6b: "D6b. Did the Officer exhibit empathy towards the victim or appeared to be concerned about her well-being?"
	label define d6b 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 0 "Could not observe properly"
	label values d6b d6b

	label variable d6c "D6c. Did the police officer use any curses or foul language when speaking?"
	note d6c: "D6c. Did the police officer use any curses or foul language when speaking?"
	label define d6c 1 "Yes" 0 "No"
	label values d6c d6c

	label variable d6d "D6d. Did the Officer blame the victim or said that she were at fault?"
	note d6d: "D6d. Did the Officer blame the victim or said that she were at fault?"
	label define d6d 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 0 "Could not observe properly"
	label values d6d d6d

	label variable d6e "D6e. Did the officer ask her to come back some other day to register the complai"
	note d6e: "D6e. Did the officer ask her to come back some other day to register the complaint?"
	label define d6e 1 "Yes" 0 "No"
	label values d6e d6e

	label variable d6f "D6f. Did the officer believe in the truthfulness of the victim's complaint?"
	note d6f: "D6f. Did the officer believe in the truthfulness of the victim's complaint?"
	label define d6f 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 0 "Could not observe properly"
	label values d6f d6f

	label variable d6g "D6g. Did the Officer appear to be dismissive towards her case?"
	note d6g: "D6g. Did the Officer appear to be dismissive towards her case?"
	label define d6g 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 0 "Could not observe properly"
	label values d6g d6g

	label variable d6h "D6h. Did the Officer pass any of the following remarks:"
	note d6h: "D6h. Did the Officer pass any of the following remarks:"

	label variable q1 "Q1. What was your overall feeling after interacting with the Officer?"
	note q1: "Q1. What was your overall feeling after interacting with the Officer?"

	label variable q2 "Q2. Did the officer suspect you at any point? Narrate your experience as a decoy"
	note q2: "Q2. Did the officer suspect you at any point? Narrate your experience as a decoy here."

	label variable q3 "Q3. Describe your overall observations about the thana. (How were the other vict"
	note q3: "Q3. Describe your overall observations about the thana. (How were the other victims being treated? How were the facilities in the thana? How were the female constables being treated? Did you observe any misbehaviour?)"

	label variable q4 "Q4. Any special incident that you would like to talk about?"
	note q4: "Q4. Any special incident that you would like to talk about?"

	label variable q5 "Q5. How were the other victims being treated in the Police Station? In particula"
	note q5: "Q5. How were the other victims being treated in the Police Station? In particular, how was the behaviour of the Officers towards the female victims?"

	label variable comment "Any other comment"
	note comment: "Any other comment"






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
*   Corrections file path and filename:  C:/Users/dibbo/Dropbox/Debiasing Police in India/005-Data-and-analysis-2022/Decoy_2023/00.raw-data/Decoy Survey_corrections.csv
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
