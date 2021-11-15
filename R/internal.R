dc_read_table <- function(file, ...){
  tibble::as_tibble(
    data.table::fread(file = file, na.strings = c("NA", "")),
    .name_repair = "minimal"
  )
  # readr::read_csv(file, show_col_types = FALSE)
  # vroom::vroom(file, show_col_types = FALSE)
}

is_yyyymmdd <- function(x) {
  tryCatch(
    inherits(as.Date(x), "Date"), 
    error = function(e) FALSE
  )
}

COLUMN_SPEC <- list(
  assessment_dim = c(
    id = "character",
    slug = "character",
    language = "character"
  ),
  chapter_dim = c(
    id = "character",
    title = "character",
    slug = "character",
    xp = "integer",
    technology = "character",
    topic = "character",
    nb_exercises = "integer",
    course_title = "character",
    course_slug = "character",
    course_xp = "integer",           
    course_description = "character",
    course_short_description = "character",
    course_launched_date = "Date"
  ),
  course_dim = c(
    id = "character",
    title = "character",
    technology = "character",
    topic = "character",
    xp = "integer",
    nb_hours_needed = "double",
    slug = "character",
    description = "character",
    short_description = "character",
    launched_date = "Date"
  ),
  exercise_dim = c(
    id = "character",
    title = "character",
    type = "character",
    xp = "character", # should be "integer" but needs manual override
    topic = "character",
    technology = "character",
    course_title = "character",
    course_slug = "character",
    course_xp = "character", # should be "integer" but needs manual override
    course_description = "character",
    course_short_description = "character",
    course_launched_date = "Date",
    chapter_title = "character",
    chapter_slug = "character",
    chapter_xp = "integer",
    chapter_nb_exercises = "integer"
  ),
  learning_assessment_fact = c(
    user_id = "character",
    assessment_id = "character",
    date_id = "character",
    started_at = "POSIXct",
    completed_at = "POSIXct",
    score = "integer",
    percentile = "integer",
    time_spent = "integer"
  ),
  learning_chapter_fact = c(
    user_id = "character",
    chapter_id = "character",
    date_id = "character",
    started_at = "POSIXct",
    completed_at = "POSIXct",
    xp = "integer",
    time_spent = "integer"
  ),
  learning_course_fact = c(
    user_id = "character",
    course_id = "character",
    date_id = "character",
    started_at = "POSIXct",
    completed_at = "POSIXct",
    xp = "integer",
    time_spent = "integer"
  ),
  learning_exercise_fact = c(
    user_id = "character",
    exercise_id = "character",
    date_id = "character",
    started_at = "POSIXct",
    completed_at = "POSIXct",
    xp = "double", # should be "integer"  but need to explicitly convert
    time_spent = "integer"
  ),
  learning_practice_fact = c(
    user_id = "character",
    practice_id = "character",
    date_id = "character",
    started_at = "POSIXct",
    completed_at = "POSIXct",
    is_mobile = "integer", # should be "logical" but need to explicitly convert
    xp = "double", # should be "integer"  but need to explicitly convert
    time_spent = "integer"
  ),
  learning_project_fact = c(
    user_id = "character",
    project_id = "character",
    date_id = "character",
    started_at = "POSIXct",
    completed_at = "POSIXct",
    xp = "integer",
    time_spent = "integer"
  ),
  practice_dim = c(
    id = "character",
    title = "character",
    technology = "character",
    xp = "integer",
    status = "character"
  ),
  project_dim = c(
    id = "character",
    title = "character",
    technology = "character",
    xp = "integer",
    nb_hours_needed = "double",
    is_guided = "character", # should be "logical" but need to explicitly convert
    description = "character",
    short_description = "character"
  ),
  team_dim = c(
    id = "character",
    name = "character",
    slug = "character",
    created_date = "Date",
    updated_date = "Date",
    deleted_date = "Date"
  ),
  user_dim = c(
    id = "character",
    first_name = "character",
    last_name = "character",
    email = "character",
    slug = "character",
    registered_at = "POSIXct",
    deleted_at = "POSIXct",
    last_visit_at = "POSIXct",
    last_time_spent_at = "Date",
    onboarding_completed_at = "POSIXct",
    first_content_completed_at = "POSIXct"
  ),
  user_team_bridge = c(
    user_id = "character",
    team_id = "character",
    joined_team_date = "POSIXct",
    left_team_date = "Date"
  )
)