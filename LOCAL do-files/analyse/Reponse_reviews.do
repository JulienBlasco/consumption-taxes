cd "E:\Code\21-03 Datasets V7 (JPubEc Resubmit)\LOCAL do-files"

// Comparaison Euromod
do "comparaison_euromod\LOCAL compare_euromod.do"

// scaling
do "check_imputation/LOCAL donnees_observees.do"

// Test imputation
do "check_imputation\LOCAL prepa_indicateurs_imputation.do"
do "check_imputation\LOCAL qualite imputation percentiles.do"
do "check_imputation/LOCAL_comparaison_sur_summaries.do"
