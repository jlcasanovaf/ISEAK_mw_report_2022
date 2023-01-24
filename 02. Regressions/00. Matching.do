********************************************************************************
* Title: 00. Matching.do
* Date: 22/12/2022
* Description: This dofile generates a matching sample for our treatment group,
* following the steps from the ISEAK (2022) paper on the MW analysis.
********************************************************************************
	
	clear all
	set trace off
	ssc inst unique
	ssc install cem
	
********************************************************************************
* A. Directories
********************************************************************************

	global mpath "E:\Jorgec\ISEAK mw report 2022"
		
		global path "$mpath\02. Regressions"
		global dta "$mpath\00. Data processing\00. MCVL\dta"
		global out "$path\out"
		global log "$path\log"
	
	local today : display %tdCYND date(c(current_date), "DMY")
		
		
********************************************************************************
* B. Log file
********************************************************************************

	cap log close
	log using "$log\00. Matching `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data
********************************************************************************
	
	use "$dta\99. Consolidated data.dta", clear
	
		keep if month(date) == 11 & year(date) == 2018 & !mi(treated_pot)
	
		* Generate dummy variables for all categories
		foreach var in edad_cat nworkers skill gcnae regcot coefparc_cat {
			tab `var', gen(`var'_t)
			qui ds `var'_t*
			local `var'_list = r(varlist)
		}
	
		gen rgeneral = (regcot == 111)
	
	
********************************************************************************
* D. Differences in mean before the matching
********************************************************************************		
	
	foreach var in gcnae male sexo edad_cat nworkers {
	
		preserve
			
			drop gcnae_str
			
			cap drop str_`var'
			decode `var',gen(str_`var')
			qui levelsof str_`var' if !mi(str_`var'),local(cats)
			local n_val = r(r)
			
			local x = 1
			foreach cat of local cats {
				
				local cat`x' = "`cat'"
				
				qui count if treated_pot == 0
				local total_cont = r(N)
			
				qui count if treated_pot == 1
				local total_treat = r(N)			
			
				qui count if str_`var' == "`cat'" & treated_pot == 0
				local `var'_cont`x' = r(N)/`total_cont'				
	
				qui count if str_`var' == "`cat'" & treated_pot == 1
				local `var'_treat`x' = r(N)/`total_treat'					
				
				cap drop aux
				gen aux = (str_`var' == "`cat'")
				
				qui ttest aux, by(treated_pot)
				local `var'_p`x' = r(p)
				
				local x = `x' + 1				
			}
			
			clear
			set obs `n_val'
			gen category = ""
			gen treated = .
			gen control = .
			gen pvalue = .
			
			forval x = 1/`n_val' {
				replace category = "`cat`x''" in `x'
				replace treated = ``var'_treat`x'' in `x'
				replace control = ``var'_cont`x'' in `x'
				replace pvalue = ``var'_p`x'' in `x'
			}
			qui drop if category == "None"
			
			sort category

			tempfile `var'
			save ``var'', replace	
				
		restore
	}

	preserve
	
		clear
		foreach var in male sexo edad_cat nworkers gcnae {	
		append using ``var''
		}
		order category treated control pvalue
		list
		
		export excel "$out\Table 4.xlsx", sheetreplace sheet("raw")
		
	restore
	
********************************************************************************
* E. Matching
********************************************************************************			
	
	* CEM
	cem sexo permanent_ft permanent_pt temporary_ft temporary_pt espanol rgeneral edad (16 25.5 35.5 44.5 55.5 60) numtrab (0 10.5 49.5 249.5) regcot (1 2.5 7.5 9.5) `gcnae_list' coefparc (0 249.5 500.5 750.5 999.5), treatment(treated_pot) k2k
	
	* Generate new treatment variable and weights
	gen treated = treated_pot if cem_matched == 1
	gen weights = cem_weights
	gen weights_pre = 1
	
********************************************************************************
* F. Differences in mean after the matching
********************************************************************************		
	
	foreach var in male sexo edad_cat nworkers temporary_ft temporary_pt permanent_ft permanent_pt coefparc_cat {
	
		preserve
			
			cap drop str_`var'
			decode `var',gen(str_`var')
			qui levelsof str_`var' if !mi(str_`var'),local(cats)
			local n_val = r(r)
			local x = 1
			
			foreach cat of local cats {
			
				qui sum `var' if str_`var' == "`cat'"
				local y = r(max)				
				
				local cat`x' = "`cat'"

	
				foreach period in treated_pot treated {
				
					if "`period'" == "treated_pot" {
						local type "pre"
						local weights "weights_pre"
					}
					if "`period'" == "treated" {
						local type "post"
						local weights "weights"			
					}
					
					if "`var'" == "male" | "`var'" == "sexo" | "`var'" == "temporary_ft" | "`var'" == "temporary_pt" | "`var'" == "permanent_ft" | "`var'" == "permanent_pt"  {
						qui sum `var' if `period' == 0 [w=`weights']
						local `var'_cont_`type'`x' = r(mean)
			
						qui sum `var' if `period' == 1 [w=`weights']
						local `var'_treat_`type'`x' = r(mean)					
						
						qui reg `period' `var' [w=`weights']
						mat table = r(table)
						local `var'_p_`type'`x' = table[4,1]			
					}
					else {
						qui sum `var'_t`y' if `period' == 0 [w=`weights']
						local `var'_cont_`type'`x' = r(mean)
			
						qui sum `var'_t`y' if `period' == 1 [w=`weights']
						local `var'_treat_`type'`x' = r(mean)					
						
						cap drop aux
						gen aux = (str_`var' == "`cat'")
						
						qui reg `period' aux [w=`weights']
						mat table = r(table)
						local `var'_p_`type'`x' = table[4,1]
					}
				}
				local x = `x' + 1
			}
			
			clear
			set obs `n_val'
			gen category = ""
			gen treated = .
			gen control = .
			gen pvalue = .
			gen treated_pre = .
			
			forval x = 1/`n_val' {
				replace category = "`cat`x''" in `x'
				replace treated = ``var'_treat_post`x'' in `x'
				replace control = ``var'_cont_post`x'' in `x'
				replace pvalue = ``var'_p_post`x'' in `x'
				replace treated_pre = ``var'_treat_pre`x'' in `x'				
			}
			
			qui drop if category == "None"
			
			sort category
			
			tempfile `var'
			save ``var'', replace	
				
		restore
	}

	preserve
	
		clear
		foreach var in male sexo edad_cat nworkers temporary_ft temporary_pt permanent_ft permanent_pt coefparc_cat {	
		append using ``var''
		}
		
		order category treated control pvalue treated_pre
		list
		
		export excel "$out\Table 5.xlsx", sheetreplace sheet("raw")
	
	restore
	
********************************************************************************
* G. Export matching
********************************************************************************			

	keep identpers treated weights
	sort identpers 
	
	compress
	save "$path\dta\00. Matches.dta", replace
	
	
* End of this dofile
cap log close
exit,clear
