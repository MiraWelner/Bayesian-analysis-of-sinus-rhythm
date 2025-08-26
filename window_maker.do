*tostring label_one, gen(label_one_s) format(%9.0g)

*gen strL window_3 = ""
replace window_3 = "[" + label_one_s + "," + label_one_s[_n+1] + "," + label_one_s[_n+2] + "]" ///
    if _n <= _N-2

gen strL window_5 = ""
replace window_5 = "[" + label_one_s + "," + label_one_s[_n+1] + "," + label_one_s[_n+2] + "," + label_one_s[_n+3] + "," + label_one_s[_n+4] + "]" ///
    if _n <= _N-4

gen strL window_10 = ""
replace window_10 = "[" + label_one_s + "," + label_one_s[_n+1] + "," + label_one_s[_n+2] + "," + label_one_s[_n+3] + "," + label_one_s[_n+4] + "," + label_one_s[_n+5] + "," + label_one_s[_n+6] + "," + label_one_s[_n+7] + "," + label_one_s[_n+8] + "," + label_one_s[_n+9] + "]" ///
    if _n <= _N-9
