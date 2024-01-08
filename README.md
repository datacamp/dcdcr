
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dcdcr

<!-- badges: start -->

[![Lifecycle:
deprecated](https://img.shields.io/badge/lifecycle-deprecated-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#deprecated)
<!-- badges: end -->

This package contains utilities to work with DataCamp Data Connector. It
is designed to be used by administrators and managers of DataCamp
groups. Some prior experience of writing reports with R is recommended.

## DEPRECATION WARNING

Warning, this package is no longer actively maintained! Please see the
[announcement](https://enterprise-docs.datacamp.com/data-connector/data-connector-faq/deprecating-dcdcpy-and-dcdcr)
for more information and alternatives.

## Installation

You can install the development version with:

``` r
if (!requireNamespace('remotes', quietly = TRUE)){
  install.packages("remotes")
}
remotes::install_github("datacamp/dcdcr")
```

## Getting Started

Before you begin, you need to enable Data Connector in your DataCamp
group, and set S3 credentials as environment variables, as described in
this [this Support
article](https://support.datacamp.com/hc/en-us/articles/4405070893591-DataCamp-Data-Connector-A-Step-by-Step-Configuration-Guide-for-Automated-Data-Exports).
If in doubt, speak to your Customer Success Manager.

## Accessing Data

You can access any of the tables in the data connector by initializing
it using the `data_connector` function and using autocomplete to access
all the tables.

By default the connector is set up to access data for the latest date.
However, you can also pass a `date` argument to `dc_data_connector` to
initialize it to access data for a specific date. This is useful when
you want to create reports and want to pin your analysis to data as on a
specific date.

``` r
library(dcdcr)
dc <- data_connector()
dc$assessment_dim()
```

You can also print the documentation for each table by accessing the
function using autocomplete, but NOT invoking it.

``` r
dc$assessment_dim
```

![dc-help](man/figures/dc-help.png)

All the data accessors are memoized and will cache the results in memory
when they are run for the first time. This should speed up analysis
considerably since the data is already cached in memory.
