.onLoad <- function(libname, pkgname) {
  # Set default environment variables expected by paws::s3()
  if (Sys.getenv('AWS_BUCKET') == ''){
    Sys.setenv('AWS_BUCKET' = Sys.getenv('AWS_S3_BUCKET_NAME'))
  }
  if (Sys.getenv('AWS_REGION') == ''){
    Sys.setenv('AWS_REGION' = Sys.getenv('AWS_DEFAULT_REGION'))
  }
  # Get package environment
  pkg_ns_env <- parent.env(environment())
  # usethis::ui_info("Creating accessor functions ...")
  # create_accessors_s3(env = pkg_ns_env)
  # usethis::ui_info("Type tbl_ and use autocomplete to select a table")
}
