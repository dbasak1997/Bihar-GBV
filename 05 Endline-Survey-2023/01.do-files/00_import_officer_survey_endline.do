/*==============================================================================
File Name: Endline Officer's Survey 2023 - Importing do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	19/09/2023
Created by: Dibyajyoti Basak
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Importing Do file for the Endline Officer's Survey 2023. 

*	Inputs:  00.raw-data "Officer Survey Endline Main_WIDE.csv" 
*	Outputs: 02.intermediate-data "01.import-officersurveybihar_intermediate.dta"

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

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "$MO_endline_raw/Officer Survey Endline Main_WIDE.csv"
local dtafile "$MO_endline_raw/Officer Survey Endline Main.dta"
local corrfile "$MO_endline_raw/Officer Survey Endline Main_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid uploadstamp var_comment a1 a2 a4 a5 a6 police_district_station a6label a7_el i1_name i1_phno marital_status key_baseline k5p1 k5p1_os k6p1"
local text_fields2 "k6p1_os po_new_station l1p1 l1p1_os l1p1_name l1p1_phno l1p1_marital l1p1_blkey a7 b0a_os b1 b2 b2text b3b b3b_os b3c b3d b3d_os b3h b3h_os b3i b3j b3j_os b5 b5a q102_os q107_village q109 q109_os"
local text_fields3 "q110_os q111filter q305a_os random_s8 s8name s8name_hindi random_dp random_dptext random_dptext_hindi networkroster_count networkid_* network_officer_name_* network_officer_name_os_* network_count"
local text_fields4 "ntwrkid1 ntwrkid2 ntwrkid3 ntwrkid4 ntwrkid5 hs1h_os hs5b_2 hs5b_os hs6b hs6b_os hs6d hs6d_os cs1 cs1_os cs4 cs8 cs8_os activityroster_count activitystart_calc_* activitycode_* activitycode_os_*"
local text_fields5 "actcount marital_bl refuse_talktowife wifename officeraddress wifephone wifealternate q106a comment instanceid instancename"
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


	label variable a3 "Surveyor ID"
	note a3: "Surveyor ID"
	label define a3 01 "Akash deep" 02 "Amit Kumar" 03 "Amit Kumar Shukla" 04 "Anshul Kumar" 05 "Anuj Kumar Pal" 27 "Arti Devi" 31 "Ashutosh Kumar" 06 "Chandan Kumar Singh" 32 "Devendra Singh" 33 "Guru Dayal Singh" 07 "Gyan Chand Ram" 08 "Jaswant Singh" 09 "JayKant Kumar" 10 "Kaushal Kumar" 34 "Manjesh Kumar" 35 "Navjeet Kumar" 12 "Nawal Kishore Prasad Sinha" 36 "Nityanand Pandey" 13 "Pappu Kumar" 28 "Prabhakar Kumar" 14 "Rajeev Kumar" 15 "Rajesh Kumar" 29 "Ranjeet Kumar Verma" 16 "Ranjeet Singh" 17 "Ratnaker Singh" 18 "Sarvesh Kumar Tiwari" 20 "Shailesh Kumar Singh" 21 "Sitesh Kumar" 22 "Sonu Kumar 1" 23 "Sonu Kumar 2" 37 "Sudhir Kumar Dixit" 24 "Sunny Kumar" 25 "Tribhuwan Kumar" 26 "Veerendra Singh" 38 "Vikas Ranjan" 30 "Vivek Kumar" 39 "Vivek Singh" 40 "Anil Kumar" 41 "Suraj Kumar" 42 "Navjeet Kumar" 43 "Ajay Kumar" 44 "Amar Kant" 45 "Chandra Bhushan Kumar" 46 "Dharmendra Pandey" 47 "Mithlesh Pandey" 48 "Shashi kant Singh" 49 "Tej Pratap" 50 "Jitendra Kumar" 51 "Upendra Kumar" 52 "Chandan Kumar" 53 "Rajesh Kumar" 54 "Indresh Kumar" 55 "Ramchandra Rahi" 56 "Avinash Kumar" 57 "Sunil Kumar Yadav" 58 "Nirmal Kumar Singh"
	label values a3 a3

	label variable a4 "A4. Survey location Note to surveyor: Please note down as accurate a location as"
	note a4: "A4. Survey location Note to surveyor: Please note down as accurate a location as possible (Example. PS Sadar, Vaishali)."

	label variable a5 "A5. Select the police district"
	note a5: "A5. Select the police district"

	label variable a6 "A6. Select the Police Station"
	note a6: "A6. Select the Police Station"

	label variable a7_el "A7. Officer Unique ID"
	note a7_el: "A7. Officer Unique ID"

	label variable k5p1 "In which other district you were posted from 8th September to today?"
	note k5p1: "In which other district you were posted from 8th September to today?"

	label variable k5p1_os "In which other district you were posted from 8th September to today?: Others Spe"
	note k5p1_os: "In which other district you were posted from 8th September to today?: Others Specify"

	label variable k6p1 "In which other Police Station you were posted from 8th September to today?"
	note k6p1: "In which other Police Station you were posted from 8th September to today?"

	label variable k6p1_os "In which other Police Station you were posted from 8th September to today?: Othe"
	note k6p1_os: "In which other Police Station you were posted from 8th September to today?: Others Specify"

	label variable l1p1 "Name of Respondent"
	note l1p1: "Name of Respondent"

	label variable l1p1_os "Name of Respondent"
	note l1p1_os: "Name of Respondent"

	label variable b0 "B0. Do you agree to participate in this interview? Instructions for the enumerat"
	note b0: "B0. Do you agree to participate in this interview? Instructions for the enumerator: If the respondent does not provide consent, proceed to B0a and end the survey. Proceed to the next questions starting from B1 only if the answer to this question is Yes."
	label define b0 1 "Yes" 0 "No"
	label values b0 b0

	label variable b0a "B0a. If No, what are your reasons to not participate in this survey?"
	note b0a: "B0a. If No, what are your reasons to not participate in this survey?"
	label define b0a 1 "Too busy with work and do not have much time" 2 "Doesn’t think this is an important exercise" 3 "Has privacy issues" 4 "Scared about action being taken against the officer for the answers given during" -888 "Others Specify"
	label values b0a b0a

	label variable b1 "B1. Name of Respondent"
	note b1: "B1. Name of Respondent"

	label variable b2_el "B2. Sir, please confirm if \${b2text} is your current position in the Bihar Poli"
	note b2_el: "B2. Sir, please confirm if \${b2text} is your current position in the Bihar Police. Instructions for the Enumerator: Please confirm that the prefill rank is correct. If the rank reported by the officer is different from the pre-fill, please record it in the next question. This Survey should be administered only to the ASI, SI, Inspector and SHO rank Police Officers. If the respondent does not belong to any of the above categories, this survey should not be continued."
	label define b2_el 1 "Yes" 0 "No"
	label values b2_el b2_el

	label variable b2a "B2a. What is your current rank in the Bihar Police?"
	note b2a: "B2a. What is your current rank in the Bihar Police?"
	label define b2a 1 "Assistant Sub Inspector of Police (ASI)" 2 "Sub-Inspector of Police (SI)" 3 "Police Sub-Inspector (PSI - In training for Inspector)" 4 "Inspector of Police, but not SHO" 5 "Station Head Officer (SHO)" -666 "Refused to answer"
	label values b2a b2a

	label variable b3 "B3. Do you confirm that you are stationed in \${a6label}?"
	note b3: "B3. Do you confirm that you are stationed in \${a6label}?"
	label define b3 1 "Yes" 0 "No"
	label values b3 b3

	label variable b3a "B3a. If no, where is your current posting?"
	note b3a: "B3a. If no, where is your current posting?"
	label define b3a 1 "Within the same district" 2 "To a different district" -888 "Others Specify"
	label values b3a b3a

	label variable b3b "B3b. please state station"
	note b3b: "B3b. please state station"

	label variable b3c "B3c. please select district"
	note b3c: "B3c. please select district"

	label variable b3d "B3d. please state station"
	note b3d: "B3d. please state station"

	label variable b3f "B3f. In the past 3 months have you been transferred?"
	note b3f: "B3f. In the past 3 months have you been transferred?"
	label define b3f 1 "Yes" 0 "No"
	label values b3f b3f

	label variable b3g "B3g. If yes, where was your previous posting?"
	note b3g: "B3g. If yes, where was your previous posting?"
	label define b3g 1 "Within the same district" 2 "To a different district" -888 "Others Specify"
	label values b3g b3g

	label variable b3h "B3h. please state station"
	note b3h: "B3h. please state station"

	label variable b3i "B3i. please select district"
	note b3i: "B3i. please select district"

	label variable b3j "B3j. please state station"
	note b3j: "B3j. please state station"

	label variable b5 "B5. Mobile number of respondents Instruction: Move to B2a if the respondent does"
	note b5: "B5. Mobile number of respondents Instruction: Move to B2a if the respondent does not have a contact number."

	label variable b5a "B5a. Alternative contact number (if applicable) Instruction: If the respondent d"
	note b5a: "B5a. Alternative contact number (if applicable) Instruction: If the respondent does not have a contact number in the previous question, ask if they can provide the contact details of a close relative or a friend that we can reach later on."

	label variable q101 "101. What is your Age? (In years)"
	note q101: "101. What is your Age? (In years)"

	label variable q102 "102. What is the highest level of education you received?"
	note q102: "102. What is the highest level of education you received?"
	label define q102 1 "10th" 2 "Plus 2" 3 "Diploma after Plus 2" 4 "Started college, did not complete/currently attending" 5 "College completed (B.A)" 6 "Post Graduate (M.A.)" -888 "Others Specify"
	label values q102 q102

	label variable q102_os "102. What is the highest level of education you received?: Others Specify"
	note q102_os: "102. What is the highest level of education you received?: Others Specify"

	label variable q105_years "YEARS"
	note q105_years: "YEARS"

	label variable q105_months "Months"
	note q105_months: "Months"

	label variable q105a_years "YEARS"
	note q105a_years: "YEARS"

	label variable q105a_months "Months"
	note q105a_months: "Months"

	label variable q107_state "State"
	note q107_state: "State"
	label define q107_state 1 "Andaman Nicobar" 2 "Andhra Pradesh" 3 "Arunachal Pradesh" 4 "Assam" 5 "Bihar" 6 "Chandigarh" 7 "Chhattisgarh" 8 "Dadra Nagar Haveli" 9 "Daman Diu" 10 "Delhi" 11 "Goa" 12 "Gujarat" 13 "Haryana" 14 "Himachal Pradesh" 15 "Jammu Kashmir" 16 "Jharkhand" 17 "Karnataka" 18 "Kerala" 19 "Lakshadweep" 20 "Ladakh" 21 "Madhya Pradesh" 22 "Maharashtra" 23 "Manipur" 24 "Meghalaya" 25 "Mizoram" 26 "Nagaland" 27 "Odisha" 28 "Puducherry" 29 "Punjab" 30 "Rajasthan" 31 "Sikkim" 32 "Tamil Nadu" 33 "Telangana" 34 "Tripura" 35 "Uttar Pradesh" 36 "Uttarakhand" 37 "West Bengal"
	label values q107_state q107_state

	label variable q107_district "District"
	note q107_district: "District"
	label define q107_district 1 "Nicobar" 2 "North Middle Andaman" 3 "South Andaman" 4 "Anantapur" 5 "Chittoor" 6 "East Godavari" 7 "Guntur" 8 "Kadapa" 9 "Krishna" 10 "Kurnool" 11 "Nellore" 12 "Prakasam" 13 "Srikakulam" 14 "Visakhapatnam" 15 "Vizianagaram" 16 "West Godavari" 17 "Anjaw" 18 "Central Siang" 19 "Changlang" 20 "Dibang Valley" 21 "East Kameng" 22 "East Siang" 23 "Kamle" 24 "Kra Daadi" 25 "Kurung Kumey" 26 "Lepa Rada" 27 "Lohit" 28 "Longding" 29 "Lower Dibang Valley" 30 "Lower Siang" 31 "Lower Subansiri" 32 "Namsai" 33 "Pakke Kessang" 34 "Papum Pare" 35 "Shi Yomi" 36 "Tawang" 37 "Tirap" 38 "Upper Siang" 39 "Upper Subansiri" 40 "West Kameng" 41 "West Siang" 42 "Bajali" 43 "Baksa" 44 "Barpeta" 45 "Biswanath" 46 "Bongaigaon" 47 "Cachar" 48 "Charaideo" 49 "Chirang" 50 "Darrang" 51 "Dhemaji" 52 "Dhubri" 53 "Dibrugarh" 54 "Dima Hasao" 55 "Goalpara" 56 "Golaghat" 57 "Hailakandi" 58 "Hojai" 59 "Jorhat" 60 "Kamrup" 61 "Kamrup Metropolitan" 62 "Karbi Anglong" 63 "Karimganj" 64 "Kokrajhar" 65 "Lakhimpur" 66 "Majuli" 67 "Morigaon" 68 "Nagaon" 69 "Nalbari" 70 "Sivasagar" 71 "Sonitpur" 72 "South Salmara-Mankachar" 73 "Tinsukia" 74 "Udalguri" 75 "West Karbi Anglong" 76 "Araria" 77 "Arwal" 78 "Aurangabad" 79 "Banka" 80 "Begusarai" 81 "Bhagalpur" 82 "Bhojpur" 83 "Buxar" 84 "Darbhanga" 85 "East Champaran" 86 "Gaya" 87 "Gopalganj" 88 "Jamui" 89 "Jehanabad" 90 "Kaimur" 91 "Katihar" 92 "Khagaria" 93 "Kishanganj" 94 "Lakhisarai" 95 "Madhepura" 96 "Madhubani" 97 "Munger" 98 "Muzaffarpur" 99 "Nalanda" 100 "Nawada" 101 "Patna" 102 "Purnia" 103 "Rohtas" 104 "Saharsa" 105 "Samastipur" 106 "Saran" 107 "Sheikhpura" 108 "Sheohar" 109 "Sitamarhi" 110 "Siwan" 111 "Supaul" 112 "Vaishali" 113 "West Champaran" 114 "Chandigarh" 115 "Balod" 116 "Baloda Bazar" 117 "Balrampur" 118 "Bastar" 119 "Bemetara" 120 "Bijapur" 121 "Bilaspur" 122 "Dantewada" 123 "Dhamtari" 124 "Durg" 125 "Gariaband" 126 "Gaurela Pendra Marwahi" 127 "Janjgir Champa" 128 "Jashpur" 129 "Kabirdham" 130 "Kanker" 131 "Kondagaon" 132 "Korba" 133 "Koriya" 134 "Mahasamund" 135 "Mungeli" 136 "Narayanpur" 137 "Raigarh" 138 "Raipur" 139 "Rajnandgaon" 140 "Sukma" 141 "Surajpur" 142 "Surguja" 143 "Dadra Nagar Haveli" 144 "Daman" 145 "Diu" 146 "Central Delhi" 147 "East Delhi" 148 "New Delhi" 149 "North Delhi" 150 "North East Delhi" 151 "North West Delhi" 152 "Shahdara" 153 "South Delhi" 154 "South East Delhi" 155 "South West Delhi" 156 "West Delhi" 157 "North Goa" 158 "South Goa" 159 "Ahmedabad" 160 "Amreli" 161 "Anand" 162 "Aravalli" 163 "Banaskantha" 164 "Bharuch" 165 "Bhavnagar" 166 "Botad" 167 "Chhota Udaipur" 168 "Dahod" 169 "Dang" 170 "Devbhoomi Dwarka" 171 "Gandhinagar" 172 "Gir Somnath" 173 "Jamnagar" 174 "Junagadh" 175 "Kheda" 176 "Kutch" 177 "Mahisagar" 178 "Mehsana" 179 "Morbi" 180 "Narmada" 181 "Navsari" 182 "Panchmahal" 183 "Patan" 184 "Porbandar" 185 "Rajkot" 186 "Sabarkantha" 187 "Surat" 188 "Surendranagar" 189 "Tapi" 190 "Vadodara" 191 "Valsad" 192 "Ambala" 193 "Bhiwani" 194 "Charkhi Dadri" 195 "Faridabad" 196 "Fatehabad" 197 "Gurugram" 198 "Hisar" 199 "Jhajjar" 200 "Jind" 201 "Kaithal" 202 "Karnal" 203 "Kurukshetra" 204 "Mahendragarh" 205 "Mewat" 206 "Palwal" 207 "Panchkula" 208 "Panipat" 209 "Rewari" 210 "Rohtak" 211 "Sirsa" 212 "Sonipat" 213 "Yamunanagar" 214 "Bilaspur" 215 "Chamba" 216 "Hamirpur" 217 "Kangra" 218 "Kinnaur" 219 "Kullu" 220 "Lahaul Spiti" 221 "Mandi" 222 "Shimla" 223 "Sirmaur" 224 "Solan" 225 "Una" 226 "Anantnag" 227 "Bandipora" 228 "Baramulla" 229 "Budgam" 230 "Doda" 231 "Ganderbal" 232 "Jammu" 233 "Kathua" 234 "Kishtwar" 235 "Kulgam" 236 "Kupwara" 237 "Poonch" 238 "Pulwama" 239 "Rajouri" 240 "Ramban" 241 "Reasi" 242 "Samba" 243 "Shopian" 244 "Srinagar" 245 "Udhampur" 246 "Bokaro" 247 "Chatra" 248 "Deoghar" 249 "Dhanbad" 250 "Dumka" 251 "East Singhbhum" 252 "Garhwa" 253 "Giridih" 254 "Godda" 255 "Gumla" 256 "Hazaribagh" 257 "Jamtara" 258 "Khunti" 259 "Koderma" 260 "Latehar" 261 "Lohardaga" 262 "Pakur" 263 "Palamu" 264 "Ramgarh" 265 "Ranchi" 266 "Sahebganj" 267 "Seraikela Kharsawan" 268 "Simdega" 269 "West Singhbhum" 270 "Bagalkot" 271 "Bangalore Rural" 272 "Bangalore Urban" 273 "Belgaum" 274 "Bellary" 275 "Bidar" 276 "Chamarajanagar" 277 "Chikkaballapur" 278 "Chikkamagaluru" 279 "Chitradurga" 280 "Dakshina Kannada" 281 "Davanagere" 282 "Dharwad" 283 "Gadag" 284 "Gulbarga" 285 "Hassan" 286 "Haveri" 287 "Kodagu" 288 "Kolar" 289 "Koppal" 290 "Mandya" 291 "Mysore" 292 "Raichur" 293 "Ramanagara" 294 "Shimoga" 295 "Tumkur" 296 "Udupi" 297 "Uttara Kannada" 298 "Vijayapura" 299 "Yadgir" 300 "Alappuzha" 301 "Ernakulam" 302 "Idukki" 303 "Kannur" 304 "Kasaragod" 305 "Kollam" 306 "Kottayam" 307 "Kozhikode" 308 "Malappuram" 309 "Palakkad" 310 "Pathanamthitta" 311 "Thiruvananthapuram" 312 "Thrissur" 313 "Wayanad" 314 "Lakshadweep" 315 "Kargil" 316 "Leh" 317 "Agar Malwa" 318 "Alirajpur" 319 "Anuppur" 320 "Ashoknagar" 321 "Balaghat" 322 "Barwani" 323 "Betul" 324 "Bhind" 325 "Bhopal" 326 "Burhanpur" 327 "Chachaura" 328 "Chhatarpur" 329 "Chhindwara" 330 "Damoh" 331 "Datia" 332 "Dewas" 333 "Dhar" 334 "Dindori" 335 "Guna" 336 "Gwalior" 337 "Harda" 338 "Hoshangabad" 339 "Indore" 340 "Jabalpur" 341 "Jhabua" 342 "Katni" 343 "Khandwa" 344 "Khargone" 345 "Maihar" 346 "Mandla" 347 "Mandsaur" 348 "Morena" 349 "Narsinghpur" 350 "Nagda" 351 "Neemuch" 352 "Niwari" 353 "Panna" 354 "Raisen" 355 "Rajgarh" 356 "Ratlam" 357 "Rewa" 358 "Sagar" 359 "Satna" 360 "Sehore" 361 "Seoni" 362 "Shahdol" 363 "Shajapur" 364 "Sheopur" 365 "Shivpuri" 366 "Sidhi" 367 "Singrauli" 368 "Tikamgarh" 369 "Ujjain" 370 "Umaria" 371 "Vidisha" 372 "Ahmednagar" 373 "Akola" 374 "Amravati" 375 "Aurangabad" 376 "Beed" 377 "Bhandara" 378 "Buldhana" 379 "Chandrapur" 380 "Dhule" 381 "Gadchiroli" 382 "Gondia" 383 "Hingoli" 384 "Jalgaon" 385 "Jalna" 386 "Kolhapur" 387 "Latur" 388 "Mumbai City" 389 "Mumbai Suburban" 390 "Nagpur" 391 "Nanded" 392 "Nandurbar" 393 "Nashik" 394 "Osmanabad" 395 "Palghar" 396 "Parbhani" 397 "Pune" 398 "Raigad" 399 "Ratnagiri" 400 "Sangli" 401 "Satara" 402 "Sindhudurg" 403 "Solapur" 404 "Thane" 405 "Wardha" 406 "Washim" 407 "Yavatmal" 408 "Bishnupur" 409 "Chandel" 410 "Churachandpur" 411 "Imphal East" 412 "Imphal West" 413 "Jiribam" 414 "Kakching" 415 "Kamjong" 416 "Kangpokpi" 417 "Noney" 418 "Pherzawl" 419 "Senapati" 420 "Tamenglong" 421 "Tengnoupal" 422 "Thoubal" 423 "Ukhrul" 424 "East Garo Hills" 425 "East Jaintia Hills" 426 "East Khasi Hills" 427 "North Garo Hills" 428 "Ri Bhoi" 429 "South Garo Hills" 430 "South West Garo Hills" 431 "South West Khasi Hills" 432 "West Garo Hills" 433 "West Jaintia Hills" 434 "West Khasi Hills" 435 "Aizawl" 436 "Champhai" 437 "Hnahthial" 438 "Kolasib" 439 "Khawzawl" 440 "Lawngtlai" 441 "Lunglei" 442 "Mamit" 443 "Saiha" 444 "Serchhip" 445 "Saitual" 446 "Mon" 447 "Dimapur" 448 "Kiphire" 449 "Kohima" 450 "Longleng" 451 "Mokokchung" 452 "Noklak" 453 "Peren" 454 "Phek" 455 "Tuensang" 456 "Wokha" 457 "Zunheboto" 458 "Angul" 459 "Balangir" 460 "Balasore" 461 "Bargarh" 462 "Bhadrak" 463 "Boudh" 464 "Cuttack" 465 "Debagarh" 466 "Dhenkanal" 467 "Gajapati" 468 "Ganjam" 469 "Jagatsinghpur" 470 "Jajpur" 471 "Jharsuguda" 472 "Kalahandi" 473 "Kandhamal" 474 "Kendrapara" 475 "Kendujhar" 476 "Khordha" 477 "Koraput" 478 "Malkangiri" 479 "Mayurbhanj" 480 "Nabarangpur" 481 "Nayagarh" 482 "Nuapada" 483 "Puri" 484 "Rayagada" 485 "Sambalpur" 486 "Subarnapur" 487 "Sundergarh" 488 "Karaikal" 489 "Mahe" 490 "Puducherry" 491 "Yanam" 492 "Amritsar" 493 "Barnala" 494 "Bathinda" 495 "Faridkot" 496 "Fatehgarh Sahib" 497 "Fazilka" 498 "Firozpur" 499 "Gurdaspur" 500 "Hoshiarpur" 501 "Jalandhar" 502 "Kapurthala" 503 "Ludhiana" 504 "Mansa" 505 "Moga" 506 "Mohali" 507 "Muktsar" 508 "Pathankot" 509 "Patiala" 510 "Rupnagar" 511 "Sangrur" 512 "Shaheed Bhagat Singh Nagar" 513 "Tarn Taran" 514 "Ajmer" 515 "Alwar" 516 "Banswara" 517 "Baran" 518 "Barmer" 519 "Bharatpur" 520 "Bhilwara" 521 "Bikaner" 522 "Bundi" 523 "Chittorgarh" 524 "Churu" 525 "Dausa" 526 "Dholpur" 527 "Dungarpur" 528 "Hanumangarh" 529 "Jaipur" 530 "Jaisalmer" 531 "Jalore" 532 "Jhalawar" 533 "Jhunjhunu" 534 "Jodhpur" 535 "Karauli" 536 "Kota" 537 "Nagaur" 538 "Pali" 539 "Pratapgarh" 540 "Rajsamand" 541 "Sawai Madhopur" 542 "Sikar" 543 "Sirohi" 544 "Sri Ganganagar" 545 "Tonk" 546 "Udaipur" 547 "East Sikkim" 548 "North Sikkim" 549 "South Sikkim" 550 "West Sikkim" 551 "Ariyalur" 552 "Chengalpattu" 553 "Chennai" 554 "Coimbatore" 555 "Cuddalore" 556 "Dharmapuri" 557 "Dindigul" 558 "Erode" 559 "Kallakurichi" 560 "Kanchipuram" 561 "Kanyakumari" 562 "Karur" 563 "Krishnagiri" 564 "Madurai" 565 "Mayiladuthurai" 566 "Nagapattinam" 567 "Namakkal" 568 "Nilgiris" 569 "Perambalur" 570 "Pudukkottai" 571 "Ramanathapuram" 572 "Ranipet" 573 "Salem" 574 "Sivaganga" 575 "Tenkasi" 576 "Thanjavur" 577 "Theni" 578 "Thoothukudi" 579 "Tiruchirappalli" 580 "Tirunelveli" 581 "Tirupattur" 582 "Tiruppur" 583 "Tiruvallur" 584 "Tiruvannamalai" 585 "Tiruvarur" 586 "Vellore" 587 "Viluppuram" 588 "Virudhunagar" 589 "Adilabad" 590 "Bhadradri Kothagudem" 591 "Hyderabad" 592 "Jagtial" 593 "Jangaon" 594 "Jayashankar" 595 "Jogulamba" 596 "Kamareddy" 597 "Karimnagar" 598 "Khammam" 599 "Komaram Bheem" 600 "Mahabubabad" 601 "Mahbubnagar" 602 "Mancherial" 603 "Medak" 604 "Medchal" 605 "Mulugu" 606 "Nagarkurnool" 607 "Nalgonda" 608 "Narayanpet" 609 "Nirmal" 610 "Nizamabad" 611 "Peddapalli" 612 "Rajanna Sircilla" 613 "Ranga Reddy" 614 "Sangareddy" 615 "Siddipet" 616 "Suryapet" 617 "Vikarabad" 618 "Wanaparthy" 619 "Warangal Rural" 620 "Warangal Urban" 621 "Yadadri Bhuvanagiri" 622 "Dhalai" 623 "Gomati" 624 "Khowai" 625 "North Tripura" 626 "Sepahijala" 627 "South Tripura" 628 "Unakoti" 629 "West Tripura" 630 "Agra" 631 "Aligarh" 632 "Ambedkar Nagar" 633 "Amethi" 634 "Amroha" 635 "Auraiya" 636 "Ayodhya" 637 "Azamgarh" 638 "Baghpat" 639 "Bahraich" 640 "Ballia" 641 "Balrampur" 642 "Banda" 643 "Barabanki" 644 "Bareilly" 645 "Basti" 646 "Bhadohi" 647 "Bijnor" 648 "Budaun" 649 "Bulandshahr" 650 "Chandauli" 651 "Chitrakoot" 652 "Deoria" 653 "Etah" 654 "Etawah" 655 "Farrukhabad" 656 "Fatehpur" 657 "Firozabad" 658 "Gautam Buddha Nagar" 659 "Ghaziabad" 660 "Ghazipur" 661 "Gonda" 662 "Gorakhpur" 663 "Hamirpur" 664 "Hapur" 665 "Hardoi" 666 "Hathras" 667 "Jalaun" 668 "Jaunpur" 669 "Jhansi" 670 "Kannauj" 671 "Kanpur Dehat" 672 "Kanpur Nagar" 673 "Kasganj" 674 "Kaushambi" 675 "Kheri" 676 "Kushinagar" 677 "Lalitpur" 678 "Lucknow" 679 "Maharajganj" 680 "Mahoba" 681 "Mainpuri" 682 "Mathura" 683 "Mau" 684 "Meerut" 685 "Mirzapur" 686 "Moradabad" 687 "Muzaffarnagar" 688 "Pilibhit" 689 "Pratapgarh" 690 "Prayagraj" 691 "Raebareli" 692 "Rampur" 693 "Saharanpur" 694 "Sambhal" 695 "Sant Kabir Nagar" 696 "Shahjahanpur" 697 "Shamli" 698 "Shravasti" 699 "Siddharthnagar" 700 "Sitapur" 701 "Sonbhadra" 702 "Sultanpur" 703 "Unnao" 704 "Varanasi" 705 "Almora" 706 "Bageshwar" 707 "Chamoli" 708 "Champawat" 709 "Dehradun" 710 "Haridwar" 711 "Nainital" 712 "Pauri" 713 "Pithoragarh" 714 "Rudraprayag" 715 "Tehri" 716 "Udham Singh Nagar" 717 "Uttarkashi" 718 "Alipurduar" 719 "Bankura" 720 "Birbhum" 721 "Cooch Behar" 722 "Dakshin Dinajpur" 723 "Darjeeling" 724 "Hooghly" 725 "Howrah" 726 "Jalpaiguri" 727 "Jhargram" 728 "Kalimpong" 729 "Kolkata" 730 "Malda" 731 "Murshidabad" 732 "Nadia" 733 "North 24 Parganas" 734 "Paschim Bardhaman" 735 "Paschim Medinipur" 736 "Purba Bardhaman" 737 "Purba Medinipur" 738 "Purulia" 739 "South 24 Parganas" 740 "Uttar Dinajpur"
	label values q107_district q107_district

	label variable q107_village "Village/City"
	note q107_village: "Village/City"

	label variable q108 "108. On induction, you must have undergone a basic training. How long ago did yo"
	note q108: "108. On induction, you must have undergone a basic training. How long ago did you last receive any additional training other than basic police training? Surveyor instructions: Please make it clear to ask the details only about the last training session attended by the Police Officer"
	label define q108 1 "Never had an additional training" 2 "Within the past 1 month" 3 "Within the past 1 year" 4 "Within the last 5 years" 5 "Between 5-10 years" 6 "More than 10 years ago" -666 "Refuse to answer" -999 "Do not know"
	label values q108 q108

	label variable q109 "109. What was the topic of this training? Enumerator Prompt:Do not read options "
	note q109: "109. What was the topic of this training? Enumerator Prompt:Do not read options out loud. Select all that apply"

	label variable q109_os "109. What was the topic of this training?: Others Specify"
	note q109_os: "109. What was the topic of this training?: Others Specify"

	label variable q110 "110. Who conducted this training?"
	note q110: "110. Who conducted this training?"
	label define q110 1 "Bihar Police" 2 "Other State Police training center (please specify name of state)" 3 "NGO" -888 "Others Specify"
	label values q110 q110

	label variable q110_policeaca_oth "Other State Police training center (please specify name of state)"
	note q110_policeaca_oth: "Other State Police training center (please specify name of state)"
	label define q110_policeaca_oth 1 "Andaman Nicobar" 2 "Andhra Pradesh" 3 "Arunachal Pradesh" 4 "Assam" 5 "Bihar" 6 "Chandigarh" 7 "Chhattisgarh" 8 "Dadra Nagar Haveli" 9 "Daman Diu" 10 "Delhi" 11 "Goa" 12 "Gujarat" 13 "Haryana" 14 "Himachal Pradesh" 15 "Jammu Kashmir" 16 "Jharkhand" 17 "Karnataka" 18 "Kerala" 19 "Lakshadweep" 20 "Ladakh" 21 "Madhya Pradesh" 22 "Maharashtra" 23 "Manipur" 24 "Meghalaya" 25 "Mizoram" 26 "Nagaland" 27 "Odisha" 28 "Puducherry" 29 "Punjab" 30 "Rajasthan" 31 "Sikkim" 32 "Tamil Nadu" 33 "Telangana" 34 "Tripura" 35 "Uttar Pradesh" 36 "Uttarakhand" 37 "West Bengal"
	label values q110_policeaca_oth q110_policeaca_oth

	label variable q110_os "Others Specify"
	note q110_os: "Others Specify"

	label variable q111_unit "Unit"
	note q111_unit: "Unit"
	label define q111_unit 1 "Days" 2 "Weeks" 3 "Months"
	label values q111_unit q111_unit

	label variable q111 "111. How long did this training last?"
	note q111: "111. How long did this training last?"

	label variable q201a "201a. The Woman Does not report to the Police because, the police cannot help he"
	note q201a: "201a. The Woman Does not report to the Police because, the police cannot help her and it is an internal matter between the husband and the wife"
	label define q201a 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q201a q201a

	label variable q201b "201b. The Woman Does not report to the Police because, such incidents are very c"
	note q201b: "201b. The Woman Does not report to the Police because, such incidents are very common and happen too often"
	label define q201b 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q201b q201b

	label variable q201c "201c. The Woman Does not report to the Police because, She fears being beaten up"
	note q201c: "201c. The Woman Does not report to the Police because, She fears being beaten up by her husband again if she reports to the police"
	label define q201c 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q201c q201c

	label variable q202a "q202a. It is justified for a husband to hit his wife, if she goes out without te"
	note q202a: "q202a. It is justified for a husband to hit his wife, if she goes out without telling him."
	label define q202a 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q202a q202a

	label variable q202b "q202b. It is justified for a husband to hit his wife if she neglects the childre"
	note q202b: "q202b. It is justified for a husband to hit his wife if she neglects the children"
	label define q202b 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q202b q202b

	label variable q202c "q202c. It is justified for a husband to hit his wife if she burns the food"
	note q202c: "q202c. It is justified for a husband to hit his wife if she burns the food"
	label define q202c 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q202c q202c

	label variable q202d "q202d. It is justified for a husband to hit his wife if she argues with the husb"
	note q202d: "q202d. It is justified for a husband to hit his wife if she argues with the husband"
	label define q202d 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q202d q202d

	label variable q202e "q202e. It is justified for a husband to hit his wife if she refuses to have sex "
	note q202e: "q202e. It is justified for a husband to hit his wife if she refuses to have sex with the husband"
	label define q202e 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q202e q202e

	label variable q301 "301. A woman was walking home alone late at night when she was approached by a g"
	note q301: "301. A woman was walking home alone late at night when she was approached by a group of men. The men started making inappropriate comments and advances towards her. When the woman resisted, the men became violent and assaulted her. The victim's sister, who witnessed the incident, goes to the police station to file a complaint on her behalf. Can the sister file the complaint on the victim's behalf? Enumerator prompt: Read options aloud"
	label define q301 1 "Yes, the sister can file a complaint on behalf of the victim in cases like these" 2 "No, only the victim herself can file a complaint." 3 "Yes, but the complaint will not be considered valid unless the victim also gives" 4 "No, the police do not accept complaints filed by relatives of the victim." -666 "Refused to answer" -999 "Do not know"
	label values q301 q301

	label variable q302 "302. A woman from a nearby village accuses a man of forcing her to have sex with"
	note q302: "302. A woman from a nearby village accuses a man of forcing her to have sex with him while she was on her way back home alone. She visits the police station to seek help. She approaches you and says, 'I have been raped. Please help me to file a complaint.' With whom does the burden of proof lie? Enumerator prompt: Read options aloud"
	label define q302 1 "Burden of proof lies with the accused." 2 "Burden of proof lies with victim" 3 "Depends on case to case" 4 "Burden of proof lies with the police" -666 "Refuse to answer" -999 "Do not know"
	label values q302 q302

	label variable q303 "303. If a married woman is evicted from her ‘matrimonial house’ but has not been"
	note q303: "303. If a married woman is evicted from her ‘matrimonial house’ but has not been subjected to any other physical abuse, does that constitute domestic violence? Enumerator prompt: Read options aloud"
	label define q303 1 "Yes, it is a case of domestic violence because the woman is being subjected to e" 2 "No, it is not a case of domestic violence as she has not been subjected to physi" 3 "It cannot be determined whether it is a case of domestic violence or not." -666 "Refuse to answer" -999 "Do not know"
	label values q303 q303

	label variable q304 "304. A female victim says she does not feel safe at her home and wants the polic"
	note q304: "304. A female victim says she does not feel safe at her home and wants the police to assist her in finding shelter. Can the police assist with this? Enumerator prompt: Read options aloud"
	label define q304 1 "Yes, the police can assist the victim in finding shelter" 2 "The victim must wait in the Police Station itself and will be accompanied by a f" 3 "No, the Police cannot help in this case" -666 "Refuse to answer" -999 "Do not know"
	label values q304 q304

	label variable q305 "305. A woman accuses a man who is an acquaintance for having verbally abused her"
	note q305: "305. A woman accuses a man who is an acquaintance for having verbally abused her in a marketplace. Is this a chargeable offense?"
	label define q305 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q305 q305

	label variable q305a "305a. If yes, under what section of the IPC will you book him? Enumerator prompt"
	note q305a: "305a. If yes, under what section of the IPC will you book him? Enumerator prompt: Read options aloud"
	label define q305a 1 "IPC Section 402" 2 "IPC Section 317" 3 "IPC Section 509" 4 "IPC Section 310" 5 "IPC Section 354" -888 "Others Specify" -666 "Refuse to answer" -999 "Do not know"
	label values q305a q305a

	label variable q306 "306. A police officer you work with has released information about a sexual abus"
	note q306: "306. A police officer you work with has released information about a sexual abuse victim to the media. Is this a chargeable offense?"
	label define q306 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q306 q306

	label variable q306a "306a. will you book him? If yes, under which section of the IPC shall you book h"
	note q306a: "306a. will you book him? If yes, under which section of the IPC shall you book him? Enumerator prompt: read options aloud"
	label define q306a 1 "I shall let him get away with a warning and not book him/her." 2 "Book him/her under IPC Section 219a" 3 "Book him/her under IPC Section 228a." 4 "Book him/her under IPC Section 211a." -666 "Refuse to answer" -999 "Do not know"
	label values q306a q306a

	label variable q401 "401. Out of 10 cases like this, in how many such complaints are false?"
	note q401: "401. Out of 10 cases like this, in how many such complaints are false?"
	label define q401 0 "No chance of complain being False" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Complain is always False" -666 "Refuse to answer" -999 "Do not know"
	label values q401 q401

	label variable q402 "402. Out of 10 cases like this in how many cases is recommending a compromise wi"
	note q402: "402. Out of 10 cases like this in how many cases is recommending a compromise without filing an FIR enough to solve the issue?"
	label define q402 0 "None can be solved by compromise alone" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "all ten can be solved by compromise alone" -666 "Refuse to answer" -999 "Do not know"
	label values q402 q402

	label variable q403 "403. Out of 10 cases like this, in how many are women pressing false charges rel"
	note q403: "403. Out of 10 cases like this, in how many are women pressing false charges related to sexual harrassment in order to gain unfair advantage in land dispute cases?"
	label define q403 0 "Never" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Always" -666 "Refuse to answer" -999 "Do not know"
	label values q403 q403

	label variable q404 "404. Out of 10 cases like this,how many such complaints are false?"
	note q404: "404. Out of 10 cases like this,how many such complaints are false?"
	label define q404 0 "No chance of complain being False" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Complain is always False" -666 "Refuse to answer" -999 "Do not know"
	label values q404 q404

	label variable q405 "405. Out of 10 cases like this,, in how many cases the woman faced such a situat"
	note q405: "405. Out of 10 cases like this,, in how many cases the woman faced such a situation because she did not behave in a socially acceptable manner?"
	label define q405 0 "Never" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Always" -666 "Refuse to answer" -999 "Do not know"
	label values q405 q405

	label variable q406 "406. Out of 10 cases like this,, in how many cases is the woman trying to frame "
	note q406: "406. Out of 10 cases like this,, in how many cases is the woman trying to frame the man after a fall-out of the relationship?"
	label define q406 0 "Never" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Always" -666 "Refuse to answer" -999 "Do not know"
	label values q406 q406

	label variable q407 "407. The complaint is usually more believable if the woman is also accompanied b"
	note q407: "407. The complaint is usually more believable if the woman is also accompanied by her relatives rather than when she comes alone."
	label define q407 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -666 "Refuse to answer" -999 "Do not know"
	label values q407 q407

	label variable q408 "408. Cases related to women receive too much attention by the police, relative t"
	note q408: "408. Cases related to women receive too much attention by the police, relative to other crime and law and order issues."
	label define q408 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree" -666 "Refuse to answer" -999 "Do not know"
	label values q408 q408

	label variable q501 "501. I tend to have very strong opinions about morality"
	note q501: "501. I tend to have very strong opinions about morality"
	label define q501 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q501 q501

	label variable q502 "502. I find it easy to put myself in somebody else’s shoes"
	note q502: "502. I find it easy to put myself in somebody else’s shoes"
	label define q502 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q502 q502

	label variable q503 "503. I am good at predicting how someone will feel"
	note q503: "503. I am good at predicting how someone will feel"
	label define q503 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q503 q503

	label variable q504 "504. I am able to make decisions without being influenced by others feeling"
	note q504: "504. I am able to make decisions without being influenced by others feeling"
	label define q504 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q504 q504

	label variable q505 "505. I can tune into how someone else feels rapidly and intuitively."
	note q505: "505. I can tune into how someone else feels rapidly and intuitively."
	label define q505 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q505 q505

	label variable q506 "506. I can usually appreciate the other person’s viewpoint, even if I don’t agre"
	note q506: "506. I can usually appreciate the other person’s viewpoint, even if I don’t agree with it."
	label define q506 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q506 q506

	label variable q601a "601a. Now, thinking about the story, do you think that this consists of abusive "
	note q601a: "601a. Now, thinking about the story, do you think that this consists of abusive behavior by Suresh?"
	label define q601a 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q601a q601a

	label variable q601b "601b. Do you think this is a problem that the police can help with?"
	note q601b: "601b. Do you think this is a problem that the police can help with?"
	label define q601b 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q601b q601b

	label variable q601c "601c. The complaint filed by Reena is true."
	note q601c: "601c. The complaint filed by Reena is true."
	label define q601c 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q601c q601c

	label variable q601d "601d. The independence enjoyed by women these days is causing such problems."
	note q601d: "601d. The independence enjoyed by women these days is causing such problems."
	label define q601d 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q601d q601d

	label variable q601e "601e. I can imagine what it must be like to be in Reena's place"
	note q601e: "601e. I can imagine what it must be like to be in Reena's place"
	label define q601e 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q601e q601e

	label variable q602a "602a. To what extent do you believe that Alka is speaking the truth?"
	note q602a: "602a. To what extent do you believe that Alka is speaking the truth?"
	label define q602a 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q602a q602a

	label variable q602b "602b. To what extent do you agree that this incident happened because Alka was t"
	note q602b: "602b. To what extent do you agree that this incident happened because Alka was traveling alone?"
	label define q602b 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q602b q602b

	label variable q602c "602c. I can imagine what it must be like to be in Alka's place."
	note q602c: "602c. I can imagine what it must be like to be in Alka's place."
	label define q602c 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q602c q602c

	label variable q602d "602d. Do you think the police can register a case against the men based on the c"
	note q602d: "602d. Do you think the police can register a case against the men based on the complaint?"
	label define q602d 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values q602d q602d

	label variable q701a "701a. When I work on a committee I like to take charge of things."
	note q701a: "701a. When I work on a committee I like to take charge of things."
	label define q701a 1 "TRUE" 0 "FALSE"
	label values q701a q701a

	label variable q701b "701b. I am a better talker than listener."
	note q701b: "701b. I am a better talker than listener."
	label define q701b 1 "TRUE" 0 "FALSE"
	label values q701b q701b

	label variable q701c "701c. I must admit that it makes me angry when other people interfere with my da"
	note q701c: "701c. I must admit that it makes me angry when other people interfere with my daily activity."
	label define q701c 1 "TRUE" 0 "FALSE"
	label values q701c q701c

	label variable q701d "701d. It bothers me when something unexpected interrupts my daily routine."
	note q701d: "701d. It bothers me when something unexpected interrupts my daily routine."
	label define q701d 1 "TRUE" 0 "FALSE"
	label values q701d q701d

	label variable q701e "701e. I don't like to undertake any project unless I have a pretty good idea as "
	note q701e: "701e. I don't like to undertake any project unless I have a pretty good idea as to how it will turn out"
	label define q701e 1 "TRUE" 0 "FALSE"
	label values q701e q701e

	label variable q701f "701f. I don't like things to be uncertain and unpredictable."
	note q701f: "701f. I don't like things to be uncertain and unpredictable."
	label define q701f 1 "TRUE" 0 "FALSE"
	label values q701f q701f

	label variable q701g "701g. I must admit I try to see what others think before I take a stand."
	note q701g: "701g. I must admit I try to see what others think before I take a stand."
	label define q701g 1 "TRUE" 0 "FALSE"
	label values q701g q701g

	label variable q701h "701h. I keep out of trouble at all costs."
	note q701h: "701h. I keep out of trouble at all costs."
	label define q701h 1 "TRUE" 0 "FALSE"
	label values q701h q701h

	label variable q701i "701i. It wouldn't make me nervous if any members of my family got into trouble w"
	note q701i: "701i. It wouldn't make me nervous if any members of my family got into trouble with the law."
	label define q701i 1 "TRUE" 0 "FALSE"
	label values q701i q701i

	label variable q702a "702a. You come with ideas other people haven't thought of before"
	note q702a: "702a. You come with ideas other people haven't thought of before"
	label define q702a 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702a q702a

	label variable q702b "702b. You are curious about many different things"
	note q702b: "702b. You are curious about many different things"
	label define q702b 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702b q702b

	label variable q702c "702c. You are a deep thinker"
	note q702c: "702c. You are a deep thinker"
	label define q702c 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702c q702c

	label variable q702d "702d. You have an active imagination"
	note q702d: "702d. You have an active imagination"
	label define q702d 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702d q702d

	label variable q702e "702e. You are inventive"
	note q702e: "702e. You are inventive"
	label define q702e 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702e q702e

	label variable q702f "702f. You like art and beauty"
	note q702f: "702f. You like art and beauty"
	label define q702f 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702f q702f

	label variable q702g "702g. You prefer work that is routine"
	note q702g: "702g. You prefer work that is routine"
	label define q702g 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702g q702g

	label variable q702h "702h. You like to reflect on and play with ideas"
	note q702h: "702h. You like to reflect on and play with ideas"
	label define q702h 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702h q702h

	label variable q702i "702i. You are sophisticated in art, music and literature"
	note q702i: "702i. You are sophisticated in art, music and literature"
	label define q702i 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q702i q702i

	label variable q801a "801a. Now, thinking about the story, do you think that Vijay Kumar is at fault i"
	note q801a: "801a. Now, thinking about the story, do you think that Vijay Kumar is at fault in any way?"
	label define q801a 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801a q801a

	label variable q801b "801b. Do you think this is a problem that the police can help with?"
	note q801b: "801b. Do you think this is a problem that the police can help with?"
	label define q801b 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801b q801b

	label variable q801c "801c. The complaint filed by \${s8name} is true"
	note q801c: "801c. The complaint filed by \${s8name} is true"
	label define q801c 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801c q801c

	label variable q801d "801d. This is a typical case that I have seen being reported to the Police Stati"
	note q801d: "801d. This is a typical case that I have seen being reported to the Police Station where a woman tries to frame a man."
	label define q801d 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801d q801d

	label variable q801e "801e. I can imagine what it must be like to be in \${s8name}'s place"
	note q801e: "801e. I can imagine what it must be like to be in \${s8name}'s place"
	label define q801e 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801e q801e

	label variable q801f "801f. In most ways my work life is close to my ideal."
	note q801f: "801f. In most ways my work life is close to my ideal."
	label define q801f 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801f q801f

	label variable q801g "801g. The conditions of my work life are excellent"
	note q801g: "801g. The conditions of my work life are excellent"
	label define q801g 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801g q801g

	label variable q801h "801h. I am satisfied with my work life"
	note q801h: "801h. I am satisfied with my work life"
	label define q801h 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801h q801h

	label variable q801i "801i. So far I have gotten the important things I want in my work life"
	note q801i: "801i. So far I have gotten the important things I want in my work life"
	label define q801i 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801i q801i

	label variable q801j "801j. If I could live my work life over, I would change almost nothing"
	note q801j: "801j. If I could live my work life over, I would change almost nothing"
	label define q801j 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801j q801j

	label variable q801k "801k. Reservation for women in the police force is beneficial for Bihar Police."
	note q801k: "801k. Reservation for women in the police force is beneficial for Bihar Police."
	label define q801k 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801k q801k

	label variable q801l "801l. Female and male constables should not share equal workload in your police "
	note q801l: "801l. Female and male constables should not share equal workload in your police station."
	label define q801l 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801l q801l

	label variable q801m "801m. It is useful to have female police officers to work on cases such such as "
	note q801m: "801m. It is useful to have female police officers to work on cases such such as domestic violence."
	label define q801m 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801m q801m

	label variable q801n "801n. It is useful to have female police officers to work on cases such as domes"
	note q801n: "801n. It is useful to have female police officers to work on cases such as domestic theft."
	label define q801n 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801n q801n

	label variable q801o "801o. Having more women in the Bihar Police improve the workplace environment."
	note q801o: "801o. Having more women in the Bihar Police improve the workplace environment."
	label define q801o 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801o q801o

	label variable q801p "801p. Having fewer female officers improves the productivity of your police stat"
	note q801p: "801p. Having fewer female officers improves the productivity of your police station"
	label define q801p 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801p q801p

	label variable q801q "801q. According to you, do you make efforts to address/understand challenges fac"
	note q801q: "801q. According to you, do you make efforts to address/understand challenges faced by women police officers in your Police Station?"
	label define q801q 1 "Strongly Agree" 2 "Slightly Agree" 3 "Neither Agree nor Disagree" 4 "Slightly Disagree" 5 "Strongly Disagree"
	label values q801q q801q

	label variable q801r "801r. Your police station gets a tip that a female has been found lying unconsci"
	note q801r: "801r. Your police station gets a tip that a female has been found lying unconscious on the side of the road, a suspected rape victim. Based on your experiences, how likely are you to ask a female police personnel to accompany you?"
	label define q801r 0 "Not at all likely" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Very likely"
	label values q801r q801r

	label variable q801s "801s. Your police station receives news of an unidentified person found unconsci"
	note q801s: "801s. Your police station receives news of an unidentified person found unconscious in a nearby warehouse. It is unclear whether the individual is a male or a female. How likely are you to ask a female police personnel to accompany you?"
	label define q801s 0 "Not at all likely" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Very likely"
	label values q801s q801s

	label variable q801t "801t. You are on overnight duty at your station. You receive a call about illega"
	note q801t: "801t. You are on overnight duty at your station. You receive a call about illegal alcohol and are ordered to conduct a raid. How likely are you to ask a female police personnel to accompany you?"
	label define q801t 0 "Not at all likely" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Very likely"
	label values q801t q801t

	label variable q704a "704a. Feeling nervous, anxious or tensed/worried"
	note q704a: "704a. Feeling nervous, anxious or tensed/worried"
	label define q704a 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704a q704a

	label variable q704b "704b. Not being able to stop or control worrying"
	note q704b: "704b. Not being able to stop or control worrying"
	label define q704b 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704b q704b

	label variable q704c "704c. Worrying too much about different things"
	note q704c: "704c. Worrying too much about different things"
	label define q704c 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704c q704c

	label variable q704d "704d. Trouble relaxing"
	note q704d: "704d. Trouble relaxing"
	label define q704d 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704d q704d

	label variable q704e "704e. Being so restless that it’s hard to sit still"
	note q704e: "704e. Being so restless that it’s hard to sit still"
	label define q704e 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704e q704e

	label variable q704f "704f. Becoming easily annoyed or irritable"
	note q704f: "704f. Becoming easily annoyed or irritable"
	label define q704f 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704f q704f

	label variable q704g "704g. Feeling afraid as if something awful might happen"
	note q704g: "704g. Feeling afraid as if something awful might happen"
	label define q704g 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q704g q704g

	label variable q705a "705a. In the past 2 weeks did you Have little interest or pleasure in doing thin"
	note q705a: "705a. In the past 2 weeks did you Have little interest or pleasure in doing things"
	label define q705a 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705a q705a

	label variable q705b "705b. In the past 2 weeks did you Feeling down, unhappy/miserable, or hopeless"
	note q705b: "705b. In the past 2 weeks did you Feeling down, unhappy/miserable, or hopeless"
	label define q705b 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705b q705b

	label variable q705c "705c. In the past 2 weeks did you Trouble falling or staying asleep (i.e. due to"
	note q705c: "705c. In the past 2 weeks did you Trouble falling or staying asleep (i.e. due to nightmares), or sleeping too much"
	label define q705c 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705c q705c

	label variable q705d "705d. In the past 2 weeks did you Feeling tired or having little energy"
	note q705d: "705d. In the past 2 weeks did you Feeling tired or having little energy"
	label define q705d 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705d q705d

	label variable q705e "705e. In the past 2 weeks did you Poor appetite or overeating"
	note q705e: "705e. In the past 2 weeks did you Poor appetite or overeating"
	label define q705e 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705e q705e

	label variable q705f "705f. In the past 2 weeks did you Feeling bad about yourself – or that you are a"
	note q705f: "705f. In the past 2 weeks did you Feeling bad about yourself – or that you are a failure or have let yourself or your family down"
	label define q705f 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705f q705f

	label variable q705g "705g. In the past 2 weeks did you Trouble concentrating on things, such as readi"
	note q705g: "705g. In the past 2 weeks did you Trouble concentrating on things, such as reading the newspaper"
	label define q705g 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705g q705g

	label variable q705h "705h. In the past 2 weeks did you Moving or speaking so slowly that other people"
	note q705h: "705h. In the past 2 weeks did you Moving or speaking so slowly that other people could have noticed; or the opposite—being so anxious or restless that you have been moving around a lot more than usual"
	label define q705h 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705h q705h

	label variable q705i "705i. In the past 2 weeks did you Thoughts that you would be better off dead or "
	note q705i: "705i. In the past 2 weeks did you Thoughts that you would be better off dead or of hurting yourself in some way"
	label define q705i 1 "Not at all" 2 "Several Days" 3 "More than half the days" 4 "Nearly every day" -666 "Refuse to answer" -999 "Do not know"
	label values q705i q705i

	label variable q703a "703a. It is sometimes hard for me to go on with my work if I am not encouraged."
	note q703a: "703a. It is sometimes hard for me to go on with my work if I am not encouraged."
	label define q703a 1 "TRUE" 0 "FALSE"
	label values q703a q703a

	label variable q703b "703b. I sometimes feel resentful when I don't get my own way."
	note q703b: "703b. I sometimes feel resentful when I don't get my own way."
	label define q703b 1 "TRUE" 0 "FALSE"
	label values q703b q703b

	label variable q703c "703c. On a few occasions, I have given up doing something because I thought too "
	note q703c: "703c. On a few occasions, I have given up doing something because I thought too little of my ability."
	label define q703c 1 "TRUE" 0 "FALSE"
	label values q703c q703c

	label variable q703d "703d. There have been times when I felt like rebelling against people in authori"
	note q703d: "703d. There have been times when I felt like rebelling against people in authority even though I knew they were right."
	label define q703d 1 "TRUE" 0 "FALSE"
	label values q703d q703d

	label variable q703e "703e. No matter who I’m talking to, I’m always a good listener."
	note q703e: "703e. No matter who I’m talking to, I’m always a good listener."
	label define q703e 1 "TRUE" 0 "FALSE"
	label values q703e q703e

	label variable q703f "703f. There have been occasions when I took advantage of someone."
	note q703f: "703f. There have been occasions when I took advantage of someone."
	label define q703f 1 "TRUE" 0 "FALSE"
	label values q703f q703f

	label variable q703g "703g. I’m always willing to admit it when I make a mistake."
	note q703g: "703g. I’m always willing to admit it when I make a mistake."
	label define q703g 1 "TRUE" 0 "FALSE"
	label values q703g q703g

	label variable q703h "703h. I sometimes try to get even, rather than forgive and forget."
	note q703h: "703h. I sometimes try to get even, rather than forgive and forget."
	label define q703h 1 "TRUE" 0 "FALSE"
	label values q703h q703h

	label variable q703i "703i. I am always courteous, even to people who are disagreeable."
	note q703i: "703i. I am always courteous, even to people who are disagreeable."
	label define q703i 1 "TRUE" 0 "FALSE"
	label values q703i q703i

	label variable q703j "703j. I have never been irked when people expressed ideas very different from my"
	note q703j: "703j. I have never been irked when people expressed ideas very different from my own."
	label define q703j 1 "TRUE" 0 "FALSE"
	label values q703j q703j

	label variable q703k "703k. There have been times when I was quite jealous of the good fortune of othe"
	note q703k: "703k. There have been times when I was quite jealous of the good fortune of others."
	label define q703k 1 "TRUE" 0 "FALSE"
	label values q703k q703k

	label variable q703l "703l. I am sometimes irritated by people who ask favours of me."
	note q703l: "703l. I am sometimes irritated by people who ask favours of me."
	label define q703l 1 "TRUE" 0 "FALSE"
	label values q703l q703l

	label variable q703m "703m. I have never deliberately said something that hurt someone’s feelings."
	note q703m: "703m. I have never deliberately said something that hurt someone’s feelings."
	label define q703m 1 "TRUE" 0 "FALSE"
	label values q703m q703m

	label variable hs1a "Diabetes"
	note hs1a: "Diabetes"
	label define hs1a 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1a hs1a

	label variable hs1b "High Blood Pressure (Hypertension)"
	note hs1b: "High Blood Pressure (Hypertension)"
	label define hs1b 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1b hs1b

	label variable hs1c "Asthma"
	note hs1c: "Asthma"
	label define hs1c 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1c hs1c

	label variable hs1d "High Cholesterol"
	note hs1d: "High Cholesterol"
	label define hs1d 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1d hs1d

	label variable hs1e "Gastrointestinal Issues (e.g., Gastritis, Ulcers)"
	note hs1e: "Gastrointestinal Issues (e.g., Gastritis, Ulcers)"
	label define hs1e 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1e hs1e

	label variable hs1f "Arthritis, Joint-pain, Back-pain"
	note hs1f: "Arthritis, Joint-pain, Back-pain"
	label define hs1f 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1f hs1f

	label variable hs1g "Sleep disorder"
	note hs1g: "Sleep disorder"
	label define hs1g 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
	label values hs1g hs1g

	label variable hs1h "Any other medical condition"
	note hs1h: "Any other medical condition"
	label define hs1h 1 "Yes" 0 "No" -666 "Refused to answer" -999 "Do not know"
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

	label variable cs1 "CS1. What are the major constraints that you face while handling the GBV cases?"
	note cs1: "CS1. What are the major constraints that you face while handling the GBV cases?"

	label variable cs2 "CS2. Did you attend the 3-day training on GBV that was held in this district?"
	note cs2: "CS2. Did you attend the 3-day training on GBV that was held in this district?"
	label define cs2 1 "Yes" 0 "No"
	label values cs2 cs2

	label variable cs3 "CS3. Did you find any value in this training that you attended?"
	note cs3: "CS3. Did you find any value in this training that you attended?"
	label define cs3 1 "Yes" 0 "No"
	label values cs3 cs3

	label variable cs4 "CS4. If so, can you please let us know in one or two lines how you found this tr"
	note cs4: "CS4. If so, can you please let us know in one or two lines how you found this training session useful?"

	label variable cs5 "CS5. Did you receive a booklet of GBV related laws during your GBV training? Enu"
	note cs5: "CS5. Did you receive a booklet of GBV related laws during your GBV training? Enumerator: Remind the officer about the training date depending on the district"
	label define cs5 1 "Yes" 0 "No"
	label values cs5 cs5

	label variable cs6 "CS6. Do you still have that booklet in your possession?"
	note cs6: "CS6. Do you still have that booklet in your possession?"
	label define cs6 1 "Yes" 0 "No"
	label values cs6 cs6

	label variable cs7 "CS7. Have you ever consulted this GBV booklet since the training?"
	note cs7: "CS7. Have you ever consulted this GBV booklet since the training?"
	label define cs7 1 "Yes" 0 "No"
	label values cs7 cs7

	label variable cs8 "CS8. If yes, for what types of cases have you used it for?"
	note cs8: "CS8. If yes, for what types of cases have you used it for?"

	label variable marital_check "Sir, is the marital status correct for you? Marital Status: \${marital_status}"
	note marital_check: "Sir, is the marital status correct for you? Marital Status: \${marital_status}"
	label define marital_check 1 "Yes" 0 "No"
	label values marital_check marital_check

	label variable marital_el "Sir, if we may ask, what is your marital status?"
	note marital_el: "Sir, if we may ask, what is your marital status?"
	label define marital_el 1 "Never married" 2 "Married and lives together" 3 "Married but Lives Separately" 4 "Divorced" 5 "Separated" 6 "Widower" -666 "Refuse to answer"
	label values marital_el marital_el

	label variable talktowife "Sir, we would like to ask your spouse/wife some questions about her experiences "
	note talktowife: "Sir, we would like to ask your spouse/wife some questions about her experiences as a police officers’ wives and the wellbeing of officers like you. The survey will be conducted at your residence by a female surveyor. Questions will be asked around her life as a police officer’s wife. This will be a short conversation."
	label define talktowife 1 "Yes" 0 "No"
	label values talktowife talktowife

	label variable refuse_talktowife "Sir, would you like to share the reason for refusing this survey?"
	note refuse_talktowife: "Sir, would you like to share the reason for refusing this survey?"

	label variable wifename "Wife's Name"
	note wifename: "Wife's Name"

	label variable officeraddress "Address"
	note officeraddress: "Address"

	label variable wifephone "Wife's Phone Number"
	note wifephone: "Wife's Phone Number"

	label variable wifealternate "Alternate phone number(blank allowed)"
	note wifealternate: "Alternate phone number(blank allowed)"

	label variable q104 "104. Sir, do you have children? Enumerator instruction: If the officer responds "
	note q104: "104. Sir, do you have children? Enumerator instruction: If the officer responds yes, proceed to ask the following question- Sir, may we ask how many sons and daughters do you have?"
	label define q104 1 "Have Children" 2 "I do not have children" -666 "Refuse to answer"
	label values q104 q104

	label variable q104_sons "Sons"
	note q104_sons: "Sons"

	label variable q104_daughters "Daughters"
	note q104_daughters: "Daughters"

	label variable q104_total "Total"
	note q104_total: "Total"

	label variable q106 "106. Sir, would you be comfortable sharing which Category you belong to?"
	note q106: "106. Sir, would you be comfortable sharing which Category you belong to?"
	label define q106 1 "SC" 2 "ST" 3 "OBC" 4 "General" -666 "Refuse to answer"
	label values q106 q106

	label variable q106a "106a. If you are willing to share, may I ask what is your sub-caste or jati?"
	note q106a: "106a. If you are willing to share, may I ask what is your sub-caste or jati?"

	label variable d1 "Survey End time"
	note d1: "Survey End time"

	label variable comment "Surveyor Comment"
	note comment: "Surveyor Comment"

	label variable surveystatus "Survey Status"
	note surveystatus: "Survey Status"
	label define surveystatus 1 "Completed" 2 "Partially completed" 3 "Refused" 4 "Not Available"
	label values surveystatus surveystatus

	label variable gpslocationlatitude "Record GPS location (latitude)"
	note gpslocationlatitude: "Record GPS location (latitude)"

	label variable gpslocationlongitude "Record GPS location (longitude)"
	note gpslocationlongitude: "Record GPS location (longitude)"

	label variable gpslocationaltitude "Record GPS location (altitude)"
	note gpslocationaltitude: "Record GPS location (altitude)"

	label variable gpslocationaccuracy "Record GPS location (accuracy)"
	note gpslocationaccuracy: "Record GPS location (accuracy)"



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

	capture {
		foreach rgvar of varlist activitystart_* {
			label variable `rgvar' "Start"
			note `rgvar': "Start"
		}
	}

	capture {
		foreach rgvar of varlist activityend_* {
			label variable `rgvar' "End"
			note `rgvar': "End"
		}
	}

	capture {
		foreach rgvar of varlist activitycode_* {
			label variable `rgvar' "Activity"
			note `rgvar': "Activity"
		}
	}

	capture {
		foreach rgvar of varlist activitycode_os_* {
			label variable `rgvar' "Activity: Others Specify"
			note `rgvar': "Activity: Others Specify"
		}
	}

	capture {
		foreach rgvar of varlist activity_check_* {
			label variable `rgvar' "Do you want to add another activity / hours?"
			note `rgvar': "Do you want to add another activity / hours?"
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
	save "$MO_endline_intermediate_dta\01.import-endlinesurvey.dta", replace

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
*   Corrections file path and filename:  ${raw}/Officer Survey Endline Main_corrections.csv
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
		save "$MO_endline_intermediate_dta\01.import-endlinesurvey.dta", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
