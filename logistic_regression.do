levelsof ID, local(idlist)
capture gen heart_rate_coeff = .
capture gen heart_rate_se = .

capture gen sdnn_coeff = .
capture gen sdnn_se = .

capture gen meannn_msec_coeff = .
capture gen meannn_msec_se = .

capture gen rmssd_msec_coeff = .
capture gen rmssd_msec_se = .

*run through all ID
*foreach i of local idlist {
foreach i of numlist 1,2,3,4,5 {
	stepwise, pr(0.2) pe(0.1): ///
	logit awake heart_rate if perc_PVC<1&ID==`i' & label_one>4 & label_one<8

	matrix coeff_matrix = e(b)
	matrix covariance_matrix = e(V)
	
	* if heart_rate hasn't been removed due to lack of significance, get data
	capture matrix tmp = coeff_matrix[1,"awake:heart_rate"]
	if _rc==0 {
	    scalar coef = tmp[1,1]
	    replace heart_rate_coeff = tmp[1,1] if ID==`i'
	}
	capture matrix tmp = covariance_matrix["awake:heart_rate","awake:heart_rate"]
	if _rc==0 {
	    scalar coef = sqrt(tmp[1,1])
	    replace heart_rate_se = sqrt(tmp[1,1]) if ID==`i'
	}
	
	*sdnn
	stepwise, pr(0.2) pe(0.1): ///
	logit awake sdnn if perc_PVC<1&ID==`i' & label_one>4 & label_one<8
	
	matrix coeff_matrix = e(b)
	matrix covariance_matrix = e(V)
	
	capture matrix tmp = coeff_matrix[1,"awake:sdnn"]
	if _rc==0 {
	    scalar coef = tmp[1,1]
	    replace sdnn_coeff = tmp[1,1] if ID==`i'
	}
	capture matrix tmp = covariance_matrix["awake:sdnn","awake:sdnn"]
	if _rc==0 {
	    scalar coef = sqrt(tmp[1,1])
	    replace sdnn_se = sqrt(tmp[1,1]) if ID==`i'
	}
	
	*meannn_msec
	stepwise, pr(0.2) pe(0.1): ///
	logit awake meannn_msec if perc_PVC<1&ID==`i' & label_one>4 & label_one<8
	
	matrix coeff_matrix = e(b)
	matrix covariance_matrix = e(V)
	
	capture matrix tmp = coeff_matrix[1,"awake:meannn_msec"]
	if _rc==0 {
	    scalar coef = tmp[1,1]
	    replace meannn_msec_coeff = tmp[1,1] if ID==`i'
	}
	capture matrix tmp = covariance_matrix["awake:meannn_msec","awake:meannn_msec"]
	if _rc==0 {
	    scalar coef = sqrt(tmp[1,1])
	    replace meannn_msec_se = sqrt(tmp[1,1]) if ID==`i'
	}
	
	*rmssd
	stepwise, pr(0.2) pe(0.1): ///
	logit awake rmssd if perc_PVC<1&ID==`i' & label_one>4 & label_one<8
	
	matrix coeff_matrix = e(b)
	matrix covariance_matrix = e(V)
	
	capture matrix tmp = coeff_matrix[1,"awake:rmssd"]
	if _rc==0 {
	    scalar coef = tmp[1,1]
	    replace rmssd_msec_coeff = tmp[1,1] if ID==`i'
	}
	capture matrix tmp = covariance_matrix["awake:rmssd","awake:rmssd"]
	if _rc==0 {
	    scalar coef = sqrt(tmp[1,1])
	    replace rmssd_msec_se = sqrt(tmp[1,1]) if ID==`i'
	}
	
    *
}
