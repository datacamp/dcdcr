#' Data Connector
#'
#' @param date The date for which to connect.
#' @importFrom purrr map
#' @importFrom rlang set_names
#' @export
data_connector <- function(date = "latest"){
  missing_creds <- get_missing_credentials()
  if (length(missing_creds) > 0){
    usethis::ui_info("You are missing environment variables")
    missing_creds %>% 
      purrr::walk(~ usethis::ui_todo(.x))
    usethis::ui_stop(paste(
      "Please add missing environment variables before accessing the data",
      "connector. If you are in DataCamp Workspace, you can do this using the" ,
      "Integrations tab in the sidebar on the left. If you are NOT in DataCamp",
      "Workspace, it is recommended that you set these environment variables" ,
      "in a .Rprofile file at the root of your project. e.g. ",
      "Sys.setenv(<ENV_VAR> = '...')"
    ))
  }
  .tbl <- list_tables_s3() %>%
    map(~ {
      fun <- s3_tbl_binder(.x, date)
      class(fun) <- c('function_dc', class(fun))
      attr(fun, "table") <- .x
      fun
    }) %>%
    set_names(
      list_tables_s3() %>% 
        sub('^\\learning_', '', .)
    )
   options(dcdcr.docs_bic = .tbl$docs())
  .tbl
}

#' @export
print.function_dc <- function(x, ...){
  print(s3_help(attr(x, 'table')))
}
