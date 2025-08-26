sort shhs_id

tostring label_one, gen(label_one_s) format(%02.0f)


gen strL window_3_str = ""
by shhs_id: replace window_3_str = "[" + label_one_s + "," + label_one_s[_n+1] + "," + label_one_s[_n+2] + "]" ///
    if _n <= _N-2
encode window_3_str, generate(window_3)
drop window_3_str 

gen strL window_5_str = ""
by shhs_id: replace window_5_str = "[" + label_one_s + "," + label_one_s[_n+1] + "," + label_one_s[_n+2] + "," + label_one_s[_n+3] + "," + label_one_s[_n+4] + "]" ///
    if _n <= _N-4
encode window_5_str, generate(window_5)
drop window_5_str 

gen strL window_10_str = ""
by shhs_id: replace window_10_str = "[" + label_one_s + "," + label_one_s[_n+1] + "," + label_one_s[_n+2] + "," + label_one_s[_n+3] + "," + label_one_s[_n+4] + "," + label_one_s[_n+5] + "," + label_one_s[_n+6] + "," + label_one_s[_n+7] + "," + label_one_s[_n+8] + "," + label_one_s[_n+9] + "]" ///
    if _n <= _N-9
encode window_10_str, generate(window_10)
drop window_10_str 

drop label_one_s
