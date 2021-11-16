#' Data Connector
#'
#' @param date The date for which to connect.
#' @importFrom purrr map
#' @importFrom rlang set_names
#' @export
data_connector <- function(date = "latest"){
  .tbl <- list_tables_s3() %>%
    map(~ {
      fun <- s3_tbl_binder(.x, date)
      class(fun) <- c('function_dc', class(fun))
      attr(fun, "table") <- .x
      fun
    }) %>%
    set_names(paste0('tbl_', list_tables_s3()))
  .tbl
}

#' @export
print.function_dc <- function(x, ...){
  print(s3_help(attr(x, 'table')))
}
