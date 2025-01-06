/*==============================================================================
File Name: Adding PS level variables
Project: Debiasing Police Officers in Bihar
Authors: Amaral, Borker, Prakash, Sviatschi
Created on:	03/01/2023
Created by: Dibyajyoti Basak
Updated on: 04/09/2024
Updated by:	Dibyajyoti Basak

*Notes READ ME:
*This is the Do file to import variables for PS-level data


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

log using "$addl_controls_log_files\psvars_import.log", replace text

* We will add this line from time to time if the program takes time to compute or uses a lot of loops
noisily display as text "The date is " as result "--$S_DATE--" as text " and the time is " as result "--$S_TIME--"

use "$psfs_clean_dta\psfs_combined.dta", clear
keep ps_dist_id treatment strata popdensity po_grandtotal
tempfile psfs_rough
save `psfs_rough'
clear

import dbase using "$addl_controls_raw\Health Facilities Shapefile\Nearest 5 HF per PS.dbf"
drop ps_lat-lgd_statec
gen distance_km = distance/0.008
bysort ps_dist_id: egen avgdistance_healthfacility = mean(distance_km)
duplicates drop ps_dist_id, force
tempfile healthfacilities
save `healthfacilities'

clear
import dbase using "$addl_controls_raw\GIS\districtidentifiers.dbf"
drop sd_name_2
rename pc11_s_id pc11_state_id
rename pc11_d_id_ pc11_district_id
rename pc11_sd_id pc11_subdistrict_id
tempfile districtidentifiers
save `districtidentifiers'

clear
import dbase using "$addl_controls_raw\GIS\straightline_distance.dbf"
tempfile straight_distance
save `straight_distance'

clear
import dbase using "$addl_controls_raw\GIS\PS_stats.dbf"
replace PS_Code = 1 if PS_NAME == "ARERAJ O.P"
replace PS_Code = 2 if PS_NAME == "LAKHAURA O.P"
replace PS_Code = 3 if PS_NAME == "RAGHUNATHPUR O.P"
rename PS_Code ps_code
rename PS_NAME ps_name_jurisdiction
tempfile ps_stats
save `ps_stats'


use "$addl_controls_raw\pmgsy_2015_shrid.dta", clear
split shrid, parse("-")
drop shrid5
drop if shrid1 == "01"

gen statecode_2011=""
replace statecode_2011 = shrid2 if shrid1 == "11"
gen districtcode_2011=""
replace districtcode_2011 = shrid3 if shrid1 == "11"
gen subdistrictcode_2011=""
replace subdistrictcode_2011 = shrid4 if shrid1 == "11"

/*
gen statecode_2001=""
replace statecode_2001 = shrid2 if shrid1 == "01"  
gen districtcode_2001=""
replace districtcode_2001 = shrid3 if shrid1 == "01"

destring statecode_2001, replace
destring districtcode_2001, replace

merge m:m statecode_2001 districtcode_2001 using "C:\Users\dibbo\Dropbox\Land Conflict_Lead\Analysis_2024\00 District Identifiers\00.raw-data\Census Identifiers.dta"
drop if _merge == 2
foreach var of varlist state_2011 districtname_2011 state_2001 districtname_2001 state_1991 statecode_1991 districtname_1991 districtcode_1991 LinkID censusdist_uniqid {
	gen `var'_temp = `var'
}
drop _merge state_2011 districtname_2011 state_2001 districtname_2001 state_1991 statecode_1991 districtname_1991 districtcode_1991 LinkID censusdist_uniqid

merge m:1 statecode_2011 districtcode_2011 using "C:\Users\dibbo\Dropbox\Land Conflict_Lead\Analysis_2024\00 District Identifiers\00.raw-data\Census Identifiers.dta"
drop if _merge == 2
drop _merge


foreach var of varlist state_2011 districtname_2011 state_2001 districtname_2001 state_1991 statecode_1991 districtname_1991 districtcode_1991 LinkID censusdist_uniqid {
	replace `var' = `var'_temp if shrid1 == "01"
}
*/

local vars road_award_date_new road_award_date_upg

foreach var in `vars' {
    // Convert the numeric variable to a datetime format
    gen datetime_`var' = dofc(`var')
    format datetime_`var' %td
    
    // Extract the year from the datetime variable
    gen year_`var' = year(datetime_`var')
}


local years 1960 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019

foreach year in `years' {
    // Count non-missing values in year_road_award_date_new
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_new: gen count_new_`year' = sum(!missing(year_road_award_date_new) & year_road_award_date_new == `year')

    // Sum road_length_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_new: gen length_new_`year' = sum(road_length_new) if year_road_award_date_new == `year'

    // Sum road_cost_sanc_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_new: gen totalcost_new_`year' = sum(road_cost_new) if year_road_award_date_new == `year'
	
	// Sum road_cost_sanc_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_new: gen sanctionedcost_new_`year' = sum(road_cost_sanc_new) if year_road_award_date_new == `year'

    // Sum road_cost_state_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_new: gen statecost_new_`year' = sum(road_cost_state_new) if year_road_award_date_new == `year'
}

foreach year in `years' {
    // Count non-missing values in year_road_award_date_new
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_upg: gen count_upg_`year' = sum(!missing(year_road_award_date_upg) & year_road_award_date_upg == `year')

    // Sum road_length_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_upg: gen length_upg_`year' = sum(road_length_upg) if year_road_award_date_upg == `year'

     // Sum road_cost_sanc_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_upg: gen totalcost_upg_`year' = sum(road_cost_upg) if year_road_award_date_upg == `year'
	
	// Sum road_cost_sanc_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_upg: gen sanctionedcost_upg_`year' = sum(road_cost_sanc_upg) if year_road_award_date_upg == `year'

    // Sum road_cost_state_new for the specific year
    bysort statecode_2011 districtcode_2011 subdistrictcode_2011 year_road_award_date_upg: gen statecost_upg_`year' = sum(road_cost_state_upg) if year_road_award_date_upg == `year'
}

keep statecode_2011 districtcode_2011 subdistrictcode_2011 count_new_* count_upg_* length_new_* length_upg_* totalcost_new_* totalcost_upg_* sanctionedcost_new_* sanctionedcost_upg_* statecost_new_* statecost_upg_*
order statecode_2011 districtcode_2011 subdistrictcode_2011 count_new_* count_upg_* length_new_* length_upg_* totalcost_new_* totalcost_upg_* sanctionedcost_new_* sanctionedcost_upg_* statecost_new_* statecost_upg_*


foreach var of varlist count_new_* count_upg_* {
	bysort statecode_2011 districtcode_2011 subdistrictcode_2011: egen `var'2 = max(`var')
	replace `var' = `var'2
	drop `var'2
	}
foreach var of varlist length_new_* length_upg_* totalcost_new_* totalcost_upg_* sanctionedcost_new_* sanctionedcost_upg_* statecost_new_* statecost_upg_* {
	bysort statecode_2011 districtcode_2011 subdistrictcode_2011: egen `var'2 = sum(`var')
	replace `var' = `var'2
	drop `var'2
	}
	
duplicates drop statecode_2011 districtcode_2011 subdistrictcode_2011, force
egen length_newroads = rowtotal(length_new_1960 length_new_1997 length_new_1998 length_new_1999 length_new_2000 length_new_2001 length_new_2002 length_new_2003 length_new_2004 length_new_2005 length_new_2006 length_new_2007 length_new_2008 length_new_2009 length_new_2010 length_new_2011 length_new_2012 length_new_2013 length_new_2014 length_new_2015 length_new_2016 length_new_2017 length_new_2018 length_new_2019)
egen length_upgradedroads = rowtotal(length_upg_1960 length_upg_1997 length_upg_1998 length_upg_1999 length_upg_2000 length_upg_2001 length_upg_2002 length_upg_2003 length_upg_2004 length_upg_2005 length_upg_2006 length_upg_2007 length_upg_2008 length_upg_2009 length_upg_2010 length_upg_2011 length_upg_2012 length_upg_2013 length_upg_2014 length_upg_2015 length_upg_2016 length_upg_2017 length_upg_2018 length_upg_2019)
*save "${intermediate_dta}PMGSY_district.dta", replace
keep statecode_2011 districtcode_2011 subdistrictcode_2011 length_newroads length_upgradedroads
rename statecode_2011 pc11_state_id
rename districtcode_2011 pc11_district_id
rename subdistrictcode_2011 pc11_subdistrict_id
tempfile PMGSY
save `PMGSY'


clear
import delimited  "$addl_controls_raw\PS_variables.csv"
drop pc11_d_id pc11_sd_id sd_name straightline_length_km

gen time_numeric = clock(drivingtime_hhmm, "hm")
format time_numeric %tcHH:MM
drop drivingtime_hhmm
rename time_numeric drivingtime_hhmm
gen hours = hh(drivingtime_hhmm)
gen minutes = mm(drivingtime_hhmm)
gen seconds = ss(drivingtime_hhmm)
gen drivingtime_seconds = hours * 3600 + minutes * 60 + seconds
drop hours minutes seconds

merge 1:1 ps_dist_id using `districtidentifiers'
drop if _m != 3
drop _m

merge 1:1 ps_dist_id using `straight_distance'
drop if _m != 3
drop _m

replace ps_code = 1 if ps_dist_id == "1005_11"
replace ps_code = 2 if ps_dist_id == "1005_35"
replace ps_code = 3 if ps_dist_id == "1005_51"

merge m:1 ps_code using `ps_stats'
drop if _m != 3
drop _m

merge 1:1 ps_dist_id using `healthfacilities'
drop if _m != 3
drop _m

drop ps_dist
merge 1:1 ps_dist_id using `psfs_rough'
drop if _m != 3
drop _m

merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id using "$addl_controls_raw\elevation_pc11subdist.dta"

drop if _m != 3
drop _m

merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id using "$addl_controls_raw\tri_pc11subdist.dta"

drop if _m != 3
drop _m

merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id using `PMGSY'

drop if _m != 3
drop _m

merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id using "$addl_controls_raw\pc11_td_clean_pc11subdist.dta"

drop if _m == 2
drop _m

gen lengthroads_rural = length_newroads + length_upgradedroads
gen lengthroads_urban = pc11_td_k_road + pc11_td_p_road

rename straightli straightline_length_km
rename densitymea populationdensity_ps


la var straightline_length_km "Straight line distance between PS and nearest highway (in km)"
la var road_length_km "Road distance between PS and nearest highway (in km)"
la var drivingtime_hhmm "Driving time between PS and nearest highway (in hh:mm)"
la var drivingtime_seconds "Driving time between PS and nearest highway (in seconds)"
la var length_newroads "Length of newly constructed rural roads (in km)"
la var length_upgradedroads "Length of newly upgraded rural roads (in km)"
la var lengthroads_rural "Length of newly constructed rural roads (in km)"
la var lengthroads_urban "Length of urban roads (in km)"
la var avgdistance_healthfacility "Avg distance to nearest 5 healthcare facilities for each PS (in km)"  

gen populationestimate = populationdensity_ps * area_ps_sq
bysort ps_code: egen policestrength_jurisdiction = sum(po_grandtotal)
summ policestrength_jurisdiction
gen policestrength_perlakhpop = (policestrength_jurisdiction/populationestimate) * 100000
replace lengthroads_urban = 0 if lengthroads_urban ==.

la var populationestimate "Population estimate in PS jurisdiction"
la var policestrength_jurisdiction "Officer strength in PS jurisdiction"
la var policestrength_perlakhpop "Officer strength per lakh population"

order ps_dist ps_name ps_dist_id ps_code ps_name_jurisdiction ps_lat ps_long highway_lat highway_long pc11_state_id pc11_district_id pc11_subdistrict_id straightline_length_km road_length_km drivingtime_hhmm drivingtime_seconds populationestimate policestrength_jurisdiction policestrength_perlakhpop elevation_mean tri_mean length_newroads length_upgradedroads lengthroads_rural pc11_td_k_road pc11_td_p_road lengthroads_urban avgdistance_healthfacility

keep ps_dist ps_name ps_dist_id ps_code ps_name_jurisdiction ps_lat ps_long highway_lat highway_long pc11_state_id pc11_district_id pc11_subdistrict_id straightline_length_km road_length_km drivingtime_hhmm drivingtime_seconds populationestimate policestrength_jurisdiction policestrength_perlakhpop elevation_mean tri_mean length_newroads length_upgradedroads lengthroads_rural pc11_td_k_road pc11_td_p_road lengthroads_urban avgdistance_healthfacility

sort ps_dist ps_dist_id

save "$addl_controls_clean_dta\PS_variables.dta", replace

