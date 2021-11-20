## code to prepare `help` files
library(dplyr)
library(purrr)
library(glue)
library(stringr)

create_docs <- function(tbl_docs){
  d %>%
    mutate(
      docs = pmap_chr(
        list(tbl_fun_name, column_comments, table_description),
        create_doc
      )
    )
}

create_doc <- function(tbl_fun_name, column_comments, table_description, template = "table-fun-docs.Rd"){
  tpl_column <- "\\item{{{column}}}{{{description}}}"
  column_descriptions <- column_comments %>%
    glue_data(tpl_column) %>%
    paste("    ", .) %>%
    str_c(collapse = "\n")
  tpl_doc <- paste(
    readLines(
      system.file(paste0('templates/', template), package = 'dcdcr')
    ),
    collapse = '\n'
  )
  glue(tpl_doc)
}

write_rd_files <- function(tbl_docs){
  all_docs <- create_docs(tbl_docs)
  for (i in seq_along(all_docs$tbl_fun_name)){
    cat(
      all_docs$docs[i][[1]],
      file = paste0('man/', all_docs$tbl_fun_name[i], '.Rd')
    )
  }
}
