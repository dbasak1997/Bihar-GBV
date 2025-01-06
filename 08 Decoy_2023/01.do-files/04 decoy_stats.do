
use "$decoy_clean_dta\decoy_clean_WIDE.dta", clear

gen d2a_dum = 0
replace d2a_dum = 1 if d2a_visit1 == 1 | d2a_visit2 == 1 | d2a_visit3 == 1
bysort treatment_station_decoy: tab d2a_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab d2a_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab d2a_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab d2a_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab d2a_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab d2a_dum if ps_dist_decoy == 1011

gen d2c_dum = 0
replace d2c_dum = 1 if d2c_visit1 == 1 | d2c_visit2 == 1 | d2c_visit3 == 1
bysort treatment_station_decoy: tab d2c_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab d2c_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab d2c_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab d2c_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab d2c_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab d2c_dum if ps_dist_decoy == 1011

gen d1d_dum = 0
replace d1d_dum = 1 if d1d_visit1 == 1 | d1d_visit2 == 1 | d1d_visit3 == 1
bysort treatment_station_decoy: tab d1d_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab d1d_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab d1d_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab d1d_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab d1d_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab d1d_dum if ps_dist_decoy == 1011

gen c6_dum = 0
replace c6_dum = 1 if c6_visit1 == 1 | c6_visit2 == 1 | c6_visit3 == 1
bysort treatment_station_decoy: tab c6_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab c6_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab c6_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab c6_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab c6_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab c6_dum if ps_dist_decoy == 1011

gen d2d_dum = 0
replace d2d_dum = 1 if d2d_visit1 == 1 | d2d_visit2 == 1 | d2d_visit3 == 1
bysort treatment_station_decoy: tab d2d_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab d2d_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab d2d_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab d2d_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab d2d_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab d2d_dum if ps_dist_decoy == 1011

gen d3a_dum = 0
replace d3a_dum = 1 if d3a_visit1 == 1 | d3a_visit2 == 1 | d3a_visit3 == 1
bysort treatment_station_decoy: tab d3a_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab d3a_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab d3a_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab d3a_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab d3a_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab d3a_dum if ps_dist_decoy == 1011

gen d4b_dum = 0
replace d4b_dum = 1 if d4b_visit1 == 1 | d4b_visit2 == 1 | d4b_visit3 == 1
bysort treatment_station_decoy: tab d4b_dum if ps_dist_decoy == 1003
bysort treatment_station_decoy: tab d4b_dum if ps_dist_decoy == 1004
bysort treatment_station_decoy: tab d4b_dum if ps_dist_decoy == 1006
bysort treatment_station_decoy: tab d4b_dum if ps_dist_decoy == 1007
bysort treatment_station_decoy: tab d4b_dum if ps_dist_decoy == 1010
bysort treatment_station_decoy: tab d4b_dum if ps_dist_decoy == 1011


foreach var in visit1 visit2 visit3 {
	replace c4_`var'= . if c4_`var' == -999
}
egen c4_mean = rowmean (c4_visit1 c4_visit2 c4_visit3)


foreach var of varlist d2a_dum d2c_dum d1d_dum c6_dum d2d_dum d3a_dum d4b_dum { 
	bysort treatment_station_decoy: tab `var'
}
bysort treatment_station_decoy: summ c4_mean 