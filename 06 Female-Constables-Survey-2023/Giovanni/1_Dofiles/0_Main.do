/*==============================================================================
File Name: Main Do file
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	26/11/2024
Created by: Giovanni D'Ambrosio
Updated on: 26/11/2024
Updated by:	Giovanni D'Ambrosio
Description: In this do file I create the relevant globals. 

==============================================================================*/

*** Set up settings ***

clear all
set more off
set mem 1g
set scheme burd, permanently
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
global psfs= 			"$user\01 PSFS-2024"
global MO_baseline=		"$user\02 Baseline-Survey-2022"
global randomisation=	"$user\03 Randomisation"
global reflection 		"$user\04 Reflection-Survey-2022"
global MO_endline 		"$user\05 Endline-Survey-2023"
global FC_survey 		"$user\06 Female-Constables-Survey-2023"
global Wives_survey 	"$user\07 Wives-Survey-2023"
global decoy 		    "$user\08 Decoy_2023"
global fir_data 		"$user\09 FIR Data-2024"
global addl_controls    "$user\11 Adding PS-level variables"

* Globals for female constable survey

global raw "$FC_survey\Giovanni\2_Data\0_Raw"
global do_files "$FC_survey\Giovanni\1_Dofiles"
global intermediate_dta "$FC_survey\Giovanni\2_Data\1_Intermediate"
global clean_dta "$FC_survey\Giovanni\2_Data\2_Clean"
global log_files "$FC_survey\Giovanni\3_Log files"
global tables "C:\Users\USER\Dropbox\Apps\Overleaf\Female Constable - Bihar Project\Tables"
*global graphs "$FC_survey\04.graphs"




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