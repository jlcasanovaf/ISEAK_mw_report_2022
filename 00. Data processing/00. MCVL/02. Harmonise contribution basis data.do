********************************************************************************
* Title: 02. Harmonise contribution basis data.do
* Date: 07/12/2022
* Description: This dofile harmonises the contribution basis data from the MCVL, 
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
	log using "$log\02. Harmonise contribution basis data `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data of general regime
********************************************************************************
	
	use "$dta/00. Contribution data.dta", clear	
		
	drop basetot
	
	* Keep only 2018 and 2019
	keep if inrange(anocot, 2018, 2019)
	
	*Reshape
	reshape long base, i(identpers identccc2 anocot) j(mescot)
	
	*Generate common time variable
	gen t = .
	local x = 1

	forval year = 2018/2019 {
		forval month = 1/12 {
			qui replace t = `x' if anocot == `year' & mescot == `month'
			local x = `x' + 1
		}
	}
	
	compress
	
	sort identpers identccc2 t
	save "$dta/02. Harmonized Contribution basis.dta", replace

********************************************************************************
* D. Load and prepare the data of special regime
********************************************************************************	
	
	use "$dta\00. Contribution data special regime.dta", clear
	
	drop basetot
	
	* Keep only 2018 and 2019
	keep if inrange(anocot, 2018, 2019)
	
	*Reshape
	reshape long base, i(identpers identccc2 anocot) j(mescot)
	
	*Generate common time variable
	gen t = .
	local x = 1

	forval year = 2018/2019 {
		forval month = 1/12 {
			qui replace t = `x' if anocot == `year' & mescot == `month'
			local x = `x' + 1
		}
	}
	
	compress
	
	sort identpers identccc2 t	
	save "$dta/02. Harmonized Contribution basis special regime.dta", replace
	
* End of this dofile
cap log close
exit,clear
