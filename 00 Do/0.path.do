/*==============================================================================
File Name: Main Do file
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	02/01/2025
Created by: Dibyajyoti Basak
Updated on: 02/01/2025
Updated by:	Dibyajyoti Basak
Description: In this do file I create the relevant globals. 

==============================================================================*/

*** Set up settings ***

clear all
set more off
set mem 1g
*set scheme burd, permanently
set maxvar 10000

*** THIS IS THE INPUT THAT MUST BE CHANGED SPECIFIC TO THE USER/ANALYSIS ***

if "`c(username)'" == "USER" { // Giovanni
		gl identity "C:\Users\USER\Desktop\Dropbox"
} 

else if "`c(username)'" == "dibbo" { // Dibyajyoti
		gl identity "C:\Users\dibbo\Dropbox"
} 

else if  "`c(username)'"=="wb529066" { //Mica
	gl identity "C:\Users\wb529066\OneDrive - WBG\Documents\Documents\Bihar"
}

** Creating Global File Paths ** 
 
gl user "$identity\Debiasing Police in India\005-Data-and-analysis-2022"

global do 				"$user\00 Do"
global psfs 			"$user\01 PSFS-2024"
global MO_baseline		"$user\02 Baseline-Survey-2022"
global randomisation	"$user\03 Randomisation"
global reflection 		"$user\04 Reflection-Survey-2022"
global MO_endline 		"$user\05 Endline-Survey-2023"
global FC_survey 		"$user\06 Female-Constables-Survey-2023"
global Wives_survey 	"$user\07 Wives-Survey-2023"
global decoy 		    "$user\08 Decoy_2023"
global fir_data 		"$user\09 FIR Data-2024"
global addl_controls    "$user\11 Adding PS-level variables"
global Victim_survey    "$user\12 Victim Survey-2024"

* Globals for PSFS survey

global psfs_raw "$psfs\PSFS-2022\00.raw-data"
global psfs_do_files "$psfs\PSFS-2022\01.do-files"
global psfs_intermediate_dta "$psfs\PSFS-2022\02.intermediate-data"
global psfs_clean_dta "$psfs\PSFS-2022\06.clean-data"
global psfs_log_files "$psfs\PSFS-2022\05.log-files"
global psfs_tables "$psfs\PSFS-2022\03.tables"
global psfs_graphs "$psfs\PSFS-2022\04.graphs"

* Globals for Male officers - baseline

*global MO_baseline_raw "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\00.raw-data"
global MO_baseline_do_files "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\01.do-files"
*global MO_baseline_intermediate_dta "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\02.intermediate-data"
global MO_baseline_clean_dta "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\02.clean-data"
*global MO_baseline_log_files "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\05.log-files"
*global MO_baseline_tables "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\03.tables"
*global MO_baseline_graphs "$MO_baseline\Baseline Survey_versions 1-3\Officer-Survey_combined\04.graphs"

* Globals for randomisation

global randomisation_raw "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\00.raw-data"
global randomisation_do_files "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\01.do-files"
global randomisation_intermediate_dta "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\02.intermediate-data"
global randomisation_clean_dta "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\06.clean-data"
global randomisation_log_files "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\05.log-files"
global randomisation_tables "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\03.tables"
global randomisation_graphs "$randomisation\01.Officer-Survey_Randomization\999_pooled-randomization\04.graphs"


* Globals for reflection survey

global reflection_raw "$reflection\00.raw-data"
global reflection_do_files "$reflection\01.do-files"
global reflection_intermediate_dta "$reflection\02.intermediate-data"
global reflection_clean_dta "$reflection\06.clean-data"
global reflection_log_files "$reflection\05.log-files"
global reflection_tables "$reflection\03.tables"
global reflection_graphs "$reflection\04.graphs"

* Globals for Male officers - endline

global MO_endline_raw "$MO_endline\00.raw-data"
global MO_endline_do_files "$MO_endline\01.do-files"
global MO_endline_intermediate_dta "$MO_endline\02.intermediate-data"
global MO_endline_clean_dta "$MO_endline\06.clean-data"
global MO_endline_log_files "$MO_endline\05.log-files"
global MO_endline_tables "$MO_endline\03.tables"
global MO_endline_graphs "$MO_endline\04.graphs"

* Globals for Female constable survey

global FC_survey_raw "$FC_survey\00.raw-data"
global FC_survey_do_files "$FC_survey\01.do-files"
global FC_survey_intermediate_dta "$FC_survey\02.intermediate-data"
global FC_survey_clean_dta "$FC_survey\06.clean-data"
global FC_survey_log_files "$FC_survey\05.log-files"
global FC_survey_tables "$FC_survey\03.tables"
global FC_survey_graphs "$FC_survey\04.graphs"

* Globals for Wives survey

global Wives_survey_raw "$Wives_survey\00.raw-data"
global Wives_survey_do_files "$Wives_survey\01.do-files"
global Wives_survey_intermediate_dta "$Wives_survey\02.intermediate-data"
global Wives_survey_clean_dta "$Wives_survey\06.clean-data"
global Wives_survey_log_files "$Wives_survey\05.log-files"
global Wives_survey_tables "$Wives_survey\03.tables"
global Wives_survey_graphs "$Wives_survey\04.graphs"

* Globals for Decoy survey

global decoy_raw "$decoy\00.raw-data"
global decoy_do_files "$decoy\01.do-files"
global decoy_intermediate_dta "$decoy\02.intermediate-data"
global decoy_clean_dta "$decoy\06.clean-data"
global decoy_log_files "$decoy\05.log-files"
global decoy_tables "$decoy\03.tables"
global decoy_graphs "$decoy\04.graphs"

* Globals for FIR data

global fir_data_raw "$fir_data\01 raw data"
global fir_data_do_files "$fir_data\02 do files"
global fir_data_intermediate_dta "$fir_data\03 intermediate"
global fir_data_clean_dta "$fir_data\05 clean data"
global fir_data_log_files "$fir_data\04 log files"
global fir_data_tables "$fir_data\06 tables"
global fir_data_graphs "$fir_data\07 graphs"

* Globals for additional controls

global addl_controls_raw "$addl_controls\00.raw-data"
global addl_controls_do_files "$addl_controls\01.do-files"
global addl_controls_intermediate_dta "$addl_controls\02.intermediate-data"
global addl_controls_clean_dta "$addl_controls\06.clean-data"
global addl_controls_log_files "$addl_controls\05.log-files"
global addl_controls_tables "$addl_controls\03.tables"
global addl_controls_graphs "$addl_controls\04.graphs"

* Globals for Victim survey

global Victim_survey_raw "$Victim_survey\00.raw-data"
global Victim_survey_do_files "$Victim_survey\01.do-files"
global Victim_survey_intermediate_dta "$Victim_survey\02.intermediate-data"
global Victim_survey_clean_dta "$Victim_survey\06.clean-data"
global Victim_survey_log_files "$Victim_survey\05.log-files"
global Victim_survey_tables "$Victim_survey\03.tables"
global Victim_survey_graphs "$Victim_survey\04.graphs"


*** Install necessary packages
/*
ssc install mhtexp
ssc install mhtreg
ssc install moremata, replace
ssc install ritest // for randmization inference and multiple hypothesis testing. 

capture ado uninstall ranktest
capture ado uninstall ivreg2
capture ado uninstall ftools
capture ado uninstall reghdfe
cap ado uninstall ivreghdfe

* Install ftools (remove program if it existed previously)
ssc install ranktest
ssc install ivreg2 
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)		 
* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2
* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)
ssc install ivreg2
ssc install ivreghdfe
	
ssc install icw_index
/*For Anderson's Index. ( Michael L. Anderson Multiple Inference and Gender Differences
 in the Effects of Early Intervention: AReevaluation of the Abecedarian, Perry 
 Preschool, and Early Training Projects Journal of the American Statistical 
 Association, Vol. 103, No. 484 008), pp.1481-1495) 
 */
 ssc install polychoric - to compute polychoric correlation 
	
*** Multiple hypothesis testing
ssc install mhtreg (requires - ssc install moremata, replace)
ssc inst egenmore
ssc install swindex
*/