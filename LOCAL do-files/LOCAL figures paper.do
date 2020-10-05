/* Figures with summaries dataset */cd "D:"use "BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\ConsumptionTaxes_indicators_coremodel.dta", clearappend using "BLASCOLIEPP\Code\19-08-21 Datasets V6\DTA\ConsumptionTaxes_indicators_xtnddmodel.dta", generate(model)egen min_model = min(model), by(ccyy)drop if min_model == 0 & model == 1drop min_modellabel define model 0 "Core" 1 "Extended"label values model modelegen max_year = max(year), by(cname)gen the_year = (year == max_year)egen max_year_obs = max(year) if !mi(M_inc5), by(cname)gen the_year_obs = (year == max_year_obs)egen max_year_core = max(year) if model == 0, by(cname)gen the_year_core = (year == max_year_core)// set scheme s1monoset scheme s1color// Figure 2: actual and predicted Gini coefficientsgraph dot (asis) Gini_pre Gini_inc5 Gini_inc5_pred if the_year_obs, ///	over(ccyy_f, sort(Gini_pre) descending) legend(rows(3)) ///	marker(2, msymbol(lgx)) marker(3, msymbol(lgx))// Figure 4: Gini of market, gross, disposable and post tax incomegraph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_pred if year==max_year & !mi(Gini_inc2), ///	over(ccyy_f, sort(Gini_inc5_pred) descending) marker(1, msymbol(square)) ///	marker(2, msymbol(triangle)) marker(4, msymbol(lgx)) ///	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income") ///	rows(2) title(Gini index of income inequality) subtitle(last year available))	graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_pred if year==2010 & !mi(Gini_inc2), ///	over(cname, sort(Gini_inc5_pred) descending) marker(1, msymbol(square)) ///	marker(2, msymbol(triangle)) marker(4, msymbol(lgx)) ///	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income") ///	rows(2) title(Gini index of income inequality) subtitle(year 2010))	graph dot (asis) Gini_inc2 Gini_inc3 Gini_pre Gini_inc5_pred if year==max_year_core & !mi(Gini_inc2), ///	over(ccyy_f, sort(Gini_inc5_pred) descending) marker(1, msymbol(square)) ///	marker(2, msymbol(triangle)) marker(4, msymbol(lgx)) ///	legend(order(1 "Market Income" 2 "Gross Income" 3 "Disposable Income" 4 "Post-Tax Income") ///	rows(2) title(Gini index of income inequality) subtitle(Core model only))