********************************************************************************
* Title: Master dofile.do
* Date: 31/12/2022
* Description: This dofile runs the data load, descriptive and regression 
* analysis of the minimum wages.
********************************************************************************
	
	clear all
	set trace off
	ssc inst unique
	
********************************************************************************
* A. Directories
********************************************************************************

	global mpath "E:\Jorgec\ISEAK mw report 2022"
		
		global mcvl_dataload "$mpath\00. Data processing\00. MCVL"
		global descriptives "$mpath\01. Descriptives"
		global regressions "$mpath\02. Regressions"
		
********************************************************************************
* B. MCVL - data load
********************************************************************************

	cd "$mcvl_dataload"
	
	* Cutoff dates
	do "_AUX. Generate cutoff dates.do"
	
	* Load MCVL data
	do "00. Load MCVL data.do"	
	
	* Harmonise affiliation data
	do "01. Harmonise affiliation data.do"
	
	* Harmonise contribution data
	do "02. Harmonise contribution basis data.do"
	
	* Estimate hourly wages
	do "03. Estimate hourly wages.do"
	
	* Consolidate dataset
	do "99. Consolidate dataset.do"	

********************************************************************************
* C. Descriptive analysis
********************************************************************************	

	cd "$descriptives"

	do "00. Replicate descriptives.do"

********************************************************************************
* D. Regression analysis
********************************************************************************	

	cd "$regressions"
	
	* Generating matching sample
	do "00. Matching.do"
	
	* Descriptive analysis on transitions (replication of the ISEAK report)
	do "01. Descriptives on transitions.do"
	
	* Multinomial analysis (replication of the ISEAK report)	
	do "02. Multinomial regression.do"	
	
* End of this dofile
exit,clear
