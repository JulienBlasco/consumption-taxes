use "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\2021_06_07_centralccyy_summaries_egap2.dta", clearappend using "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\DTA\2020_09_21 summaries mod10v2.dta", generate(version)drop the_year_obs last_year_obs kak_wor_pred mean_hmchous conc_dhi_hmc_wor_pred reshape wide *ours*, i(ccyy) j(version)drop if mi(itrc_ours0)graph dot (asis) Gini_ours_pred0 Gini_ours_pred1 Gini_inc2 Gini_inc3 Gini_pre, ///	over(ccyy)