set more off
macro drop _all 


global ortho /gpfs/home/baes03/tkrthr
global core /gpfs/home/baes03/srtr/usrds/stata/core2023/esrd
global inc /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/in
global rev /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/in
global det /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/in
global ps /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/ps

global pro "mjr_wmcc mjr_womcc tha tka"

***************************************************
		       *CASEY THK/THA*
		       	*2021/12/06*
***************************************************

**************************************************
*Make sure claims happen after first txp -- tx is more complete -- 
use $core/tx, clear 
keep tdate trr_id_code usrds_id
joinby usrds_id using $ortho/inc_rev_mjr_ortho, unmatched(none)
compare tdate clm_from
drop if tdate>=clm_from
save $ortho/inc_rev_mjr_ortho_txp, replace 

*PS
use $core/tx, clear 
keep tdate trr_id_code usrds_id
joinby usrds_id using $ortho/ps_mjr_ortho_pre, unmatched(none)
compare tdate clm_from
drop if tdate>=clm_from
save $ortho/ps_mjr_ortho_txp, replace 

***************************************************
*Now 1 claim per person
use $ortho/inc_rev_mjr_ortho_txp, clear
foreach v of varlist tha tka mjr_womcc mjr_wmcc {
   bys usrds_id: egen xx__`v'=min(clm_from) if `v'==1
   bys usrds_id: egen clm_from_`v'=min(xx__`v')
   drop xx__`v'
   replace `v'=0 if clm_from_`v'==.
}

tempfile ortho_txp_a
save `ortho_txp_a', replace 

use $ortho/ps_mjr_ortho_txp, clear
foreach v of varlist tha tka  {
   bys usrds_id: egen xx__`v'=min(clm_from) if `v'==1
   bys usrds_id: egen clm_from_`v'=min(xx__`v')
   drop xx__`v'
   replace `v'=0 if clm_from_`v'==.
}

tempfile ortho_txp_b
save `ortho_txp_b', replace 

use `ortho_txp_a', clear
capture append using `ortho_txp_b'

foreach v of varlist tha tka  {
   bys usrds_id: egen xx__`v'=min(clm_from_`v') if `v'==1
   bys usrds_id: egen min_clm_from_`v'=min(xx__`v')
   drop xx__`v'
   replace `v'=0 if min_clm_from_`v'==.
}

collapse (min) clm_from_* min_clm_from_* (max) tha tka mjr_womcc mjr_wmcc, by(usrds_id trr_id_code) fast

drop clm_from_tha clm_from_tka
rename min_clm_from_tha clm_from_tha
rename min_clm_from_tka clm_from_tka

egen clm_from_final = rowmin(clm_from_*)
format %td clm_from_final

save $ortho/ortho_claims_clean_txp, replace 

***************************************************
use $core/tx, clear //trr_ki and drop multiorgan
keep if rage>=18
keep if year>=2008
drop if tdate>td(31dec2018)
drop if mi(trr_id_code)
joinby usrds_id using $ortho/elig_ortho_casey
keep if inrange(tdate, begdate_new, enddate_new)
joinby usrds_id using $ortho/ortho_claims_clean_txp, unmatched(master)
drop _merge 

foreach p in $pro { 
   replace clm_from_`p' = . if !inrange(clm_from_`p', tdate, enddate_new)
   replace `p' = . if clm_from_`p'==. 
   replace `p' = 0 if clm_from_`p'==. 
} 

drop clm_from_final 
egen clm_from_final = rowmin(*clm_from*)
format %td clm_from_final

duplicates drop 

gen year_clm = year(clm_from_final)
tab year_clm, m 

duplicates tag usrds_id, gen(dup)
tab dup

/* drop if mjr_wmcc==. & trr_id==471499
drop if tha== . & trr_id==597381 */

gen thk = !mi(clm_from_final)

save $ortho/ortho_clean_txp, replace 

***************************************************

use $core/txunos_trr_ki.dta, clear 
split trr_id_code, parse("A") gen(trr_id)
drop trr_id1
destring trr_id2,replace
rename trr_id2 trr_id
keep usrds_id trr_id bmi rsex hgt wgt orgtyp age perm_state
tempfile tx
save `tx', replace

use $ortho/ortho_clean_txp, clear
merge m:1 usrds_id using $core/patients, keepusing(died race sex disgrpc) keep(match) nogen
merge 1:1 usrds_id trr_id using `tx', keep(match) nogen
merge 1:m usrds_id trr_id using $core/tx.dta, keepusing(rhisp rage) keep(match) nogen

