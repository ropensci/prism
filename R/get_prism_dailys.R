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
  path_check()
  freq <- "daily"
  if(!is.null(dates) && !is.null(maxDate)){
    stop("You can enter a date range or a vector of dates, but not both")
  }
  
  if(is.null(dates)){
    dates <- seq(as.Date(minDate),as.Date(maxDate),by="days")
  }
  
  if(as.Date(minDate) > as.Date(maxDate)){
    stop("Your minimum date must be less than your maximum date")
  }
  
  ## Get years
  years <- unique(format(dates,"%Y"))
  
  type <- match.arg(type, c("ppt", "tmean", "tmin", "tmax", "all"))
  if (type == "all") {
    get_prism_monthlys(type = "ppt", years = years, month = month, 
                       keepZip = keepZip)
    get_prism_monthlys(type = "tmin", years = years, month = month, 
                       keepZip = keepZip)
    get_prism_monthlys(type = "tmax", years = years, month = month, 
                       keepZip = keepZip)
  } else {
    
  
    

    counter <- 1
    base <- "ftp://prism.nacse.org/daily"
    
    for(i in 1:length(years)){
      #parse date
      full_path <- paste(base, type, years[i], sep = "/")
      
      if(years[i] > 1980) {
        
        fileName <- get_filenames(type,freq,years[i])
        ### subset the list of files down to the ones we want to download
        match_list <- gsub("-","",x = dates)
        
        fileName <- grep(paste(match_list,collapse="|"),fileName,value = TRUE)
        ### Check for existing file names  that are already downloaded
        fileName <- prism_check(fileName)

        if(length(fileName) >= 1){
          
          for(j in 1:length(fileName)) {
            outFile <- paste(options("prism.path"), fileName[j], sep="/")
            tryNumber <- 1
            downloaded <- FALSE
            
            if (Sys.info()["sysname"] == "Windows") {
              current_net2_status <- setInternet2(NA)
              setInternet2(FALSE)
            }
            while(tryNumber < 11 & !downloaded){
              downloaded <- TRUE
              tryCatch(
                download.file(url = paste(full_path, fileName[j], sep = "/"), 
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
              warning(paste0("Downloading failed for type = ", type, ", month = ", month[j],
                             ", and year = ", years[i]))
            } else {
              unzip(outFile, exdir = strsplit(outFile, ".zip")[[1]])
              if(!keepZip){
                file.remove(outFile)
              }
            }
            
            setTxtProgressBar(download_pb, counter)
            counter <- counter + 1
          }
        }
      } else {
        # Handle years before 1981.  
        # The whole years worth of data needs to be downloaded, 
        # then extracted, and copied into the main directory.
       cat("There is no daily data available pre-1981")
      }
      close(download_pb)
    }
  }
}


