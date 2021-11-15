dag_tasks_bic <- dc_s3_read('dag_tasks.rds', type = 'prod') %>%
  filter(grepl('^bic_', task_id)) %>%
  filter(!(
    task_id %in% c('bic_group_dim', 'bic_user_group_bridge', 'bic_team_group_bridge')
  ))

get_column_comments <- function(metadata){
  metadata$fields[[1]] %>%
    tibble::enframe() %>%
    mutate(value = purrr::map_chr(value, 1)) %>%
    select(column = name, description = value) %>%
    mutate(column = tolower(column))
}
docs_bic <- dag_tasks_bic %>%
  mutate(tbl_fun_name = gsub("bic", "tbl", task_id)) %>%
  mutate(column_comments = purrr::map(metadata, get_column_comments)) %>%
  select(tbl_fun_name, column_comments, table_description = description)

usethis::use_data(docs_bic, internal = TRUE, overwrite = TRUE)




