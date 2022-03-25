import delimited "G:\LOCAL do-files\temporel\SNA_TABLE1_22032022121247604.csv", clear
rename country cname
rename value GDP

save "G:\LOCAL do-files\temporel\SNA_TABLE1_22032022121247604", replace

