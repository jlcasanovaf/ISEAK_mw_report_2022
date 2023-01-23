********************************************************************************
* Title: 99. Consolidate datasets.do
* Date: 07/12/2022
* Description: This dofile consolidates all the datasets from the MCVL,
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
	log using "$log\99. Consolidate datasets `today'.log", replace

	
********************************************************************************
* C. Load and merge the data
********************************************************************************
	
	use "$dta\01. Harmonised affiliation data.dta", clear	
		
		*Hourly wages
		merge 1:1 identpers identccc2 t using "$dta/03. Hourly wages.dta", nogen assert(3) keep(3) keepusing(hourly_wages hours_worked days_worked date base)
		
		* Personal data
		merge m:1 identpers using "$dta/00. Personal data 2019.dta" // individuals dropped have missing dates
		
		qui unique identpers if _m == 1
		di as txt "Number of workers dropped due to missing date of birth:" %5.0fc `r(unique)'		
			
		qui unique identpers if _m == 2
		di as txt "Number of workers dropped due to other reasons:" %5.0fc `r(unique)'					
			
		keep if _m == 3
		drop _m
			
********************************************************************************
* D. Filter the data and count observations
********************************************************************************		

	qui unique identpers if !inrange(edad, 16, 60)
	di as txt "Number of workers dropped due to not having between 16 and 60 in nov 18:" %5.0fc `r(unique)'		
		
	keep if inrange(edad, 16, 60)
	
	qui unique identpers if year(dofm(ffallec)) < 2020
	di as txt "Number of workers dropped due to dying before 2020:" %5.0fc `r(unique)'		
	drop if year(dofm(ffallec)) < 2020
	
	qui unique identpers
	di as txt "Resulting sample of workers:" %5.0fc `r(unique)'			
	
********************************************************************************
* E. Generate additional variables
********************************************************************************		

	* Potentially treated variable
	gen aux = 0 if month(date) == 11 & year(date) == 2018 & employed == 1 & hourly_wages >= 4.39 & hourly_wages <= 5.47
	replace aux = 1 if month(date) == 11 & year(date) == 2018 & employed == 1 & hourly_wages >= 3.57 & hourly_wages < 4.375
	
	bys identpers: egen treated_pot = max(aux)
	label var treated_pot "Potentially treated"
	drop aux
	
	* Partiality coeff ranges
	gen coefparc_cat = 1 if coefparc >750 
	replace coefparc_cat = 2 if coefparc == 0
	replace coefparc_cat = 3 if coefparc >500 & coefparc <= 750
	replace coefparc_cat = 4 if coefparc >250 & coefparc <= 500 
	replace coefparc_cat = 5 if coefparc >0 & coefparc <= 250
	
	label define coefparc_cat 1 "Coefpar <250" 2 "Coefpar = 1000" 3 "Coefpar [250-500)" 4 "Coefpar [500-750)" 5 "Coefpar [750-1000)" 
	label values coefparc_cat coefparc_cat 

	* Impute number of workers for missing cases
	replace nworkers = 1 if mi(nworkers)
			
	* Labour market values at t == 11 (nov 2018)
	local lablist = "gcnae nworkers"
	foreach var of local lablist {
		decode `var',gen(str_`var')
		
		cap drop aux
		
		gen aux = str_`var' if t == 11
		bys identpers (aux): gen t0_str_`var' = aux[_N]
		
		encode t0_str_`var', gen(t0_`var')
		drop t0_str_`var'			
		label var t0_`var' "`var' in november 18"
	}
	
	local lablist = "permanent ft skill"
	foreach var of local lablist {		
		cap drop aux			
		gen aux = `var' if t == 11
		bys identpers : egen t0_`var' = max(aux)
		label var t0_`var' "`var' in november 18"		
	}			
		
	* Gender dummies
	gen male = (sexo == 0)
	label define male 0 "None" 1 "Male"
	label values male male 
	
	label define sexo 0 "None", modify

	* Labels
	foreach var in temporary_ft temporary_pt permanent_ft permanent_pt {
		local lab: variable label `var'
		label define `var' 0 "None" 1 "`lab'"
		label values `var' `var'
	}

	* Outcome variable

		** Values in t0
		cap drop aux			
		gen aux = coefparc if t == 11
		bys identpers : egen t0_coefparc = max(aux)
		
		** Transitions
		bys identpers (t): gen trans1 = (employed == 1 & coefparc == t0_coefparc) // Remains employed and keeps the same intensity
		bys identpers (t): gen trans2 = (employed == 1 & coefparc > t0_coefparc) // Remains employed but lowers the intensity
		bys identpers (t): gen trans3 = (employed == 0)	// Unemployment	

		** Y var
		gen y = 0
		replace y = 1 if trans1 == 1
		replace y = 2 if trans2 == 1
		replace y = 3 if trans3 == 1
		
		label define y 1 "no changes" 2 "low intensity" 3 "unemployed"
		label values y y

********************************************************************************
* F. Save
********************************************************************************			
	
	compress
	
	sort identpers identccc2 t
	save "$dta/99. Consolidated data.dta", replace
		
* End of this dofile
cap log close
exit,clear
