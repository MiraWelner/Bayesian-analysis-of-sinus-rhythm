/*
compare_sleepstates.do
Mira Welner
September 2025

*/


capture program drop plot_distribution
program define plot_distribution
	args thing_plotted distinguishing_feature max_feature_val
		local graphlist_awake
		quietly summarize `thing_plotted'
		forvalues i = 0/`max_feature_val' {
			capture histogram `thing_plotted' if `distinguishing_feature'==`i'&awake==1, title("`distinguishing_feature'_equals_`i'") normal name("hist`i'", replace) nodraw
			if _rc == 0 {
				local graphlist_awake "`graphlist_awake' hist`i'"
			}
		}
		graph combine `graphlist_awake',title("Heart Rate Coefficients when Awake")
		graph export "awake_`distinguishing_feature'.png", replace
		
		
		local graphlist_nonREM
		quietly summarize `thing_plotted'
		forvalues i = 0/`max_feature_val' {
			capture histogram `thing_plotted' if `distinguishing_feature'==`i'&non_REM==1, title("`distinguishing_feature'_equals_`i'") normal name("hist`i'", replace) nodraw
			if _rc == 0 { 
				display 2
				local graphlist_nonREM "`graphlist_nonREM' hist`i'"
			}
		}
		graph combine `graphlist_nonREM',  title("Heart Rate Coefficients when in non-REM")
		graph export "nonREM_`distinguishing_feature'.png", replace
		
		
		local graphlist_REM
		quietly summarize `thing_plotted'
		forvalues i = 0/`max_feature_val' {
			capture histogram `thing_plotted' if `distinguishing_feature'==`i'&REM==1, title("`distinguishing_feature'_equals_`i'") normal name("hist`i'", replace) nodraw
			if _rc == 0 { 
				display 7
				local graphlist_REM "`graphlist_REM' hist`i'"
			}
		}
		graph combine `graphlist_REM',  title("Heart Rate Coefficients when in REM")
		graph export "REM_`distinguishing_feature'.png", replace
		
end
		
plot_distribution heart_rate_coeff gender1 1
plot_distribution heart_rate_coeff race1c 4
xtile agequartile = age5c, nq(4)
quietly plot_distribution heart_rate_coeff agequartile 4
