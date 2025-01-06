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

**File Directory

*dibbo -- username for Dibyajyoti.
*For others, please enter your PC Name as username and copy the file path of your DB Desktop. 

if "`c(username)'"=="HP"{
	global dropbox "C:\Users\HP\Dropbox\"
	}
else if "`c(username)'"=="dibbo"{
	global dropbox "C:\Users\dibbo\Dropbox\RA-GBV-2023\005-Data-and-analysis-2022\FIR Data-2024"
	}	
/*enter the main folder for the project in Dropbox as per your system*/	
else if "`c(username)'"=="User3"{
	global dropbox "File-Path"
	}

di "`dropbox'"
	
*File Path
/*enter the local names for the different folders, create the folders if they don't exist*/
global raw "$dropbox\01 raw data"
global do_files "$dropbox\02 do files"
global intermediate_dta "$dropbox\03 intermediate\"
*global tables "$dropbox\03.tables\"
*global graphs "$dropbox\04.graphs\"
global log_files "$dropbox\04 log files\"
global clean_dta "$dropbox\05 clean data\"


* We will log in
capture log close 

log using "${log_files}importing FIR Data_Patna.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: baseline_listing_exercise_respondents.dta  "baseline_listing_exercise_respondents.dta"

import delimited "${raw}\Patna\Agamkuan PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_10"
save "${intermediate_dta}Patna\ps1.dta", replace
clear

import delimited "${raw}\Patna\Alamganj PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_13"
save "${intermediate_dta}Patna\ps4.dta", replace
clear

import delimited "${raw}\Patna\Athmalgola PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_14"
save "${intermediate_dta}Patna\ps5.dta", replace
clear

import delimited "${raw}\Patna\Bahadurpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_15"
save "${intermediate_dta}Patna\ps6.dta", replace
clear

import delimited "${raw}\Patna\Bakhtiyarpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_16"
save "${intermediate_dta}Patna\ps7.dta", replace
clear

import delimited "${raw}\Patna\Barh PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_17"
save "${intermediate_dta}Patna\ps8.dta", replace
clear

import delimited "${raw}\Patna\Belchhi  PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_18"
save "${intermediate_dta}Patna\ps9.dta", replace
clear

import delimited "${raw}\Patna\Beur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_19"
save "${intermediate_dta}Patna\ps10.dta", replace
clear

import delimited "${raw}\Patna\Bhadaur PS..csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_20"
save "${intermediate_dta}Patna\ps11.dta", replace
clear

import delimited "${raw}\Patna\Bhagwanganj PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_21"
save "${intermediate_dta}Patna\ps12.dta", replace
clear

import delimited "${raw}\Patna\Bihta PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_22"
save "${intermediate_dta}Patna\ps13.dta", replace
clear

import delimited "${raw}\Patna\Bikram PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_23"
save "${intermediate_dta}Patna\ps14.dta", replace
clear

import delimited "${raw}\Patna\Buddha Colony PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_24"
save "${intermediate_dta}Patna\ps15.dta", replace
clear

import delimited "${raw}\Patna\Bypass PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_25"
save "${intermediate_dta}Patna\ps16.dta", replace
clear

import delimited "${raw}\Patna\Chowk PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_26"
save "${intermediate_dta}Patna\ps17.dta", replace
clear

import delimited "${raw}\Patna\Daniyawan PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_28"
save "${intermediate_dta}Patna\ps19.dta", replace
clear

import delimited "${raw}\Patna\Dhanarua PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_29"
save "${intermediate_dta}Patna\ps20.dta", replace
clear

import delimited "${raw}\Patna\Didarganj PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_30"
save "${intermediate_dta}Patna\ps21.dta", replace
clear

import delimited "${raw}\Patna\Digha PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_31"
save "${intermediate_dta}Patna\ps22.dta", replace
clear

import delimited "${raw}\Patna\Dulhinbazar PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_32"
save "${intermediate_dta}Patna\ps23.dta", replace
clear

import delimited "${raw}\Patna\Fatuha PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_33"
save "${intermediate_dta}Patna\ps24.dta", replace
clear

import delimited "${raw}\Patna\Gandhi Maidan PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_34"
save "${intermediate_dta}Patna\ps25.dta", replace
clear

import delimited "${raw}\Patna\Gardanibagh PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_35"
save "${intermediate_dta}Patna\ps26.dta", replace
clear

import delimited "${raw}\Patna\Gaurichak PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_36"
save "${intermediate_dta}Patna\ps27.dta", replace
clear

import delimited "${raw}\Patna\Ghoswari PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_37"
save "${intermediate_dta}Patna\ps28.dta", replace
clear

import delimited "${raw}\Patna\Gopalpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_38"
save "${intermediate_dta}Patna\ps29.dta", replace
clear

import delimited "${raw}\Patna\Hathidah  PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_39"
save "${intermediate_dta}Patna\ps30.dta", replace
clear

import delimited "${raw}\Patna\Jakkanpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_40"
save "${intermediate_dta}Patna\ps31.dta", replace
clear

import delimited "${raw}\Patna\Janipur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_42"
save "${intermediate_dta}Patna\ps33.dta", replace
clear

import delimited "${raw}\Patna\Kadam Kuan PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_43"
save "${intermediate_dta}Patna\ps34.dta", replace
clear

import delimited "${raw}\Patna\Kadirganj PS..csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_44"
save "${intermediate_dta}Patna\ps35.dta", replace
clear

import delimited "${raw}\Patna\Kankarbagh PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_45"
save "${intermediate_dta}Patna\ps36.dta", replace
clear

import delimited "${raw}\Patna\Khagaul PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_46"
save "${intermediate_dta}Patna\ps37.dta", replace
clear

import delimited "${raw}\Patna\Khajkala PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_47"
save "${intermediate_dta}Patna\ps38.dta", replace
clear

import delimited "${raw}\Patna\Khirimore PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_48"
save "${intermediate_dta}Patna\ps39.dta", replace
clear

import delimited "${raw}\Patna\Khusrupur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_49"
save "${intermediate_dta}Patna\ps40.dta", replace
clear

import delimited "${raw}\Patna\Kotwali PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_50"
save "${intermediate_dta}Patna\ps41.dta", replace
clear

import delimited "${raw}\Patna\Malsalami PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_53"
save "${intermediate_dta}Patna\ps44.dta", replace
clear

import delimited "${raw}\Patna\Maner PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_54"
save "${intermediate_dta}Patna\ps45.dta", replace
clear

import delimited "${raw}\Patna\Maranchi PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_55"
save "${intermediate_dta}Patna\ps46.dta", replace
clear

import delimited "${raw}\Patna\Masaurdi PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_56"
save "${intermediate_dta}Patna\ps47.dta", replace
clear

import delimited "${raw}\Patna\Mehandiganj PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_57"
save "${intermediate_dta}Patna\ps48.dta", replace
clear

import delimited "${raw}\Patna\Mokamah PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_58"
save "${intermediate_dta}Patna\ps49.dta", replace
clear

import delimited "${raw}\Patna\Naubatpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_60"
save "${intermediate_dta}Patna\ps51.dta", replace
clear

import delimited "${raw}\Patna\NTPC PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_62"
save "${intermediate_dta}Patna\ps53.dta", replace
clear

import delimited "${raw}\Patna\Paliganj PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_64"
save "${intermediate_dta}Patna\ps55.dta", replace
clear

import delimited "${raw}\Patna\Pachamahala PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_65"
save "${intermediate_dta}Patna\ps56.dta", replace
clear

import delimited "${raw}\Patna\Pandarak PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_66"
save "${intermediate_dta}Patna\ps57.dta", replace
clear

import delimited "${raw}\Patna\Parsa Baazar PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_67"
save "${intermediate_dta}Patna\ps58.dta", replace
clear

import delimited "${raw}\Patna\Patliputra PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_68"
save "${intermediate_dta}Patna\ps59.dta", replace
clear

import delimited "${raw}\Patna\Patrakar Nagar PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_69"
save "${intermediate_dta}Patna\ps60.dta", replace
clear

import delimited "${raw}\Patna\Phulwari Sharif PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_70"
save "${intermediate_dta}Patna\ps61.dta", replace
clear

import delimited "${raw}\Patna\Pipra PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_71"
save "${intermediate_dta}Patna\ps62.dta", replace
clear

import delimited "${raw}\Patna\Pirbahore PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_72"
save "${intermediate_dta}Patna\ps63.dta", replace
clear

import delimited "${raw}\Patna\Punpun PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_75"
save "${intermediate_dta}Patna\ps66.dta", replace
clear

import delimited "${raw}\Patna\Rajeev Nagar PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_76"
save "${intermediate_dta}Patna\ps67.dta", replace
clear

import delimited "${raw}\Patna\Ramkrishna Nagar PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_77"
save "${intermediate_dta}Patna\ps68.dta", replace
clear

import delimited "${raw}\Patna\Rani Talab PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_78"
save "${intermediate_dta}Patna\ps69.dta", replace
clear

import delimited "${raw}\Patna\Nadi PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_79"
save "${intermediate_dta}Patna\ps70.dta", replace
clear

import delimited "${raw}\Patna\Rupaspur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_80"
save "${intermediate_dta}Patna\ps71.dta", replace
clear

import delimited "${raw}\Patna\Sachivalaya PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_81"
save "${intermediate_dta}Patna\ps72.dta", replace
clear

import delimited "${raw}\Patna\Salimpur PS..csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_82"
replace policestation = "Salimpur" if policestation == "Saligpur"
save "${intermediate_dta}Patna\ps73.dta", replace
clear

import delimited "${raw}\Patna\Shahjahanpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_85"
save "${intermediate_dta}Patna\ps76.dta", replace
clear

import delimited "${raw}\Patna\Shahpur PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_86"
save "${intermediate_dta}Patna\ps77.dta", replace
clear

import delimited "${raw}\Patna\Shastrinagar PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_88"
save "${intermediate_dta}Patna\ps79.dta", replace
clear

import delimited "${raw}\Patna\Sigori PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_89"
save "${intermediate_dta}Patna\ps80.dta", replace
clear

import delimited "${raw}\Patna\Sri Kirishna Puri PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_90"
save "${intermediate_dta}Patna\ps81.dta", replace
clear

import delimited "${raw}\Patna\Sultanganj PS.csv"
gen ps_dist = 1008
gen ps_dist_id = "1008_91"
save "${intermediate_dta}Patna\ps82.dta", replace
clear


use "${intermediate_dta}Patna\ps1.dta", clear
append using "${intermediate_dta}Patna\ps4.dta"
append using "${intermediate_dta}Patna\ps5.dta"
append using "${intermediate_dta}Patna\ps6.dta"
append using "${intermediate_dta}Patna\ps7.dta"
append using "${intermediate_dta}Patna\ps8.dta"
append using "${intermediate_dta}Patna\ps9.dta"
append using "${intermediate_dta}Patna\ps10.dta"
append using "${intermediate_dta}Patna\ps11.dta"
append using "${intermediate_dta}Patna\ps12.dta"
append using "${intermediate_dta}Patna\ps13.dta"
append using "${intermediate_dta}Patna\ps14.dta"
append using "${intermediate_dta}Patna\ps15.dta"
append using "${intermediate_dta}Patna\ps16.dta"
append using "${intermediate_dta}Patna\ps17.dta"
append using "${intermediate_dta}Patna\ps19.dta"
append using "${intermediate_dta}Patna\ps20.dta"
append using "${intermediate_dta}Patna\ps21.dta"
append using "${intermediate_dta}Patna\ps22.dta"
append using "${intermediate_dta}Patna\ps23.dta"
append using "${intermediate_dta}Patna\ps24.dta"
append using "${intermediate_dta}Patna\ps25.dta"
append using "${intermediate_dta}Patna\ps26.dta"
append using "${intermediate_dta}Patna\ps27.dta"
append using "${intermediate_dta}Patna\ps28.dta"
append using "${intermediate_dta}Patna\ps29.dta"
append using "${intermediate_dta}Patna\ps30.dta"
append using "${intermediate_dta}Patna\ps31.dta"
append using "${intermediate_dta}Patna\ps33.dta"
append using "${intermediate_dta}Patna\ps34.dta"
append using "${intermediate_dta}Patna\ps35.dta"
append using "${intermediate_dta}Patna\ps36.dta"
append using "${intermediate_dta}Patna\ps37.dta"
append using "${intermediate_dta}Patna\ps39.dta"
append using "${intermediate_dta}Patna\ps38.dta"
append using "${intermediate_dta}Patna\ps40.dta"
append using "${intermediate_dta}Patna\ps41.dta"
append using "${intermediate_dta}Patna\ps44.dta"
append using "${intermediate_dta}Patna\ps45.dta"
append using "${intermediate_dta}Patna\ps46.dta"
append using "${intermediate_dta}Patna\ps47.dta"
append using "${intermediate_dta}Patna\ps48.dta"
append using "${intermediate_dta}Patna\ps49.dta"
append using "${intermediate_dta}Patna\ps51.dta"
append using "${intermediate_dta}Patna\ps53.dta"
append using "${intermediate_dta}Patna\ps51.dta"
append using "${intermediate_dta}Patna\ps55.dta"
append using "${intermediate_dta}Patna\ps56.dta"
append using "${intermediate_dta}Patna\ps57.dta"
append using "${intermediate_dta}Patna\ps58.dta"
append using "${intermediate_dta}Patna\ps59.dta"
append using "${intermediate_dta}Patna\ps60.dta"
append using "${intermediate_dta}Patna\ps61.dta"
append using "${intermediate_dta}Patna\ps62.dta"
append using "${intermediate_dta}Patna\ps63.dta"
append using "${intermediate_dta}Patna\ps66.dta"
append using "${intermediate_dta}Patna\ps67.dta"
append using "${intermediate_dta}Patna\ps68.dta"
append using "${intermediate_dta}Patna\ps69.dta"
append using "${intermediate_dta}Patna\ps70.dta"
append using "${intermediate_dta}Patna\ps71.dta"
append using "${intermediate_dta}Patna\ps72.dta"
append using "${intermediate_dta}Patna\ps73.dta"
append using "${intermediate_dta}Patna\ps76.dta"
append using "${intermediate_dta}Patna\ps77.dta"
append using "${intermediate_dta}Patna\ps79.dta"
append using "${intermediate_dta}Patna\ps80.dta"
append using "${intermediate_dta}Patna\ps81.dta"
append using "${intermediate_dta}Patna\ps82.dta"

order ps_dist ps_dist_id, first
split firdate, parse (" ")
drop firdate
gen firdate = date(firdate1, "DMY")
format firdate %td
gen firtime = clock(firdate2,"hms#")
format firtime %tcHH:MM
drop firdate1 firdate2
order ps_dist district ps_dist_id policestation sno firno firdate firtime  

save "${intermediate_dta}Patna_FIR.dta", replace
