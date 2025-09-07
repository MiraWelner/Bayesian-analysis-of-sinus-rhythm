//30-sec bin during final waking from sleep — you will need to determine this for each person by looking backwards from the max value of timefromepochbegin_tosleeponset_ until the sleep state changes from awake to REM or non-REM and label that last sleep state of REM or non-REM as during final waking from sleep.

drop if missing(awake) | missing(REM) | missing(non_REM)


bysort MESA_id: egen final_waking_from_sleep = max((_n)*(awake==0))
bysort MESA_id: gen final_woken = 1 if _n >= final_waking_from_sleep
capture gen final_woken = .
replace final_woken = 0 if missing(final_woken)
capture gen label_one = . 
//30-sec bin of non-REM sleep (i.e., non_REM==1)
replace label_one=6 if (non_REM==1)

//30-sec bin of REM sleep (i.e., REM==1)
replace label_one=7 if (REM==1)

//30-sec bin at least 5 mins before the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ < -300)
replace label_one=1 if timefromepochbegin_tosleeponset_ <= -300

//30-sec bin just before the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ < -30)
replace label_one=2 if (timefromepochbegin_tosleeponset_ > -300) & (timefromepochbegin_tosleeponset_ <= -30)

//30-sec bin during the first onset of sleep (i.e., I labeled this for you as follows: timefromepochbegin_tosleeponset_ == 0 and thisepochisduringorclosesttoslee == 1)
replace label_one=3 if (thisepochisduringorclosesttoslee == 1) & (timefromepochbegin_tosleeponset_ == 0)

//30-sec bin right after the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ > 0 and <=-30)
replace label_one=4 if (timefromepochbegin_tosleeponset_ > 0) & (timefromepochbegin_tosleeponset_ <= 30)

//30-sec bin when the person is awake any time after the first onset of sleep and before the final waking from sleep
replace label_one=5 if (timefromepochbegin_tosleeponset_ > 0) & (final_woken == 0) & (awake==1)

//30-sec bin just before the final waking from sleep
bysort MESA_id: replace label_one = 8 if _n == final_waking_from_sleep-1
bysort MESA_id: replace label_one = 9 if _n == final_waking_from_sleep
bysort MESA_id: replace label_one = 10 if _n == final_waking_from_sleep+1
bysort MESA_id: replace label_one = 11 if (_n > final_waking_from_sleep+1) & (_n < final_waking_from_sleep+10)
capture gen label_two = .
bysort MESA_id: replace label_two = 12 if (_n > final_waking_from_sleep+1) & (_n < final_waking_from_sleep+10)
bysort MESA_id: replace label_one = 12 if _n >= final_waking_from_sleep+10

drop final_woken
drop final_waking_from_sleep
