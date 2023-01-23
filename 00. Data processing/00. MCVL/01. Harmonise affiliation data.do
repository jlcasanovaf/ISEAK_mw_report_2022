********************************************************************************
* Title: 01. Harmonise affiliation data.do
* Date: 07/12/2022
* Description: This dofile harmonises the affiliation data from the MCVL, 
* following the steps from the ISEAK (2022) paper on the MW analysis.
********************************************************************************
	
	clear all
	set trace off
	ssc inst unique
	
********************************************************************************
* A. Directories
********************************************************************************

	global mpath "E:\Jorgec\ISEAK mw report 2022"
		
		global path "$mpath\00. Data processing\00. MCVL"
		global dta "$path\dta"
		global raw "$path\raw"
		global log "$path\log"
	
	local today : display %tdCYND date(c(current_date), "DMY")
		
		
********************************************************************************
* B. Log file
********************************************************************************

	cap log close
	log using "$log\01. Harmonise affiliation data `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data
********************************************************************************
	
	use "$dta/00. Affiliation data.dta", clear	
	
	* Fix open-ended contracts (2099)
	replace fbaja = d(31dec2019) if fbaja == d(31dec2099)
	
	* Generate labels
	
		** Economic sector
		tostring cnae93, replace
		replace cnae93 = "0" + cnae93 if length(cnae93) == 2
		replace cnae93 = "00" + cnae93 if length(cnae93) == 1 & cnae93 == "0"
		assert length(cnae93) == 3
		
		qui {
			replace cnae09 = 011 if mi(cnae09) & cnae93 == "011" 
			replace cnae09 = 014 if mi(cnae09) & cnae93 == "012"        
			replace cnae09 = 015 if mi(cnae09) & cnae93 == "013"        
			replace cnae09 = 017 if mi(cnae09) & cnae93 == "015"        
			replace cnae09 = 024 if mi(cnae09) & cnae93 == "020"        
			replace cnae09 = 031 if mi(cnae09) & cnae93 == "050"        
			replace cnae09 = 051 if mi(cnae09) & cnae93 == "101"        
			replace cnae09 = 052 if mi(cnae09) & cnae93 == "102"        
			replace cnae09 = 061 if mi(cnae09) & cnae93 == "111"        
			replace cnae09 = 071 if mi(cnae09) & cnae93 == "132"        
			replace cnae09 = 072 if mi(cnae09) & cnae93 == "141"        
			replace cnae09 = 081 if mi(cnae09) & cnae93 == "142"        
			replace cnae09 = 081 if mi(cnae09) & cnae93 == "103"        
			replace cnae09 = 089 if mi(cnae09) & cnae93 == "143"        
			replace cnae09 = 089 if mi(cnae09) & cnae93 == "144"        
			replace cnae09 = 089 if mi(cnae09) & cnae93 == "145"        
			replace cnae09 = 091 if mi(cnae09) & cnae93 == "112"        
			replace cnae09 = 101 if mi(cnae09) & cnae93 == "151"        
			replace cnae09 = 102 if mi(cnae09) & cnae93 == "152"        
			replace cnae09 = 103 if mi(cnae09) & cnae93 == "153"        
			replace cnae09 = 104 if mi(cnae09) & cnae93 == "154"        
			replace cnae09 = 105 if mi(cnae09) & cnae93 == "155"        
			replace cnae09 = 106 if mi(cnae09) & cnae93 == "156"        
			replace cnae09 = 107 if mi(cnae09) & cnae93 == "158"        
			replace cnae09 = 109 if mi(cnae09) & cnae93 == "157"        
			replace cnae09 = 110 if mi(cnae09) & cnae93 == "159"        
			replace cnae09 = 120 if mi(cnae09) & cnae93 == "160"        
			replace cnae09 = 131 if mi(cnae09) & cnae93 == "171"        
			replace cnae09 = 132 if mi(cnae09) & cnae93 == "172"        
			replace cnae09 = 133 if mi(cnae09) & cnae93 == "173"        
			replace cnae09 = 139 if mi(cnae09) & cnae93 == "174"        
			replace cnae09 = 139 if mi(cnae09) & cnae93 == "175"        
			replace cnae09 = 139 if mi(cnae09) & cnae93 == "176"        
			replace cnae09 = 141 if mi(cnae09) & cnae93 == "181"        
			replace cnae09 = 141 if mi(cnae09) & cnae93 == "182"        
			replace cnae09 = 143 if mi(cnae09) & cnae93 == "177"        
			replace cnae09 = 151 if mi(cnae09) & cnae93 == "183"        
			replace cnae09 = 151 if mi(cnae09) & cnae93 == "191"        
			replace cnae09 = 151 if mi(cnae09) & cnae93 == "192"        
			replace cnae09 = 152 if mi(cnae09) & cnae93 == "193"        
																
			replace cnae09 = 161 if mi(cnae09) & cnae93 == "201"        
			replace cnae09 = 162 if mi(cnae09) & cnae93 == "202"        
			replace cnae09 = 162 if mi(cnae09) & cnae93 == "203"        
			replace cnae09 = 162 if mi(cnae09) & cnae93 == "204"        
			replace cnae09 = 162 if mi(cnae09) & cnae93 == "205"        
			replace cnae09 = 171 if mi(cnae09) & cnae93 == "211"        
			replace cnae09 = 172 if mi(cnae09) & cnae93 == "212"        
			replace cnae09 = 181 if mi(cnae09) & cnae93 == "222"        
			replace cnae09 = 182 if mi(cnae09) & cnae93 == "223"        
			replace cnae09 = 191 if mi(cnae09) & cnae93 == "231"        
			replace cnae09 = 192 if mi(cnae09) & cnae93 == "232"        
			replace cnae09 = 201 if mi(cnae09) & cnae93 == "233"        
			replace cnae09 = 201 if mi(cnae09) & cnae93 == "241"        
			replace cnae09 = 202 if mi(cnae09) & cnae93 == "242"        
			replace cnae09 = 203 if mi(cnae09) & cnae93 == "243"        
			replace cnae09 = 204 if mi(cnae09) & cnae93 == "245"        
			replace cnae09 = 205 if mi(cnae09) & cnae93 == "246"        
			replace cnae09 = 206 if mi(cnae09) & cnae93 == "247"        
			replace cnae09 = 212 if mi(cnae09) & cnae93 == "244"        
			replace cnae09 = 221 if mi(cnae09) & cnae93 == "251"        
			replace cnae09 = 222 if mi(cnae09) & cnae93 == "252"        
			replace cnae09 = 231 if mi(cnae09) & cnae93 == "261"        
			replace cnae09 = 233 if mi(cnae09) & cnae93 == "263"        
			replace cnae09 = 233 if mi(cnae09) & cnae93 == "264"        
			replace cnae09 = 234 if mi(cnae09) & cnae93 == "262"        
			replace cnae09 = 235 if mi(cnae09) & cnae93 == "265"        
			replace cnae09 = 236 if mi(cnae09) & cnae93 == "266"        
			replace cnae09 = 237 if mi(cnae09) & cnae93 == "267"        
			replace cnae09 = 239 if mi(cnae09) & cnae93 == "268"        
			replace cnae09 = 241 if mi(cnae09) & cnae93 == "271"        
			replace cnae09 = 242 if mi(cnae09) & cnae93 == "272"        
			replace cnae09 = 243 if mi(cnae09) & cnae93 == "273"        
			replace cnae09 = 244 if mi(cnae09) & cnae93 == "274"        
			replace cnae09 = 245 if mi(cnae09) & cnae93 == "275"        
			replace cnae09 = 251 if mi(cnae09) & cnae93 == "281"        
			replace cnae09 = 252 if mi(cnae09) & cnae93 == "282"        
			replace cnae09 = 253 if mi(cnae09) & cnae93 == "283"        
			replace cnae09 = 254 if mi(cnae09) & cnae93 == "296"        
			replace cnae09 = 255 if mi(cnae09) & cnae93 == "284"        
			replace cnae09 = 256 if mi(cnae09) & cnae93 == "285"        
			replace cnae09 = 257 if mi(cnae09) & cnae93 == "286"        
			replace cnae09 = 259 if mi(cnae09) & cnae93 == "287"        
																
			replace cnae09 = 261 if mi(cnae09) & cnae93 == "321"        
			replace cnae09 = 262 if mi(cnae09) & cnae93 == "300"        
			replace cnae09 = 263 if mi(cnae09) & cnae93 == "322"        
			replace cnae09 = 264 if mi(cnae09) & cnae93 == "323"        
			replace cnae09 = 265 if mi(cnae09) & cnae93 == "335"        
			replace cnae09 = 267 if mi(cnae09) & cnae93 == "332"        
			replace cnae09 = 271 if mi(cnae09) & cnae93 == "311"        
			replace cnae09 = 271 if mi(cnae09) & cnae93 == "312"        
			replace cnae09 = 272 if mi(cnae09) & cnae93 == "314"        
			replace cnae09 = 273 if mi(cnae09) & cnae93 == "313"        
			replace cnae09 = 274 if mi(cnae09) & cnae93 == "315"        
			replace cnae09 = 275 if mi(cnae09) & cnae93 == "297"        
			replace cnae09 = 281 if mi(cnae09) & cnae93 == "291"        
			replace cnae09 = 282 if mi(cnae09) & cnae93 == "292"        
			replace cnae09 = 282 if mi(cnae09) & cnae93 == "355"        
			replace cnae09 = 284 if mi(cnae09) & cnae93 == "294"        
			replace cnae09 = 284 if mi(cnae09) & cnae93 == "316"        
			replace cnae09 = 289 if mi(cnae09) & cnae93 == "295"        
			replace cnae09 = 291 if mi(cnae09) & cnae93 == "341"        
			replace cnae09 = 292 if mi(cnae09) & cnae93 == "342"        
			replace cnae09 = 293 if mi(cnae09) & cnae93 == "343"        
			replace cnae09 = 301 if mi(cnae09) & cnae93 == "351"        
			replace cnae09 = 302 if mi(cnae09) & cnae93 == "352"        
			replace cnae09 = 303 if mi(cnae09) & cnae93 == "353"        
			replace cnae09 = 309 if mi(cnae09) & cnae93 == "354"        
			replace cnae09 = 310 if mi(cnae09) & cnae93 == "361"        
			replace cnae09 = 321 if mi(cnae09) & cnae93 == "362"        
			replace cnae09 = 321 if mi(cnae09) & cnae93 == "366"        
			replace cnae09 = 322 if mi(cnae09) & cnae93 == "363"        
			replace cnae09 = 323 if mi(cnae09) & cnae93 == "364"        
			replace cnae09 = 324 if mi(cnae09) & cnae93 == "365"        
			replace cnae09 = 325 if mi(cnae09) & cnae93 == "331"        
			replace cnae09 = 325 if mi(cnae09) & cnae93 == "334"        
			replace cnae09 = 331 if mi(cnae09) & cnae93 == "293"        
																
			replace cnae09 = 332 if mi(cnae09) & cnae93 == "333"        
																
			replace cnae09 = 351 if mi(cnae09) & cnae93 == "401"        
			replace cnae09 = 352 if mi(cnae09) & cnae93 == "402"        
			replace cnae09 = 453 if mi(cnae09) & cnae93 == "403"        
			replace cnae09 = 360 if mi(cnae09) & cnae93 == "410"        
			replace cnae09 = 381 if mi(cnae09) & cnae93 == "900"        
			replace cnae09 = 383 if mi(cnae09) & cnae93 == "371"        
			replace cnae09 = 383 if mi(cnae09) & cnae93 == "372"        
			replace cnae09 = 411 if mi(cnae09) & cnae93 == "701"        
			replace cnae09 = 412 if mi(cnae09) & cnae93 == "452"        
			replace cnae09 = 431 if mi(cnae09) & cnae93 == "451"        
			replace cnae09 = 432 if mi(cnae09) & cnae93 == "453"        
			replace cnae09 = 433 if mi(cnae09) & cnae93 == "454"        
			replace cnae09 = 439 if mi(cnae09) & cnae93 == "455"        
																
			replace cnae09 = 451 if mi(cnae09) & cnae93 == "501"        
			replace cnae09 = 452 if mi(cnae09) & cnae93 == "502"        
			replace cnae09 = 453 if mi(cnae09) & cnae93 == "503"        
			replace cnae09 = 454 if mi(cnae09) & cnae93 == "504"        
			replace cnae09 = 461 if mi(cnae09) & cnae93 == "511"        
			replace cnae09 = 462 if mi(cnae09) & cnae93 == "512"        
			replace cnae09 = 463 if mi(cnae09) & cnae93 == "513"        
			replace cnae09 = 464 if mi(cnae09) & cnae93 == "514"        
			replace cnae09 = 466 if mi(cnae09) & cnae93 == "516"        
			replace cnae09 = 467 if mi(cnae09) & cnae93 == "515"        
			replace cnae09 = 469 if mi(cnae09) & cnae93 == "517"        
			replace cnae09 = 471 if mi(cnae09) & cnae93 == "521"        
			replace cnae09 = 472 if mi(cnae09) & cnae93 == "522"        
			replace cnae09 = 473 if mi(cnae09) & cnae93 == "505"        
			replace cnae09 = 476 if mi(cnae09) & cnae93 == "524"        
			replace cnae09 = 477 if mi(cnae09) & cnae93 == "523"        
			replace cnae09 = 477 if mi(cnae09) & cnae93 == "525"        
			replace cnae09 = 478 if mi(cnae09) & cnae93 == "526"        
																
			replace cnae09 = 491 if mi(cnae09) & cnae93 == "601"        
			replace cnae09 = 493 if mi(cnae09) & cnae93 == "602"        
			replace cnae09 = 495 if mi(cnae09) & cnae93 == "603"        
			replace cnae09 = 501 if mi(cnae09) & cnae93 == "611"        
			replace cnae09 = 503 if mi(cnae09) & cnae93 == "612"        
			replace cnae09 = 511 if mi(cnae09) & cnae93 == "621"        
			replace cnae09 = 511 if mi(cnae09) & cnae93 == "622"        
			replace cnae09 = 521 if mi(cnae09) & cnae93 == "631"        
			replace cnae09 = 522 if mi(cnae09) & cnae93 == "632"        
			replace cnae09 = 522 if mi(cnae09) & cnae93 == "634"        
			replace cnae09 = 531 if mi(cnae09) & cnae93 == "641"        
			replace cnae09 = 551 if mi(cnae09) & cnae93 == "651"        
			replace cnae09 = 552 if mi(cnae09) & cnae93 == "652"        
			replace cnae09 = 561 if mi(cnae09) & cnae93 == "653"        
			replace cnae09 = 562 if mi(cnae09) & cnae93 == "655"        
			replace cnae09 = 563 if mi(cnae09) & cnae93 == "654"        
			replace cnae09 = 581 if mi(cnae09) & cnae93 == "221"        
			replace cnae09 = 591 if mi(cnae09) & cnae93 == "921"        
			replace cnae09 = 601 if mi(cnae09) & cnae93 == "922"        
			replace cnae09 = 611 if mi(cnae09) & cnae93 == "642"        
			replace cnae09 = 620 if mi(cnae09) & cnae93 == "721"        
			replace cnae09 = 620 if mi(cnae09) & cnae93 == "722"        
			replace cnae09 = 620 if mi(cnae09) & cnae93 == "723"        
			replace cnae09 = 620 if mi(cnae09) & cnae93 == "724"        
			replace cnae09 = 620 if mi(cnae09) & cnae93 == "726"        
			replace cnae09 = 639 if mi(cnae09) & cnae93 == "924"        
			replace cnae09 = 691 if mi(cnae09) & cnae93 == "651"        
			replace cnae09 = 649 if mi(cnae09) & cnae93 == "652"        
			replace cnae09 = 651 if mi(cnae09) & cnae93 == "660"        
			replace cnae09 = 661 if mi(cnae09) & cnae93 == "671"        
			replace cnae09 = 662 if mi(cnae09) & cnae93 == "672"        
																
			replace cnae09 = 682 if mi(cnae09) & cnae93 == "702"        
			replace cnae09 = 683 if mi(cnae09) & cnae93 == "703"        
			replace cnae09 = 692 if mi(cnae09) & cnae93 == "741"        
			replace cnae09 = 711 if mi(cnae09) & cnae93 == "742"        
			replace cnae09 = 712 if mi(cnae09) & cnae93 == "743"        
			replace cnae09 = 721 if mi(cnae09) & cnae93 == "731"        
			replace cnae09 = 722 if mi(cnae09) & cnae93 == "732"        
			replace cnae09 = 731 if mi(cnae09) & cnae93 == "744"        
			replace cnae09 = 750 if mi(cnae09) & cnae93 == "852"        
			replace cnae09 = 771 if mi(cnae09) & cnae93 == "711"        
			replace cnae09 = 771 if mi(cnae09) & cnae93 == "712"        
			replace cnae09 = 772 if mi(cnae09) & cnae93 == "714"        
			replace cnae09 = 773 if mi(cnae09) & cnae93 == "713"        
			replace cnae09 = 782 if mi(cnae09) & cnae93 == "745"        
			replace cnae09 = 791 if mi(cnae09) & cnae93 == "633"        
			replace cnae09 = 801 if mi(cnae09) & cnae93 == "746"        
			replace cnae09 = 812 if mi(cnae09) & cnae93 == "747"        
			replace cnae09 = 813 if mi(cnae09) & cnae93 == "014"        
			replace cnae09 = 822 if mi(cnae09) & cnae93 == "748"        
			replace cnae09 = 841 if mi(cnae09) & cnae93 == "751"        
			replace cnae09 = 842 if mi(cnae09) & cnae93 == "752"        
																
			replace cnae09 = 852 if mi(cnae09) & cnae93 == "801"        
			replace cnae09 = 853 if mi(cnae09) & cnae93 == "802"        
			replace cnae09 = 854 if mi(cnae09) & cnae93 == "803"        
			replace cnae09 = 855 if mi(cnae09) & cnae93 == "804"        
			replace cnae09 = 861 if mi(cnae09) & cnae93 == "851"        
			replace cnae09 = 879 if mi(cnae09) & cnae93 == "853"        
																
			replace cnae09 = 900 if mi(cnae09) & cnae93 == "923"        
			replace cnae09 = 910 if mi(cnae09) & cnae93 == "925"        
			replace cnae09 = 920 if mi(cnae09) & cnae93 == "927"        
			replace cnae09 = 931 if mi(cnae09) & cnae93 == "926"        
			replace cnae09 = 941 if mi(cnae09) & cnae93 == "911"        
			replace cnae09 = 942 if mi(cnae09) & cnae93 == "912"        
			replace cnae09 = 949 if mi(cnae09) & cnae93 == "913"        
			replace cnae09 = 951 if mi(cnae09) & cnae93 == "527"        
			replace cnae09 = 951 if mi(cnae09) & cnae93 == "725"        
			replace cnae09 = 960 if mi(cnae09) & cnae93 == "930"        
			replace cnae09 = 970 if mi(cnae09) & cnae93 == "950"        
			replace cnae09 = 990 if mi(cnae09) & cnae93 == "990"        
		}
		
		drop cnae93
		ren cnae09 cnae
	
********************************************************************************
* D. Generate relevant variables
********************************************************************************	
	
	* Employed
	gen employed = (!inrange(trl, 751, 756) & !inrange(trl, 721, 740)) if !inrange(regcot, 512, 540) 

	* Number of workers
	gen nworkers = 1 if numtrab >= 1 & numtrab < 10 
	replace nworkers = 2 if numtrab >= 10 & numtrab <= 49
	replace nworkers = 3 if numtrab >= 50 & numtrab <= 249
	replace nworkers = 4 if numtrab >= 250 & numtrab < .
	
	label define nworkers 1 "<10 trab" 2 "10-49 trab" 3 "50-249 trab" 4 ">= 250"
	label values nworkers nworkers 
	
	*Cutoff dates
	gen m = 1
	sort m
	merge m:1 m using "$dta\_AUX. Cutoff dates.dta", nogen
	drop m
		
********************************************************************************
* E. Filter the data
********************************************************************************	
	
	* Keep only spells between Jan-18 and Dec-19
	keep if inrange(2018, year(falta), year(fbaja)) | inrange(2019, year(falta), year(fbaja))
	qui unique identpers
	di as txt "Number of initial workers:" %5.0fc `r(unique)'	
	
	* Keep only the second Tuesday of each month
	gen t1 = 1 if inrange(date1,falta,fbaja)
	local filter = "inrange(date1,falta,fbaja)"
	
	forval x = 2/24 {
		local filter = "`filter'" + " | inrange(date`x',falta,fbaja)"
		
		gen t`x' = .
		replace t`x' = 1 if inrange(date`x',falta,fbaja)
	}
	
	keep if `filter' 
	
	qui unique identpers
	di as txt "Number of workers wiht a spell in the second Tuesday of each month:" %5.0fc `r(unique)'	

	* Check for multijobs = Drop if its working as a self and nonself employee at that time
	gen auto = (inrange(regcot, 512, 540))
	gen non_auto = (!inrange(regcot, 512, 540)) if !inrange(trl, 751, 756)
	gen flag = 0

	forval x = 1/24 {
		gen auto`x' = (auto == 1 & t`x' == 1)
		gen non_auto`x' = (non_auto == 1 & t`x' == 1) 
		bys identpers: egen max_auto = max(auto`x')
		bys identpers: egen max_non_auto = max(non_auto`x')
		egen check`x' = rowmean(max_auto max_non_auto)
		replace flag = 1 if check`x' == 1 & !mi(auto`x') & !mi(non_auto`x')
		drop max_* check* auto`x' non_auto`x'
	}                       

	qui unique identpers if flag == 1
	di as txt "Number of workers dropped with self and not self simultaneos jobs:" %5.0fc `r(unique)'			
	drop if flag == 1
	drop flag
	
	* Keep only workers when a general regime, household employees or agrarian activity contract
	gen to_drop = (inrange(regcot, 521,540) | inrange(regcot, 721, 950))
	bys identpers: egen max_to_drop = max(to_drop)
	qui unique identpers if max_to_drop == 1
	di as txt "Number of workers with a special regime to be dropped:" %5.0fc `r(unique)'		
	drop if max_to_drop == 1
	drop max_to_drop to_drop

	* Check for multijobs = Have multiple jobs at the same time
	gen flag = .
	forval x = 1/24 {
		cap drop total
		gen emp`x' = 1 if t`x' == 1 & employed == 1
		bys identpers : egen total = total(emp`x')
		replace flag = 1 if total > 1 & total < . 
	}
	
	qui unique identpers if flag == 1
	di as txt "Number of individuals dropped for being multijob workers:" %5.0fc `r(unique)'	
	
	drop if flag == 1	
	drop flag
	
	* Drop unemployment spells
	drop if employed == 0
	
	*Save information about changes in job spells to update later on
	preserve
		
		keep identpers identccc2 falta fbaja tipconmod1 cparcmod1 tipconmod2 cparcmod2 grupcotmod1 tipcont fmod*
		
		destring tipconmod1 cparcmod1 tipconmod2 cparcmod2 grupcotmod1 tipcont, replace
		
		bys identpers identccc2 falta fbaja : gen dup = _N
		assert dup == 1
		drop dup
		
		sort identpers identccc2 falta fbaja  
		tempfile changes_info
		save `changes_info', replace	
	
	restore
	
	* Save information about dates
	preserve
	
		use "$dta\_AUX. Cutoff dates.dta", clear
		
		reshape long date, i(m) j(t)
		
		drop m
		
		sort t
	
		tempfile dates
		save `dates', replace
	
	restore
	
********************************************************************************
* F. Set the dataset in long form
********************************************************************************	

	* Keep relevant variables
	keep identpers identccc2 nworkers t1-t24 falta fbaja coefparc cnae grupcot domccc2 regcot numtrab
	
	ren (identccc2 domccc2) (identccc domccc)
	
	* Prepare data to reshape
	qui ds t1-t24 identpers identccc, not
	local varlist = r(varlist)

	foreach var of local varlist {
		forval x = 1/24 {
			qui gen `var'`x' = `var' if t`x' == 1
		}
		qui compress
		drop `var'
	}
	
	forval x = 1/24 {
		qui gen identccc`x' = identccc if t`x' == 1
		qui compress
	}	
	
	drop t1-t24 identccc
	
	preserve
	
		keep identpers identccc*
		qui compress
		
		collapse (firstnm) identccc*,by(identpers)
		
		sort identpers
		
		tempfile firms
		save `firms', replace
	
	restore
	
	drop identccc*
	
	qui ds identpers, not
	local varlist_wide = r(varlist)	
	
	qui compress
	
	* Collapse the data to have one obs per individual
	gcollapse (max) `varlist_wide', by(identpers)
	
	sort identpers
	merge 1:1 identpers using `firms', nogen 

	* Reshape in long format
	greshape long `varlist' identccc, i(identpers) j(t)

	ren (identccc domccc) (identccc2 domccc2)
	
********************************************************************************
* G. Update job spells with information about changes
********************************************************************************		
		
	* Get updated data
	sort identpers identccc2 falta fbaja
	merge m:1 identpers identccc2 falta fbaja using `changes_info'
	
	assert mi(falta) & mi(fbaja) if _m == 1
	keep if _m == 1 | _m == 3
	drop _m
	
	* Get dates
	merge m:1 t using `dates', nogen keep(3)
	
	* Update partiality coefficient
	replace coefparc = cparcmod1 if !mi(falta) & fmodcont1>=date & !mi(cparcmod1)
	replace coefparc = cparcmod2 if !mi(falta) & fmodcont2>=date & fmodcont1<date

	* Update type of contract
	replace tipcont = tipconmod1 if !mi(falta) & fmodcont1>=date & !mi(tipconmod1)
	replace tipcont = tipconmod1 if !mi(falta) & fmodcont2>=date & fmodcont1<date	
	
	* Update contribution group
	replace grupcot = grupcotmod1 if !mi(falta) & fmodgrup1>=date & !mi(grupcotmod1)
	
	drop tipconmod1 cparcmod1 cparcmod2 grupcotmod1 tipconmod2 fmodcont1 fmodcont2 fmodgrup1 date 
	
********************************************************************************
* H. Generate additional variables, format and save
********************************************************************************	
	
	*Dummy of employment
	gen employed = (!mi(falta))

	*Dummy of Permanent contract
	gen byte permanent = (tipcont==1|tipcont==3|tipcont==8|tipcont==9|tipcont==11|tipcont==18|tipcont==20|/*
	*/tipcont==23|tipcont==28|tipcont==38|tipcont==63|tipcont==35|(tipcont>=45 & tipcont<=48)|/*
	*/(tipcont>=40 & tipcont<=44)|tipcont==49|tipcont==50|tipcont==52|tipcont==61|tipcont==65|tipcont==81|/*
	*/(tipcont>=59 & tipcont<=62)|(tipcont>=69 & tipcont<=71)|tipcont==80|tipcont==86|tipcont==88|tipcont==89|/*
	*/tipcont==91|tipcont==98|tipcont==100|tipcont==101|tipcont==102|tipcont==109|tipcont==130|/*
	*/tipcont==131|tipcont==139|(tipcont>=141 & tipcont<=157)|tipcont==185|tipcont==186|tipcont==189|/*
	*/(tipcont>=181 & tipcont<=184)|(tipcont>=200 & tipcont<=208)|tipcont==209|tipcont==239|tipcont==289|/*
	*/(tipcont>=230 & tipcont<=238)|(tipcont>=241 & tipcont<=257)|tipcont==300|tipcont==309|tipcont==389|/*
	*/(tipcont>=330 & tipcont<=357))
	
	replace permanent = . if employed == 0 | employed == .
	
	*Dummy of Temporary
	gen byte temporary = (tipcont==4|tipcont==5|tipcont==6|tipcont==7|tipcont==10|tipcont==15|tipcont==14|/*
*/ tipcont==16|tipcont==17|tipcont==22|tipcont==26|tipcont==27|tipcont==25|tipcont==24|tipcont==34|/*
*/ (tipcont>=30 & tipcont<=33)|tipcont==36|tipcont==37|(tipcont>=53 & tipcont<=58)|tipcont==66|/*
*/ tipcont==67|tipcont==68|tipcont==64|tipcont==72|tipcont==73|tipcont==74|tipcont==76|tipcont==77|/*
*/ tipcont==78|tipcont==79|tipcont==85|tipcont==87|tipcont==96|tipcont==75|tipcont==82|tipcont==83|/*
*/ tipcont==84|tipcont==93|tipcont==94|tipcont==92|tipcont==95|tipcont==97|tipcont==401|/*
*/ tipcont==403|tipcont==408|tipcont==402|tipcont==410|tipcont==418|tipcont==420|tipcont==421|/*
*/ tipcont==430|tipcont==431|tipcont==441|tipcont==450|tipcont==451|tipcont==452|tipcont==457|/*
*/ tipcont==500|tipcont==503|tipcont==508|tipcont==501|tipcont==502|tipcont==510|tipcont==518|/*
*/ tipcont==520|tipcont==530|tipcont==531|tipcont==540|tipcont==541|tipcont==550|tipcont==551|/*
*/ tipcont==552|tipcont==557)
	
	replace temporary = . if employed == 0 | employed == .
	
		** For missing cases, assume a temporary contract
		tab tipcont if temporary == 0 & permanent == 0
		replace temporary = 1 if temporary == 0 & permanent == 0
		
		assert permanent == 0 if temporary == 1
		assert temporary == 1 if permanent == 0

	* Dummy of full time
	gen ft = (coefparc >= 750) if employed == 1
	
	* Dummy of part time
	gen pt = (coefparc > 750 & coefparc < .) if employed == 1

	* Interactions
	cap drop temporary_* permanent_*
	
	gen temporary_ft = temporary * ft
	gen temporary_pt = temporary * pt
	gen permanent_ft = permanent * ft
	gen permanent_pt = permanent * pt
	
	* Skills
	gen skill=1 if (grupcot == 1| grupcot == 2)
	replace skill=2 if inrange(grupcot, 3, 7)
	replace skill=3 if inrange(grupcot, 8, 9)		

	* Economic sector group
	qui {
		* Sector primario
			* A: Agricultura, ganaderia, silvicultura y pesca
			gen byte gcnae=1 if cnae == 011 | cnae == 012 | cnae == 013 | cnae == 014 | cnae == 015 | cnae == 016 | /*
			*/ cnae == 017 | cnae == 021 | cnae == 022 | cnae == 023 | cnae == 024 | cnae == 031 | cnae == 032 | cnae == 01/*
			*/ |cnae == 020 
		
		* Industrias extractivas y manuf. y suministros
			* B: Industrias extractivas 
			replace gcnae=2 if cnae == 050|cnae == 051 | cnae == 052 | cnae == 061 | cnae == 062 | cnae == 071 | cnae == 072 | /*
			*/ cnae == 081 | cnae == 089 | cnae == 091 | cnae == 099  

			* C: Industria manufacturera
			replace gcnae=2 if cnae == 101 | cnae == 102 | cnae == 103 | cnae == 104 | cnae == 105 | cnae == 106 | /*
			*/ cnae == 107 | cnae == 108 | cnae == 109 | cnae == 110 | cnae == 120 | cnae == 131 | cnae == 132 | cnae == 133 | /*
			*/ cnae == 139 | cnae == 141 | cnae == 142 | cnae == 143 | cnae == 151 | cnae == 152 | cnae == 161 | cnae == 162 | /*
			*/ cnae == 171 | cnae == 172 | cnae == 181 | cnae == 182 | cnae == 191 | cnae == 192 | cnae == 201 | cnae == 202 | /*
			*/ cnae == 203 | cnae == 204 | cnae == 205 | cnae == 206 | cnae == 211 | cnae == 212 | cnae == 221 | cnae == 222 | /*
			*/ cnae == 231 | cnae == 232 | cnae == 233 | cnae == 234 | cnae == 235 | cnae == 236 | cnae == 237 | cnae == 239 | /*
			*/ cnae == 241 | cnae == 242 | cnae == 243 | cnae == 244 | cnae == 245 | cnae == 251 | cnae == 252 | cnae == 253 | /*
			*/ cnae == 254 | cnae == 255 | cnae == 256 | cnae == 257 | cnae == 259 | cnae == 261 | cnae == 262 | cnae == 263 | /*
			*/ cnae == 264 | cnae == 265 | cnae == 266 | cnae == 267 | cnae == 268 | cnae == 271 | cnae == 272 | cnae == 273 | /*
			*/ cnae == 274 | cnae == 275 | cnae == 279 | cnae == 281 | cnae == 282 | cnae == 283 | cnae == 284 | cnae == 289 | /*
			*/ cnae == 291 | cnae == 292 | cnae == 293 | cnae == 301 | cnae == 302 | cnae == 303 | cnae == 304 | cnae == 309 | /*
			*/ cnae == 310 | cnae == 321 | cnae == 322 | cnae == 323 | cnae == 324 | cnae == 325 | cnae == 329 | cnae == 331 | /*
			*/ cnae == 332  

			* D: Suministro de energia electrica, gas, vapor y aire acondicionado
			replace gcnae=2 if cnae == 351 | cnae == 352 | cnae == 353 

			* E: Suministro de agua, actividades de saneamiento, gestion de residuos y descontaminacion
			replace gcnae=2 if cnae == 360 | cnae == 370 | cnae == 381 | cnae == 382 | cnae == 383 | cnae == 390  

		* Construccion
		replace gcnae=3 if cnae == 411 | cnae == 412 | cnae == 421 | cnae == 422 | cnae == 429 | cnae == 431 | /*
		*/ cnae == 432 | cnae == 433 | cnae == 439

		* Comercio
		replace gcnae=4 if cnae == 451 | cnae == 452 | cnae == 453 | cnae == 454 | cnae == 461 | cnae == 462 | /*
		*/ cnae == 463 | cnae == 464 | cnae == 465 | cnae == 466 | cnae == 467 | cnae == 469 | cnae == 471 | /*
		*/ cnae == 472 | cnae == 473 | cnae == 474 | cnae == 475 | cnae == 476 | cnae == 477 | cnae == 478 | cnae == 479

		* Transporte y almacenamiento
		replace gcnae=5 if cnae == 491 | cnae == 492 | cnae == 493 | cnae == 494 | cnae == 495 | cnae == 501 |  /*
		*/ cnae == 502 | cnae == 503 | cnae == 504 | cnae == 511 | cnae == 512 | cnae == 521 | cnae == 522 | cnae == 531 | /*
		*/ cnae == 532   

		* Hosteleria
		replace gcnae=6 if cnae == 551 | cnae == 552 | cnae == 553 | cnae == 559 | cnae == 561 | cnae == 562 | cnae == 563 

		* Informacion y comunicaciones
		replace gcnae=7 if cnae == 581 | cnae == 582 | cnae == 591 | cnae == 592 | cnae == 601 | cnae == 602 |  /*
		*/ cnae == 611 | cnae == 612 | cnae == 613 | cnae == 619 | cnae == 620 | cnae == 631 | cnae == 639 
	
		* Finanzas, seguros e inmobiliarias
			* K: Actividades financieras y de seguros
			replace gcnae=8 if cnae == 641 | cnae == 642 | cnae == 643 | cnae == 649 | cnae == 651 | cnae == 652 |  /*
			*/ cnae == 653 | cnae == 661 | cnae == 662 | cnae == 663  

			* L: Actividades inmobiliarias
			replace gcnae=8 if cnae == 681 | cnae == 682 | cnae == 683 
		
		* Profesionales, cientificas y tecnicas
		replace gcnae=9 if cnae == 691 | cnae == 692 | cnae == 701 | cnae == 702 | cnae == 711 | cnae == 712 |  /*
		*/ cnae == 721 | cnae == 722 | cnae == 731 | cnae == 732 | cnae == 741 | cnae == 742 | cnae == 743 | cnae == 749 | /*
		*/ cnae == 750

		* Actividades administrativas y servicios auxiliares
		replace gcnae=10 if cnae == 771 | cnae == 772 | cnae == 773 | cnae == 774 | cnae == 781 | cnae == 782 |  /*
			*/ cnae == 783 | cnae == 791 | cnae == 799 | cnae == 801 | cnae == 802 | cnae == 803 | cnae == 811 | cnae == 812 | /*
			*/ cnae == 813 | cnae == 821 | cnae == 822 | cnae == 823 | cnae == 829 

		* Administracion Pœblica y defensa; Seguridad Social obligatoria
		replace gcnae=11 if cnae == 841 | cnae == 842 | cnae == 843 

		* Educacion
		replace gcnae=12 if cnae == 851 | cnae == 852 | cnae == 853 | cnae == 854 | cnae == 855 | cnae == 856 

		* Actividades sanitarias y de servicios sociales
		replace gcnae=13 if cnae == 861 | cnae == 862 | cnae == 869 | cnae == 871 | cnae == 872 | cnae == 873 |  /*
		*/ cnae == 879 | cnae == 881 | cnae == 889  

		* Hogar, actividades asociativas, y artísticas y recreativas
			** Actividades artisticas, recreativas y de entretenimiento
			replace gcnae=14 if cnae == 900 | cnae == 910 | cnae == 920 | cnae == 931 | cnae == 932 

			** Otros servicios 
			replace gcnae=14 if cnae == 941 | cnae == 942 | cnae == 949 | cnae == 950|cnae == 951 | cnae == 952 | cnae == 960  

			** Actividades de los hogares como empleadores de personal domestico; 
			*actividades de los hogares como productores de bienes y servicios para uso propio 
			replace gcnae=14 if cnae == 970 | cnae == 981 | cnae == 982  

			** Actividades de organizaciones y organismos extraterritoriales 
			replace gcnae=14 if cnae == 990  
			
			** Unknown // TBC
			replace gcnae=14 if cnae == 0
			
		label define gcnae 1 "Sector primario" 2 "Industrias extractivas y manuf. y suministros" /*
		*/ 3 "Construccion" 4 "Comercio" 5 "Transporte y almacenamiento" 6 "Hosteleria" 7 /*
		*/ "Informacion y comunicaciones" 8 "Finanzas, seguros e inmobiliarias" /*
		*/ 9 "Profesionales, cientificas y tecnicas" 10 "Administrativas y servicios auxiliares" /*
		*/ 11 "Administracion Publica" 12 "Educacion" 13 "Sanidad y servicios sociales" 14 /*
		*/ "Hogar, actividades asociativas, y artísticas y recreativas"		

		label values gcnae gcnae
		
		decode gcnae ,gen(gcnae_str)	
	}
	
	label define skill 1 "High skill" 2 "Med skill" 3 "Low skill"
	label values skill skill 
	
	* Formatting
	format falta fbaja %td
	label values nworkers nworkers 
	
	label var identpers "ID"
	label var falta "Date of begin"
	label var fbaja "Date of end"		
	label var nworkers "Cat number of workers in FirmXmuni"
	label var identccc2 "Firm x Muni ID"
	label var employed "Employed"
	label var ft "Full time"
	label var pt "Part time"
	label var permanent "Permanent"
	label var temporary "Temporary"
	label var permanent_ft "Permanent x Full time"
	label var temporary_ft "Temporary x Full time"	
	label var permanent_pt "Permanent x Part time"
	label var temporary_pt "Temporary x Part time"	
	label var cnae "Firm x Muni sector"
	label var gcnae "Firm x Muni sector group"
	label var coefparc "Partiality coef"
	label var regcot "Type of regime"
	label var t "Month"
	label var grupcot "Contribution group"
	label var skill "Level of skills"
	label var domccc2 "Zip code of Firm x Muni"
	label var numtrab "Number of workers in FirmXmuni"
	
	qui compress
	sort identpers identccc2 t
	
	save "$dta\01. Harmonised affiliation data.dta", replace
	
* End of this dofile
cap log close
exit,clear
