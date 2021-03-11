# Hello

You are now viewing the website of the project "Consumption Taxes", by Julien Blasco, Elvire Guillaud and Michaël Zemmour.

## Paper and Citation
Our project is currently published in the LIS Working Paper Series. You may cite it as:
> Blasco J., Guillaud E., Zemmour M. (2020) ["Consumption Taxes and Income Inequality: An International Perspective with Microsimulation"](http://www.lisdatacenter.org/wps/liswps/785.pdf), _LIS Working Paper Series_, No. 785.

You are free to use the datasets we provide here, but please cite them as:
> Blasco J., Guillaud E., Zemmour M., _Data on the Impact of Consumption Taxes on Income Inequality_, https://doi.org/10.5281/zenodo.4291984, October 2020.

## Data
Our data is hosted on Zenodo.org under the following Digital Object Identifier (click the badge below to access):

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4291983.svg)](https://doi.org/10.5281/zenodo.4291983)

There are 5 different files available to download:
### Aggregated indicators (Gini coefficients, global tax ratios, etc.)
These are the Stata files containing the latest indicators obtained with our microsimulation method.
- Core model (82 country-years): `ConsumptionTaxes_indicators_coremodel.dta`
- Lighter model (126 country-years): `ConsumptionTaxes_indicators_xtnddmodel.dta`

### Percentiles
These are the Stata files containing the variables obtained with our microsimulation method, broken down in percentiles of disposable income. Please note that these data are mainly for graphing purposes, not detailed analysis at the percentile level.
- Core model (82 country-years): `ConsumptionTaxes_percentiles_coremodel.dta`
- Lighter model (126 country-years): `ConsumptionTaxes_percentiles_xtnddmodel.dta`

### Effective tax rates on consumption
The following dataset contains the implicit tax rates on consumption computed in our project with National Accounts data: `18-07-27 OECD_itrcs.dta`

## Sources

Our data is extracted from surveys on income and consumption, harmonized by the [Luxembourg Income Study](https://www.lisdatacenter.org). We used [OECD Statistics](https://stats.oecd.org) for National Accounts data on income, consumption and consumption tax revenue. The [code](https://github.com/JulienBlasco/consumption-taxes) is available on GitHub.

## Contact

For any questions regarding the data or our research work, please contact us at <julien.blasco@sciencespo.fr>, <elvire.guillaud@univ-paris1.fr>, and <michael.zemmour@univ-paris1.fr>.
