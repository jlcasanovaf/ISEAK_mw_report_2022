********************************************************************************
* Title: 02. Multinomial regression.do
* Date: 27/12/2022
* Description: This dofile runs the multinomial regression model, following the 
* steps from the ISEAK (2022) paper on the MW analysis.
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
	log using "$log\02. Multinomial regression `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data
********************************************************************************

	use "$dta\99. Consolidated data.dta", clear
		
		merge m:1 identpers using "$path\dta\00. Matches.dta", nogen keep(3) // Keep only obs matched
		
		keep if !mi(treated)
		
		* Regressors
		global demo = "i.sexo i.menor_30 espanol"	
		global labor = "i.t0_gcnae i.t0_nworkers i.t0_skill t0_permanent i.t0_ft"

		* Date periods
		qui sum t if year(date) == 2018 & month(date) == 12
		global t_1 = r(mean)
		
		qui sum t if year(date) == 2019 & month(date) == 11
		global t_12 = r(mean)
	
********************************************************************************
* D. Regression
********************************************************************************	
	
	gen y_hat = .
	
	forval x = $t_1 / $t_12 {	
	
		eststo reg`x': mlogit y treated $demo $labor [w=weights] if t == `x', b(0)
			
		cap drop aux
		predict aux, outcome(1)
		replace y_hat = aux*100 if t == `x'
	
	}
	
	
********************************************************************************
* E. Predicted probability of remain as in t0
********************************************************************************		

	local y = 1
	forval x = $t_1 / $t_12 {
		local t_`y' = `x'
		local y = `y' + 1
	}	
		
		preserve
		
		collapse (mean) y_hat [w=weights], by(treated t)
	
		gen mylabel = string(y_hat, "%10,1fc")
	
		# d;
		twoway (connected y_hat t if treated == 1 & inrange(t, $t_1 , $t_12 ), lcolor(blue) mfcolor(none) mlcolor(blue) mlabel(mylabel) mlabcolor(black) mlabpos(1)), 
				ylabel(50(12.5)100, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(off)
				title("Tratamiento")
				name(g1, replace);
		#d cr
		
		# d;
		twoway (connected y_hat t if treated == 0 & inrange(t, $t_1 , $t_12 ), lcolor(blue) mfcolor(none) mlcolor(blue) mlabel(mylabel) mlabcolor(black) mlabpos(1)), 
				ylabel(50(12.5)100, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("%")
				legend(off)
				title("Control")
				name(g2, replace);
		#d cr		
	
		graph combine g1 g2, graphregion(color(white))
		graph export "$out\Figure 14.png", replace					
	
		restore
		
********************************************************************************
* F. Marginal effects on lower intensity and unemployment
********************************************************************************
	
	* Estimate marginal effects
	forval x = $t_1 / $t_12 {
		forval y = 2/3 {
			
			preserve
				
				est res reg`x'
		
				keep if e(sample) == 1
						
				margins, dydx(treated) predict(outcome(`y')) 
				
				mat table = r(table)
				global b`y'_`x' = table[1,1]
				global lb`y'_`x' = table[5,1]	
				global ub`y'_`x' = table[6,1]		
			
			restore
				
		}
	}
		
	
	* Prepare the data
	local y = 1
	forval x = $t_1 / $t_12 {
		local t_`y' = `x'
		local y = `y' + 1
	}	
	
	preserve
		local nobs = $t_12 - $t_1 + 1
		clear
		set obs `nobs'
		gen t = .
		forval x = 2/3 {
			gen b`x' = .
			gen lb`x' = .
			gen ub`x' = .			
		}

		local x = 1
		forval t = $t_1 / $t_12 {
			replace t = `t' in `x'
			forval outcome = 2/3 {
				replace b`outcome' = ${b`outcome'_`t'}  in `x'
				replace lb`outcome' = ${lb`outcome'_`t'} in `x'
				replace ub`outcome' = ${ub`outcome'_`t'} in `x'
			}
			local x = `x' + 1
		}
		
		* Graphs
		# d;
		twoway 	(rcap lb2 ub2 t, lcolor(navy))
				(scatter b2 t, mcolor(navy)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(off)
				title("Empleo con reducción en intensidad laboral", size(medsmall))
				name(g1, replace);
		#d cr

		# d;		
		twoway 	(rcap lb3 ub3 t, lcolor(navy))
				(scatter b3 t, mcolor(navy)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(off)
				title("Desempleo", size(medsmall))
				name(g2, replace);
		#d cr

		graph combine g1 g2, graphregion(color(white))
		graph export "$out\Figure 15.png", replace					

	restore

********************************************************************************
* G. Marginal effects by gender
********************************************************************************

	* Estimate marginal effects
	forval x = $t_1 / $t_12 {
		forval y = 1/3 {
			
			preserve
					
				keep if t == `x'
				
				forval gender = 0/1 {
				
					eststo reg`x': mlogit y treated menor_30 espanol $labor [w=weights] if sexo == `gender', b(0)				
					
					margins, dydx(treated) predict(outcome(`y')) 
					
					mat table = r(table)
					global b`y'_`gender'_`x' = table[1,1]
					global lb`y'_`gender'_`x' = table[5,1]	
					global ub`y'_`gender'_`x' = table[6,1]		
				
				}
			
			restore
			
		}
	}
		
	
	* Prepare the data
	local y = 1
	forval x = $t_1 / $t_12 {
		local t_`y' = `x'
		local y = `y' + 1
	}	
	
	preserve
		local obs_group = $t_12 - $t_1 + 1
		local nobs = 2*`obs_group'
		clear
		set obs `nobs'
		gen gender = 0 if _n <= `obs_group'
		replace gender = 1 if mi(gender)
		
		gen t = .
		forval x = 1/3 {
			gen b`x' = .
			gen lb`x' = .
			gen ub`x' = .			
		}

		local x = 1
		forval t = $t_1 / $t_12 {
			bys gender: replace t = `t' if _n == `x'
			forval outcome = 1/3 {
				forval gender = 0/1 {
					bys gender: replace b`outcome' = ${b`outcome'_`gender'_`t'} if _n == `x' & gender == `gender'
					bys gender: replace lb`outcome' = ${lb`outcome'_`gender'_`t'} if _n == `x' & gender == `gender'
					bys gender: replace ub`outcome' = ${ub`outcome'_`gender'_`t'} if _n == `x' & gender == `gender'
				}
			}
			local x = `x' + 1
		}
		
		gen t2 = t + 0.3
		
		* Graphs
		# d;
		twoway 	(rcap lb1 ub1 t if gender == 0, lcolor(navy))
				(scatter b1 t if gender == 0, mcolor(navy))
				(rcap lb1 ub1 t2 if gender == 1, lcolor(red))
				(scatter b1 t2 if gender == 1, mcolor(red)), 
				ylabel(-0.07(0.02)0.07, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "Hombres" 3 "Mujeres") r(1))
				title("Empleo sin reducción en intensidad laboral", size(medsmall))
				name(g1, replace);
		#d cr
		
		# d;
		twoway 	(rcap lb2 ub2 t if gender == 0, lcolor(navy))
				(scatter b2 t if gender == 0, mcolor(navy))
				(rcap lb2 ub2 t2 if gender == 1, lcolor(red))
				(scatter b2 t2 if gender == 1, mcolor(red)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "Hombres" 3 "Mujeres") r(1))
				title("Empleo con reducción en intensidad laboral", size(medsmall))
				name(g2, replace);
		#d cr

		# d;		
		twoway 	(rcap lb3 ub3 t if gender == 0, lcolor(navy))
				(scatter b3 t if gender == 0, mcolor(navy))
				(rcap lb3 ub3 t2 if gender == 1, lcolor(red))
				(scatter b3 t2 if gender == 1, mcolor(red)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "Hombres" 3 "Mujeres") r(1))
				title("Desempleo", size(medsmall))
				name(g3, replace);
		#d cr

		grc1leg g1 g2 g3, legendfrom(g1) graphregion(color(white))
		graph export "$out\Figure 16.png", replace					

	restore

********************************************************************************
* H. Marginal effects by age
********************************************************************************
	
	macro drop b* lb* ub*
	
	* Estimate marginal effects
	forval x = $t_1 / $t_12 {
		forval y = 1/3 {
			
			preserve
					
				keep if t == `x'
				
				forval menor_30 = 0/1 {
				
					eststo reg`x': mlogit y treated sexo espanol $labor [w=weights] if menor_30 == `menor_30', b(0)				
					
					margins, dydx(treated) predict(outcome(`y')) 
					
					mat table = r(table)
					global b`y'_`menor_30'_`x' = table[1,1]
					global lb`y'_`menor_30'_`x' = table[5,1]	
					global ub`y'_`menor_30'_`x' = table[6,1]		
				
				}
			
			restore
			
		}
	}
		
	
	* Prepare the data
	local y = 1
	forval x = $t_1 / $t_12 {
		local t_`y' = `x'
		local y = `y' + 1
	}	
	
	preserve
		local obs_group = $t_12 - $t_1 + 1
		local nobs = 2*`obs_group'
		clear
		set obs `nobs'
		gen menor_30 = 0 if _n <= `obs_group'
		replace menor_30 = 1 if mi(menor_30)
		
		gen t = .
		forval x = 1/3 {
			gen b`x' = .
			gen lb`x' = .
			gen ub`x' = .			
		}

		local x = 1
		forval t = $t_1 / $t_12 {
			bys menor_30: replace t = `t' if _n == `x'
			forval outcome = 1/3 {
				forval menor_30 = 0/1 {
					bys menor_30: replace b`outcome' = ${b`outcome'_`menor_30'_`t'} if _n == `x' & menor_30 == `menor_30'
					bys menor_30: replace lb`outcome' = ${lb`outcome'_`menor_30'_`t'} if _n == `x' & menor_30 == `menor_30'
					bys menor_30: replace ub`outcome' = ${ub`outcome'_`menor_30'_`t'} if _n == `x' & menor_30 == `menor_30'
				}
			}
			local x = `x' + 1
		}
		
		gen t2 = t + 0.3		
		
		* Graphs
		# d;
		twoway 	(rcap lb1 ub1 t if menor_30 == 0, lcolor(forest_green))
				(scatter b1 t if menor_30 == 0, mcolor(forest_green))
				(rcap lb1 ub1 t2 if menor_30 == 1, lcolor(purple))
				(scatter b1 t2 if menor_30 == 1, mcolor(purple)), 
				ylabel(-0.07(0.02)0.07, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "<=30 años" 3 ">30 años") r(1))
				title("Empleo sin reducción en intensidad laboral", size(medsmall))
				name(g1, replace);
		#d cr
		
		# d;
		twoway 	(rcap lb2 ub2 t if menor_30 == 0, lcolor(forest_green))
				(scatter b2 t if menor_30 == 0, mcolor(forest_green))
				(rcap lb2 ub2 t2 if menor_30 == 1, lcolor(purple))
				(scatter b2 t2 if menor_30 == 1, mcolor(purple)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "<=30 años" 3 ">30 años") r(1))
				title("Empleo con reducción en intensidad laboral", size(medsmall))
				name(g2, replace);
		#d cr

		# d;		
		twoway 	(rcap lb3 ub3 t if menor_30 == 0, lcolor(forest_green))
				(scatter b3 t if menor_30 == 0, mcolor(forest_green))
				(rcap lb3 ub3 t2 if menor_30 == 1, lcolor(purple))
				(scatter b3 t2 if menor_30 == 1, mcolor(purple)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "<=30 años" 3 ">30 años") r(1))
				title("Desempleo", size(medsmall))
				name(g3, replace);
		#d cr

		grc1leg g1 g2 g3, legendfrom(g1) graphregion(color(white))
		graph export "$out\Figure 17.png", replace					

	restore

********************************************************************************
* I. Marginal effects by job intensity 
********************************************************************************

	macro drop b* lb* ub*
	
	* Estimate marginal effects
	forval x = $t_1 / $t_12 {
		forval y = 1/3 {
			
			preserve
					
				keep if t == `x'
				
				forval t0_ft = 0/1 {
				
					eststo reg`x': mlogit y treated sexo menor_30 espanol i.t0_gcnae i.t0_nworkers i.t0_skill t0_permanent [w=weights] if t0_ft == `t0_ft', b(0)				
					
					margins, dydx(treated) predict(outcome(`y')) 
					
					mat table = r(table)
					global b`y'_`t0_ft'_`x' = table[1,1]
					global lb`y'_`t0_ft'_`x' = table[5,1]	
					global ub`y'_`t0_ft'_`x' = table[6,1]		
				
				}
			
			restore
			
		}
	}
		
	
	* Prepare the data
	local y = 1
	forval x = $t_1 / $t_12 {
		local t_`y' = `x'
		local y = `y' + 1
	}	
	
	preserve
		local obs_group = $t_12 - $t_1 + 1
		local nobs = 2*`obs_group'
		clear
		set obs `nobs'
		gen ft = 0 if _n <= `obs_group'
		replace ft = 1 if mi(ft)
		
		gen t = .
		forval x = 1/3 {
			gen b`x' = .
			gen lb`x' = .
			gen ub`x' = .			
		}

		local x = 1
		forval t = $t_1 / $t_12 {
			bys ft: replace t = `t' if _n == `x'
			forval outcome = 1/3 {
				forval ft = 0/1 {
					bys ft: replace b`outcome' = ${b`outcome'_`ft'_`t'} if _n == `x' & ft == `ft'
					bys ft: replace lb`outcome' = ${lb`outcome'_`ft'_`t'} if _n == `x' & ft == `ft'
					bys ft: replace ub`outcome' = ${ub`outcome'_`ft'_`t'} if _n == `x' & ft == `ft'
				}
			}
			local x = `x' + 1
		}
	
		gen t2 = t + 0.3		
	
		* Graphs
		# d;
		twoway 	(rcap lb1 ub1 t if ft == 0, lcolor(orange))
				(scatter b1 t if ft == 0, mcolor(orange))
				(rcap lb1 ub1 t2 if ft == 1, lcolor(forest_green))
				(scatter b1 t2 if ft == 1, mcolor(forest_green)), 
				ylabel(-0.07(0.02)0.07, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "Jornada parcial" 3 "Jornada completa") r(1))
				title("Empleo sin reducción en intensidad laboral", size(medsmall))
				name(g1, replace);
		#d cr
		
		# d;
		twoway 	(rcap lb2 ub2 t if ft == 0, lcolor(orange))
				(scatter b2 t if ft == 0, mcolor(orange))
				(rcap lb2 ub2 t2 if ft == 1, lcolor(forest_green))
				(scatter b2 t2 if ft == 1, mcolor(forest_green)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "Jornada parcial" 3 "Jornada completa") r(1))
				title("Empleo con reducción en intensidad laboral", size(medsmall))
				name(g2, replace);
		#d cr

		# d;		
		twoway 	(rcap lb3 ub3 t if ft == 0, lcolor(orange))
				(scatter b3 t if ft == 0, mcolor(orange))
				(rcap lb3 ub3 t2 if ft == 1, lcolor(forest_green))
				(scatter b3 t2 if ft == 1, mcolor(forest_green)), 
				ylabel(-0.04(0.01)0.04, labsize(small)) 
				xlabel(`t_1' "t+1" `t_2' "t+2" `t_3' "t+3" `t_4' "t+4" `t_5' "t+5" `t_6' "t+6" `t_7' "t+7" `t_8' "t+8" `t_9' "t+9" `t_10' "t+10" `t_11' "t+11" `t_12' "t+12",format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("")
				ytitle("")
				yline(0, lcolor(red))
				legend(order(1 "Jornada parcial" 3 "Jornada completa") r(1))
				title("Desempleo", size(medsmall))
				name(g3, replace);
		#d cr

		grc1leg g1 g2 g3, legendfrom(g1) graphregion(color(white))
		graph export "$out\Figure 18.png", replace					

	restore
	
* End of this dofile
cap log close
exit,clear	
