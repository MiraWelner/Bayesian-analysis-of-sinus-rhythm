// Deep - plot histograms and probability density (generic) on Ln scale

*****-------------USER INPUT START
	//load dataset (NOTE: will clear current unsaved dataset so save before running if needed)
	//use "L:\SHHS\SHHS 2020-02\SHHS1_NSRR_ECG_dataset_20200312_v1f_ns4.dta", clear
	// set folder to save graphs and outputs
	
	// specify variables, e.g., heart_rate, sdnn, etc
	quietly local keyvar1 "heart_rate_norm_coeff sdnn_norm_coeff meannn_msec_norm_coeff rmssd_msec_norm_coeff vlfpow_norm_coeff lfpow_norm_coeff hfpow_norm_coeff LF_norm_coeff HF_norm_coeff VLF_norm_coeff lfdivhfpow_norm_coeff totpow_clin_norm_coeff mean_pulseox_norm_coeff median_pulseox_norm_coeff stdev_pulseox_norm_coeff rr_en_m4w30r5_norm_coeff meancoh_norm_coeff qtvi_norm_coeff qt_norm_coeff qtc_norm_coeff qtrrslope_norm_coeff qtrr_r2_norm_coeff"
	
	quietly local keyvar2 ""
	
	//specify groups to compare (e.g., dead, stroke, gender, sleep_state, etc)
	quietly local condition1 "!missing(non_REM) & non_REM"
	
	//specify bin size & kernel size
	local divide_xstep = 30
	**local bw = 0.5 -- kernel size is autoset below based on data
	
	// specify colors
	quietly local c1 = "midblue" 
	quietly local c2 = "red" 
// 	quietly local c3 = "gold"
//	quietly local c1 = "dkgreen" 
//	quietly local c2 = "orange_red"
//	quietly local c1 = "navy" 
//	quietly local c2 = "magenta" 
*****-------------USER INPUT END


set pformat %-5.1e
set more off
//graph drop _all

quietly local keyvar = `'"`keyvar1'"'
quietly local c_var = `'"`condition1'"'

// loop through each condition and keyvar and create plot

	foreach k_var of local keyvar {

			capture macro drop xmax xmin xstep step start count_t count_0 count_1
			local dropvar x1 d1 x2 d2 x3 d3 d1max d2max d3max ln`k_var'
			foreach x of local dropvar {
				capture drop `x'
				}
			
		//convert to natural log and drop 
		capture gen ln`k_var' = (`k_var') // specific inclusion criteria
		//capture gen ln`k_var'_ = (`k_var') // specific inclusion criteria
		//capture replace ln`k_var' = . if ln`k_var'<=-3 | ln`k_var'>=3  // specify range 
			
		// calculate range and number of bins for each variable
		summarize ln`k_var'
		capture local xmax = r(max)
		capture local xmin = r(min)
		capture local xstep = (r(max)-r(min))/`divide_xstep'
		capture local step = 5*(`xstep')
		capture local start : `xmin' - `xstep'
		capture local count_t = r(N)		
		
		capture summarize ln`k_var' if `condition1'==0
		quietly capture local count_0 = r(N)
		quietly capture summarize ln`k_var' if `condition1'==1
		quietly capture local count_1 = r(N) 
		
		capture ttest `k_var', by(`condition1')
		capture local p_value = r(p)
		capture local p_value : di %-5.1e `p_value'
		capture local xmax : di %-2.1e `xmax'
		capture local xmin : di %-2.1e `xmin'
		capture local step : di %-2.1e `step'
		capture local start : di %-2.1e `start'
		capture local xstep : di %-2.1e `xstep'
		
		sort ln`k_var'
		
		local bw = 3*`xstep'
		local choices kernel(epan2) bw(`bw') at(ln`k_var') //may need to adjust bw for over or under fitting
		kdensity ln`k_var' if `c_var'==0, `choices' gen(x1 d1) nodraw  //specify condition values for plot 1
		kdensity ln`k_var' if `c_var'==1, `choices' gen(x2 d2) nodraw  //specify condition values for plot 2
		kdensity ln`k_var', `choices' gen(x3 d3) nodraw
				
		capture egen d1max = max(d1)
		capture egen d2max = max(d2)
		capture egen d3max = max(d3)

		capture replace d1=d1/d1max
		capture replace d2=d2/d2max
		capture replace d3=d3/d3max

		capture di "N; total=`count_t' `condition1'_0=`count_0' `condition1'_1=`count_1'" 
		capture di "start=`start' min=`xmin' max=`xmax' step=`step' xstep=`xstep'"

		capture twoway (line d3 ln`k_var', yaxis(2) lcolor(`c3'%0) ylabel(, axis(1) labsize(vsmall)) xlabel(,labsize(vsmall)) ylabel(, axis(2) labsize(vsmall))) ///
		(area d1 ln`k_var', yaxis(2) color(`c1'%20)) ///
		(area d2 ln`k_var', yaxis(2) color(`c2'%20)) ///
		(histogram ln`k_var' if `c_var'==0, yaxis(1) start(`start') width(`xstep') percent lcolor(`c1'%60) color(`c1'%40))  ///
		(histogram ln`k_var' if `c_var'==1, yaxis(1) xlabel(`xmin'(`step')`xmax', format(%9.1f)) start(`start') width(`xstep') percent lcolor(`c2'%60) color(`c2'%40))  ///
		, scheme (sol) legend(off) note("") xsize(2) ysize(2) name(kd_`k_var', replace) saving(kd_`k_var', replace) //note("Subjects: Nt=`count_t', N0=`count_0', N1=`count_1'", size(small)) 
		
		//capture graph export `k_var'.png, as(png) replace
		
		local graphs1 "`graphs1' kd_`k_var'"  //keep track of each new graph created within the loop keyvar
						
		}

//redo categorical plots without kernel density fit
quietly local keyvar = `'"`keyvar2'"'
	
	foreach k_var of local keyvar {

			capture macro drop xmax xmin xstep step start count_t count_0 count_1
			local dropvar x1 d1 x2 d2 x3 d3 d1max d2max d3max ln`k_var'
			foreach x of local dropvar {
				capture drop `x'
				}
			
		//convert to natural log and drop 
		capture gen ln`k_var' = (`k_var') // specific inclusion criteria
		//capture gen ln`k_var'_ = (`k_var') // specific inclusion criteria
		//capture replace ln`k_var' = . if ln`k_var'<=-3 | ln`k_var'>=3  // specify range 
			
		// calculate range and number of bins for each variable
		summarize ln`k_var'
		capture local xmax = r(max)
		capture local xmin = r(min)
		capture local xstep = (r(max)-r(min))/`divide_xstep'
		capture local step = 5*(`xstep')
		capture local start : `xmin' - `xstep'
		capture local count_t = r(N)		
		
		capture summarize ln`k_var' if `condition1'==0
		quietly capture local count_0 = r(N)
		quietly capture summarize ln`k_var' if `condition1'==1
		quietly capture local count_1 = r(N) 
		
		capture ttest `k_var', by(`condition1')
		capture local p_value = r(p)
		capture local p_value : di %-5.1e `p_value'
		capture local xmax : di %-2.1e `xmax'
		capture local xmin : di %-2.1e `xmin'
		capture local step : di %-2.1e `step'
		capture local start : di %-2.1e `start'
		capture local xstep : di %-2.1e `xstep'
		
		sort ln`k_var'
		
		local bw = 3*`xstep'
		local choices kernel(epan2) bw(`bw') at(ln`k_var') //may need to adjust bw for over or under fitting
		kdensity ln`k_var' if `c_var'==0, `choices' gen(x1 d1) nodraw  //specify condition values for plot 1
		kdensity ln`k_var' if `c_var'==1, `choices' gen(x2 d2) nodraw  //specify condition values for plot 2
		kdensity ln`k_var', `choices' gen(x3 d3) nodraw
				
		capture egen d1max = max(d1)
		capture egen d2max = max(d2)
		capture egen d3max = max(d3)

		capture replace d1=d1/d1max
		capture replace d2=d2/d2max
		capture replace d3=d3/d3max

		capture di "N; total=`count_t' `condition1'_0=`count_0' `condition1'_1=`count_1'" 
		capture di "start=`start' min=`xmin' max=`xmax' step=`step' xstep=`xstep'"

		capture twoway (line d3 ln`k_var', yaxis(2) lcolor(`c3'%0) ylabel(, axis(1) labsize(vsmall)) xlabel(,labsize(vsmall)) ylabel(, axis(2) labsize(vsmall))) ///
		(area d1 ln`k_var', yaxis(2) color(`c1'%0)) ///
		(area d2 ln`k_var', yaxis(2) color(`c2'%0)) ///
		(histogram ln`k_var' if `c_var'==0, yaxis(1) start(`start') width(`xstep') percent lcolor(`c1'%60) color(`c1'%40))  ///
		(histogram ln`k_var' if `c_var'==1, yaxis(1) xlabel(`xmin'(`step')`xmax', format(%9.1f)) start(`start') width(`xstep') percent lcolor(`c2'%60) color(`c2'%40))  ///
		, scheme (sol) legend(off) note("") xsize(2) ysize(2) name(kd_`k_var', replace) saving(kd_`k_var', replace) //note("Subjects: Nt=`count_t', N0=`count_0', N1=`count_1'", size(small)) 
		
		//capture graph export `k_var'.png, as(png) replace
		
		local graphs1 "`graphs1' kd_`k_var'"  //keep track of each new graph created within the loop keyvar
						
		}


//combine into one plot
			
//quietly local keyvar1 "age PMH_HTN diasbp nonHDLchol ivcd mnhrdesat DeepEntropy4 hf_mfaw"
//quietly local keyvar1 "age PMH_HTN diasbp nonHDLchol ivcd mnhrdesat DeepEntropy4 hf_mfaw ECGdynamics2 FRS chadsvasc charge_AF CAFS"
//quietly local keyvar1 "heart_rate_norm_coeff lfdivhfpow_norm_coeff rr_en_m4w30r5_norm_coeff meancoh_norm_coeff qt_norm_coeff qtrrslope_norm_coeff"
	
	foreach k_var of local keyvar1 {	
		local graphs1 "`graphs1' kd_`k_var'"  //keep track of each new graph created within the loop keyvar
		}
	graph combine `graphs1', rows(3) cols(3) name(kd_all, replace) imargin(small) xsize(8) ysize(6) //combine the graphs for each keyvar1 -- set the #row and #cols by the number of vars in keyvar1 (can use an autocounter instead)
	
	// local graphs2 "`graphs2' kd_`c_var'"  //keep track of each new graph created within the loop condition
	// graph combine `graphs2', rows(2) cols(1) xcommon ycommon name(kd_combined, replace) imargin(small) //combine the graphs for each condition -- set the #row and #cols by the number of vars in condition (can use an autocounter instead)
	// graph save kd_combined_1.gph, replace			
	// graph export kd_combined_1.png, as(png) replace
	
//graph combine kd_age kd_FRS kd_chadsvasc kd_charge_AF kd_DeepEntropy4 kd_CAFS, rows(2) cols(3) name(kd_combined, replace) imargin(small) xsize(6) ysize(4) 
//capture graph export kd_combined.png, as(png) replace