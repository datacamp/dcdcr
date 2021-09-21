get_dc_bucket <- function(s3_conn, bucket = Sys.getenv("AWS_S3_BUCKET_NAME")) {
  s3_conn$list_objects_v2(Bucket = bucket)
}

#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
get_bucket_keys <- function(dc_bucket) {
  dc_bucket$Contents %>% 
    map_chr(~ .$Key) %>% 
    unname()
}

#' @importFrom purrr set_names
#' @importFrom readr read_csv
read_object <- function(filename, s3_conn, bucket = Sys.getenv("AWS_S3_BUCKET_NAME")) {
  obj <- s3_conn$get_object(
    Bucket = bucket, 
    Key = filename
  )
  read_csv(rawToChar(obj$Body), show_col_types = FALSE)
}