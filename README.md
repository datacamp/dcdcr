
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dcdcr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

This package contains utilities to work with DataCamp Data Connector. It
is designed to be used by administrators and managers of DataCamp
groups. Some prior experience of writing reports with R is recommended.

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

    #> # A tibble: 14 × 5
    #>    assessment_id title                                   slug   technology    id
    #>            <int> <chr>                                   <chr>  <chr>      <int>
    #>  1          1874 Understanding and Interpreting Data     under… Theory      1874
    #>  2          1663 Data Manipulation with Python           data-… Python      1663
    #>  3          1649 R Programming                           r-pro… R           1649
    #>  4          1979 Data Visualization with R               data-… R           1979
    #>  5          1688 Machine Learning Fundamentals in R      machi… R           1688
    #>  6          1735 Importing & Cleaning Data with R        impor… R           1735
    #>  7          1936 Statistics Fundamentals with R          stati… R           1936
    #>  8          1679 Python Programming                      pytho… Python      1679
    #>  9          1815 Data Analysis in SQL (PostgreSQL)       data-… SQL         1815
    #> 10          1645 Data Manipulation with R                data-… R           1645
    #> 11          1742 Importing & Cleaning Data with Python   impor… Python      1742
    #> 12          1882 Statistics Fundamentals with Python     stati… Python      1882
    #> 13          1857 Data Visualization with Python          data-… Python      1857
    #> 14          1714 Machine Learning Fundamentals in Python machi… Python      1714

You can also print the documentation for each table by accessing the
function using autocomplete, but NOT invoking it.

``` r
dc$assessment_dim
```

![dc-help](man/figures/dc-help.png)

All the data accessors are memoized and will cache the results in memory
when they are run for the first time. This should speed up analysis
considerably since the data is already cached in memory.
