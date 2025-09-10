/*
logistic_regression_SSH.do
Mira Welner
September 2025
This .do file calculates the relevance of various data points to whether a patient is asleep, in REM sleep, or non-REM sleep. It does this
via taking the logistic regression and recording the coefficient and standard error.

It is designed for the SHHS dataset and is almost identical to the one for the MESA dataset (logistic_regression_MESA.do) with a few important changes
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
		 quietly capture logit `dependent_variable' `independent_variable' if perc_PVC<1&perc_kept>85&chaos_id==`id' & is_valid_data == 1
	}
	else {
		 quietly capture logit `dependent_variable' `independent_variable' if perc_PVC<1&chaos_id==`id' & is_valid_data == 1
	}
	
	if _rc == 0 {
		*the e(b) gets the coefficient matrix. This technically contains the se but it looks like the se is deleted after creation
		*so, the e(V) matrix get the variance covariance matrix, which is used toget the se
		matrix b = e(b)
		matrix V = e(V)
			
		matrix tmp = b[1,"`dependent_variable':`independent_variable'"]	
		local coeff = el(tmp, 1,1)
		replace `coeff_column_name' = `coeff' if `dependent_variable' == 1 & chaos_id == `id'

		matrix tmp = V["`dependent_variable':`independent_variable'","`dependent_variable':`independent_variable'"]
		local se = sqrt(el(tmp,1,1))
		replace `se_column_name' = `se' if `dependent_variable' == 1 & chaos_id==`id'

	}
end

* qrs_area rs_amplitude_abs t_area qt_area t_amplitude
* qtv -> qtv_msecsqu
local vars_to_normalize heart_rate sdnn meannn_msec rmssd_msec vlfpow lfpow hfpow LF HF VLF lfdivhfpow totpow_clin mean_pulseox median_pulseox stdev_pulseox rr_en_m4w30r5 rr_en_m4w50r5 rr_en_pow_m4w30r5 rr_en_pow_m4w50r5 meancoh qtvi qt qtc qtrrslope qtrr_r2 qtv_msecsqu qt_en_m4w30r5 qt_en_m4w50r5 qt_en_pow_m4w30r5 qt_en_pow_m4w50r5

foreach var of local vars_to_normalize {
    qui summarize `var', detail
    local median = r(p50)
	capture gen `var'_norm = .
    replace `var'_norm = `var' / `median'
}

*these were the independent variables listed in the email which were not supposed to be filtered by perc_kept>85. There was no rr_en_m4w50r5 or rs_amplitude qrs_area so I left it out
local ind_vars_not_use_perc_kept heart_rate_norm sdnn_norm meannn_msec_norm rmssd_msec_norm vlfpow_norm lfpow_norm hfpow_norm LF_norm HF_norm VLF_norm lfdivhfpow_norm totpow_clin_norm mean_pulseox_norm median_pulseox_norm stdev_pulseox_norm rr_en_m4w30r5_norm rr_en_m4w50r5_norm rr_en_pow_m4w30r5_norm rr_en_pow_m4w50r5_norm

*these were the independent variables listed in the email which were supposed to be filtered by perc_kept>85. qt_en_m4w50r5 was left out because it was not found in the dataset
local ind_vars_use_perc_kept meancoh_norm qtvi_norm qt_norm qtc_norm qtrrslope_norm qtrr_r2_norm qtv_msecsqu_norm qt_en_m4w30r5_norm qt_en_m4w50r5_norm qt_en_pow_m4w30r5_norm qt_en_pow_m4w50r5_norm


*iterate through all indpenedent variables for awake, rem, and non-REM

quietly summarize chaos_id
local max_id = 6441
local batch_size = 100
local nframes = 65

forvalues g = 0/`=`nframes'-1' {
	capture frame drop temp
	local start_id = `g'*`batch_size'
	local end_id `=min((`g'+1)*`batch_size', `max_id')'
	display `end_id'
	frame put if (chaos_id>`start_id') & (chaos_id <= `end_id'), into(temp)
	frame change temp
	quietly summarize chaos_id
	local start = r(min)
	local stop = r(max)
	forvalues i = `start'/`stop' {
		foreach iv of local ind_vars_not_use_perc_kept{
			quietly use_lr awake `iv' `i' 0
			quietly use_lr REM `iv' `i' 0
			quietly use_lr non_REM `iv' `i' 0
		} 
		foreach iv of local ind_vars_use_perc_kept{
			quietly use_lr awake `iv' `i' 1
			quietly use_lr REM `iv' `i' 1
			quietly use_lr non_REM `iv' `i' 1
		}
	}
	local savefile = "frame`g'.dta"
	save "`savefile'", replace
	frame change default
}
