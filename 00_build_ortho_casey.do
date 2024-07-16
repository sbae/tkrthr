set more off
macro drop _all 


global ortho /gpfs/home/baes03/tkrthr
global core /gpfs/home/baes03/srtr/usrds/stata/core2023/esrd
global inc /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/in
global rev /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/in
global det /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/in
global ps /gpfs/home/baes03/srtr/usrds/stata/claims_v1/esrd/ps

global pro "mjr_wmcc mjr_womcc tha tka"

global start_dt = td(01jan2000)

capture log close //closing all logs 
local cdat: di %tdCCYYNNDD date(c(current_date),"DMY") // converting current date as a string to numberic and storing it in a macro 
di "`cdat'" // display macro 
log using $ortho/motter_build_ortho_`cdat'.log, replace  


***************************************************
		       *CASEY THK/THA*
		       	*2021/12/06*
***************************************************

*II.PULL CLAIMS: DRG CODES
clear
forvalues y=2008/2018 {  
   clear 
      /* if inrange(`y', 2008, 2011) {  
      foreach seq in a b c d e f g h i j k l m n o p q r s t w x y z {
            capture append using $inc/inc`y'`seq'
            if _rc==0 di "file DET`y'`seq' loading complete"
      }
   }  
   
   else if inrange(`y',2012,2018) { */
      capture append using $inc/ip_clm_`y'
         if _rc==0 di "file INC`y' loading complete"
         
   /* } */

   tempfile clm_inc`y'

   gen mjr_wmcc = . 
   replace mjr_wmcc = 1 if drg_cd=="469"
   
   gen mjr_womcc= . 
   replace mjr_womcc = 1 if drg_cd=="470"


   keep usrds_id clm_from mjr_womcc mjr_wmcc hcfasaf seq_key drg_cd
   keep if mjr_wmcc==1 | mjr_womcc==1
   collapse (max) mjr_womcc mjr_wmcc (firstnm) drg_cd, by(usrds_id clm_from hcfasaf seq_key) fast
   rename clm_from clm_from_`y'

   compress
   
   save `clm_inc`y'', replace     

}

*APPEND 
clear
forvalue y=2008/2018 {
   capture append using `clm_inc`y''
   if _rc==0 di "file `y' loading complete"
}

save $ortho/inc_mjr_ortho_v1, replace 


*II.PULL CLAIMS: ICD-9/10 codes -- detailed 
clear
forvalues y=2008/2018 {   
/* forvalues y=2008/2017 {   */
   clear 
      /* if inrange(`y',2008,2011) {
         foreach seq in a b c d e f g h i j k l m n o p q r s t w x y z {
            capture append using $rev/rev`y'`seq'
            if _rc==0 di "file DET`y'`seq' loading complete"
      }
   }     
    
   else if inrange(`y',2012,2017) { */
      foreach src in ip {
         capture append using $rev/`src'_det_`y'
               if _rc==0 di "file DET`y'`seq' loading complete"
      }
   /* } */

   tempfile clm_det`y'

   gen tha = . 
   replace tha = 1 if code =="8151" 
   replace tha = 1 if code =="0SR90J9"
   replace tha = 1 if code =="0SR90JA"
   replace tha = 1 if code =="0SR90JZ"
   replace tha = 1 if code =="0SRB0J9"
   replace tha = 1 if code =="0SRB0JA"
   replace tha = 1 if code =="0SRB0JZ"
   replace tha = 1 if regexm(code, "0SR901")
   replace tha = 1 if regexm(code, "0SR902")
   replace tha = 1 if regexm(code, "0SR903")
   replace tha = 1 if regexm(code, "0SR904")
   replace tha = 1 if regexm(code, "0SR906")
   replace tha = 1 if regexm(code, "0SRB01")
   replace tha = 1 if regexm(code, "0SRB02")
   replace tha = 1 if regexm(code, "0SRB03")
   replace tha = 1 if regexm(code, "0SRB04")
   replace tha = 1 if regexm(code, "0SRB06")
   replace tha = 1 if hcpcs=="27130"


   gen tka = . 
   replace tka = 1 if code=="8154"
   replace tka = 1 if code=="0SRC06Z"
   replace tka = 1 if code=="0SRD06Z"
   replace tka = 1 if code=="0SRC07Z"
   replace tka = 1 if code=="0SRD07Z"
   replace tka = 1 if code=="0SRC0JZ"
   replace tka = 1 if code=="0SRD0JZ"
   replace tka = 1 if code=="0SRC0KZ"
   replace tka = 1 if code=="0SRD0KZ"
   replace tka = 1 if code=="0SRC0LZ"
   replace tka = 1 if code=="0SRD0LZ"
   replace tka = 1 if code=="0SRT07Z"
   replace tka = 1 if code=="0SRU07Z"
   replace tka = 1 if code=="0SRT0JZ"
   replace tka = 1 if code=="0SRU0JZ"
   replace tka = 1 if code=="0SRT0KZ"
   replace tka = 1 if code=="0SRU0KZ"
   replace tka = 1 if code=="0SRV07Z"
   replace tka = 1 if code=="0SRW07Z"
   replace tka = 1 if code=="0SRV0JZ"
   replace tka = 1 if code=="0SRW0JZ"
   replace tka = 1 if code=="0SRV0KZ"
   replace tka = 1 if code=="0SRW0KZ"
   replace tka = 1 if hcpcs=="27447"

   /*gen hha = . 
   replace hha = 1 if code=="8152"
   replace hha = 1 if code=="0SRA009"
   replace hha = 1 if code=="0SRE009"
   replace hha = 1 if code=="0SRA00A"
   replace hha = 1 if code=="0SRE00A"
   replace hha = 1 if code=="0SRA00Z"
   replace hha = 1 if code=="0SRE00Z"
   replace hha = 1 if code=="0SRA019"
   replace hha = 1 if code=="0SRE019"
   replace hha = 1 if code=="0SRA01A"
   replace hha = 1 if code=="0SRE01A"
   replace hha = 1 if code=="0SRA01Z"
   replace hha = 1 if code=="0SRE01Z"
   replace hha = 1 if code=="0SRA039"
   replace hha = 1 if code=="0SRE039"
   replace hha = 1 if code=="0SRA03A"
   replace hha = 1 if code=="0SRE03A"
   replace hha = 1 if code=="0SRA03Z"
   replace hha = 1 if code=="0SRE03Z"
   replace hha = 1 if code=="0SRA07Z"
   replace hha = 1 if code=="0SRE07Z"
   replace hha = 1 if code=="0SRA0J9"
   replace hha = 1 if code=="0SRE0J9"
   replace hha = 1 if code=="0SRA0JA"
   replace hha = 1 if code=="0SRE0JA"
   replace hha = 1 if code=="0SRA0JZ"
   replace hha = 1 if code=="0SRE0JZ"
   replace hha = 1 if code=="0SRA0KZ"
   replace hha = 1 if code=="0SRE0KZ"
   replace hha = 1 if regexm(code,"0SSR")
   replace hha = 1 if regexm(code,"0SRS")*/

   keep usrds_id clm_from hcfasaf seq_key tha tka 
   keep if tha==1 | tka==1 
   collapse (max) tha tka, by(usrds_id clm_from hcfasaf seq_key) fast
   rename clm_from clm_from_`y'

   compress
   
   save `clm_det`y'', replace     

}

*APPEND 
clear
/* forvalue y=2008/2017 { */
forvalue y=2008/2018 {
   capture append using `clm_det`y''
   if _rc==0 di "file `y' loading complete"
}

save $ortho/rev_mjr_ortho, replace 

*II.PULL CLAIMS: ICD-9/10 codes -- detailed //no claims in 2018
clear
forvalues y=2008/2018 {  
   clear 
      /* if inrange(`y',2008,2011) {
         foreach seq in a b c d e f g h i j k l m n o p q r s t w x y z {
            capture append using $det/det`y'`seq'
            if _rc==0 di "file DET`y'`seq' loading complete"
      }
   }     
    
   else if inrange(`y',2012,2018) { */
      foreach src in ip {
         capture append using $det/`src'_dxp_`y'
               if _rc==0 di "file DET`y'`seq' loading complete"
      }
   /* } */

   tempfile clm_det`y'

   gen tha = . 
   replace tha = 1 if code =="8151" 
   replace tha = 1 if code =="0SR90J9"
   replace tha = 1 if code =="0SR90JA"
   replace tha = 1 if code =="0SR90JZ"
   replace tha = 1 if code =="0SRB0J9"
   replace tha = 1 if code =="0SRB0JA"
   replace tha = 1 if code =="0SRB0JZ"
   replace tha = 1 if regexm(code, "0SR901")
   replace tha = 1 if regexm(code, "0SR902")
   replace tha = 1 if regexm(code, "0SR903")
   replace tha = 1 if regexm(code, "0SR904")
   replace tha = 1 if regexm(code, "0SR906")
   replace tha = 1 if regexm(code, "0SRB01")
   replace tha = 1 if regexm(code, "0SRB02")
   replace tha = 1 if regexm(code, "0SRB03")
   replace tha = 1 if regexm(code, "0SRB04")
   replace tha = 1 if regexm(code, "0SRB06")


   gen tka = . 
   replace tka = 1 if code=="8154"
   replace tka = 1 if code=="0SRC06Z"
   replace tka = 1 if code=="0SRD06Z"
   replace tka = 1 if code=="0SRC07Z"
   replace tka = 1 if code=="0SRD07Z"
   replace tka = 1 if code=="0SRC0JZ"
   replace tka = 1 if code=="0SRD0JZ"
   replace tka = 1 if code=="0SRC0KZ"
   replace tka = 1 if code=="0SRD0KZ"
   replace tka = 1 if code=="0SRC0LZ"
   replace tka = 1 if code=="0SRD0LZ"
   replace tka = 1 if code=="0SRT07Z"
   replace tka = 1 if code=="0SRU07Z"
   replace tka = 1 if code=="0SRT0JZ"
   replace tka = 1 if code=="0SRU0JZ"
   replace tka = 1 if code=="0SRT0KZ"
   replace tka = 1 if code=="0SRU0KZ"
   replace tka = 1 if code=="0SRV07Z"
   replace tka = 1 if code=="0SRW07Z"
   replace tka = 1 if code=="0SRV0JZ"
   replace tka = 1 if code=="0SRW0JZ"
   replace tka = 1 if code=="0SRV0KZ"
   replace tka = 1 if code=="0SRW0KZ"


   /*gen hha = . 
   replace hha = 1 if code=="8152"
   replace hha = 1 if code=="0SRA009"
   replace hha = 1 if code=="0SRE009"
   replace hha = 1 if code=="0SRA00A"
   replace hha = 1 if code=="0SRE00A"
   replace hha = 1 if code=="0SRA00Z"
   replace hha = 1 if code=="0SRE00Z"
   replace hha = 1 if code=="0SRA019"
   replace hha = 1 if code=="0SRE019"
   replace hha = 1 if code=="0SRA01A"
   replace hha = 1 if code=="0SRE01A"
   replace hha = 1 if code=="0SRA01Z"
   replace hha = 1 if code=="0SRE01Z"
   replace hha = 1 if code=="0SRA039"
   replace hha = 1 if code=="0SRE039"
   replace hha = 1 if code=="0SRA03A"
   replace hha = 1 if code=="0SRE03A"
   replace hha = 1 if code=="0SRA03Z"
   replace hha = 1 if code=="0SRE03Z"
   replace hha = 1 if code=="0SRA07Z"
   replace hha = 1 if code=="0SRE07Z"
   replace hha = 1 if code=="0SRA0J9"
   replace hha = 1 if code=="0SRE0J9"
   replace hha = 1 if code=="0SRA0JA"
   replace hha = 1 if code=="0SRE0JA"
   replace hha = 1 if code=="0SRA0JZ"
   replace hha = 1 if code=="0SRE0JZ"
   replace hha = 1 if code=="0SRA0KZ"
   replace hha = 1 if code=="0SRE0KZ"
   replace hha = 1 if regexm(code,"0SSR")
   replace hha = 1 if regexm(code,"0SRS")*/

   keep usrds_id clm_from hcfasaf seq_key tha tka
   keep if tha==1 | tka==1 
   collapse (max) tha tka, by(usrds_id clm_from hcfasaf seq_key) fast
   rename clm_from clm_from_`y'

   compress
   
   save `clm_det`y'', replace     

}

*APPEND 
clear
forvalue y=2008/2018 {
   capture append using `clm_det`y''
   if _rc==0 di "file `y' loading complete"
}

save $ortho/inc_mjr_ortho_v2, replace 


*IV.PULL CLAIMS: PS 
/* clear
forvalues y=2008/2011 {  
   clear 
      if inrange(`y',2008,2011) {
         foreach seq in a b c d e f g h i j k l m n o p q r s t w x y z {
            capture append using $ps/ps`y'`seq'
            if _rc==0 di "file PS`y'`seq' loading complete"
      }
   }     

   tempfile clm_ps`y'
   rename diag code

   gen tha = . 
   replace tha = 1 if code =="8151" 
   replace tha = 1 if code =="0SR90J9"
   replace tha = 1 if code =="0SR90JA"
   replace tha = 1 if code =="0SR90JZ"
   replace tha = 1 if code =="0SRB0J9"
   replace tha = 1 if code =="0SRB0JA"
   replace tha = 1 if code =="0SRB0JZ"
   replace tha = 1 if regexm(code, "0SR901")
   replace tha = 1 if regexm(code, "0SR902")
   replace tha = 1 if regexm(code, "0SR903")
   replace tha = 1 if regexm(code, "0SR904")
   replace tha = 1 if regexm(code, "0SR906")
   replace tha = 1 if regexm(code, "0SRB01")
   replace tha = 1 if regexm(code, "0SRB02")
   replace tha = 1 if regexm(code, "0SRB03")
   replace tha = 1 if regexm(code, "0SRB04")
   replace tha = 1 if regexm(code, "0SRB06")
   replace tha = 1 if hcpcs=="27130"


   gen tka = . 
   replace tka = 1 if code=="8154"
   replace tka = 1 if code=="0SRC06Z"
   replace tka = 1 if code=="0SRD06Z"
   replace tka = 1 if code=="0SRC07Z"
   replace tka = 1 if code=="0SRD07Z"
   replace tka = 1 if code=="0SRC0JZ"
   replace tka = 1 if code=="0SRD0JZ"
   replace tka = 1 if code=="0SRC0KZ"
   replace tka = 1 if code=="0SRD0KZ"
   replace tka = 1 if code=="0SRC0LZ"
   replace tka = 1 if code=="0SRD0LZ"
   replace tka = 1 if code=="0SRT07Z"
   replace tka = 1 if code=="0SRU07Z"
   replace tka = 1 if code=="0SRT0JZ"
   replace tka = 1 if code=="0SRU0JZ"
   replace tka = 1 if code=="0SRT0KZ"
   replace tka = 1 if code=="0SRU0KZ"
   replace tka = 1 if code=="0SRV07Z"
   replace tka = 1 if code=="0SRW07Z"
   replace tka = 1 if code=="0SRV0JZ"
   replace tka = 1 if code=="0SRW0JZ"
   replace tka = 1 if code=="0SRV0KZ"
   replace tka = 1 if code=="0SRW0KZ"
   replace tka = 1 if hcpcs=="27447"

   /*gen hha = . 
   replace hha = 1 if code=="8152"
   replace hha = 1 if code=="0SRA009"
   replace hha = 1 if code=="0SRE009"
   replace hha = 1 if code=="0SRA00A"
   replace hha = 1 if code=="0SRE00A"
   replace hha = 1 if code=="0SRA00Z"
   replace hha = 1 if code=="0SRE00Z"
   replace hha = 1 if code=="0SRA019"
   replace hha = 1 if code=="0SRE019"
   replace hha = 1 if code=="0SRA01A"
   replace hha = 1 if code=="0SRE01A"
   replace hha = 1 if code=="0SRA01Z"
   replace hha = 1 if code=="0SRE01Z"
   replace hha = 1 if code=="0SRA039"
   replace hha = 1 if code=="0SRE039"
   replace hha = 1 if code=="0SRA03A"
   replace hha = 1 if code=="0SRE03A"
   replace hha = 1 if code=="0SRA03Z"
   replace hha = 1 if code=="0SRE03Z"
   replace hha = 1 if code=="0SRA07Z"
   replace hha = 1 if code=="0SRE07Z"
   replace hha = 1 if code=="0SRA0J9"
   replace hha = 1 if code=="0SRE0J9"
   replace hha = 1 if code=="0SRA0JA"
   replace hha = 1 if code=="0SRE0JA"
   replace hha = 1 if code=="0SRA0JZ"
   replace hha = 1 if code=="0SRE0JZ"
   replace hha = 1 if code=="0SRA0KZ"
   replace hha = 1 if code=="0SRE0KZ"
   replace hha = 1 if regexm(code,"0SSR")
   replace hha = 1 if regexm(code,"0SRS")*/

   keep usrds_id clm_from plcsrv tha tka 
   keep if tha==1 | tka==1  
   collapse (max) tha tka, by(usrds_id clm_from plcsrv) fast
   rename clm_from clm_from_`y'

   compress
   
   save `clm_ps`y'', replace     

} */

*IV.PULL CLAIMS: PS 
clear
forvalues y=2008/2018 {  
/* forvalues y=2012/2018 {   */
   clear 
      /* if `y'==2012 {
         capture append using $ps/ps`y'
               if _rc==0 di "file PS`y'`seq' loading complete"
   }
    
   else if inrange(`y',2013,2018) { */
      foreach src in clm dx line {
         capture append using $ps/ps_`src'_`y'
               if _rc==0 di "file PS`y'`seq' loading complete"
      }
   /* } */


   tempfile clm_ps`y'
   rename diag code

   gen tha = . 
   replace tha = 1 if code =="8151" 
   replace tha = 1 if code =="0SR90J9"
   replace tha = 1 if code =="0SR90JA"
   replace tha = 1 if code =="0SR90JZ"
   replace tha = 1 if code =="0SRB0J9"
   replace tha = 1 if code =="0SRB0JA"
   replace tha = 1 if code =="0SRB0JZ"
   replace tha = 1 if regexm(code, "0SR901")
   replace tha = 1 if regexm(code, "0SR902")
   replace tha = 1 if regexm(code, "0SR903")
   replace tha = 1 if regexm(code, "0SR904")
   replace tha = 1 if regexm(code, "0SR906")
   replace tha = 1 if regexm(code, "0SRB01")
   replace tha = 1 if regexm(code, "0SRB02")
   replace tha = 1 if regexm(code, "0SRB03")
   replace tha = 1 if regexm(code, "0SRB04")
   replace tha = 1 if regexm(code, "0SRB06")
   replace tha = 1 if hcpcs=="27130"


   gen tka = . 
   replace tka = 1 if code=="8154"
   replace tka = 1 if code=="0SRC06Z"
   replace tka = 1 if code=="0SRD06Z"
   replace tka = 1 if code=="0SRC07Z"
   replace tka = 1 if code=="0SRD07Z"
   replace tka = 1 if code=="0SRC0JZ"
   replace tka = 1 if code=="0SRD0JZ"
   replace tka = 1 if code=="0SRC0KZ"
   replace tka = 1 if code=="0SRD0KZ"
   replace tka = 1 if code=="0SRC0LZ"
   replace tka = 1 if code=="0SRD0LZ"
   replace tka = 1 if code=="0SRT07Z"
   replace tka = 1 if code=="0SRU07Z"
   replace tka = 1 if code=="0SRT0JZ"
   replace tka = 1 if code=="0SRU0JZ"
   replace tka = 1 if code=="0SRT0KZ"
   replace tka = 1 if code=="0SRU0KZ"
   replace tka = 1 if code=="0SRV07Z"
   replace tka = 1 if code=="0SRW07Z"
   replace tka = 1 if code=="0SRV0JZ"
   replace tka = 1 if code=="0SRW0JZ"
   replace tka = 1 if code=="0SRV0KZ"
   replace tka = 1 if code=="0SRW0KZ"
   replace tka = 1 if hcpcs=="27447"

   /*gen hha = . 
   replace hha = 1 if code=="8152"
   replace hha = 1 if code=="0SRA009"
   replace hha = 1 if code=="0SRE009"
   replace hha = 1 if code=="0SRA00A"
   replace hha = 1 if code=="0SRE00A"
   replace hha = 1 if code=="0SRA00Z"
   replace hha = 1 if code=="0SRE00Z"
   replace hha = 1 if code=="0SRA019"
   replace hha = 1 if code=="0SRE019"
   replace hha = 1 if code=="0SRA01A"
   replace hha = 1 if code=="0SRE01A"
   replace hha = 1 if code=="0SRA01Z"
   replace hha = 1 if code=="0SRE01Z"
   replace hha = 1 if code=="0SRA039"
   replace hha = 1 if code=="0SRE039"
   replace hha = 1 if code=="0SRA03A"
   replace hha = 1 if code=="0SRE03A"
   replace hha = 1 if code=="0SRA03Z"
   replace hha = 1 if code=="0SRE03Z"
   replace hha = 1 if code=="0SRA07Z"
   replace hha = 1 if code=="0SRE07Z"
   replace hha = 1 if code=="0SRA0J9"
   replace hha = 1 if code=="0SRE0J9"
   replace hha = 1 if code=="0SRA0JA"
   replace hha = 1 if code=="0SRE0JA"
   replace hha = 1 if code=="0SRA0JZ"
   replace hha = 1 if code=="0SRE0JZ"
   replace hha = 1 if code=="0SRA0KZ"
   replace hha = 1 if code=="0SRE0KZ"
   replace hha = 1 if regexm(code,"0SSR")
   replace hha = 1 if regexm(code,"0SRS")*/

   keep usrds_id clm_from plcsrv seq_keyc tha tka 
   keep if tha==1 | tka==1 
   collapse (max) tha tka, by(usrds_id clm_from plcsrv seq_keyc) fast
   rename clm_from clm_from_`y'

   compress
   
   save `clm_ps`y'', replace     

}

*APPEND 
clear
forvalue y=2008/2018 {
   capture append using `clm_ps`y''
   if _rc==0 di "file `y' loading complete"
}

save $ortho/ps_mjr_ortho, replace 


*************************************************
*Merge the two:
use $ortho/inc_mjr_ortho_v1, clear
   egen clm_from = rowmin(clm_from_*)
   format %td clm_from
   drop clm_from_*
   order usrds_id clm_from
save $ortho/inc_mjr_ortho_pre_v1, replace 

use $ortho/inc_mjr_ortho_v2, clear
   egen clm_from = rowmin(clm_from_*)
   format %td clm_from
   drop clm_from_*
   order usrds_id clm_from
save $ortho/inc_mjr_ortho_pre_v2, replace 

use $ortho/rev_mjr_ortho, clear
   egen clm_from = rowmin(clm_from_*)
   format %td clm_from
   drop clm_from_*
   order usrds_id clm_from
save $ortho/rev_mjr_ortho_pre_v3, replace

   *Casey wants to drop HHA 
   use $ortho/inc_mjr_ortho_pre_v1, clear 
   merge 1:1 usrds_id seq_key clm_from hcfasaf using $ortho/inc_mjr_ortho_pre_v2, nogen 
   merge 1:1 usrds_id seq_key clm_from hcfasaf using $ortho/rev_mjr_ortho_pre_v3, nogen
   keep if inlist(hcfasaf, "I", "M")
   save $ortho/inc_rev_mjr_ortho, replace 

use $ortho/ps_mjr_ortho, clear
   egen clm_from = rowmin(clm_from_*)
   format %td clm_from
   drop clm_from_*
   keep if inlist(plcsrv, "21")
   order usrds_id clm_from
save $ortho/ps_mjr_ortho_pre, replace

**************************************************
*Make sure claims happen after first ESRD service but before transplant 
use $core/patients, clear 
keep first_se usrds_id
joinby usrds_id using $ortho/inc_rev_mjr_ortho
compare first_se clm_from
drop if clm_from<=first_se
save $ortho/inc_rev_mjr_ortho_cut, replace 

use $core/txunos_trr_ki.dta, clear
keep tdate trr_id usrds_id
joinby usrds_id using $ortho/inc_rev_mjr_ortho_cut, unmatched(using)
compare tdate clm_from
drop if tdate<clm_from & _merge==3 

drop _merge 
keep if first_se>=$start_dt

save $ortho/inc_rev_mjr_ortho_cut_v2, replace 

*PS
use $core/patients, clear 
keep first_se usrds_id
joinby usrds_id using $ortho/ps_mjr_ortho_pre
compare first_se clm_from
drop if clm_from<=first_se
save $ortho/ps_mjr_ortho_cut, replace 

use $core/txunos_trr_ki.dta, clear
keep tdate trr_id usrds_id
joinby usrds_id using $ortho/ps_mjr_ortho_cut, unmatched(using)
compare tdate clm_from
drop if tdate<clm_from & _merge==3 

drop _merge 
keep if first_se>=$start_dt

save $ortho/ps_mjr_ortho_cut_v2, replace 


***************************************************
*Now 1 claim per person
use $ortho/inc_rev_mjr_ortho_cut_v2, clear
foreach v of varlist tha tka mjr_womcc mjr_wmcc {
   bys usrds_id: egen xx__`v'=min(clm_from) if `v'==1
   bys usrds_id: egen clm_from_`v'=min(xx__`v')
   drop xx__`v'
   replace `v'=0 if clm_from_`v'==.
}

tempfile ortho_claims_clean_v1
save `ortho_claims_clean_v1', replace
 

use $ortho/ps_mjr_ortho_cut_v2, clear
foreach v of varlist tha tka  {
   bys usrds_id: egen xx__`v'=min(clm_from) if `v'==1
   bys usrds_id: egen clm_from_`v'=min(xx__`v')
   drop xx__`v'
   replace `v'=0 if clm_from_`v'==.
}

tempfile ortho_claims_clean_v2
save `ortho_claims_clean_v2', replace


use `ortho_claims_clean_v1', clear 
capture append using `ortho_claims_clean_v2'

foreach v of varlist tha tka  {
   bys usrds_id: egen xx__`v'=min(clm_from_`v') if `v'==1
   bys usrds_id: egen min_clm_from_`v'=min(xx__`v')
   drop xx__`v'
   replace `v'=0 if min_clm_from_`v'==.
}

collapse (min) clm_from_* min_clm_from_* (max) tha tka mjr_womcc mjr_wmcc, by(usrds_id trr_id) fast

drop clm_from_tha clm_from_tka
rename min_clm_from_tha clm_from_tha
rename min_clm_from_tka clm_from_tka

egen clm_from_final = rowmin(clm_from_*)
format %td clm_from_final

save $ortho/ortho_claims_clean, replace 

***************************************************
*III.ELIGIBILITY -- 
*include 90 days after first SE, include it start 90 days after SE, only those medicare  
*enrolled covered by medicare >90 days - pre tranplant co-moribidities, and weed out other claims 
*concerned about low sensitivity claim;
*90 days later than first se; don't apply it it's include in the   
use $core/payhist, clear
replace enddate=td(31dec2018) if enddate==.

gen mp = cond(inlist(payer, "MPO", "MPAB"), 1, 0)
sort usrds_id begdate
gen seq=1
gen extra=0          
replace extra=1 if usrds_id==usrds_id[_n-1] & mp!=mp[_n-1]     
* extra=1 if the record is from the same person as the previous record but different payer. (= if someone has used more than 1 payer during the fu)
replace seq=seq[_n-1]+extra if usrds_id==usrds_id[_n-1]              
* seq is the serial number of the different types of payer within a person
bys usrds_id seq:  egen begdate_new = min(begdate) 
bys usrds_id seq:  egen enddate_new = max(enddate)

gen dual=dualelig=="Y"
label define dual 0 "No" 1 "Yes"
label values dual dual
bys usrds_id seq: egen max_dual = max(dual)
label values max_dual dual 

drop if mp==0
duplicates drop usrds_id begdate_new enddate_new max_dual, force

keep usrds_id begdate_new enddate_new max_dual
compress
save $ortho/elig_ortho_casey, replace

***************************************************
use $core/patients, clear 
keep inc_age first_se usrds_id 
keep if inc_age>=18 
keep if first_se>=$start_dt
joinby usrds_id using $ortho/elig_ortho_casey
keep if inrange(first_se, begdate_new, enddate_new)
joinby usrds_id using $ortho/ortho_claims_clean, unmatched(master)

drop _merge 
sort usrds_id first_se *clm*

//make sure every claim falls in between medicare coverage
foreach p in $pro { 
   replace clm_from_`p' = . if !inrange(clm_from_`p', first_se, enddate_new)
   replace `p' = . if clm_from_`p'==. 
   replace `p' = 0 if clm_from_`p'==. 
} 

drop clm_from_final 
egen clm_from_final = rowmin(*clm_from*)
format %td clm_from_final

gen year = year(clm_from_final)

tab year, m 

replace clm_from_final = . if year==2007
gen thk = !mi(clm_from_final)

codebook usrds_id

assert clm_from_final>first_se

compress

save $ortho/ortho_dial_clean,replace 


*************************************************************

use $ortho/ortho_dial_clean, clear

*Getting earliest transplant date
preserve 
use tdate usrds_id using $core/txunos_trr_ki.dta, clear
merge m:1 usrds_id using $ortho/ortho_dial_clean, keepusing(usrds_id first_se enddate_new)  keep(using match) nogen
collapse (min) tdate, by(usrds_id)
tempfile t 
save `t', replace 
restore 

merge 1:1 usrds_id using `t', keep(master match) nogen 
compare clm_from_final tdate
drop if tdate<clm_from_final




















/*-No claims at all 0 outcome 
anyone diyalsis count in 2010 
start dialysis in 2005, start ju in 2005/2208

*include about more ESRD prevalent pop, at point of study intiation
//do we care about previously txp; huge change in number of txp over time 
//consider it as covatiate 

*number of events over time either linear independent variable is calentar year//
//indecator number of people eligible should come out over trends. 
//late entries might not be of interest; not at risk before 1997; 2007 
//2005 would be a late entry 
//incident ones 



poisson numb i.era, exposure(how long the person was at risk for in each era) irr 
count into a rate per year - years at, calculate time at risk, 
started at april 1-and left january 8, length of follow-up time in person-years 
intercept is log(rate per year)*/


