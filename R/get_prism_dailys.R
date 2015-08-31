#' Download daily prism data
#' @description Download daily data from the prism project at 4km grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", "tmax",
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
  if(!is.null(dates) && !is.null(maxDate)){
    stop("You can enter a date range or a vector of dates, but not both")
  }
  
  if(is.null(dates)){
    dates <- seq(as.Date(minDate),as.Date(maxDate),by="days")
    
    if(as.Date(minDate) > as.Date(maxDate)){
      stop("Your minimum date must be less than your maximum date")
    }
  }
  
  if( min(as.numeric(format(dates,"%Y"))) < 1981 ) { 
      stop("You must enter a date that is later than 1980")
    }
  
  ## Get years
  years <- unique(format(dates,"%Y"))
  
  type <- match.arg(type, c("ppt", "tmean", "tmin", "tmax", "all"))
  
  uri_dates <- gsub(pattern = "-",replacement = "",dates)
  uris <- sapply(uri_dates,function(x){paste("http://services.nacse.org/prism/data/public/4km",type,x,sep="/")})
  
  download_pb <- txtProgressBar(min = 0, max = length(uris) , style = 3)
  
    for(i in 1:length(uris)){
            prism_webservice(uris[i],keepZip)
            setTxtProgressBar(download_pb, i)

    }
  close(download_pb)
  
  }



