# Hello

You are now viewing the website of the project "Consumption Taxes", by Julien Blasco, Elvire Guillaud and Michaël Zemmour.

## Paper and Citation
Our project is currently published in the LIS Working Paper Series. You may cite it as:
> Blasco J., Guillaud E., Zemmour M. (2019) ["Consumption Taxes and Income Inequality: An International Perspective with Microsimulation"](http://www.lisdatacenter.org/wps/liswps/785.pdf), _LIS Working Paper Series_, No. 785.

You are free to use the datasets we provide here, but please cite them as:
> Blasco J., Guillaud E., Zemmour M., _Consumption Taxes Data_, http://julienblasco.github.io/consumption-taxes, October 2020.


## Data
### Aggregated indicators (Gini coefficients, global tax ratios, etc.)
You can download here the Stata files (.dta) containing the latest indicators obtained with our microsimulation method.
- Core model (82 country-years): [ConsumptionTaxes_indicators_coremodel.dta](https://github.com/JulienBlasco/consumption-taxes/blob/master/DTA/ConsumptionTaxes_indicators_coremodel.dta?raw=true "ConsumptionTaxes_indicators_coremodel.dta")
- Extended model (126 country-years): [ConsumptionTaxes_indicators_xtnddmodel](https://github.com/JulienBlasco/consumption-taxes/raw/master/DTA/ConsumptionTaxes_indicators_xtnddmodel.dta "ConsumptionTaxes_indicators_xtnddmodel")

### Percentiles
You can download here the Stata files (.dta) containing the variables obtained with our microsimulation method, broken down in percentiles of disposable income. Please note that these data are mainly for graphing purposes, not detailed analysis at the percentile level.
- Core model (82 country-years): [ConsumptionTaxes_percentiles_coremodel](https://github.com/JulienBlasco/consumption-taxes/raw/master/DTA/ConsumptionTaxes_percentiles_coremodel.dta "ConsumptionTaxes_percentiles_coremodel")
- Extended model (126 country-years): [ConsumptionTaxes_percentiles_xtnddmodel](https://github.com/JulienBlasco/consumption-taxes/raw/master/DTA/ConsumptionTaxes_percentiles_xtnddmodel.dta "ConsumptionTaxes_percentiles_xtnddmodel")

### Effective tax rates on consumption
The following dataset contains the implicit tax rates on consumption computed in our project with OECD National Accounts data: [18-07-27 OECD_itrcs.dta](https://github.com/JulienBlasco/consumption-taxes/raw/master/Itrcs%20scalings/Implicit%20tax%20rates/DTA/18-07-27%20OECD_itrcs.dta)

## Sources

Our data is extracted from surveys on income and consumption, harmonized by the [Luxembourg Income Study](https://www.lisdatacenter.org). We used [OECD Statistics](https://stats.oecd.org) for National Accounts data on income, consumption and consumption tax revenue. The [code](https://github.com/JulienBlasco/consumption-taxes) is available on GitHub.
