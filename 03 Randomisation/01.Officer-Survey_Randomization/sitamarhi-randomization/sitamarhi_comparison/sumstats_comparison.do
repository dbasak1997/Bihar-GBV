/*Comparison of sum-stats: Sitamarhi


Author: SB
Date: 14 December 2022 

*/


use "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization\01.Officer-Survey_Randomization\001.sitamarhi-randomization\sitamarhi_comparison\PSFSclean_17Oct22_Deidentified_8Nov22_VW.dta"

*keep only Sitamarhi

keep if ps_dist== 1010
tab ps_dist_id, missing


keep ps_dist_id ps_confidential ps_bathroom ps_fembathroom ps_confidential ps_femconfidential ps_electricity ps_fourwheeler ps_twowheeler ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_fembarrack ps_suffbarrack ps_storage ps_evidence ps_phone ps_lockup ps_femlockup ps_shelter ps_femshelter ps_cctv ps_new_cctv ps_fir po_m_headconstable po_f_headconstable po_tot_headconstable po_m_wtconstable po_f_wtconstable po_tot_wtconstable po_m_constable po_f_constable po_tot_constable po_m_asi po_f_asi po_tot_asi po_m_si po_f_si po_tot_si po_m_ins po_f_ins po_tot_ins po_m_sho po_f_sho po_tot_sho 

gen ra_id=0

gen po_grandtotal=. 

replace po_grandtotal = po_tot_headconstable + po_tot_wtconstable + po_tot_constable + po_tot_asi + po_tot_si + po_tot_ins + po_tot_sho

la var po_grandtotal "Total Officers Strength in the PS (Strata Variable)"


*Appending SB Clean dataset
append using "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization\01.Officer-Survey_Randomization\001.sitamarhi-randomization\sitamarhi_comparison\sitamarhi-PSFS_SB.dta"


global variables "po_grandtotal ps_fir ps_confidential ps_bathroom ps_fembathroom ps_confidential ps_femconfidential ps_electricity ps_fourwheeler ps_twowheeler ps_computer ps_seating ps_cleaning ps_water ps_barrack ps_fembarrack ps_suffbarrack ps_storage ps_evidence ps_phone ps_lockup ps_femlockup ps_shelter ps_femshelter ps_cctv po_m_headconstable po_f_headconstable po_tot_headconstable po_m_wtconstable po_f_wtconstable po_tot_wtconstable po_m_constable po_f_constable po_tot_constable po_m_asi po_f_asi po_tot_asi po_m_si po_f_si po_tot_si po_m_ins po_f_ins po_tot_ins po_m_sho po_f_sho po_tot_sho"

estpost ttest $variables, by(ra_id)

estimates store sitamarhi_sb_vw

esttab sitamarhi_sb_vw using "D:\Dropbox_SB\Dropbox\Debiasing Police in India\005-Data-and-analysis-2022\Randomization\01.Officer-Survey_Randomization\001.sitamarhi-randomization\sitamarhi_comparison\sitamarhi-comparison.csv" , ///
	cells("mu_1(fmt(3) label(Vishakha)) mu_2(fmt(3) label(Shubhro)) p(fmt(3) label(P-value of Diff) star)") ///
	nonotes replace label noobs ///
	star(* 0.10 ** 0.05 *** 0.01) nonumbers alignment(ccc) gaps width(\hsize)










