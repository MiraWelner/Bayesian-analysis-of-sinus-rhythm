//30-sec bin during final waking from sleep — you will need to determine this for each person by looking backwards from the max value of timefromepochbegin_tosleeponset_ until the sleep state changes from awake to REM or non-REM and label that last sleep state of REM or non-REM as during final waking from sleep.

drop if missing(REM) | missing(non_REM)
*  mod(REM, 1) != 0  | mod(non_REM, 1) != 0 | mod(awake, 1) != 0
capture drop first_sleep
capture gen first_sleep_not_happened = .
capture drop observation_number
capture drop gotosleep

capture drop final_waking_from_sleep
capture gen final_waking_from_sleep_happened = .
capture gen is_valid_data = .


bysort chaos_id: egen final_waking_from_sleep = max((_n)*(awake==0))
bysort chaos_id: replace final_waking_from_sleep_happened = 1 if _n >= final_waking_from_sleep


bysort chaos_id: gen observation_number = _n 
bysort chaos_id (observation_number): gen gotosleep = awake==0 & awake[_n-1]!=0
bysort chaos_id: egen first_sleep = min(cond(gotosleep==1, observation_number, .))
bysort chaos_id: replace first_sleep_not_happened = 1 if _n <= first_sleep
replace first_sleep_not_happened = 0 if missing(first_sleep_not_happened)
replace final_waking_from_sleep_happened = 0 if missing(final_waking_from_sleep_happened)

replace is_valid_data = (first_sleep_not_happened==0) & (final_waking_from_sleep_happened==0)
