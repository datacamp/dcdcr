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
list_objects_s3 <- function(bucket = Sys.getenv("AWS_BUCKET"), date = 'latest'){
  s3 <- paws::s3()
  # usethis::ui_info("Fetching first 1000 objects ...")
  response <- s3$list_objects_v2(bucket, Prefix = date)
  content <- response$Contents
  is_truncated <- response$IsTruncated
  while (is_truncated){
    # usethis::ui_info("Fetching next 1000 objects ...")
    response <-  s3$list_objects_v2(
      bucket,
      Prefix = date,
      ContinuationToken = response$NextContinuationToken
    )
    content <- c(content, response$Contents)
    is_truncated <- response$IsTruncated
  }
  content %>%
    purrr::map_df(~ list(
      name = tools::file_path_sans_ext(basename(.x$Key)),
      key = .x$Key,
      last_modified = .x$LastModified
    ))
}


#' List tables in S3 bucket
#'
#' @export
list_tables_s3 <- function(){
  list_objects_s3() %>%
    dplyr::pull(key) %>%
    basename() %>%
    tools::file_path_sans_ext() %>%
    purrr::discard(~ grepl('^test', .))
}

#' Read table from S3
#'
#' @param x The name of the table
#' @param date The date when it was generated (defaults to "latest")
#' @examples
#' \dontrun{
#' tbl_s3('chapter_dim')
#' }
#' @importFrom paws s3
s3_tbl <- memoise::memoise(function(x, date = 'latest'){
  s3 <- paws::s3()
  tf <- tempfile(fileext = '.csv')
  file = glue::glue('{date}/{x}.csv')
  s3$get_object(
    Bucket = Sys.getenv("AWS_BUCKET"),
    Key = glue::glue('{date}/{x}.csv')
  ) %>%
    magrittr::extract2('Body') %>%
    writeBin(con = tf)
  dc_read_table(tf)
})

s3_tbl_docs <- function(){
  docs_bic %>%
    dplyr::mutate(tbl_fun_name = paste0('tbl_', table_name)) %>%
    dplyr::select(-table_name) %>%
    dplyr::group_by(tbl_fun_name, table_description) %>%
    tidyr::nest(column_comments = c(column, description))
}

#' Get help documents
#'
#' @param x The name of the table
s3_help <- function(x){
  .tbl_fun_name = paste0('tbl_', x)
  doc <- s3_tbl_docs() %>%
    dplyr::filter(tbl_fun_name == .tbl_fun_name)

  column_comments <- doc %>%
    dplyr::pull(column_comments) %>%
    magrittr::extract2(1) %>%
    as.list() %>%
    purrr::transpose()

  informant <- s3_tbl(x) %>%
    pointblank::create_informant(
      tbl = .,
      label = 'Data Connector'
    )


  informant <- informant %>%
    pointblank::info_tabular(
      summary = doc$table_description
    )

  for (column in column_comments){
    informant <- informant %>%
      pointblank::info_columns(
        columns = column$column,
        info = column$description
      )
  }

  informant %>%
    pointblank::get_informant_report(
      title = snakecase::to_title_case(x),
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
    purrr::walk(~ {
      fun_str <- sprintf('function(date = "latest"){s3_tbl("%s", date)}', .x)
      fun <- eval(parse(text = fun_str))
      fun_name <- paste0('tbl_', .x)
      assign(fun_name, fun_memoized, envir = env)
    })
}
