/*==============================================================================
File Name: PSFS-2022 - Error and Logical Consistency Checks do File
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	02/12/2022
Created by: Shubhro Bhattacharya
Updated on:	22/11/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to perform the error and logical consistency checks on the PSFS Survey 2022. 

*	Inputs: 02.intermediate-data  "02.ren-PSFS_intermediate"
*	Outputs: 06.clean-data  "01.PSFS_clean_PII"

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

log using "$psfs_log_files\PSFS_errorcheck.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

*open the input dta file: 02.intermediate-data  "02.ren-PSFS_intermediate"

use "$psfs_intermediate_dta\02.ren-PSFS_intermediate.dta" , clear



/*==============Error Correction and Logical Checks==================================*/

*1. Checking for the uniqueness of PS Id. 

tab ps_dist_id, missing
*Note: Five id variables missing which we need to match with the PS Id of the Officer's survey Data

sort ps_dist_id

/*Note: (A) Three missing values are from Patna and one from Bettiah. The Following PS have missing ids: 1. Shastrinagar PS, 2. Patna Vishwavidyalaya OP, 3. NMCH T.O.P, 4. GNMCH OP 5. Ramraj More T.O.P

(B) The above errors have been reconciled by matching the PS IDs from the pslist (Survey CTO Input File) in the Raw DATA Folder.

*/

*1. Shastrinagar, Patna
replace ps_name = "Shastrinagar PS" if sv_location=="SASHTRINAGAR PS"
replace ps_dist_id= "1008_88" if ps_name == "Shastrinagar PS"

*2. NMCH T.O.PC, Patna
replace ps_name= "N.M.C.H.T.O.P PS" if sv_location== "NMCH OTP, Patna"
replace sv_location= "N.M.C.H.T.O.P PS" if ps_name== "N.M.C.H.T.O.P PS" 

replace ps_series="97" if ps_name== "N.M.C.H.T.O.P PS"
replace ps_dist_id="1008_97" if ps_name== "N.M.C.H.T.O.P PS"

*3. G.N.M.C.H. O.P, Bettiah
replace ps_series= "47" if ps_name== "G.N.M.C.H. O.P"
replace ps_dist_id="1002_47" if ps_name== "G.N.M.C.H. O.P"

*4. Vishvidhyalay o.p.
replace ps_name="Vishvidhyalay o.p." if sv_location=="Vishvidhyalay o.p."
replace ps_series= "51" if ps_name== "Vishvidhyalay o.p."
replace ps_dist_id= "1008_51" if ps_name== "Vishvidhyalay o.p."

*5 Ramraj More T.O.P
replace ps_series= "40" if ps_name== "RAMRAJ MORE T.O.P"
replace ps_dist_id= "1011_40" if ps_name== "RAMRAJ MORE T.O.P"


*Note: Now that the above errors have been reconciled, we will move forward by checking and correcting for duplicate entries. 


*Checking for the uniqueness of the ps_dist_id variable
duplicates report ps_dist_id // Several Duplicate entries found which need to be corrected

duplicates tag ps_dist_id, gen(dup_psid)
tab dup_psid
sort dup_psid ps_name

/*Duplicate Entries for the Following PS found:
1. Jakkanpur PS, Patna
2. Sahiyara PS, Sitamarhi
3. Sachivalaya PS, Patna
4. NTPC PS, Patna -- One of them should be Neura Thana
5. Kotawa PS, Motihari -- One of them should be Chainpur PS
6. Agamkuan PS
*/


*1. Jakkanpur PS, Patna
drop if key== "uuid:fea155bc-ec13-4b13-b853-04223c2e6104"

drop if key== "uuid:de0be66a-054f-44cc-97b5-eb10cb4ab5fd"

drop if key=="uuid:bc735391-409d-4044-9fe9-b338e72b509b"

*2. Sahiyara PS, Sitamarhi

drop if key== "uuid:5a587974-b851-4cc4-a41f-50ea0570a33f"

*3. Sachivalaya PS, Patna

drop if key== "uuid:745a58aa-e08b-4ca9-8aaf-9c3040c7e0cb"

*4. Neura Thana,Patna -- Recoded

replace ps_name="Neura Thana" if sv_location=="Neura thana"
replace ps_series="61" if ps_name=="Neura Thana"
replace ps_dist_id="1008_61" if ps_name=="Neura Thana"  //This PS was wrongly recorded as NTPC Thana. The error has now been reconciled and the correct PS name and PS series has been now assigned. Now NTPC O.P and Neura Thana have seperate ids. 

*5. Chainpur PS  -- Recoded

replace ps_name = "Chainpur PS" if sv_location=="Kundwa Chainpur" 
replace ps_series="15" if ps_name=="Chainpur PS"
replace ps_dist_id="1005_15" if ps_name=="Chainpur PS" //This PS was wrongly recorded as Kotawa Thana, Motihari. The error has now been reconciled and the correct PS name and PS series has been now assigned. Now Kotawa Thana and Chainpur PS have seperate ids. 

*6. Agamkuan PS
drop if key== "uuid:acb55f6a-af77-4021-8fc7-719e56f652cb" // Some of the numbers from the two entries do not match. However, this entry is being deleted after considering two factors: 1) consultation from the field supervisor 2) The other entry survey was filled up by a more senior rank Officer, hence, better chances of having a more reliable information. 


*Re-checking Duplicate ids:

drop dup_psid
duplicates tag ps_dist_id, gen(dup_psid)
tab dup_psid
sort dup_psid ps_name //

*19-01-2022: Duplicates found in Vaishali

*Hajipur Sadar Thana has been wrongly input as Town PS 

replace ps_dist_id="1012_20" if key=="uuid:1b540774-0891-4b65-8dd2-652c38ec6b0e"

*Re-checking Duplicate ids:

drop dup_psid
duplicates tag ps_dist_id, gen(dup_psid)
tab dup_psid
sort dup_psid ps_name //No duplicates found


*Dropping superfluous PS Name identifiers:
drop ps_series_os
drop dup_psid
*Checking Strata Variables:


//===========1. Number of FIRs========================//

tab ps_fir, missing
sort ps_fir


*1. Mehandiganj PS

replace ps_fir=154 if ps_dist_id=="1008_57" // The SHO of this PS confirmed this figure -- Call made on 14/December/2022

*2. AIIMS T.O.P 
replace ps_fir=0 if ps_dist_id=="1008_98" //All the FIRs of this O.P are transferred to a main thana, hence number of FIRs recorded is Zero. 

*3. PMCH  T. O. P 
replace ps_fir=0 if ps_dist_id=="1008_74" //All the FIRs of this O.P are transferred to a main thana, hence number of FIRs recorded is Zero. 

*4. I.G.I.A.M.S PS
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 

*5. S.K Puri PS
replace ps_fir=1148 if ps_dist_id=="1008_90"  //After consulting with the nodal officer from Patna, this error has been reconciled. Against the intially recorded 0 number of FIRs, total 1148 FIRs were recored in this PS for the previous year. 

*6 RAMRAJ MORE T.O.P
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 

*7 G.N.M.C.H O.P
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 

*8 BHITTHA O.P SITAMARHI
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 

*9 Vishvidhyalay O.P
drop if ps_dist_id=="1008_51"
//Since there are no Officer's survey recorded for this PS, we are dropping it from the PSFS as well as this PS is no longer a part of our study. 
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 

*10 Pandarak Thana, Patna 
replace ps_fir=141 if ps_dist_id=="1008_66"  //After consulting with the nodal officer from Patna, this error has been reconciled. Against the intially recorded 0 number of FIRs, total 147 FIRs were recored in this PS for the previous year.  

*11 Fakuli OP, Muzaffarpur
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 


*12 Panapur Kariyat (Kati OP)
//The number of FIRs recorded being Zero is fine since it is an O.P and all the cases are transferred to a parent PS. 


*re-checking FIR
tab ps_fir, missing
sort ps_fir ps_dist //All PS with Zero FIRs are OPs

//=============2. Total Number of Officers===============//

*Total Officers Strength


gen po_grandtotal=. 

replace po_grandtotal = po_tot_headconstable + po_tot_wtconstable + po_tot_constable + po_tot_asi + po_tot_si + po_tot_ins + po_tot_sho

la var po_grandtotal "Total Officers Strength in the PS (Strata Variable)"

tab po_grandtotal
sort po_grandtotal

*We need to individually check all the PS where the Total Number of Police Officers posted are <5. 

*1. Shaksohra PS
drop if ps_dist_id=="1008_87"  //This PS is not willing to cooperate and despite of best efforts and multiple calls from SB, field staff and our nodal officer, the information for the number of Officers could not be obtained. It is in the best interest of the study to drop this PS. 

*2. Ramraj More T.O.P
//Confirmed and verified information -- indeed only two officers posted here.

*3. Bhopatpur O.P
//Confirmed and verified information -- indeed only four officers posted here.


**Dropping Airport PS:
drop if ps_dist_id=="1008_11"  //The SHO has refused consent for this PS hence we are dropping this from the sample. 


*Tabulating the two stratifying variables:

tabstat po_grandtotal ps_fir, stat(count max min p25 p50 p75)  //Just some basic checks to make sure everything is in place.


save "$psfs_clean_dta\01.PSFS_clean_PII.dta", replace 

