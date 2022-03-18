copy "https://raw.githubusercontent.com/TaxFoundation/consumption-taxes/main/intermediate_outputs/consumption_data.csv" ///
	"G:\LOCAL do-files\temporel\consumption_data.csv"
	
import delimited "G:\LOCAL do-files\temporel\consumption_data.csv", clear
rename country cname

tostring year, generate(year_s)
gen yy = substr(year_s, 3,2)
gen cc = strlower(iso_2)
egen ccyy = concat(cc yy)

save "G:\LOCAL do-files\temporel\consumption_data", replace

