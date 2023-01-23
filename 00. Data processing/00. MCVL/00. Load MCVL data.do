********************************************************************************
* Title: 00. Load MCVL data.do
* Date: 06/12/2022
* Description: This dofile loads all the data from the MCVL 2019 SDF, including
* personal data, contribution basis and affiliation data. It also loads the 
* personal data from the MCVL 2017 and 2018.
********************************************************************************
	
	clear all
	set trace off
	
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
	log using "$log\00. Load MCVL data `today'.log", replace

	
********************************************************************************
* C. Load personal data
********************************************************************************
	
	forval wave = 2017/2019 {
		insheet using "$raw/MCVL`wave'/MCVL`wave'PERSONAL.TXT", delimiter(";") clear
			
			ren (v1-v10) (identpers fnacim sexo nacionalidad provnac provpriaf domicilio ffallec paisnac educacion)

			* Birth date
			tostring fnacim, replace
			gen year_birth = real(substr(fnacim,1,4))
			gen month_birth = real(substr(fnacim,5,.))
			drop fnacim
			gen fnacim = ym(year_birth, month_birth)
			format fnacim %tm
			drop if mi(fnacim)
			drop year_birth month_birth
			
			* Age in january 2018
			gen int edad = (ym(2019,1) - fnacim)/12		
			drop if mi(edad)
			label var edad "Age in Jan-2018"
			
			gen edad_cat = 1 if inrange(edad, 16, 25)
			replace edad_cat = 2 if inrange(edad, 26, 35)
			replace edad_cat = 3 if inrange(edad, 36, 44)
			replace edad_cat = 4 if inrange(edad, 45, 54)
			replace edad_cat = 5 if edad >= 56
			
			cap label define edad_cat 1 "16-25 años" 2 "26-35 años" 3 "36-44 años" 4 "45-54 años" 5 "Más de 56 años"
			label values edad_cat edad_cat 
			
			* Age dummy
			gen menor_30 = (edad<=30)			
							
			* Gender
			gen female=(sexo==2)
			drop sexo
			ren female sexo
			cap label define sexo 0 "Male" 1 "Female"
			label values sexo sexo
			
			* Spanish nationality
			gen espanol=(nacionalidad=="N00")
			
			encode nacionalidad, gen(nat2)
			drop nacionalidad
			ren nat2 nacionalidad

			encode paisnac, gen(cob2)
			drop paisnac
			ren cob2 paisnac
			
			* Province of birth
			destring provnac, replace
			replace provnac = . if provnac == 66 | provnac == 0
		
			* Province first afiliation
			destring provpriaf, replace
			replace provpriaf = . if provpriaf == 66 | provpriaf == 0

			* Death date
			tostring ffallec, replace
			gen year_death = real(substr(ffallec,1,4))
			gen month_death = real(substr(ffallec,5,.))
			drop ffallec
			gen ffallec = ym(year_death, month_death)
			format ffallec %tm
			drop year_death month_death
			
			*Zipcode of residence
			replace domicilio = . if domicilio == 0
			
		compress
		
		sort identpers
		save "$dta\00. Personal data `wave'.dta", replace
	}

********************************************************************************
* D. Load affiliation data
********************************************************************************
	
	forval x=1/4 {
		clear
		insheet using "$raw/MCVL2019/MCVL2019AFILIAD`x'.TXT", delimiter(";") 

		rename v1 identpers
		rename v2 regcot
		rename v3 grupcot
		rename v4 tipcont
		rename v5 coefparc
		rename v6 falta
		rename v7 fbaja
		rename v8 causabaja
		rename v9 minusv
		rename v10 identccc2
		rename v11 domccc2
		rename v12 cnae09
		rename v13 numtrab
		rename v14 fantigemp
		rename v15 trl
		rename v16 colecttrabaj
		rename v17 tipempleador
		rename v18 tipempleadorcif
		rename v19 identccc1
		rename v20 provccc1
		rename v21 fmodcont1
		rename v22 tipconmod1
		rename v23 cparcmod1
		rename v24 fmodcont2
		rename v25 tipconmod2
		rename v26 cparcmod2
		rename v27 fmodgrup1
		rename v28 grupcotmod1
		rename v29 cnae93
		rename v30 indsetaagraria
		rename v31 trlotras
		rename v32 faltaefecto
		rename v33 fbajaefecto 

		label var identpers "ID"
		label var regcot "Contribution regime"
		label var grupcot "Contribution group"
		label var tipcont "Type of contract"
		label var coefparc "Partiality coef"
		label var falta "Date of begin"
		label var fbaja "Date of end"
		label var causabaja "Reason of end"
		label var minusv "Disability"
		label var identccc2 "Firm x Muni ID"
		label var domccc2 "Firm x Muni zip code"
		label var cnae09 "Firm x Muni sector (CNAE09)"
		label var numtrab "Firm x Muni num workers"
		label var fantigemp "Firm x Muni date of begin of the first worker" 
		label var trl "Firm x Muni type of labor relation"
		label var colecttrabaj "Firm x Muni special group"
		label var tipempleador "Type of employer"
		label var tipempleadorcif "Employer's type of firm"
		label var identccc1 "Firm ID"
		label var provccc1 "Firm province"
		label var fmodcont1 "Date of change of the inicial type of contract or partiality coef"
		label var tipconmod1  "First type of contract"
		label var cparcmod1 "First partiality coef"
		label var fmodcont2 "Date of change of the second type of contract or partiality coef" 
		label var tipconmod2 "Second type of contract"
		label var cparcmod2 "Second partiality coef"
		label var fmodgrup1 "Date of change of initial contribution group" 
		label var grupcotmod1 "Initial contribution group"
		label var cnae93 "Firm x Muni sector (CNAE93)"
		label var indsetaagraria "Sistema especial de trabajadores agrarios (SETA)"
		label var trlotras "Type of relations with other entities"
		label var faltaefecto "Effective date of begin"
		label var fbajaefecto "Effective date of end"

		qui compress	
		tempfile afiliad`x'
		save `afiliad`x'',replace
	 }
	
	use `afiliad1',clear
	
	forval x=2/4 {
		append using `afiliad`x''
	}

	duplicates drop identpers falta fbaja identccc2, force
	
	* Clean dates
	foreach date in falta fbaja faltaefecto fbajaefecto fantigemp fmodcont1 fmodcont2 fmodgrup1 {
		tostring `date', replace
		gen year = real(substr(`date',1,4))
		gen month = real(substr(`date',5,2))
		gen day = real(substr(`date',7,.))
		drop `date'
		gen `date' = mdy(month, day, year)
		format `date' %td
		drop year month day
	}
	
	save "$dta/00. Affiliation data.dta", replace
	

********************************************************************************
* E. Contribution data
********************************************************************************

	* Import the data
	forval a=1/13{
		clear
		set more off
		insheet using "$raw/MCVL2019/MCVL2019COTIZA`a'.TXT", delimiter(";") 

		rename v1 identpers
		rename v2 identccc2
		rename v3 anocot
		rename v4 base1
		rename v5 base2
		rename v6 base3
		rename v7 base4
		rename v8 base5
		rename v9 base6
		rename v10 base7
		rename v11 base8
		rename v12 base9
		rename v13 base10
		rename v14 base11
		rename v15 base12
		rename v16 basetot

		qui compress
		tempfile f`a'
		save `f`a'',replace
	 }
	
	* General regime
	 use `f1',clear
	 
	 forval x=2/12 {
		append using `f`x''
	 }
 
	* Fix mistakes of monthly contributions // TBC
*	forval x=1(1)12{
*		replace base`x'=-base`x' if base`x'<0
*	}	
	
		** Adjust contributions to euros instead of cents of euros
		forval x=1(1)12{
		replace base`x'=base`x'/100
		}	
		
		** Collapse data to one row per year x firm x person
		foreach x in base1 base2 base3 base4 base5 base6 base7 base8 base9 base10 base11 base12 basetot {
			bysort identpers identccc2 anocot: egen `x'_new=total(`x')
			drop `x'
			rename `x'_new `x'
		}

		duplicates drop identpers identccc2 anocot, force
		
		compress
		sort identpers identccc2 anocot
		
		save "$dta\00. Contribution data.dta",replace

	* Special regime	
	use `f13', clear
	
		** Adjust contributions to euros instead of cents of euros
		forval x=1(1)12{
		replace base`x'=base`x'/100
		}	
		
		** Collapse data to one row per year x firm x person
		foreach x in base1 base2 base3 base4 base5 base6 base7 base8 base9 base10 base11 base12 basetot {
			bysort identpers identccc2 anocot: egen `x'_new=total(`x')
			drop `x'
			rename `x'_new `x'
		}

		duplicates drop identpers identccc2 anocot, force
		
		compress
		sort identpers identccc2 anocot
		
		save "$dta\00. Contribution data special regime.dta",replace
	
* End of this dofile
cap log close
exit,clear
