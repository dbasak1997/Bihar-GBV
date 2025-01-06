/*==============================================================================
File Name: PSFS 2022 - Import do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	30/11/2022
Created by: Shubhro Bhattacharya
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Import Do file for the PSFS 2022. 

*	Inputs:  00.raw-data "PSFS_FacilityAssessment_V2_WIDE.csv"
*	Outputs: 02.intermediate-data "01.import-PSFS_intermediate.dta"

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

log using "$psfs_log_files\PSFS_import.log", replace text

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
local csvfile "PSFS_FacilityAssessment_V2_WIDE.csv"
local dtafile "PSFS_FacilityAssessment_V2.dta"
local corrfile "PSFS_FacilityAssessment_V2_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid uploadstamp var_comment p1 p2 p4 p6 p6_os intvar1 p6label p7 e3 instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"


disp
disp "Starting import of CSV File"
disp


* import data from primary .csv file
insheet using "$psfs_raw\PSFS_FacilityAssessment_V2_WIDE.csv", names clear

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


	label variable p3 "P3. Surveyor ID"
	note p3: "P3. Surveyor ID"
	label define p3 01 "Akash deep" 02 "Amit Kumar" 03 "Amit Kumar Shukla" 04 "Anshul Kumar" 05 "Anuj Kumar Pal" 27 "Arti Devi" 06 "Chandan Kumar Singh" 07 "Gyan Chand Ram" 08 "Jaswant Singh" 09 "JayKant Kumar" 10 "Kaushal Kumar" 12 "Nawal Kishore Prasad Sinha" 13 "Pappu Kumar" 28 "Prabhakar Kumar" 14 "Rajeev Kumar" 15 "Rajesh Kumar" 16 "Ranjeet Singh" 29 "Ranjeet Kumar Verma" 17 "Ratnaker Singh" 18 "Sarvesh Kumar Tiwari" 20 "Shailesh Kumar Singh" 21 "Sitesh Kumar" 22 "Sonu Kumar 1" 23 "Sonu Kumar 2" 24 "Sunny Kumar" 25 "Tribhuwan Kumar" 26 "Veerendra Singh" 30 "Vivek Kumar"
	label values p3 p3

	label variable p4 "P4. Survey location Note to surveyor: Please note down as accurate a location as"
	note p4: "P4. Survey location Note to surveyor: Please note down as accurate a location as possible (Example. PS Sadar, Vaishali)."

	label variable p5 "P5. Select the police district"
	note p5: "P5. Select the police district"
	label define p5 1000 "Arwal" 1001 "Bagaha" 1002 "Bettiah" 1003 "Bhojpur" 1004 "Gopalganj" 1005 "Motihari" 1006 "Muzaffarpur" 1007 "Nalanda" 1008 "Patna" 1009 "Saran" 1010 "Sitamarhi" 1011 "Siwan" 1012 "Vaishali"
	label values p5 p5

	label variable p6 "P6. Select the Police Station"
	note p6: "P6. Select the Police Station"

	label variable p6_os "P6. Select the Police Station: Others Specify"
	note p6_os: "P6. Select the Police Station: Others Specify"

	label variable p7 "P7. Name of Respondent"
	note p7: "P7. Name of Respondent"

	label variable p8 "P8. What is your current position in the Bihar Police? Instructions for the Enum"
	note p8: "P8. What is your current position in the Bihar Police? Instructions for the Enumerator: This survey should be answered by SHO rank police officers. If the SHO is not available, move on to the next-senior officer."
	label define p8 01 "Assistant Sub Inspector of Police (ASI)" 02 "Sub-Inspector of Police (SI)" 03 "Police Sub-Inspector (PSI - In training for Inspector)" 04 "Inspector of Police, but not SHO" 05 "Station Head Officer (SHO)" 06 "Constable (Munshi)" -666 "Refused to answer"
	label values p8 p8

	label variable p9 "P9. Do you confirm that you are stationed in \${p6label}?"
	note p9: "P9. Do you confirm that you are stationed in \${p6label}?"
	label define p9 1 "Yes" 0 "No"
	label values p9 p9

	label variable q901 "901. Is there a bathroom in the police station?"
	note q901: "901. Is there a bathroom in the police station?"
	label define q901 1 "Yes" 0 "No"
	label values q901 q901

	label variable q902 "902. Does the police station have separate bathrooms for men and women?"
	note q902: "902. Does the police station have separate bathrooms for men and women?"
	label define q902 1 "Yes" 0 "No"
	label values q902 q902

	label variable q903 "903. Is there a seperate room in the Police Station for reporting or hearing of "
	note q903: "903. Is there a seperate room in the Police Station for reporting or hearing of confidential complaints?"
	label define q903 1 "Yes" 0 "No"
	label values q903 q903

	label variable q903a "903a. Is this room also used for women's complaints to report case?"
	note q903a: "903a. Is this room also used for women's complaints to report case?"
	label define q903a 1 "Yes" 0 "No"
	label values q903a q903a

	label variable q904 "904. Is there electricity in the police station?"
	note q904: "904. Is there electricity in the police station?"
	label define q904 1 "Yes" 0 "No"
	label values q904 q904

	label variable q905a "905a. How many official four-wheeler patrol vehicles are available for the polic"
	note q905a: "905a. How many official four-wheeler patrol vehicles are available for the police station?"

	label variable q905b "905b. How many official two-wheelers patrol are available for the police station"
	note q905b: "905b. How many official two-wheelers patrol are available for the police station?"

	label variable q906 "906. How many functional computers are there in the police station?"
	note q906: "906. How many functional computers are there in the police station?"

	label variable q907 "907. Does the police station have a seating area for the complainants?"
	note q907: "907. Does the police station have a seating area for the complainants?"
	label define q907 1 "Yes" 0 "No"
	label values q907 q907

	label variable q908 "908. Is the police station cleaned regularly?"
	note q908: "908. Is the police station cleaned regularly?"
	label define q908 1 "Yes" 0 "No"
	label values q908 q908

	label variable q909 "909. Does the police station have a provision for drinking water?"
	note q909: "909. Does the police station have a provision for drinking water?"
	label define q909 1 "Yes" 0 "No"
	label values q909 q909

	label variable q910 "910. Is there a barrack in the police station?"
	note q910: "910. Is there a barrack in the police station?"
	label define q910 1 "Yes" 0 "No"
	label values q910 q910

	label variable q910a "910a. Are these different for women and men?"
	note q910a: "910a. Are these different for women and men?"
	label define q910a 1 "Yes" 0 "No"
	label values q910a q910a

	label variable q910b "910b. Are there sufficient number of barracks for all the constables posted in t"
	note q910b: "910b. Are there sufficient number of barracks for all the constables posted in the police station?"
	label define q910b 1 "Yes" 0 "No"
	label values q910b q910b

	label variable q911 "911. Does the police station have a place to safely store case files?"
	note q911: "911. Does the police station have a place to safely store case files?"
	label define q911 1 "Yes" 0 "No"
	label values q911 q911

	label variable q912 "912. Is there a place to safely keep sensitive evidence in the police station?"
	note q912: "912. Is there a place to safely keep sensitive evidence in the police station?"
	label define q912 1 "Yes" 0 "No"
	label values q912 q912

	label variable q913 "913. Does the police station have a functioning official phone number?"
	note q913: "913. Does the police station have a functioning official phone number?"
	label define q913 1 "Yes" 0 "No"
	label values q913 q913

	label variable q914a "914a. How many lockups are there in your police station?"
	note q914a: "914a. How many lockups are there in your police station?"

	label variable q914b "914b. Is there a separate lockup for women and men?"
	note q914b: "914b. Is there a separate lockup for women and men?"
	label define q914b 1 "Yes" 0 "No"
	label values q914b q914b

	label variable q915 "915. Is there a room in the police station for the victims to sleep if they have"
	note q915: "915. Is there a room in the police station for the victims to sleep if they have to stay overnight?"
	label define q915 1 "Yes" 0 "No"
	label values q915 q915

	label variable q915a "915a. Is there a separate room for female victims to sleep if they stay overnigh"
	note q915a: "915a. Is there a separate room for female victims to sleep if they stay overnight?"
	label define q915a 1 "Yes" 0 "No"
	label values q915a q915a

	label variable q916 "916. How many functional CCTV cameras are there in the police station?"
	note q916: "916. How many functional CCTV cameras are there in the police station?"

	label variable q916a "916a. Is there a proposal to install CCTV cameras in the police station?"
	note q916a: "916a. Is there a proposal to install CCTV cameras in the police station?"
	label define q916a 1 "Yes" 0 "No"
	label values q916a q916a

	label variable q917 "917. Please state the number of FIRs recorded by your police station in the last"
	note q917: "917. Please state the number of FIRs recorded by your police station in the last one year i.e. between January 1, 2021 and December 31, 2021"

	label variable q918a_male "Male"
	note q918a_male: "Male"

	label variable q918a_female "Female"
	note q918a_female: "Female"

	label variable q918a_total "Total"
	note q918a_total: "Total"

	label variable q918b_male "Male"
	note q918b_male: "Male"

	label variable q918b_female "Female"
	note q918b_female: "Female"

	label variable q918b_total "Total"
	note q918b_total: "Total"

	label variable q918c_male "Male"
	note q918c_male: "Male"

	label variable q918c_female "Female"
	note q918c_female: "Female"

	label variable q918c_total "Total"
	note q918c_total: "Total"

	label variable q918d_male "Male"
	note q918d_male: "Male"

	label variable q918d_female "Female"
	note q918d_female: "Female"

	label variable q918d_total "Total"
	note q918d_total: "Total"

	label variable q918e_male "Male"
	note q918e_male: "Male"

	label variable q918e_female "Female"
	note q918e_female: "Female"

	label variable q918e_total "Total"
	note q918e_total: "Total"

	label variable q918f_male "Male"
	note q918f_male: "Male"

	label variable q918f_female "Female"
	note q918f_female: "Female"

	label variable q918f_total "Total"
	note q918f_total: "Total"

	label variable q918g_male "Male"
	note q918g_male: "Male"

	label variable q918g_female "Female"
	note q918g_female: "Female"

	label variable q918g_total "Total"
	note q918g_total: "Total"

	label variable e1 "Survey End time"
	note e1: "Survey End time"

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
	save "$psfs_intermediate_dta\01.import-PSFS_intermediate.dta", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of CSV File"
disp
