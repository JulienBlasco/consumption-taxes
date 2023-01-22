twoway scatter hmc.

sort ccyy dhi_quantiles

twoway (scatter global_prop_q dhi_quantiles) ///
	(line global_prop_pred_q dhi_quantiles) ///
	(line global_prop_wor_pred_q  dhi_quantiles), by(ccyy_f)
