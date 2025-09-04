/*
logistic_regression.do
Mira Welner
August 2025
This .do file calculates the relevance of various data points to whether a patient is asleep, in REM sleep, or non-REM sleep. It does this
via taking the logistic regression and recording the coefficient and standard error.
*/


*create function to calculate the logistic regression
capture program drop use_lr
program define use_lr
    args dependent_variable independent_variable id use_perc_kept
	
	*create column names depending on the variables
	local coeff_column_name "`independent_variable'_coeff"
	local se_column_name "`independent_variable'_se"

	capture gen `coeff_column_name' = .
	capture gen `se_column_name' = .

	*some of the variables need to be filtered by perc_kept > 85, this if/else provides the filtering
	if `use_perc_kept' == 1 {
		quietly logit `dependent_variable' `independent_variable' if perc_PVC<1&perc_kept>85&ID==`id' & label_one>4 & label_one<8
	}
	else {
		quietly logit `dependent_variable' `independent_variable' if perc_PVC<1&ID==`id' & label_one>4 & label_one<8
	}
	
	if _rc == 0 {
		*the e(b) gets the coefficient matrix. This technically contains the se but it looks like the se is deleted after creation
		*so, the e(V) matrix get the variance covariance matrix, which is used toget the se
		matrix b = e(b)
		matrix V = e(V)
			
		matrix tmp = b[1,"`dependent_variable':`independent_variable'"]	

		local coeff = el(tmp, 1,1)
		replace `coeff_column_name' = `coeff' if `dependent_variable' == 1 & ID == `id'

		matrix tmp = V["`dependent_variable':`independent_variable'","`dependent_variable':`independent_variable'"]
		local se = sqrt(el(tmp,1,1))
		replace `se_column_name' = `se' if `dependent_variable' == 1 & ID==`id'

	}
end

*these were the independent variables listed in the email which were not supposed to be filtered by perc_kept>85. There was no rmssd_msec so I used rmssd instead, and there was no rr_en_m4w50r5 so I left it out
local ind_vars_not_use_perc_kept heart_rate sdnn meannn_msec rmssd vlfpow lfpow hfpow LF HF VLF lfdivhfpow totpow_clin mean_pulseox median_pulseox stdev_pulseox rr_en_m4w30r5 rr_en_pow_m4w30r5 qrs_area rs_amplitude_abs

*these were the independent variables listed in the email which were supposed to be filtered by perc_kept>85. qt_en_m4w50r5 was left out because it was not found in the dataset
local ind_vars_use_perc_kept meancoh qtvi qt qtc qtrrslope qtrr_r2 qtv qt_en_m4w30r5 qt_en_pow_m4w30r5 t_area qt_area t_amplitude

*iterate through all indpenedent variables for awake, rem, and non-REM
quietly summarize ID
local max_id = 34
local batch_size = 20
local nframes = 2

frame change default

forvalues g = 0/`=`nframes'-1' {
	capture frame drop temp
	local start_id = `g'*`batch_size'
	local end_id `=min((`g'+1)*`batch_size', `max_id')'
	display `end_id'
	frame put if (ID>`start_id') & (ID <= `end_id'), into(temp)
	frame change temp
	quietly summarize ID
	local start = r(min)
	local stop = r(max)
	forvalues i = `start'/`stop' {
		foreach iv of local ind_vars_not_use_perc_kept{
			capture use_lr awake `iv' `i' 0
			capture use_lr REM `iv' `i' 0
			capture use_lr non_REM `iv' `i' 0
		} 
		foreach iv of local ind_vars_use_perc_kept{
			capture use_lr awake `iv' `i' 1
			capture use_lr REM `iv' `i' 1
			capture use_lr non_REM `iv' `i' 1
		}
	}
	local savefile = "frame`g'.dta"
	save "`savefile'", replace
	frame change default
}