#' Download daily prism data
#' @description Download daily data from the prism project at 4km grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", "tmax", or "all",
#'        which downloads "ppt", "tmin", and "tmax". Note that tmean == mean(tmin, tmax).
#' @param minDate a valid iso-8601 (e.g. YYYY-MM-DD) date to start to download data.
#' @param maxDate  a valid iso-8601 (e.g. YYYY-MM-DD) date to end downloading data.
#' @param dates a vector of iso-8601 formatted dates to download data for, can also be a single date.
#' @param keepZip if true, leave the downloaded zip files in your 'prism.path', if FALSE, they will be deleted
#' @details Dates must be in the proper format or downloading will not work properly, you can either enter a date range via minDate and maxDate, or a vector of dates, but not both. You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)
#' @export
get_prism_dailys <- function(type, minDate = NULL, maxDate =  NULL, dates = NULL, keepZip = TRUE){
  prism:::path_check()
  if(!is.null(dates) && !is.null(maxDate)){
    stop("You can enter a date range or a vector of dates, but not both")
  }
  
  if(is.null(dates)){
    dates <- seq(as.Date(minDate),as.Date(maxDate),by="days")
  }
  
  ### parameter and error handling
  type <- match.arg(type, c("ppt", "tmean", "tmin", "tmax", "all"))
  if (type == "all") {
    get_prism_dailys(type = "ppt", minDate = NULL, maxDate = NULL, 
                     dates = dates, keepZip = keepZip)
    get_prism_dailys(type = "tmin", minDate = NULL, maxDate = NULL, 
                     dates = dates, keepZip = keepZip)
    get_prism_dailys(type = "tmax", minDate = NULL, maxDate = NULL, 
                     dates = dates, keepZip = keepZip)
  } else {
    download_pb <- txtProgressBar(min = 0, max = length(dates), style = 3)
    base <- "ftp://prism.nacse.org/daily"
    # If the requested dates fall in the last 6 months,
    # some may show as provisional. Since this takes time,
    # only want to do this if data is from the last 6 months.
    if (max(dates) > Sys.Date() - 190) {
      full_path_this <- paste(base, type, year(Sys.Date()), "", sep = "/")
      filenames_this <- getURL(full_path_this, ftp.use.epsv = FALSE, dirlistonly = TRUE)
      filenames_this <- strsplit(filenames_this, split = "\r\n")[[1]]
      
      full_path_last <- paste(base, type, year(Sys.Date()) - 1, "", sep = "/")
      filenames_last <- getURL(full_path_last, ftp.use.epsv = FALSE, dirlistonly = TRUE)
      # Stores all the filenames for this and last year
      filenames <- c(filenames_this, strsplit(filenames_last, split = "\r\n")[[1]])
    }
    for(i in 1:length(dates)){
      # parse date
      dstring <- strsplit(as.character(dates[i]), "-")[[1]]
      if(as.numeric(dstring[1]) < 1981) stop("You must ask for data after 1981")
      
      if(dates[i] > Sys.Date() - 190) {
        index <- grep(gsub("-", "", dates[i]), filenames)
        if (length(index) == 0) {
          # Handle dates that are unavailable
          warning(paste0("Data unavailable for type = ", type, " and date = ", dates[i]))
          next
        }
        fileName <- filenames[index]
      } else {
        fileName <- paste0("PRISM_", type, "_stable_4kmD1_", 
                           paste(dstring, collapse = ""), "_bil.zip")
      }
      
      full_path <- paste(base, type, year(dates[i]), sep = "/")
      if(length(prism:::prism_check(fileName)) == 1){
        outFile <- paste(options("prism.path"), fileName, sep = "/")
        tryNumber <- 1
        downloaded <- FALSE
        
        if (Sys.info()["sysname"] == "Windows") {
          current_net2_status <- setInternet2(NA)
          setInternet2(FALSE)
        }
        while(tryNumber < 11 & !downloaded){
          downloaded <- TRUE
          tryCatch(download.file(url = paste(full_path, fileName, sep = "/"), 
                                 destfile = outFile, mode = "wb", quiet = TRUE), 
                   error = function(e){
                     downloaded <<- FALSE
                   })
          tryNumber <- tryNumber + 1
        }   
        if (Sys.info()["sysname"] == "Windows") {
          setInternet2(current_net2_status)
        }
        
        if (!downloaded) {
          warning(paste0("Downloading failed for type = ", type, " and date = ", dates[i]))
        } else {
          unzip(outFile, exdir = strsplit(outFile, ".zip")[[1]])
          
          if(!keepZip){
            file.remove(outFile)
          }
        }
      }
      setTxtProgressBar(download_pb, i)
    }
    close(download_pb)
  }
}
