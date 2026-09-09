# this creates the matrix mapping for which variables we should expect station 
# meta data in. 
# the output matrix is saved as stn_csv_matrix in the package

make_stn_csv_matrix <- function(path) {
  x <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA")
  )
  
  # Derive the data family from the PRISM retrieval function.
  x$data_class <- ifelse(
    grepl("get_prism_normals", x$fun, fixed = TRUE),
    "normals",
    "time series"
  )
  
  # Historical functions: get_prism_annual(), get_prism_monthlys(),
  # get_prism_dailys().
  #
  # Normals labels: get_prism_normals() annual, monthly, daily.
  x$time_step <- ifelse(
    grepl("normals", x$fun, ignore.case = TRUE),
    sub("^.*\\)\\s*", "", x$fun),
    sub(
      "^get_prism_(daily|monthly|annual)s?\\(\\)$",
      "\\1",
      x$fun
    )
  )
  
  # Fail explicitly if a new/unrecognized function naming convention appears.
  valid_time_steps <- c("daily", "monthly", "annual")
  if (any(!x$time_step %in% valid_time_steps)) {
    bad <- unique(x$fun[!x$time_step %in% valid_time_steps])
    stop(
      "Could not derive `time_step` from `fun`: ",
      paste(bad, collapse = ", "),
      call. = FALSE
    )
  }
  
  # `has_stn_csv` is already logical in this CSV, but normalize it to make
  # the function robust if it arrives as character data.
  x$has_stn_csv <- as.logical(x$has_stn_csv)
  
  # There should be exactly one row per four-dimensional combination.
  key <- interaction(
    x$time_step,
    x$type,
    x$resolution,
    x$data_class,
    drop = TRUE,
    lex.order = TRUE
  )
  
  if (anyDuplicated(key)) {
    duplicated_keys <- unique(key[duplicated(key)])
    stop(
      "Duplicate [time_step, type, resolution, data_class] combinations: ",
      paste(duplicated_keys, collapse = ", "),
      call. = FALSE
    )
  }
  
  time_steps <- c("daily", "monthly", "annual")
  variables <- unique(x$variable)
  resolutions <- unique(x$resolution)
  data_classes <- c("time series", "normals")
  
  out <- array(
    NA,
    dim = c(
      time_step = length(time_steps),
      variable = length(variables),
      resolution = length(resolutions),
      data_class = length(data_classes)
    ),
    dimnames = list(
      time_step = time_steps,
      variable = variables,
      resolution = resolutions,
      data_class = data_classes
    )
  )
  
  out[cbind(
    match(x$time_step, time_steps),
    match(x$variable, variables),
    match(x$resolution, resolutions),
    match(x$data_class, data_classes)
  )] <- x$has_stn_csv
  
  out
}

dput(make_stn_csv_matrix("data-raw/create_station_md_matrix/PRISM test matrix results (CSV).csv"))
