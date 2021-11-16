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
#'   AWS_REGION = "your region"
#' )
#' }
#' s3_sess <- create_s3_session()
#' str(s3_sess, 1)
#' @seealso \code{\link[paws]{s3}}
#' @importFrom paws s3
create_s3_session <- function(
  access_key_id = get_env_var_aws_access_key(), 
  secret_access_key = get_env_var_aws_secret(), 
  region = get_env_var_aws_region()) {
  s3(
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


#' List objects in an S3 bucket
#'
#' @param bucket The name of the S3 bucket.
#' @param date The date to filter the objects on.
#' @importFrom usethis ui_info
#' @importFrom purrr map_df
#' @keywords internal
#' @examples
#' \dontrun{
#' list_objects_s3() %>%
#'   head()
#' }
#' @importFrom purrr map_df
#' @importFrom tools file_path_sans_ext
list_objects_s3 <- function(bucket = get_env_var_aws_bucket(), date = 'latest'){
  s3 <- create_s3_session()
  # usethis::ui_info("Fetching first 1000 objects ...")
  response <- s3$list_objects_v2(bucket, Prefix = date)
  content <- response$Contents
  is_truncated <- isTRUE(response$IsTruncated)
  while (is_truncated){
    # usethis::ui_info("Fetching next 1000 objects ...")
    response <- s3$list_objects_v2(
      bucket,
      Prefix = date,
      ContinuationToken = response$NextContinuationToken
    )
    content <- c(content, response$Contents)
    is_truncated <- response$IsTruncated
  }
  content %>%
    map_df(~ list(
      name = file_path_sans_ext(basename(.x$Key)),
      key = .x$Key,
      last_modified = .x$LastModified
    ))
}


#' List tables in S3 bucket
#'
#' @importFrom dplyr pull
#' @importFrom purrr discard
#' @importFrom tools file_path_sans_ext
#' @export
list_tables_s3 <- function(){
  list_objects_s3() %>%
    pull(key) %>%
    basename() %>%
    file_path_sans_ext() %>%
    discard(~ grepl('^test', .))
}

#' Read table from S3
#'
#' @param x The name of the table
#' @param date The date when it was generated (defaults to "latest")
#' @examples
#' \dontrun{
#' tbl_s3('chapter_dim')
#' }
#' @importFrom glue glue
#' @importFrom magrittr extract2
#' @importFrom memoise memoise
#' @importFrom magrittr extract2
#' @importFrom paws s3
s3_tbl <- memoise(function(x, date = 'latest'){
  s3 <- create_s3_session()
  tf <- tempfile(fileext = '.csv')
  file <- glue('{date}/{x}.csv')
  key <- glue('{date}/{x}.csv')
  tryCatch(
    {
      s3$get_object(
        Bucket = get_env_var_aws_bucket(),
        Key = key
      ) %>%
        extract2('Body') %>%
        writeBin(con = tf)
      dc_read_table(tf)
    },
    error = function(e) {
      warning(sprintf("%s could not be read from S3.", key))
      NULL
    }
  )
})

#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#' @importFrom dplyr pull
#' @importFrom magrittr extract2
#' @importFrom purrr transpose
#' @importFrom tidyr nest
s3_tbl_docs <- function(){
  docs_bic %>%
    mutate(tbl_fun_name = paste0('tbl_', table_name)) %>%
    select(-table_name) %>%
    group_by(tbl_fun_name, table_description) %>%
    nest(column_comments = c(column, description))
}

#' Get help documents
#'
#' @param x The name of the table
#' @importFrom dplyr filter
#' @importFrom pointblank create_informant
#' @importFrom pointblank info_tabular
#' @importFrom pointblank info_columns
#' @importFrom pointblank get_informant_report
#' @importFrom snakecase to_title_case
s3_help <- function(x){
  .tbl_fun_name = paste0('tbl_', x)
  doc <- s3_tbl_docs() %>%
    filter(tbl_fun_name == .tbl_fun_name)
  
  if(nrow(doc) == 0) {
    warning(sprintf("No documentation is available for %s.", x), call. = FALSE)
    return(invisible())
  }
  column_comments <- doc %>%
    pull(column_comments) %>%
    extract2(1) %>%
    as.list() %>%
    transpose()

  informant <- s3_tbl(x) %>%
    create_informant(
      tbl = .,
      label = 'Data Connector'
    )

  informant <- informant %>%
    info_tabular(
      summary = doc$table_description
    )

  for (column in column_comments){
    informant <- informant %>%
      info_columns(
        columns = column$column,
        info = column$description
      )
  }

  informant %>%
    get_informant_report(
      title = to_title_case(x),
      size = 'small'
    )
}

#' Create table accessors for S3
#'
#' @param date The date for the tables to be accessed
#' @param env The environment into which the accessor functions should be
#'   written
#' @importFrom purrr walk
#' @importFrom memoise memoise
create_accessors_s3 <- function(date = 'latest', env){
  list_tables_s3() %>%
    walk(~ {
      fun <- s3_tbl_binder(.x, date)
      class(fun) <- c('function_dc', class(fun))
      fun_name <- paste0('tbl_', .x)
      assign(fun_name, fun, envir = env)
    })
}

s3_tbl_binder <- function(x, date) {
  function() {
    s3_tbl(x, date)
  }
}