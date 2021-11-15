#' Data Connector
#'
#' @param date The date for which to connect.
#' @export
data_connector <- function(date = "latest"){
  .tbl <- list_tables_s3() %>%
    purrr::map(~ {
      fun_str <- sprintf('function(date = "%s"){s3_tbl("%s", date)}', date, .x)
      fun <- eval(parse(text = fun_str))
      class(fun) <- c('function_dc', class(fun))
      attr(fun, "table") <- .x
      fun
    }) %>%
    rlang::set_names(paste0('tbl_', list_tables_s3()))

  # .help <- list_tables_s3() %>%
  #   purrr::map(~ {
  #     fun_str <- sprintf('function(){s3_help("%s")}', .x)
  #     fun <- eval(parse(text = fun_str))
  #   }) %>%
  #   rlang::set_names(paste0('help_', list_tables_s3()))

  .tbl
}

#' @export
print.function_dc <- function(x, ...){
  print(s3_help(attr(x, 'table')))
}
