#' Check the integrity of downloaded PRISM data
#' 
#' `prism_archive_verify()` checks the data in the prism archive to ensure it 
#' is valid, or at least can be read into R, i.e., it is not corrupt. The 
#' prism variable type, time period, etc. is specified the same as for 
#' [prism_archive_subset()]. Any files that are not readable can automatically 
#' be re-downloaded.
#' 
#' Under the hood, it uses `raster::stack()` and then `raster::rasterToPoints()` 
#' to determine if the bil files are readable. If both those files are able 
#' to successfully read the files, they are assumed to be valid/readable.
#' 
#' @inheritParams prism_archive_subset
#' 
#' @param download_corrupt If `TRUE`, then any unreadable prism data are 
#'   automatically re-downloaded. 
#'   
#' @param keepZip If `TRUE`, leave the downloaded zip files in your 
#'   'prism.path', if `FALSE`, they will be deleted.
#'   
#' @return `prism_archive_verify()` returns `TRUE` if all data are readable. 
#'   Any prism data that are not readable are returned (folder names), whether
#'   they are re-downloaded or not.
#'   
#' @examples \dontrun{
#' # check all annual precipitation data from 2000-2023 are readable
#' # x will contain any corrupt files, or be TRUE if they are all readable
#' x <- prism_archive_verify('ppt', 'annual', 2000:2023)
#' }
#' 
#'   
#' @export
prism_archive_verify <- function(type, temp_period, years = NULL, mon = NULL, 
                                 minDate = NULL, maxDate = NULL, dates = NULL,
                                 download_corrupt = TRUE, keepZip = TRUE) {
  prism_check_dl_dir()
  
  pd <- prism_archive_subset(type, temp_period, years = years, mon = mon, 
                             minDate = minDate, maxDate = maxDate, 
                             dates = dates)
  
  # check every folder to ensure it is readable --------------------
  is_readable <- simplify2array(lapply(pd, function(pp) pd_is_readable(pp)))
  
  # redownload if not readable -----------------------
  dl_files <- pd[!is_readable]
  
  if (length(dl_files) > 0 && download_corrupt) {
    message("Re-downloading ", length(dl_files), " corrupt prism files.\n")
    dl_url <- folder_to_url(dl_files)
    
    mpb <- txtProgressBar(min = 0, max =length(dl_url), style = 3)
    
    for(i in seq_along(dl_url)){
      prism_webservice(dl_url[i], keepZip)
      setTxtProgressBar(mpb, i)
    }
    
    close(mpb)
  } else if (length(dl_files) == 0) {
    dl_files <- TRUE
  } 
  
  dl_files
}


#' @description `check_corrupt()` is the deprecated version of 
#' `prism_archive_verify()`
#'
#' @inheritParams get_prism_dailys
#'
#' @return `check_corrupt()` returns `logical` indicating whether the process 
#' succeeded.
#'
#' @export
#' @rdname prism_archive_verify
check_corrupt <- function(type, minDate = NULL, maxDate = NULL, dates = NULL) {
  .Deprecated("prism_archive_verify()")
  
  type <- match.arg(type, prism_vars())
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  folders_to_check <- prism_archive_subset(type, "daily", dates = dates)

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
        # the following catches issues with bil files that are readable but 
        # will not convert to good data
        # rr <- raster::rasterToPoints(my_stack)
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

pd_is_readable <- function(pd) {
  pf <- pd_to_file(pd)
  
  is_readable <- TRUE
  
  # first error check
  tryCatch(
    {
      my_stack <- raster::stack(pf)
    },
    error = function(e) is_readable <<- FALSE
  )
  
  # second error check
  if (is_readable) {
    tryCatch(
      rr <-  raster::rasterToPoints(my_stack),
      error = function(e) is_readable <<- FALSE
    )
  }
  
  is_readable
}

folder_to_url <- function(pd) {
  pd <- stringr::str_split(pd, "_", simplify = TRUE)
  
  pd_norm <- pd[pd[,3] == "30yr",,drop = FALSE]
  pd_other <- pd[pd[,3] != "30yr",,drop = FALSE]

  urls <- c()
  
  if (length(pd_other) > 0) {
    # daily, monthly, annual
    urls <- c(urls, paste0(
      "http://services.nacse.org/prism/data/public/4km/",
      pd_other[,2], "/", pd_other[,5]
    ))
  } 
  
  if (length(pd_norm) > 0) {
    # normals
    # if any are annual, change to "14"
    pd_norm[pd_norm[,6] == "annual",6] <- "14"
    
    # strip off "M2" from resolution
    pd_norm[,5] <- stringr::str_remove(pd_norm[,5], "M2")
    
    urls <- c(urls, paste0(
      "http://services.nacse.org/prism/data/public/normals/",
      pd_norm[,5], "/", pd_norm[,2], "/", pd_norm[,6]
    ))
  }
  
  urls
}
