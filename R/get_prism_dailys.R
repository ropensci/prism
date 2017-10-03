#' Download daily prism data
#' @description Download daily data from the prism project at 4km grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#'        Note that tmean == mean(tmin, tmax).
#' @param minDate a valid iso-8601 (e.g. YYYY-MM-DD) date to start downloading data. 
#' May be provided as either a character or \code{\link[base]{Date}} class.
#' @param maxDate  a valid iso-8601 (e.g. YYYY-MM-DD) date to end downloading data.
#' May be provided as either a character or \code{\link[base]{Date}} class.
#' @param dates a vector of iso-8601 formatted dates to download data for, can 
#' also be a single date. May be provided as either a character or 
#' \code{\link[base]{Date}} class.
#' @param keepZip if \code{TRUE}, leave the downloaded zip files in your 'prism.path', if \code{FALSE}, they will be deleted.
#' @param check One of "httr" or "internal". "httr", the default, checks the file name using the web
#' service, and downloads if that file name is not in the file system. "internal" (much faster) 
#' only attempts to download layers that are not already in the file system as stable. "internal"
#' should be used with caution as it is not robust to changes in version or file names.
#' @details Dates must be in the proper format or downloading will not work properly, you can either enter a date range via minDate and maxDate, or a vector of dates, but not both. You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")

#' @examples 
#' \dontrun{
#' # Valid calls:
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=FALSE)
#' get_prism_dailys(type="ppt", dates = "2013/06/01", keepZip=FALSE)
#' get_prism_dailys(type="tmean", dates = as.Date("2013-06-01", "2013-06-14", "2014-06-30"), keepZip=FALSE)
#' 
#' # will fail:
#' get_prism_dailys(type="ppt", minDate = "2013-06-01", dates = "2013-06-14", keepZip=FALSE)
#' get_prism_dailys(type="ppt", minDate = "2013-06-01", keepZip=FALSE)
#' }

#' @importFrom httr HEAD
#' @export
get_prism_dailys <- function(type, minDate = NULL, maxDate =  NULL, dates = NULL, keepZip = TRUE,
                             check = "httr"){
  path_check()
  check <- match.arg(check, c("httr", "internal"))
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)

  if( min(as.numeric(format(dates,"%Y"))) < 1981 ) { 
    stop("You must enter a date that is later than 1980")
  }
  
  ## Get years
  years <- unique(format(dates,"%Y"))
  
  type <- match.arg(type, c("ppt", "tmean", "tmin", "tmax"))
  
  uri_dates <- gsub(pattern = "-",replacement = "",dates)
  uris <- sapply(uri_dates,function(x){paste("http://services.nacse.org/prism/data/public/4km",type,x,sep="/")})
  
  if(check == "internal"){
    x <- httr::HEAD(uris[1])
    fn <- x$headers$`content-disposition`
    fn <- regmatches(fn,regexpr('\\"[a-zA-Z0-9_\\.]+',fn))
    fn <- substr(fn,2,nchar((fn)))
    fn <- gsub("provisional|early", "stable", fn)
    file_names <- sapply(uri_dates, function(x) gsub("[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]", x, fn))
    to_download_lgl <- prism_check(file_names, lgl = TRUE)
    uris <- uris[to_download_lgl]
  }
  download_pb <- txtProgressBar(min = 0, max = max(length(uris), 1), style = 3)
  
  if(length(uris) > 0){
    for(i in 1:length(uris)){
      prism_webservice(uri = uris[i],keepZip)
      setTxtProgressBar(download_pb, i)
    }
  } else {
    setTxtProgressBar(download_pb, max(length(uris), 1))
  }

  close(download_pb)
  
}



