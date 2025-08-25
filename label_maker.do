//30-sec bin at least 5 mins before the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ < -300)
replace ss=1 if timefromepochbegin_tosleeponset_ < -300

//30-sec bin just before the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ < -30)
replace ss=2 if timefromepochbegin_tosleeponset_ > -300 & timefromepochbegin_tosleeponset_ < -30

//30-sec bin during the first onset of sleep (i.e., I labeled this for you as follows: timefromepochbegin_tosleeponset_ == 0 and thisepochisduringorclosesttoslee == 1)
replace ss=3 if timefromepochbegin_tosleeponset_ > 0 & thisepochisduringorclosesttoslee == 1

//30-sec bin right after the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ > 0 and <=-30)
replace ss=4 if timefromepochbegin_tosleeponset_ > 0 & timefromepochbegin_tosleeponset_ < 30

//30-sec bin when the person is awake any time after the first onset of sleep  and before the final waking from sleep

//30-sec bin of non-REM sleep (i.e., non_REM==1)
replace ss=6 if non_REM==1

//30-sec bin of REM sleep (i.e., REM==1)
replace ss=7 if REM==1

//30-sec bin just before the final waking from sleep (as defined in #9)

//30-sec bin during final waking from sleep — you will need to determine this for each person by looking backwards from the max value of timefromepochbegin_tosleeponset_ until the sleep state changes from awake to REM or non-REM and label that last sleep state of REM or non-REM as during final waking from sleep.
