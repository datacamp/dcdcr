
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dcdcr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

dcdcr contains utilities to work with DataCamp Data Connector.

This package is designed to be used by administrators and managers of
DataCamp groups. Some prior experience of writing reports with R is
recommended.

## Installation

You can install the development version with:

``` r
# install.packages("remotes")
remotes::install_github("datacamp/dcdcr")
```

## Before you begin

You need to enable Data Connector in your DataCamp group, and set S3
credentials as environment variables, as described in [this Support
article](https://support.datacamp.com/hc/en-us/articles/4405070893591-DataCamp-Data-Connector-A-Step-by-Step-Configuration-Guide-for-Automated-Data-Exports).
If in doubt, speak to your Customer Success Manager.

## Importing data

Importing data requires two commands. First you set up the connector to
S3, then you get the datasets. By default, all the data is returned for
the most recent date.

``` r
library(dcdcr)
# Setup connector to Amazon S3
s3_conn <- create_s3_connector()

# Retrieve all data on the latest date available
dc <- get_dc_datasets(s3_conn)
#> Warning: One or more parsing issues, see `problems()` for details

# See the results
str(dc, 1, give.attr = FALSE)
#> List of 15
#>  $ assessment_dim          : spec_tbl_df [14 × 4] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ chapter_dim             : spec_tbl_df [1,630 × 13] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ course_dim              : spec_tbl_df [396 × 10] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ exercise_dim            : spec_tbl_df [29,451 × 16] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ learning_assessment_fact: spec_tbl_df [2,232 × 8] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ learning_chapter_fact   : spec_tbl_df [297,209 × 7] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ learning_course_fact    : spec_tbl_df [49,772 × 7] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ learning_exercise_fact  : spec_tbl_df [259,893 × 7] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ learning_practice_fact  : spec_tbl_df [13,056 × 8] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ learning_project_fact   : spec_tbl_df [5,131 × 7] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ practice_dim            : spec_tbl_df [109 × 5] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ project_dim             : spec_tbl_df [107 × 8] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ team_dim                : spec_tbl_df [64 × 6] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ user_dim                : spec_tbl_df [323 × 11] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ user_team_bridge        : spec_tbl_df [428 × 4] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
```

You can specify which datasets are returned, on which date.

``` r
dc_team <- get_dc_datasets(s3_conn, "team_dim", Sys.Date() - 7)
dc_team
#> $team_dim
#> # A tibble: 63 x 6
#>       id name          slug               created_date updated_date deleted_date
#>    <dbl> <chr>         <chr>              <date>       <date>       <date>      
#>  1 17124 HR Team       hr-team            2021-04-20   2021-04-20   NA          
#>  2 15771 Learning Exp… learning-experien… 2021-02-11   2021-02-11   NA          
#>  3 14782 test          test-01db52b5-8ce… 2020-12-16   2020-12-16   2020-12-16  
#>  4 16659 Demand Gen    demand-gen         2021-03-26   2021-03-26   NA          
#>  5  1188 Growth        growth             2018-06-27   2019-06-12   NA          
#>  6 17756 Managers at … managers-at-my-or… 2021-06-02   2021-06-10   2021-06-10  
#>  7 19261 Assignment t… assignment-test-t… 2021-09-09   2021-09-09   NA          
#>  8  9427 Direct        direct-73a23592-3… 2020-01-27   2020-01-27   NA          
#>  9 16772 Demo          demo               2021-04-01   2021-04-01   2021-04-01  
#> 10 10684 Example       example-91371104-… 2020-03-26   2020-03-26   2020-03-26  
#> # … with 53 more rows
#> 
#> attr(,"date")
#> [1] "2021-09-13"
```
