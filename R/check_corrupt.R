#' @title Check the integrity of downloaded PRISM data
#' @description Uses the \code{raster::stack} function
#' to determine if the bil files are readable. Any that
#' are not readable are redownloaded.
#' @inheritParams get_prism_dailys
#' @return \code{logical} indicating whether the process 
#' succeeded.
check_corrupt <- function(type, minDate = NULL, maxDate =  NULL){
  minDate <- as.Date(minDate)
  maxDate <- as.Date(maxDate)
  
    prism_folders <- list.files(getOption("prism.path"))
    required_dates <- seq(minDate, maxDate, by = "days")
    
    type_folders <- grep(pattern = paste0("_", type, "_"), 
                         prism_folders, value = TRUE)
    # Use D2 for ppt
    if(type == "ppt"){
      type_folders <- grep(pattern = "4kmD2_", 
                           type_folders, value = TRUE)
    } else {
      type_folders <- grep(pattern = "4kmD1_", 
                           type_folders, value = TRUE)
    }
    # Don't want zips
    type_folders <- grep(pattern = ".zip", 
                         type_folders, value = TRUE, invert = TRUE)
    # Check for missing dates:
    type_folders_dates <- stringr::str_extract(type_folders, 
                                               "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")
    type_folders_dates <- as.Date(type_folders_dates, "%Y%m%d")
    dates_missing <- setdiff(required_dates, type_folders_dates)
    if(length(dates_missing) > 0){
      stop(paste0("PRISM-", type, " days missing for: ", paste(dates_missing, collapse = ", ")))
    }
    file_folders <- paste0(getOption("prism.path"), "/", type_folders)
    files_to_check <- paste0(file_folders, "/", type_folders, ".bil")
  
  file_names_tmp <- files_to_check
  file_names_tmp_old <- files_to_check
  it_worked <- FALSE
  try_number <- 1
  while(!it_worked & try_number <= 10){
    it_worked <- TRUE
    # Do not use quick = TRUE here as it won't check if the files are corrupted.
    tryCatch({
      my_stack <- raster::stack(file_names_tmp)
    }, error = function(e){
      message(e)
      it_worked <<- FALSE
      broken <- stringr::str_extract(as.character(e), "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")
      date_broken <- as.Date(broken, "%Y%m%d")
      # Remaining files to process
      file_names_tmp <<- file_names[1:length(file_names) >= which(type_folders_dates == date_broken)]
      unlink(grep(broken, file_folders, value = TRUE), recursive = TRUE)
      message(paste0("Redownloading PRISM file type = ", type, " and date = ", date_broken))
      prism::get_prism_dailys(type = type, dates = date_broken, keepZip = FALSE)
      if(identical(file_names_tmp_old, file_names_tmp)){
        try_number <<- try_number + 1
      }
      file_names_tmp_old <<- file_names_tmp
      if(length(file_names_tmp) == 0){
        it_worked <- TRUE
      }
    })
  }
  return(it_worked)
}
