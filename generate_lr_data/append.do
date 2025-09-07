use frame0.dta, clear

* Append the rest
forvalues i = 1/20 {
    append using frame`i'.dta
}

save all_frames_MESA.dta, replace
