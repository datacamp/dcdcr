
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
# Setup Amazon S3 session
s3_sess <- create_s3_session()

# Retrieve all data on the latest date available
dc <- get_dc_datasets(s3_sess)

# See the results
str(dc, 1, give.attr = FALSE)
#> List of 15
#>  $ assessment_dim          : tibble [14 × 4] (S3: tbl_df/tbl/data.frame)
#>  $ chapter_dim             : tibble [1,638 × 13] (S3: tbl_df/tbl/data.frame)
#>  $ course_dim              : tibble [398 × 10] (S3: tbl_df/tbl/data.frame)
#>  $ exercise_dim            : tibble [29,547 × 16] (S3: tbl_df/tbl/data.frame)
#>  $ learning_assessment_fact: tibble [2,263 × 8] (S3: tbl_df/tbl/data.frame)
#>  $ learning_chapter_fact   : tibble [297,633 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ learning_course_fact    : tibble [50,046 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ learning_exercise_fact  : tibble [261,584 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ learning_practice_fact  : tibble [13,109 × 8] (S3: tbl_df/tbl/data.frame)
#>  $ learning_project_fact   : tibble [5,185 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ practice_dim            : tibble [109 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ project_dim             : tibble [107 × 8] (S3: tbl_df/tbl/data.frame)
#>  $ team_dim                : tibble [65 × 6] (S3: tbl_df/tbl/data.frame)
#>  $ user_dim                : tibble [331 × 11] (S3: tbl_df/tbl/data.frame)
#>  $ user_team_bridge        : tibble [435 × 4] (S3: tbl_df/tbl/data.frame)
```

You can specify which datasets are returned, on which date.

``` r
dc_team <- get_dc_datasets(s3_sess, "team_dim", Sys.Date() - 7)
dc_team
#> $team_dim
#> # A tibble: 64 x 6
#>    id    name       slug                  created_date updated_date deleted_date
#>    <chr> <chr>      <chr>                 <date>       <date>       <date>      
#>  1 1187  Learn      learn                 2018-06-27   2020-01-27   2020-01-27  
#>  2 9709  Founder T… founder-team          2020-02-11   2020-02-19   2020-02-19  
#>  3 18309 test       test                  2021-07-16   2021-07-16   2021-07-16  
#>  4 1140  Content (… content-old           2018-06-21   2020-02-11   2020-02-11  
#>  5 9744  Customer … customer-success-a8e… 2020-02-12   2020-02-12   NA          
#>  6 19047 test       test-3b956847-44d0-4… 2021-08-30   2021-08-30   NA          
#>  7 1145  Sales      sales-735bf4d6-2307-… 2018-06-21   2020-02-12   2020-02-12  
#>  8 18142 Test Bulk… test-bulk-team-add    2021-07-05   2021-09-10   2021-09-10  
#>  9 16656 test       test-3310307c-db83-4… 2021-03-26   2021-03-26   2021-03-26  
#> 10 7072  Support    support               2019-08-30   2019-08-30   NA          
#> # … with 54 more rows
#> 
#> attr(,"date")
#> [1] "2021-09-22"
```
