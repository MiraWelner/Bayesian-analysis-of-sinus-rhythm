use frame0.dta, clear

* Append the rest
forvalues i = 1/64 {
    append using frame`i'.dta
}

save welner_SHHS1-consolidated-normalized-lr_september-9.dta, replace
