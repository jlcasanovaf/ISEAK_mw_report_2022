********************************************************************************
* Title: 01. Descriptives on transitions.do
* Date: 24/12/2022
* Description: This dofile generates the descriptives on transitions on the 
* extensive and intensive margin, following the steps from the ISEAK (2022) 
* paper on the MW analysis.
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
	log using "$log\01. Descriptives on transitions `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data
********************************************************************************
	
	use "$dta\99. Consolidated data.dta", clear
		
		merge m:1 identpers using "$path\dta\00. Matches.dta", nogen	
	
	* Interactions of transitions x treatment
	forval x = 1/3 {
		forval y = 0/1 {
			gen trans`x'_treatpo`y' = trans`x' if treated_pot == `y'
			gen trans`x'_treat`y' = trans`x' if treated == `y'
		}
	}

	forval y = 0/1 {	
		gen treated_pot`y' = (treated_pot == `y')
		gen treated`y' = (treated == `y')		
	}

	* Date periods
	qui sum t if year(date) == 2018 & month(date) == 12
	global t_1 = r(mean)
	
	qui sum t if year(date) == 2019 & month(date) == 11
	global t_12 = r(mean)		
	
	* Collapse
	collapse (sum) trans*_treat* treated*, by(t)
	
	forval x = 1/3 {
		forval y = 0/1 {
		replace trans`x'_treatpo`y' = 100*trans`x'_treatpo`y'/treated_pot`y'
		replace trans`x'_treat`y' = 100*trans`x'_treat`y'/treated`y'
		}
	}
	
	gen t2 = t + 0.3
	
********************************************************************************
* D. Transition 1 - Keeps employment and with the same intensity
********************************************************************************			

	local y = 1
	forval x = $t_1 / $t_12 {
		local t_`y' = `x'
		local y = `y' + 1
	}	
	
		# d;
		twoway (bar trans1_treatpo1 t, barw(0.3) bcolor(green)) 
				(bar trans1_treatpo0 t2, barw(0.3) bcolor(orange))
				if inrange(t,$t_1 , $t_12 ), 
				ylabel(50(5)100, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(order(1 "Tratamiento" 2 "Control") r(1) ring(0) position(1) nobox
				region(lstyle(none) color(none)))
				title("Pre-matching")
				name(g1, replace);
		#d cr
		
		# d;
		twoway (bar trans1_treat1 t, barw(0.3) bcolor(green)) 
				(bar trans1_treat0 t2, barw(0.3) bcolor(orange))
				if inrange(t,$t_1 , $t_12 ), 
				ylabel(50(5)100, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(order(1 "Tratamiento" 2 "Control") r(1) ring(0) position(1) nobox
				region(lstyle(none) color(none)))
				title("Matching")
				name(g2, replace);
		#d cr
		
		grc1leg g1 g2, legendfrom(g1) pos(12) graphregion(color(white)) 
		graph export "$out\Figure 13A.png", replace	
	
	
********************************************************************************
* E. Transition 2 - Keeps employment and lowers jobs intensity
********************************************************************************				
	
		# d;
		twoway (bar trans2_treatpo1 t, barw(0.3) bcolor(green)) 
				(bar trans2_treatpo0 t2, barw(0.3) bcolor(orange))
				if inrange(t,$t_1 , $t_12 ), 
				ylabel(0(2)11, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(order(1 "Tratamiento" 2 "Control") r(1) ring(0) position(1) nobox
				region(lstyle(none) color(none)))
				title("Pre-matching")
				name(g1, replace);
		#d cr
		
		# d;
		twoway (bar trans2_treat1 t, barw(0.3) bcolor(green)) 
				(bar trans2_treat0 t2, barw(0.3) bcolor(orange))
				if inrange(t,$t_1 , $t_12 ), 
				ylabel(0(2)11, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(order(1 "Tratamiento" 2 "Control") r(1) ring(0) position(1) nobox
				region(lstyle(none) color(none)))
				title("Matching")
				name(g2, replace);
		#d cr
		
		grc1leg g1 g2, legendfrom(g1) pos(12) graphregion(color(white)) 
		graph export "$out\Figure 13B.png", replace		
		
********************************************************************************
* F. Transition 3 - To unemployment
********************************************************************************				
	
		# d;
		twoway (bar trans3_treatpo1 t, barw(0.3) bcolor(green)) 
				(bar trans3_treatpo0 t2, barw(0.3) bcolor(orange))
				if inrange(t,$t_1 , $t_12 ), 
				ylabel(0(5)30, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(order(1 "Tratamiento" 2 "Control") r(1) ring(0) position(1) nobox
				region(lstyle(none) color(none)))
				title("Pre-matching")
				name(g1, replace);
		#d cr
		
		# d;
		twoway (bar trans3_treat1 t, barw(0.3) bcolor(green)) 
				(bar trans3_treat0 t2, barw(0.3) bcolor(orange))
				if inrange(t,$t_1 , $t_12 ), 
				ylabel(0(5)25, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(order(1 "Tratamiento" 2 "Control") r(1) ring(0) position(1) nobox
				region(lstyle(none) color(none)))
				title("Matching")
				name(g2, replace);
		#d cr
		
		grc1leg g1 g2, legendfrom(g1) pos(12) graphregion(color(white)) 
		graph export "$out\Figure 13C.png", replace				
		
	
* End of this dofile
cap log close
exit,clear
