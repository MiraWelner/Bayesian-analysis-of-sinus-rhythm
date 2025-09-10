/*
Mira Welner
September 2025
Do the initial analysis required for every dataset listed here:

[Step #1] First and foremost, know the N (e.g., total, missing, nonmissing) and if applicable, subgroups of any events vs. non-events of interest
[Step #2] Assess corresponding distributions (e.g., normal, log-normal, non-normal, number and type of peaks)
[Step #3] Calculate the statistical moments (e.g., mean/median/mode, SD/IQR, kurtosis, skewness
*/


ssc install mdesc

local original heart_rate sdnn meannn_msec rmssd_msec vlfpow lfpow hfpow LF HF VLF lfdivhfpow totpow_clin mean_pulseox median_pulseox stdev_pulseox meancoh qtvi qt qtc qtrrslope qtrr_r2 qtvi

local coefficients heart_rate_norm_coeff sdnn_norm_coeff meannn_msec_norm_coeff rmssd_msec_norm_coeff vlfpow_norm_coeff lfpow_norm_coeff hfpow_norm_coeff LF_norm_coeff HF_norm_coeff VLF_norm_coeff lfdivhfpow_norm_coeff totpow_clin_norm_coeff mean_pulseox_norm_coeff median_pulseox_norm_coeff stdev_pulseox_norm_coeff meancoh_norm_coeff qtvi_norm_coeff qt_norm_coeff qtc_norm_coeff qtrrslope_norm_coeff qtrr_r2_norm_coeff qtvi_norm_coeff


local norms heart_rate_norm sdnn_norm meannn_msec_norm rmssd_msec_norm vlfpow_norm lfpow_norm hfpow_norm LF_norm HF_norm VLF_norm lfdivhfpow_norm totpow_clin_norm mean_pulseox_norm median_pulseox_norm stdev_pulseox_norm meancoh_norm qtvi_norm qt_norm qtc_norm qtrrslope_norm qtrr_r2_norm qtvi_norm

local histogram_names
foreach i of local coefficients {
	hist `i', name(g_`i', replace) title("`i'") bins(200)
	local histogram_names `histogram_names' g_`i'
}

graph combine `histogram_names', title("Histograms of Coefficients")
graph export "coeff_hists.png", replace

local histogram_names_norms
foreach i of local norms {
	hist `i', name(g_`i', replace) title("`i'") bins(200)
	local histogram_names_norms `histogram_names_norms' g_`i'
}

graph combine `histogram_names_norms', title("Histograms of Norms")
graph export "norm_hists.png", replace

local histogram_names_original
foreach i of local original {
	hist `i', name(g_`i', replace) title("`i'") bins(200)
	local histogram_names_original `histogram_names_original' g_`i'
}

graph combine `histogram_names_original', title("Histograms of Original Values")
graph export "original_hists.png", replace


mdesc `coefficients'
mdesc `norms'
mdesc `original'
summarize `coefficients'
summarize `norms'
summarize `original'