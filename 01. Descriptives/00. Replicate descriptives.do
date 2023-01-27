********************************************************************************
* Title: 00. Replicate descriptives.do
* Date: 07/12/2022
* Description: This dofile replicates the descriptives of the ISEAK (2022) paper 
* on the MW analysis, using the MCVL sample.
********************************************************************************
	
	clear all
	set trace off
	ssc inst unique
	
********************************************************************************
* A. Directories
********************************************************************************

	global mpath "E:\Jorgec\ISEAK mw report 2022"
		
		global path "$mpath\01. Descriptives"
		global dta "$mpath\00. Data processing\00. MCVL\dta"
		global out "$path\out"
		global log "$path\log"
	
	local today : display %tdCYND date(c(current_date), "DMY")
		
		
********************************************************************************
* B. Log file
********************************************************************************

	cap log close
	log using "$log\00. Replicate descriptives `today'.log", replace

	
********************************************************************************
* C. Load and prepare the data
********************************************************************************
	
	use "$dta/99. Consolidated data.dta", clear	

	gen one_18 = hourly_wages if employed == 1 & year(date) == 2018 & month(date) == 11
	gen one_19 = hourly_wages if employed == 1 & year(date) == 2019 & month(date) == 1
	gen one_19_nov = hourly_wages if employed == 1 & year(date) == 2019 & month(date) == 11
	
	gen year = year(date)
	
********************************************************************************
* D. Load and prepare the data
********************************************************************************	
	
	preserve
	
		keep if !mi(one_18) | !mi(one_19) 
		
			# d;
			twoway (hist one_18, width(0.1) freq bcolor(navy%60)) 
					(hist one_19, width(0.1) freq bcolor(none) fcolor(none) bcolor(red%70))	
					if hourly_wages <= 6, 
					xlabel(0(1)6) 
					ylabel(0 "0" 5000 "125" 10000 "250" 15000 "375" 20000 "500",format(%12,0fc)) // Extrapolate 4% sample
					graphregion(color(white))
					xtitle("Salario/hora")
					ytitle("Personas (en miles)")
					legend(order(1 "2018" 2 "2019") r(2) ring(0) position(10) nobox
					region(lstyle(none) color(none)));
			#d cr
			graph export "$out\Figure 2.png", replace
			
			# d;
			twoway (hist one_18, width(0.1) freq bcolor(navy%60)) 
					(hist one_19, width(0.1) freq bcolor(none) fcolor(none) bcolor(red%70))	
					if hourly_wages <= 6 & ft == 1, 
					xlabel(0(1)6) 
					ylabel(0 "0" 5000 "125" 10000 "250" 15000 "375" 20000 "500",format(%12,0fc)) // Extrapolate 4% sample
					graphregion(color(white))
					xtitle("Salario/hora")
					ytitle("Personas (en miles)")
					legend(order(1 "2018" 2 "2019") r(2) ring(0) position(10) nobox
					region(lstyle(none) color(none)));
			#d cr
			graph export "$out\Figure 3A.png", replace		
			
			# d;
			twoway (hist one_18, width(0.1) freq bcolor(navy%60)) 
					(hist one_19, width(0.1) freq bcolor(none) fcolor(none) bcolor(red%70))	
					if hourly_wages <= 6 & ft == 0, 
					xlabel(0(1)6) 
					ylabel(0 "0" 5000 "125" 10000 "250" 15000 "375" 20000 "500",format(%12,0fc)) // Extrapolate 4% sample
					graphregion(color(white))
					xtitle("Salario/hora")
					ytitle("Personas (en miles)")
					legend(order(1 "2018" 2 "2019") r(2) ring(0) position(10) nobox
					region(lstyle(none) color(none)));
			#d cr
			graph export "$out\Figure 3B.png", replace				
		
		restore
		
********************************************************************************
* D. Table 1
********************************************************************************			
	
	foreach var in gcnae sexo edad_cat nworkers {
		
		preserve
		
			keep if !mi(one_18) | !mi(one_19) 
		
			drop gcnae_str
			keep if !mi(one_18)
		
			cap drop str_`var'
			decode `var',gen(str_`var')
			qui levelsof str_`var' if !mi(str_`var'),local(cats)
			local n_val = r(r)
			
			local x = 1
			foreach cat of local cats {
				
				local cat`x' = "`cat'"
				
				qui count if hourly_wages < 4.375 & str_`var' == "`cat'" 
				local `var'`x' = r(N)
				
				qui count if str_`var' == "`cat'"
				local `var'_tot`x' = r(N)
				
				local share`x' = ``var'`x'' / ``var'_tot`x''
				
				local x = `x' + 1
			}
			
			clear
			set obs `n_val'
			gen category = ""
			gen freq = .
			gen freq_tot = .
			gen share = .
			
			forval x = 1/`n_val' {
				replace category = "`cat`x''" in `x'
				replace freq = ``var'`x'' in `x'
				replace freq_tot = ``var'_tot`x'' in `x'
				replace share = `share`x'' in `x'
			}
			
			tempfile `var'
			save ``var'', replace	
				
		restore
	}
	
	preserve
		clear
		foreach var in sexo edad_cat nworkers gcnae {	
		append using ``var''
		}
		
		export excel "$out\Table 1.xlsx", sheetreplace sheet("raw") first(var)
	restore
	
********************************************************************************
* D. Table 2
********************************************************************************				

	foreach type in all smi men women{

	foreach var in gcnae sexo edad_cat nworkers {
	
		preserve
		
			keep if !mi(one_18) | !mi(one_19) 
			
			drop gcnae_str
			keep if !mi(one_18)
			
			if "`type'" == "all" {
				local filter ""
				qui count
				local total = r(N)
			}
			if "`type'" == "smi" {
				local filter "hourly_wages < 4.375 & "
				qui count if hourly_wages < 4.375
				local total = r(N)		
			}
			if "`type'" == "men" {
				local filter "hourly_wages < 4.375 & sexo == 0 & "
				qui count if hourly_wages < 4.375 & sexo == 0
				local total = r(N)						
			}
			if "`type'" == "women" {
				local filter "hourly_wages < 4.375 & sexo == 1 & "
				qui count if hourly_wages < 4.375 & sexo == 1
				local total = r(N)										
			}
			
			cap drop str_`var'			
			decode `var',gen(str_`var')
			qui levelsof str_`var' if !mi(str_`var'),local(cats)
			local n_val = r(r)
			
			local x = 1
			foreach cat of local cats {
				
				local cat`x' = "`cat'"
				
				qui count if `filter' str_`var' == "`cat'" 
				local `var'`x' = r(N)/`total'
				local x = `x' + 1				
			}
			
			clear
			set obs `n_val'
			gen category = ""
			gen `type' = .
			
			forval x = 1/`n_val' {
				replace category = "`cat`x''" in `x'
				replace `type' = ``var'`x'' in `x'
			}
			
			sort category
			
			tempfile `var'
			save ``var'', replace	
				
		restore
	}
	
	preserve
	
		clear
		foreach var in sexo edad_cat nworkers gcnae {	
		append using ``var''
		}
		
		tempfile `type'
		save ``type'', replace
	
	restore
	
	}
	
	preserve
		
		use `all', clear
		
		foreach type in smi men women{	
			sort category
			merge 1:1 category using ``type'', nogen keep(3)
		}
		
		export excel "$out\Table 2.xlsx", sheetreplace sheet("raw") first(var)
	
	restore

	
********************************************************************************
* E. Graph 4
********************************************************************************					
	
	preserve
		
		keep if !mi(one_18) | !mi(one_19) 
	
		drop gcnae_str
		keep if !mi(one_18)
			
		gen affected = (hourly_wages > 3.57 & hourly_wages < 4.375)
		gen all = 1
		gen men = (sexo == 0)
		gen women = (sexo == 1)
		gen nacional = (espanol == 1)
		gen foreign = (espanol == 0)
		gen less_30 = (edad <= 30)
		gen more_30 = (edad > 30)

		foreach type in all men women nacional foreign less_30 more_30 {
			qui sum hourly_wages if `type' == 1 & affected == 1
			local `type' = (r(mean)/4.375)*100
		}

		clear 
		set obs 7
		gen category = "Total" in 1
		replace category = "Hombres" in 2
		replace category = "Mujeres" in 3
		replace category = "Nacionales" in 4
		replace category = "Extranjeros" in 5
		replace category = "<=30" in 6
		replace category = ">30" in 7

		encode category, gen(category_n)

		gen value = `all' in 1
		replace value = `men' in 2 
		replace value = `women' in 3 
		replace value = `nacional' in 4
		replace value = `foreign' in 5
		replace value = `less_30' in 6
		replace value = `more_30' in 7

		gen mylabel = string(value, "%10,1fc")

		local smi18 = (3.57/4.375)*100

		# delimit;
			twoway (scatter value category_n if category == "Total", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6)) 
			(scatter value category_n if category == "Hombres", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6))
			(scatter value category_n if category == "Mujeres", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6)) 
			(scatter value category_n if category == "Nacionales", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6)) 
			(scatter value category_n if category == "Extranjeros", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6)) 
			(scatter value category_n if category == "<=30", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6)) 
			(scatter value category_n if category == ">30", color(navy) mlabel(mylabel) mlabcolor(black) mlabpos(6)),
			xlabel(1 "Total" 2 "Hombres" 3 "Mujeres" 4 "Nacionales" 5 "Extranjeros" 6 "<=30" 7 ">30", labsize(small))
			xtitle("")
			ytitle("%")
			yline(`smi18', lpat(dash) lcolor(red))
			ylabel(80(10)100, labsize(small))
			legend(off)
			graphregion(color(white));
		# delimit cr
		graph export "$out\Figure 4.png", replace

	restore

********************************************************************************
* F. Graph 5
********************************************************************************						
	
	preserve
		
		keep if !mi(one_18) | !mi(one_19) 
	
		drop gcnae_str
		keep if !mi(one_18)
		
		gen affected = (hourly_wages > 3.57 & hourly_wages < 4.375)
		gen all = 1
		gen men = (sexo == 0)
		gen women = (sexo == 1)
		gen nacional = (espanol == 1)
		gen foreign = (espanol == 0)
		gen less_30 = (edad <= 30)
		gen more_30 = (edad > 30)
	
		foreach type in all men women nacional foreign less_30 more_30 {
			
			local x = 1
			foreach num of numlist 3.6(0.1)4.4 {
				
				local num2 = `num' + 0.1
				
				qui count if `type' == 1 & hourly_wages >= 3.6 & hourly_wages < 4.5
				local `type'_tot`x' = r(N)
				
				qui count if `type' == 1 & hourly_wages >= `num' & hourly_wages < `num2'
				local `type'`x' = (r(N)/``type'_tot`x'')*100
				
				local x = `x' + 1

			}																				
		}	
		
		clear 
		set obs 7
		gen category = "all" in 1
		replace category = "men" in 2
		replace category = "women" in 3
		replace category = "nacional" in 4
		replace category = "foreign" in 5
		replace category = "less_30" in 6
		replace category = "more_30" in 7

		encode category, gen(category_n)
	
		expand 9
		bys category: gen range = _n

		gen value = . 
		foreach type in all men women nacional foreign less_30 more_30 {
		
			forval x = 1/9 {
			
				replace value = ``type'`x'' if category == "`type'" & range == `x'
			
			}	
		}
		
		# delimit;
			twoway (scatter value range if category == "men", mfcolor(none) mlcolor(blue) msymbol(O)) 
			(scatter value range if category == "women", mfcolor(none) mlcolor(green) msymbol(T)),
			xlabel(1 "3.6" 2 "3.7" 3 "3.8" 4 "3.9" 5 "4" 6 "4.1" 7 "4.2" 8 "4.3" 9 "4.4", labsize(small))
			xtitle("Salario/hora")
			ytitle("%")
			ylabel(0(7)28, labsize(small))
			graphregion(color(white))
			legend(order(1 "Hombres" 2 "Mujeres") r(2) ring(0) position(1) nobox
			region(lstyle(none) color(none)));
		# delimit cr
		graph export "$out\Figure 5A.png", replace		
		
		# delimit;
			twoway (scatter value range if category == "nacional", mfcolor(none) mlcolor(green) msymbol(O)) 
			(scatter value range if category == "foreign", mfcolor(none) mlcolor(red) msymbol(T)),
			xlabel(1 "3.6" 2 "3.7" 3 "3.8" 4 "3.9" 5 "4" 6 "4.1" 7 "4.2" 8 "4.3" 9 "4.4", labsize(small))
			xtitle("Salario/hora")
			ytitle("%")
			ylabel(0(7)28, labsize(small))
			graphregion(color(white))
			legend(order(1 "Nacional" 2 "Extranjero") r(2) ring(0) position(1) nobox
			region(lstyle(none) color(none)));
		# delimit cr
		graph export "$out\Figure 5B.png", replace		
		
		
		# delimit;
			twoway (scatter value range if category == "less_30", mfcolor(none) mlcolor(blue) msymbol(O)) 
			(scatter value range if category == "more_30", mfcolor(none) mlcolor(gold) msymbol(T)),
			xlabel(1 "3.6" 2 "3.7" 3 "3.8" 4 "3.9" 5 "4" 6 "4.1" 7 "4.2" 8 "4.3" 9 "4.4", labsize(small))
			xtitle("Salario/hora")
			ytitle("%")
			ylabel(0(7)28, labsize(small))
			graphregion(color(white))
			legend(order(1 "<= 30 años" 2 ">30 años") r(2) ring(0) position(1) nobox
			region(lstyle(none) color(none)));
		# delimit cr
		graph export "$out\Figure 5C.png", replace				

	restore
	
********************************************************************************
* G. Graph 6
********************************************************************************							
	
	preserve
	
		keep if !mi(one_18) | !mi(one_19_nov) 
		
			# d;
			twoway (hist one_18, width(0.1) freq bcolor(navy%60)) 
					(hist one_19_nov, width(0.1) freq bcolor(none) fcolor(none) bcolor(red%70))	
					if hourly_wages <= 15, 
					xlabel(0(1)15) 
					ylabel(0 "0" 5000 "125" 10000 "250" 15000 "375" 20000 "500",format(%12,0fc)) // Extrapolate 4% sample
					graphregion(color(white))
					xtitle("Salario/hora")
					ytitle("Personas (en miles)")
					legend(order(1 "2018" 2 "2019") r(2) ring(0) position(1) nobox
					region(lstyle(none) color(none)));
			#d cr
			graph export "$out\Figure 6.png", replace	
	
	restore
	
********************************************************************************
* G. Graph 12
********************************************************************************									
	
	preserve
	
		keep if !mi(one_18)
		
			# d;
			twoway (hist one_18, width(0.1) freq bcolor(navy%60)) 
					if hourly_wages <= 6, 
					xlabel(0(1)6) 
					ylabel(0 "0" 5000 "125" 10000 "250" 15000 "375",format(%12,0fc)) // Extrapolate 4% sample
					graphregion(color(white))
					xtitle("Salario/hora")
					ytitle("Personas (en miles)")
					xline(4.39, lcolor(orange))
					xline(5.47, lcolor(orange))
					xline(3.57, lcolor(navy%60))
					xline(4.375, lcolor(navy%60))
					ttext(13000 4 "Grupo de" "tratamiento", size(small) color(navy))
					ttext(13000 5 "Grupo de" "control", size(small) color(orange))				
					legend(off);
			#d cr
			graph export "$out\Figure 12.png", replace	

	restore

********************************************************************************
* H. Graph 7
********************************************************************************										
	
	preserve
	
		keep if !mi(one_18) | !mi(one_19_nov) 
		
		gen one = 1

		
		gen delta = .
	
			local x = 1
			foreach num of numlist 0(0.1)14.9 {
				
				local num2 = `num' + 0.1
					
				qui replace delta = `num' if hourly_wages >= `num' & hourly_wages < `num2'
			}

		gen cum_w = hourly_wages * hours_worked
	
		collapse (sum) one cum_w , by(year delta)
		
		reshape wide one cum_w, i(delta) j(year)
		
		egen total2018 = total(one2018)
		egen totalw2018 = total(cum_w2018)		
		
		gen varemp = 100*((one2019-one2018)/total2018)		
		gen cumemp = 100*(sum(one2019-one2018)/total2018)
		gen cumw = 100*(sum(cum_w2019-cum_w2018)/totalw2018)
		
		# d;
		twoway (bar varemp delta, barw(0.07) bcolor(blue)) 
				(line cumemp delta, color(orange))
				(line cumw delta, color(green)), 
				ylabel(-8(2)6, labsize(small)) 
				xlabel(0(1)15,format(%12,0fc) labsize(vsmall)) // Extrapolate 4% sample
				graphregion(color(white))
				xtitle("Salario/hora", size(small))
				ytitle("Cambio con respecto a 2018 (%)", size(small))
				legend(order(1 "Personas asalariadas" 2 "Personas asalariadas (acumulado)" 3 "Masa salarial (acumulado)") size(small) r(3) ring(0) position(4) nobox
				region(lstyle(none) color(none)));
		#d cr		
		graph export "$out\Figure 7.png", replace
		
	restore
	
********************************************************************************
* I. Graph 8
********************************************************************************										
	
	preserve
	
		keep if !mi(one_18) | !mi(one_19_nov) 	
				
		forval x = 2018/2019 {
			qui sum base if year == `x',d
			global qmed_`x' = r(c_5)		

			centile base if year == `x' & base < ${qmed_`x'}, c(20 40 60 80)
			
			global q1_`x' = r(c_1)
			global q2_`x' = r(c_2)
			global q3_`x' = r(c_3)
			global q4_`x' = r(c_4)	
			
		}
		
		* Split sample on quintiles
		forval x = 2018/2019 {
		
			gen one_q1_`x' = base if year == `x' & base < ${q1_`x'}	
			gen one_q2_`x' = base if year == `x' & base >= ${q1_`x'} & base < ${q2_`x'}
			gen one_q3_`x' = base if year == `x' & base >= ${q2_`x'} & base < ${q3_`x'}
			gen one_q4_`x' = base if year == `x' & base >= ${q3_`x'} & base < ${q4_`x'}
			gen one_q5_`x' = base if year == `x' & base >= ${q4_`x'} & base < ${qmed_`x'}
		}	

		forval x = 2018/2019 {
			gen lw_`x' = base if year == `x' & base < ${qmed_`x'}
		}
		
		* Collapse and estimate shares of income
		collapse (sum) one_q* lw_*
		
		forval x = 2018/2019 {
			forval q = 1/5 {
			
				gen s_q`q'_`x' = (one_q`q'_`x'/lw_`x')*100
			}
		}	
		keep s_q*	
		
		gen ID = 1
		
		reshape long s_q1_ s_q2_ s_q3_ s_q4_ s_q5_, i(ID) j(year)
		
		ren (s_q1_ s_q2_ s_q3_ s_q4_ s_q5_) (sq1 sq2 sq3 sq4 sq5)
		
		reshape long sq, i(year) j(q)
		
		gen sq18 = sq if year == 2018
		gen sq19 = sq if year == 2019
		
		label define q 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
		label values q q
		
		# d;
		graph bar (mean) sq18 sq19, 
				over(q)
				blabel(total, format(%12,1fc) position(inside) color(white))
				ylabel(0(7.5)30, labsize(small)) 
				graphregion(color(white))
				ytitle("")
				bar(1,color(blue))
				bar(2,color(green))			
				legend(order(1 "2018" 2 "2019") size(small) r(1)
				region(lstyle(none) color(none)));
		#d cr		
		graph export "$out\Figure 8.png", replace	
	
	restore	

********************************************************************************
* J. Figure 9
********************************************************************************

	* Prepare list of missing workers from previous waves	
	preserve
	
		use "$dta/00. Personal data 2017.dta", clear

		merge 1:1 identpers using "$dta/00. Personal data 2018.dta"

			qui unique identpers if _m == 1 & !mi(ffallec)
			di as txt "Number of workers who passed away in 2017 wave:" %5.0fc `r(unique)'		

			qui unique identpers if _m == 1 & mi(ffallec)
			di as txt "Number of workers who dissapeared from 2017 wave:" %5.0fc `r(unique)'			
			
			keep if _m == 1 & mi(ffallec)
			
			gen base = 0			
			gen year = 2018
			
			keep identpers year base
			
			tempfile old_wave_17
			save `old_wave_17', replace
	
	restore
	preserve
	
		use "$dta/00. Personal data 2018.dta", clear	
	
		sort identpers 
		merge 1:1 identpers using "$dta/00. Personal data 2019.dta"

			qui unique identpers if _m == 1 & !mi(ffallec)
			di as txt "Number of workers who passed away in 2018 wave:" %5.0fc `r(unique)'		

			qui unique identpers if _m == 1 & mi(ffallec)
			di as txt "Number of workers who dissapeared from 2018 wave:" %5.0fc `r(unique)'			
			
			keep if _m == 1 & mi(ffallec)
			drop _m

			gen base = 0			
			gen year = 2019
			
			keep identpers year base			
			
			tempfile old_wave_18
			save `old_wave_18', replace
	
	restore
	
		* Estimate the share for each quintile of the half lowest distribution
		preserve
			
			keep if !mi(one_18) | !mi(one_19_nov) 
			append using `old_wave_17'
			append using `old_wave_18'
			
			forval x = 2018/2019 {
				qui sum base if year == `x',d
				global qmed_`x' = r(p50)		

				centile base if year == `x' & base < ${qmed_`x'}, c(20 40 60 80)
				
				global q1_`x' = r(c_1)
				global q2_`x' = r(c_2)
				global q3_`x' = r(c_3)
				global q4_`x' = r(c_4)	
				
			}
			
			* Split sample on quintiles
			forval x = 2018/2019 {
			
				gen one_q1_`x' = base if year == `x' & base < ${q1_`x'}	
				gen one_q2_`x' = base if year == `x' & base >= ${q1_`x'} & base < ${q2_`x'}
				gen one_q3_`x' = base if year == `x' & base >= ${q2_`x'} & base < ${q3_`x'}
				gen one_q4_`x' = base if year == `x' & base >= ${q3_`x'} & base < ${q4_`x'}
				gen one_q5_`x' = base if year == `x' & base >= ${q4_`x'} & base < ${qmed_`x'}
			}	

			forval x = 2018/2019 {
				gen lw_`x' = base if year == `x' & base < ${qmed_`x'}
			}
			
			* Collapse and estimate shares of income
			collapse (sum) one_q* lw_*
			
			forval x = 2018/2019 {
				forval q = 1/5 {
				
					gen s_q`q'_`x' = (one_q`q'_`x'/lw_`x')*100
				}
			}	
			keep s_q*	
			
			gen ID = 1
			
			reshape long s_q1_ s_q2_ s_q3_ s_q4_ s_q5_, i(ID) j(year)
			
			ren (s_q1_ s_q2_ s_q3_ s_q4_ s_q5_) (sq1 sq2 sq3 sq4 sq5)
			
			reshape long sq, i(year) j(q)
			
			gen sq18 = sq if year == 2018
			gen sq19 = sq if year == 2019
			
			label define q 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
			label values q q
			
			# d;
			graph bar (mean) sq18 sq19, 
					over(q)
					blabel(total, format(%12,1fc) position(12) color(black))
					ylabel(0(5)35, labsize(small)) 
					graphregion(color(white))
					ytitle("")
					bar(1,color(blue))
					bar(2,color(green))			
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)));
			#d cr		
			graph export "$out\Figure 9.png", replace	

	restore
	
********************************************************************************
* K. Figure 10 and Table 3
********************************************************************************		

	* Prepare list of missing workers from previous waves	
	preserve
	
		use "$dta/00. Personal data 2017.dta", clear

		merge 1:1 identpers using "$dta/00. Personal data 2018.dta"

			qui unique identpers if _m == 1 & !mi(ffallec)
			di as txt "Number of workers who passed away in 2017 wave:" %5.0fc `r(unique)'		

			qui unique identpers if _m == 1 & mi(ffallec)
			di as txt "Number of workers who dissapeared from 2017 wave:" %5.0fc `r(unique)'			
			
			keep if _m == 1 & mi(ffallec)
			
			gen renta = 0			
			gen year = 2018
			
			keep identpers year renta sexo espanol menor_30
			
			tempfile old_wave_17
			save `old_wave_17', replace
	
	restore
	preserve
	
		use "$dta/00. Personal data 2018.dta", clear	
	
		sort identpers 
		merge 1:1 identpers using "$dta/00. Personal data 2019.dta"

			qui unique identpers if _m == 1 & !mi(ffallec)
			di as txt "Number of workers who passed away in 2018 wave:" %5.0fc `r(unique)'		

			qui unique identpers if _m == 1 & mi(ffallec)
			di as txt "Number of workers who dissapeared from 2018 wave:" %5.0fc `r(unique)'			
			
			keep if _m == 1 & mi(ffallec)
			drop _m

			gen renta = 0			
			gen year = 2019
			
			keep identpers year renta sexo espanol menor_30
			
			tempfile old_wave_18
			save `old_wave_18', replace
	
	restore
	
	* Estimate the share for each quintile of the half lowest distribution
	preserve
			
			keep if !mi(one_18) | !mi(one_19_nov) 
			append using `old_wave_17'
			append using `old_wave_18'
		
		replace renta = base if mi(renta)
		
		forval x = 2018/2019 {
			qui sum base if year == `x',d
			global qmed_w_`x' = r(p50)					
			
			qui sum renta if year == `x',d
			global qmed_r_`x' = r(p50)								
		}
		
		* Split sample on quintiles
		forval x = 2018/2019 {
			
			** Total obs 
			gen one_1_`x' = base if year == `x' & base < ${qmed_w_`x'}
			gen one_4_`x' = renta if year == `x' & renta < ${qmed_r_`x'}
				
			** Social group
				*** Women
				gen bm_1_1_`x' = base if sexo == 1 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_1_`x' = renta if sexo == 1 & year == `x' & renta < ${qmed_r_`x'}			

				*** Foreign			
				gen bm_1_2_`x' = base if espanol == 0 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_2_`x' = renta if espanol == 0 & year == `x' & renta < ${qmed_r_`x'}						
				
				*** Less than 30y
				gen bm_1_3_`x' = base if menor_30 == 1 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_3_`x' = renta if menor_30 == 1 & year == `x' & renta < ${qmed_r_`x'}									
		}	

		* Collapse and estimate shares of income
		collapse (sum) one_* bm_*
		
		forval x = 2018/2019 {
			foreach source in 1 4 {
				foreach catvar in 1 2 3 {
					gen s_`source'_`catvar'_`x' = (bm_`source'_`catvar'_`x'/one_`source'_`x')*100
				}
			}
		}	
		
		keep s_*	
		
		gen ID = 1
		
		reshape long s_1_1_ s_1_2_ s_1_3_ s_4_1_ s_4_2_ s_4_3_, i(ID) j(year)
		
		ren (s_1_1_ s_1_2_ s_1_3_ s_4_1_ s_4_2_ s_4_3_) (s1_1 s1_2 s1_3 s4_1 s4_2 s4_3)
		
		reshape long s1_ s4_, i(ID year) j(type)

		label define type 1 "Mujeres" 2 "Extranjeros" 3 "Jóvenes"
		label values type type 

		ren (s1_ s4_) (s1 s4)
		
		reshape long s, i(ID year type) j(income)		
		
		label define income 1 "Salarios" 4 "Rentas"
		label values income income 
		
		gen s18 = s if year == 2018 
		gen s19 = s if year == 2019
		
		gen s18_lab = string(s18, "%10,1fc")
		gen s19_lab = string(s19, "%10,1fc")
		
		gen income2 = income + 0.9
		
		** Plot
		
			*** Women
			# d;
			twoway (bar s18 income if type == 1, barw(0.8) bcolor(blue))
					(bar s19 income2 if type == 1, barw(0.8) bcolor(green))
					(scatter s18 income if type == 1, mlabel(s18_lab) mlabcolor(black) mlabpos(12) mcolor(none))
					(scatter s19 income2 if type == 1, mlabel(s19_lab) mlabcolor(black) mlabpos(12) mcolor(none)),
					xlabel(1.5 "Salarios" 2.5 " " 3.5 " " 4.5 "Rentas" 5.5 " ")
					graphregion(color(white))
					ytitle("")
					ylabel(45(2)55)
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)))
					title("Mujeres")
					name(g1, replace);
			#d cr				

			*** Foreign
			# d;
			twoway (bar s18 income if type == 2, barw(0.8) bcolor(blue))
					(bar s19 income2 if type == 2, barw(0.8) bcolor(green))
					(scatter s18 income if type == 2, mlabel(s18_lab) mlabcolor(black) mlabpos(12) mcolor(none))
					(scatter s19 income2 if type == 2, mlabel(s19_lab) mlabcolor(black) mlabpos(12) mcolor(none)),
					xlabel(1.5 "Salarios" 2.5 " " 3.5 " " 4.5 "Rentas" 5.5 " ")
					graphregion(color(white))
					ytitle("")
					ylabel(11(1)16)
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)))
					title("Extranjeros")
					name(g2, replace);
			#d cr				
				
			*** Less than 30 years old
			# d;
			twoway (bar s18 income if type == 3, barw(0.8) bcolor(blue))
					(bar s19 income2 if type == 3, barw(0.8) bcolor(green))
					(scatter s18 income if type == 3, mlabel(s18_lab) mlabcolor(black) mlabpos(12) mcolor(none))
					(scatter s19 income2 if type == 3, mlabel(s19_lab) mlabcolor(black) mlabpos(12) mcolor(none)),
					xlabel(1.5 "Salarios" 2.5 " " 3.5 " " 4.5 "Rentas" 5.5 " ")
					graphregion(color(white))
					ytitle("")
					ylabel(23(1)28)
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)))
					title("Jóvenes")
					name(g3, replace);
			#d cr								
			
			*** Combine
			#d;
			grc1leg g1 g2 g3,
				legendfrom(g1)
				r(1)	
				graphregion(color(white));			
			# d cr		
			graph export "$out\Figure 10.png", replace	
		
		graph drop _all
	
	restore	

********************************************************************************
* L. Figure 11 and Table 3
********************************************************************************			
	
	* Prepare list of missing workers from previous waves	
	preserve
	
		use "$dta/00. Personal data 2017.dta", clear

		merge 1:1 identpers using "$dta/00. Personal data 2018.dta"

			qui unique identpers if _m == 1 & !mi(ffallec)
			di as txt "Number of workers who passed away in 2017 wave:" %5.0fc `r(unique)'		

			qui unique identpers if _m == 1 & mi(ffallec)
			di as txt "Number of workers who dissapeared from 2017 wave:" %5.0fc `r(unique)'			
			
			keep if _m == 1 & mi(ffallec)
			
			gen renta = 0			
			gen year = 2018
			
			keep identpers year renta sexo espanol menor_30
			
			tempfile old_wave_17
			save `old_wave_17', replace
	
	restore
	preserve
	
		use "$dta/00. Personal data 2018.dta", clear	
	
		sort identpers 
		merge 1:1 identpers using "$dta/00. Personal data 2019.dta"

			qui unique identpers if _m == 1 & !mi(ffallec)
			di as txt "Number of workers who passed away in 2018 wave:" %5.0fc `r(unique)'		

			qui unique identpers if _m == 1 & mi(ffallec)
			di as txt "Number of workers who dissapeared from 2018 wave:" %5.0fc `r(unique)'			
			
			keep if _m == 1 & mi(ffallec)
			drop _m

			gen renta = 0			
			gen year = 2019
			
			keep identpers year renta sexo espanol menor_30
			
			tempfile old_wave_18
			save `old_wave_18', replace
	
	restore
	
	* Estimate the share for each quintile of the half lowest distribution
	preserve		
			keep if !mi(one_18) | !mi(one_19_nov) 
			append using `old_wave_17'
			append using `old_wave_18'
		
		replace renta = base if mi(renta)
		
		forval x = 2018/2019 {
			qui sum base if year == `x',d
			global qmed_w_`x' = r(p50)					
			
			qui sum renta if year == `x',d
			global qmed_r_`x' = r(p50)								
		}
		
		* Split sample on quintiles
		forval x = 2018/2019 {
			
			** Total obs 
			gen one_1_`x' = base if year == `x' & base < ${qmed_w_`x'}
			gen one_4_`x' = renta if year == `x' & renta < ${qmed_r_`x'}
				
			** Social group
			
				*** Men
				gen bm_1_10_`x' = base if sexo == 0 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_10_`x' = renta if sexo == 0 & year == `x' & renta < ${qmed_r_`x'}			
			
				*** Women
				gen bm_1_11_`x' = base if sexo == 1 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_11_`x' = renta if sexo == 1 & year == `x' & renta < ${qmed_r_`x'}			

				*** Spanish		
				gen bm_1_20_`x' = base if espanol == 1 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_20_`x' = renta if espanol == 1 & year == `x' & renta < ${qmed_r_`x'}										
				
				*** Foreign			
				gen bm_1_21_`x' = base if espanol == 0 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_21_`x' = renta if espanol == 0 & year == `x' & renta < ${qmed_r_`x'}						
				
				*** More than 30y
				gen bm_1_30_`x' = base if menor_30 == 0 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_30_`x' = renta if menor_30 == 0 & year == `x' & renta < ${qmed_r_`x'}													
						
				*** Less than 30y
				gen bm_1_31_`x' = base if menor_30 == 1 & year == `x' & base < ${qmed_w_`x'}
				gen bm_4_31_`x' = renta if menor_30 == 1 & year == `x' & renta < ${qmed_r_`x'}		
				
			** Gaps
			
				*** Gender
				foreach source in 1 4 {
					qui sum bm_`source'_10_`x'
					local men = r(mean)
				
					qui sum bm_`source'_11_`x'
					local women = r(mean)				
				
					gen gap_gend_`source'_`x' = ((`women'-`men')/`men')*100*(-1)
				}	
				
				*** Citizenship
				foreach source in 1 4 {
					qui sum bm_`source'_21_`x'
					local foreign = r(mean)
				
					qui sum bm_`source'_20_`x'
					local spanish = r(mean)				
				
					gen gap_citizen_`source'_`x' = ((`foreign'-`spanish')/`spanish')*100*(-1)
				}	
				
				*** Age
				foreach source in 1 4 {
					qui sum bm_`source'_31_`x'
					local less_30 = r(mean)
				
					qui sum bm_`source'_30_`x'
					local more_30 = r(mean)				
				
					gen gap_age_`source'_`x' = ((`less_30'-`more_30')/`more_30')*100*(-1)
				}					
				
		}	

		* Collapse and estimate shares of income
		collapse (sum) one_* bm_* (mean) gap_*
		
		forval x = 2018/2019 {
			foreach source in 1 4 {
				foreach catvar in 10 11 20 21 30 31 {
					gen s_`source'_`catvar'_`x' = (bm_`source'_`catvar'_`x'/one_`source'_`x')*100
				}
			}
		}	
		
		keep s_* gap_*	
		
		gen ID = 1
		
		reshape long s_1_10_ s_1_11_ s_1_20_ s_1_21_ s_1_30_ s_1_31_ s_4_10_ ///
					s_4_11_ s_4_20_ s_4_21_ s_4_30_ s_4_31_ gap_gend_1_ ///
					gap_citizen_1_ gap_age_1_ gap_gend_4_ gap_citizen_4_ gap_age_4_ ///
					, i(ID) j(year)
		
		ren (s_1_10_ s_1_11_ s_1_20_ s_1_21_ s_1_30_ s_1_31_ s_4_10_ s_4_11_ ///
			s_4_20_ s_4_21_ s_4_30_ s_4_31_ gap_gend_1_ gap_citizen_1_ gap_age_1_ ///
			gap_gend_4_ gap_citizen_4_ gap_age_4_) (s1_10 s1_11 s1_20 s1_21 ///
			s1_30 s1_31 s4_10 s4_11 s4_20 s4_21 s4_30 s4_31 gap_gend1 ///
			gap_citizen1 gap_age1 gap_gend4 gap_citizen4 gap_age4)
		
		reshape long s1_ s4_, i(ID year) j(type)

		label define type 10 "Hombres" 11 "Mujeres" 20 "Español" 21 "Extranjeros" 30 "Mayores de 30" 31 "Jóvenes"
		label values type type 

		ren (s1_ s4_) (s1 s4)
		
		reshape long s gap_gend gap_citizen gap_age, i(ID year type) j(income)		
		
		label define income 1 "Salarios" 4 "Rentas"
		label values income income 
		
		foreach var in gap_gend gap_citizen gap_age {
			gen `var'18 = `var' if year == 2018
			gen `var'18_lab = string(`var'18, "%10,1fc")
			
			gen `var'19 = `var' if year == 2019
			gen `var'19_lab = string(`var'19, "%10,1fc")			
		}
		
		gen income2 = income + 0.9
		
		** Plot gaps
			*** Women
			# d;
			twoway (bar gap_gend18 income, barw(0.8) bcolor(blue))
					(bar gap_gend19 income2, barw(0.8) bcolor(green))
					(scatter gap_gend18 income, mlabel(gap_gend18_lab) mlabcolor(black) mlabpos(12) mcolor(none))
					(scatter gap_gend19 income2, mlabel(gap_gend19_lab) mlabcolor(black) mlabpos(12) mcolor(none)),
					xlabel(1.5 "Salarios" 2.5 " " 3.5 " " 4.5 "Rentas" 5.5 " ")
					graphregion(color(white))
					ytitle("")
					ylabel(0(4)16)
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)))
					title("Mujeres")
					name(g1, replace);
			#d cr				

			*** Foreign
			# d;
			twoway (bar gap_citizen18 income, barw(0.8) bcolor(blue))
					(bar gap_citizen19 income2, barw(0.8) bcolor(green))
					(scatter gap_citizen18 income, mlabel(gap_citizen18_lab) mlabcolor(black) mlabpos(12) mcolor(none))
					(scatter gap_citizen19 income2, mlabel(gap_citizen19_lab) mlabcolor(black) mlabpos(12) mcolor(none)),
					xlabel(1.5 "Salarios" 2.5 " " 3.5 " " 4.5 "Rentas" 5.5 " ")
					graphregion(color(white))
					ytitle("")
					ylabel(0(5)25)
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)))
					title("Extranjeros")
					name(g2, replace);
			#d cr				
				
			*** Less than 30 years old
			# d;
			twoway (bar gap_age18 income, barw(0.8) bcolor(blue))
					(bar gap_age19 income2, barw(0.8) bcolor(green))
					(scatter gap_age18 income, mlabel(gap_age18_lab) mlabcolor(black) mlabpos(12) mcolor(none))
					(scatter gap_age19 income2, mlabel(gap_age19_lab) mlabcolor(black) mlabpos(12) mcolor(none)),
					xlabel(1.5 "Salarios" 2.5 " " 3.5 " " 4.5 "Rentas" 5.5 " ")
					graphregion(color(white))
					ytitle("")
					ylabel(0(3)12)
					legend(order(1 "2018" 2 "2019") size(small) r(1)
					region(lstyle(none) color(none)))
					title("Jóvenes")
					name(g3, replace);
			#d cr								
			
			*** Combine
			#d;
			grc1leg g1 g2 g3,
				legendfrom(g1)
				r(1)	
				graphregion(color(white));			
			# d cr		
			graph export "$out\Figure 11.png", replace	
		
		graph drop _all		
		
		** Export excel file
		label var year "Año"
		label var type "Colectivo"
		label var income "Tipo de ingreso"
		label var s "Composición (%)"
		
		export excel year type income s using "$out\Table 3.xlsx", replace first(varl)	
	
	restore
	
* End of this dofile
cap log close
exit,clear
