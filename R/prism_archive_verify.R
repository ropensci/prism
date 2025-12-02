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
      prism_webservice(dl_url[i], keepZip)
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
    web_service_version <- ifelse(grepl("PRISM", folder), "v1", "v2")
    
    if (web_service_version == "v1") {
      # Parse webservice v1 folder names
      parts <- stringr::str_split(folder, "_", simplify = TRUE)
      
      if (parts[3] == "30yr") {
        # Normals - use FTP service
        var_type <- parts[2]
        resolution_part <- stringr::str_remove(parts[5], "M[0-9]")
        time_part <- parts[6]
        
        # Convert annual to "14" for normals
        if (time_part == "annual") {
          time_part <- "14"
        }
        
        urls <- c(urls, gen_prism_url(time_part, var_type, resolution, 
                                      service = "ftp_v2_normals_bil"))
      } else {
        # Non-normals - use webservice v2
        var_type <- parts[2]
        date_part <- parts[5]
        
        urls <- c(urls, gen_prism_url(date_part, var_type, resolution))
      }
    } else {
      # Parse webservice v2 folder names
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
      
      if (grepl('avg', folder)) {
        service_part <- 'ftp_v2_normals_bil'
        date_part <- substring(date_part, 5) 
      }
      else(
        service_part <- 'web_service_v2'
      )
      
      urls <- c(
        urls, 
        gen_prism_url(
          date_part, 
          var_type, 
          file_resolution, 
          ts_service = service_part
      ))
    }
  }
  
  urls
}