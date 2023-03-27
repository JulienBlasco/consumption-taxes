gen log_hmc = log(hmc_q)
gen log_hmchous = log(hmchous_q)
gen rapport_hmc_hmchous = log_hmchous/log_hmc

gen rapport_absolu = hmchous_q/hmc_q
gen log_rapport_absolu = log(rapport_absolu)

sort ccyy dhi_q
gen croissance_hmc = (hmc_q[_n+10]-hmc_q[_n])/(dhi_q[_n+10]-dhi_q[_n]) if dhi_quantiles < 90
gen croissance_hmchous = (hmchous_q[_n+10]-hmchous_q[_n])/(dhi_q[_n+10]-dhi_q[_n]) if dhi_quantiles < 90

gen rapport_croissance = croissance_hmchous/croissance_hmc

egen decile = floor(dhi_q/10)

gen log_dhi = log(dhi_q)

gen mediane = dhi_q if dhi_quantiles == 50

egen mediane_ccyy = max(mediane), by(ccyy)

gen 
