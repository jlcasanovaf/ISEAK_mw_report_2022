********************************************************************************
* Title: 03. Estimate hourly wages.do
* Date: 07/12/2022
* Description: This dofile estimates hourly wages for the filtered sample from 
* the MCVL, following the steps from the ISEAK (2022) paper on the MW analysis.
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
	log using "$log\03. Estimate hourly wages `today'.log", replace

	
********************************************************************************
* C. Load and merge the data
********************************************************************************
	
	* Cutoff dates
	use "$dta\_AUX. Cutoff dates.dta", clear
	
	reshape long date, i(m) j(t)
	
	drop m
	
	sort t
	tempfile dates
	save `dates', replace
	
	* MCVL data
	use "$dta\01. Harmonised affiliation data.dta", clear	
		
		keep identpers identccc2 falta fbaja coefparc t
		
		merge 1:1 identpers identccc2 t using "$dta/02. Harmonized Contribution basis.dta", keep(1 3) nogen keepusing(base)
		merge 1:1 identpers identccc2 t using "$dta/02. Harmonized Contribution basis special regime.dta", keep(1 4) nogen keepusing(base) replace update		 	
		
		sort t
		merge m:1 t using `dates', nogen
		
********************************************************************************
* D. Estimate hourly wages
********************************************************************************		
	
	* Number of days worked
	gen t_lb = mdy(month(date), 1, year(date))
	gen t_ub = mdy(month(date), day(mdy(month(date)+1,1,year(date))-1), year(date)) if month(date) < 12
	replace t_ub = mdy(12, 31, year(date)) if month(date) == 12
	
	replace t_lb = falta if t_lb < falta & !mi(falta)
	replace t_ub = fbaja if t_lb > fbaja	
	
	gen days_worked = t_ub - t_lb + 1
	assert days_worked <= 31
	
	* Number of hours worked per day
	gen hours_worked = 8 if coefparc == 0
	replace hours_worked = 8*coefparc/1000 if coefparc != 0
	assert mi(hours_worked) | hours_worked > 0
	
	* Hourly wages
	gen hourly_wages = base / (days_worked * hours_worked) 
	
	compress
	
	* Fix weird cases with negative wages but employed in that period ()
	assert identpers == "19935M0VH340100" if base < 0
	replace base = -base if base < 0
	replace hourly_wages = -hourly_wages if hourly_wages < 0
	
	* Set base and hourly wage to zero when, even employed, it does not receive a monthly wage
	replace base = . if base == 0
	replace hourly_wage = . if hourly_wage == 0
	
	* Keep relevant variables
	drop t_lb t_ub
	
	sort identpers identccc2 t
	save "$dta/03. Hourly wages.dta", replace
		
* End of this dofile
cap log close
exit,clear
