********************************************************************************
* Title: _AUX. Generate cutoff dates.do
* Date: 07/12/2022
* Description: This dofile generates the cutoff dates to filter the data from
* the MCVL. It keeps the second Tuesday of each month, from 2018 to 2019.
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
	log using "$log\_AUX. Generate cutoff dates `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data
********************************************************************************

	clear
	set obs 24
	gen year = 2018 if _n <= 12
	replace year = 2019 if _n > 12

	bys year: gen month = _n

	sort year month

	gen days = (mdy(month,1,year) - 1) - mdy(month[_n-1],1,year[_n-1]) + 1
	replace days = 31 if year == 2018 & month == 1

	expand days

	bys year month: gen day = _n

	gen date = mdy(month, day, year)
	format date %td

	gen dow = dow(date)

	keep if dow == 2 // Keep only Tuesdays

	bys year month: keep if _n == 2 // Keep second of each month

	gen t = _n

	keep t date

	gen m = 1

	reshape wide date, i(m) j(t)
	
	sort m
	
	save "$dta\_AUX. Cutoff dates.dta", replace

* End of this dofile
cap log close
exit,clear	
