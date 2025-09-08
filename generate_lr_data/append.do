use frame0.dta, clear

* Append the rest
forvalues i = 1/20 {
    append using frame`i'.dta
}

save welner_MESA-normalized-lr_september-8.dta, replace
