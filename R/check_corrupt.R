#' @title Check the integrity of downloaded PRISM data
#' @description Uses the \code{raster::stack} function
#' to determine if the bil files are readable. Any that
#' are not readable are redownloaded.
#' @inheritParams get_prism_dailys
#' @return \code{logical} indicating whether the process 
#' succeeded.
#' @export
#' @importFrom magrittr %>%
check_corrupt <- function(type, minDate = NULL, maxDate = NULL, dates = NULL){
    dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
    folders_to_check <- subset_prism_folders(type, dates)
     
    # Check for missing dates:
    folders_dates <- stringr::str_extract(folders_to_check, 
                                               "[0-9]{8}")
    folders_dates <- as.Date(folders_dates, "%Y%m%d")
    dates_missing <- as.Date(setdiff(dates, folders_dates), origin = "1970-01-01")
    if(length(dates_missing) > 0){
      stop(paste0("PRISM-", type, " days missing for: ", paste(dates_missing, collapse = ", ")))
    }
    file_folders <- paste0(getOption("prism.path"), "/", folders_to_check)
  files_to_check <- paste0(file_folders, "/", folders_to_check, ".bil")
  
  files_to_check_tmp <- files_to_check
  files_to_check_tmp_old <- files_to_check
  it_worked <- FALSE
  try_number <- 1
  while(!it_worked & try_number <= 10){
    it_worked <- TRUE
    # Do not use quick = TRUE here as it won't check if the files are corrupted.
    tryCatch({
      my_stack <- raster::stack(files_to_check_tmp)
    }, error = function(e){
      message(e)
      it_worked <<- FALSE
      broken <- stringr::str_extract(as.character(e), "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")
      date_broken <- as.Date(broken, "%Y%m%d")
      # Remaining files to process
      files_to_check_tmp <<- files_to_check[1:length(files_to_check) >= which(folders_dates == date_broken)]
      unlink(grep(broken, file_folders, value = TRUE), recursive = TRUE)
      message(paste0("Redownloading PRISM file type = ", type, " and date = ", date_broken))
      prism::get_prism_dailys(type = type, dates = date_broken, keepZip = FALSE)
      if(identical(files_to_check_tmp_old, files_to_check_tmp)){
        try_number <<- try_number + 1
      }
      files_to_check_tmp_old <<- files_to_check_tmp
      if(length(files_to_check_tmp) == 0){
        it_worked <- TRUE
      }
    })
  }
  return(it_worked)
}
