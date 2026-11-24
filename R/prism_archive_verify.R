#' Check the integrity of downloaded PRISM data
#' 
#' `prism_archive_verify()` checks the data in the prism archive to ensure it 
#' is valid, or at least can be read into R, i.e., it is not corrupt. The 
#' prism variable type, time period, etc. is specified the same as for 
#' [prism_archive_subset()]. Any files that are not readable can automatically 
#' be re-downloaded.
#' 
#' Under the hood, it uses `terra::rast()` to determine if the PRISM data files 
#' are readable. If both those files are able to successfully read the files, 
#' they are assumed to be valid/readable.
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
#' x <- prism_archive_verify('ppt', 'annual', 2000:2023, resolution = "4km")
#' }
#' 
#'   
#' @export
prism_archive_verify <- function(type, temp_period, years = NULL, mon = NULL, 
                                 minDate = NULL, maxDate = NULL, dates = NULL,
                                 resolution = NULL, download_corrupt = TRUE, 
                                 keepZip = TRUE) {
  prism_check_dl_dir()
  
  pd <- prism_archive_subset(type, temp_period, years = years, mon = mon, 
                             minDate = minDate, maxDate = maxDate, 
                             dates = dates, resolution = resolution)
  
  # check every folder to ensure it is readable --------------------
  is_readable <- simplify2array(lapply(pd, function(pp) pd_is_readable(pp)))
  
  # redownload if not readable -----------------------
  dl_files <- pd[!is_readable]
  
  if (length(dl_files) > 0 && download_corrupt) {
    message("Re-downloading ", length(dl_files), " corrupt prism files.\n")
    dl_url <- folder_to_url(dl_files, resolution)
    
    mpb <- txtProgressBar(min = 0, max =length(dl_url), style = 3)
    
    for(i in seq_along(dl_url)){
      prism_webservice(
        dl_url[i],
        keepZip = keepZip,
        normals = grepl("avg_30y", dl_files[i])
      )
      setTxtProgressBar(mpb, i)
    }
    
    close(mpb)
  } else if (length(dl_files) == 0) {
    dl_files <- TRUE
  } 
  
  dl_files
}

pd_is_readable <- function(pd) {
  pf <- pd_to_file(pd)
  
  is_readable <- TRUE
  
  tryCatch({
    x <- terra::rast(pf)
    terra::as.data.frame(x, xy = TRUE)
  }, error = function(e) is_readable <<- FALSE)
  
  is_readable
}

folder_to_url <- function(pd, resolution = "4km") {
  urls <- c()
  
  for (i in seq_along(pd)) {
    folder <- pd[i]
    parts <- stringr::str_split(folder, "_", simplify = TRUE)
      var_type <- parts[2]
      date_part <- parts[5]
      
      # Detect resolution from filename
      if (grepl("30s", folder)) {
        file_resolution <- "800m"
      } else if (grepl("25m", folder)) {
        file_resolution <- "4km"
      } else {
        file_resolution <- resolution  # fallback to provided resolution
      }
      
      if (grepl("avg", folder)) {
        date_part <- substring(date_part, 5)
        if (identical(date_part, "")) date_part <- "14"
        urls <- c(urls, gen_prism_normals_url(date_part, var_type, file_resolution))
      } else {
        urls <- c(urls, gen_prism_url(date_part, var_type, file_resolution))
      }
  }
  
  urls
}