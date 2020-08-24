#' Check the integrity of downloaded PRISM data
#'
#' Uses the `raster::stack` function to determine if the bil files are readable.
#' Any that are not readable are redownloaded.
#'
#' @inheritParams get_prism_dailys
#'
#' @return \code{logical} indicating whether the process succeeded.
#'
#' @export
check_corrupt <- function(type, minDate = NULL, maxDate = NULL, dates = NULL) {
  type <- match.arg(type, prism_vars())
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  folders_to_check <- prism_data_subset(type, "daily", dates)

  # Check for missing dates:
  folders_dates <- stringr::str_extract(folders_to_check, "[0-9]{8}")
  folders_dates <- as.Date(folders_dates, "%Y%m%d")
  dates_missing <- as.Date(setdiff(dates, folders_dates), origin = "1970-01-01")
  if (length(dates_missing) > 0) {
    stop(
      paste0("PRISM-", type, " days missing for: ", 
            paste(dates_missing, collapse = ", "))
    )
  }
  file_folders <- paste0(prism_get_dl_dir(), "/", folders_to_check)
  files_to_check <- file.path(file_folders, paste0(folders_to_check, ".bil"))

  files_to_check_tmp <- files_to_check
  files_to_check_tmp_old <- files_to_check
  it_worked <- FALSE
  try_number <- 1
  while (!it_worked & try_number <= 10) {
    it_worked <- TRUE
    # Do not use quick = TRUE here as it won't check if the files are corrupted.
    tryCatch(
      {
        my_stack <- raster::stack(files_to_check_tmp)
      },
      error = function(e) {
        message(e)
        it_worked <<- FALSE
        broken <- stringr::str_extract(
          as.character(e), 
          "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
        )
        date_broken <- as.Date(broken, "%Y%m%d")
        # Remaining files to process
        file_i <- seq_len(files_to_check) >= which(folders_dates == date_broken)
        files_to_check_tmp <<- files_to_check[file_i]
        unlink(grep(broken, file_folders, value = TRUE), recursive = TRUE)
        message(
          "Redownloading PRISM file type = ", type, " and date = ", date_broken
        )
        
        prism::get_prism_dailys(
          type = type, 
          dates = date_broken, 
          keepZip = FALSE
        )
        
        if (identical(files_to_check_tmp_old, files_to_check_tmp)) {
          try_number <<- try_number + 1
        }
        files_to_check_tmp_old <<- files_to_check_tmp
        if (length(files_to_check_tmp) == 0) {
          it_worked <- TRUE
        }
      }
    )
  }
  return(it_worked)
}
