#' Create Amazon S3 session
#' 
#' Creates an Amazon Simple Storage Service session. (This is where DataCamp  
#' Data Connector data is hosted).
#' 
#' @param access_key_id String containing the S3 access key. 
#' @param secret_access_key String containing the S3 secret access key.
#' @param region String containing the S3 default region.
#' @note Find the arguments to this function in the Admin Portal for
#' your DataCamp group. See Reporting -> Export -> Data Connector -> View
#' Configuration Details. It is recommended to store these values as environment 
#' variables.
#' @examples 
#' \dontrun{
#' Sys.setenv(
#'   AWS_ACCESS_KEY_ID = "your access key ID",
#'   AWS_SECRET_ACCESS_KEY = "your secret key",
#'   AWS_DEFAULT_REGION = "your default region"
#' )
#' }
#' s3_sess <- create_s3_session()
#' str(s3_sess, 1)
#' @seealso \code{\link[paws]{s3}}
#' @importFrom paws s3
#' @export
create_s3_session <- function(
  access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"), 
  secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
  region = Sys.getenv("AWS_DEFAULT_REGION")) {
  paws::s3(
    config = list(
      credentials = list(
        creds = list(
          access_key_id = access_key_id,
          secret_access_key = secret_access_key
        )
      ),
      region = region
    )
  )
}

#' Get the most recent date where data is available
#' 
#' Get the most recent date where DataCamp Data Connector data is available.
#'
#' @param s3_sess An S3 data connector, as returned by \code{create_s3_sessector}.
#' @param bucket A string containing the DataCamp Data Connector bucket name.
#' @param verbose If \code{TRUE}, print a message of the date of the data.
#' @return A string containing the date in \code{%Y-%m-%d} format.
#' @note Find the bucket argument to this function in the Admin Portal for
#' your DataCamp group. See Reporting -> Export -> Data Connector -> View
#' Configuration Details. It is recommended to store this value as an 
#' environment variable.
#' @examples 
#' \dontrun{
#' Sys.setenv(
#'   AWS_ACCESS_KEY_ID = "your access key ID",
#'   AWS_SECRET_ACCESS_KEY = "your secret key",
#'   AWS_DEFAULT_REGION = "your default region",
#'   AWS_S3_BUCKET_NAME = "your bucket"
#' )
#' }
#' s3_sess <- create_s3_sessector()
#' get_most_recent_date(s3_sess, verbose = TRUE)
#' @seealso \code{\link{create_s3_sessector}}
#' @importFrom stringr str_extract
#' @export
get_most_recent_date <- function(s3_sess, 
    bucket = Sys.getenv("AWS_S3_BUCKET_NAME"), verbose = getOption("verbose")) {
  dc_bucket <- get_dc_bucket(s3_sess, bucket)
  dc_bucket_keys <- get_bucket_keys(dc_bucket)
  most_recent_date <- dc_bucket_keys %>% 
    stringr::str_extract("\\d{4}-\\d{2}-\\d{2}") %>% 
    max(na.rm = TRUE)
  if(verbose) {
    message("The most recent data is from ", most_recent_date)
  }
  most_recent_date
}

#' Dataset names
#' 
#' Names of datasets available via data connector.
#' @return Character vector of names of datasets.
#' @examples
#' DC_DATASETS
#' @export
DC_DATASETS <- c(
  "assessment_dim", "chapter_dim", "course_dim", "exercise_dim", 
  "learning_assessment_fact", "learning_chapter_fact", "learning_course_fact", 
  "learning_exercise_fact", "learning_practice_fact", "learning_project_fact", 
  "practice_dim", "project_dim", "team_dim", "user_dim", "user_team_bridge"
)

#' Get DataCamp Data Connector datasets
#' 
#' Gets DataCamp Data Connector datasets from S3.
#' 
#' @param s3_sess An S3 data connector, as returned by \code{create_s3_sessector}.
#' @param datasets Names of the datasets to import.
#' @param date A Date or string in \code{\%Y-\%m-\%d} format denoting the date at 
#' which to retrieve data for. Use \code{"latest"} to get the most recent data.
#' @param bucket A string containing the DataCamp Data Connector bucket name.
#' @param verbose If \code{TRUE}, print a message of the date of the data.
#' @return A list of tibbles containing the datasets. The date is stored in an
#' attribute named \code{date}
#' @examples 
#' \dontrun{
#' Sys.setenv(
#'   AWS_ACCESS_KEY_ID = "your access key ID",
#'   AWS_SECRET_ACCESS_KEY = "your secret key",
#'   AWS_DEFAULT_REGION = "your default region",
#'   AWS_S3_BUCKET_NAME = "your bucket"
#' )
#' }
#' s3_sess <- create_s3_sessector()
#' dc <- get_dc_datasets(s3_sess)
#' str(dc, 1, give.attr = FALSE)
#' @seealso \code{\link{create_s3_sessector}}, \code{\link{DC_DATASETS}}
#' @importFrom magrittr %>%
#' @importFrom purrr map2
#' @importFrom purrr set_names
#' @export
#' @include internal.R
get_dc_datasets <- function(
  s3_sess, datasets = DC_DATASETS, date = "latest",
  bucket = Sys.getenv("AWS_S3_BUCKET_NAME"),
  verbose = getOption("verbose")
) {
  datasets <- match.arg(datasets, DC_DATASETS, several.ok = TRUE)
  if(!identical(date, "latest")) {
    if(inherits(date, "Date")) {
      date <- format(date, "%Y-%m-%d")
    } else {
      stopifnot("The format for `date` should be yyyy-mm-dd." = is_yyyymmdd(date))
    }
  }
  filenames <- paste0(date, "/", datasets, ".csv")
  dc <- map2(
      filenames, COLUMN_SPEC[datasets], 
      ~ {
        if(verbose) {
          message("Reading ", .x)
        }
        read_object(.x, colClasses = .y, s3_sess = s3_sess, bucket = bucket) 
      }
    ) %>% 
    set_names(datasets)
  
  # Custom overrides for dodgy data columns
  if(!is.null(dc$exercise_dim)) {
    dc$exercise_dim$xp <- as.integer(dc$exercise_dim$xp)
    dc$exercise_dim$course_xp <- as.integer(dc$exercise_dim$course_xp)
  }
  if(!is.null(dc$learning_exercise_fact)) {
    dc$learning_exercise_fact$xp <- as.integer(dc$learning_exercise_fact$xp)
  }
  if(!is.null(dc$learning_practice_fact)) {
    dc$learning_practice_fact$xp <- as.integer(dc$learning_practice_fact$xp)
    dc$learning_practice_fact$is_mobile <- as.logical(dc$learning_practice_fact$is_mobile)
  }
  if(!is.null(dc$project_dim)) {
    dc$project_dim$is_guided <- dc$project_dim$is_guided == "t"
  }
  attr(dc, "date") <- date
  dc
}