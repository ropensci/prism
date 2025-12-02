#' @param minDate Date to start downloading daily data. Must be specified in 
#'   a valid iso-8601 (e.g. YYYY-MM-DD) format. May be provided as either a 
#'   character or [base::Date] class.
#'   
#' @param maxDate Date to end downloading daily data.  Must be specified in 
#'   a valid iso-8601 (e.g. YYYY-MM-DD) format. May be provided as either a 
#'   character or [base::Date] class.
#' 
#' @param dates A vector of dates to download daily data. Must be specified in 
#'   a valid iso-8601 (e.g. YYYY-MM-DD) format. May be provided as either a 
#'   character or [base::Date] class.
#'
#' @param resolution Character string specifying spatial resolution. One of 
#'   "4km" or "800m". Default is "4km". Note that "400m" resolution is planned 
#'   but not yet available from the PRISM web service.
#' 
#' @section Daily:
#' 
#' Daily prism data are available beginning on January 1, 1981. To download the 
#' daily data, dates must be in the proper format or downloading will not work 
#' properly. Dates can be specified using either a date range via `minDate` and 
#' `maxDate`, or a vector of `dates`, but not both. 
#' 
#' Data are available at two spatial resolutions: 4km (approximately 2.5 
#' arc-minutes) and 800m. The 4km resolution covers the entire CONUS and is 
#' suitable for most applications. The 800m resolution provides higher spatial 
#' detail but results in larger file sizes and longer download times.
#'
#' @examples 
#' \dontrun{
#' # get daily average temperature data for June 1 - 14, 2013 at 4km resolution
#' get_prism_dailys(
#'   type = "tmean", 
#'   minDate = "2013-06-01", 
#'   maxDate = "2013-06-14", 
#'   keepZip = FALSE
#' )
#' 
#' # get precipitation data for June 1, 2013 at 800m resolution
#' get_prism_dailys(
#'   type = "ppt", 
#'   dates = "2013/06/01", 
#'   resolution = "800m",
#'   keepZip = FALSE
#' )
#' 
#' # get average temperature for three specific days at default resolution
#' get_prism_dailys(
#'   type = "tmean", 
#'   dates = c("2013-06-01", "2013-06-14", "2014-06-30"), 
#'   keepZip = FALSE
#' )
#' 
#' # get high-resolution daily maximum temperature for a date range
#' get_prism_dailys(
#'   type = "tmax",
#'   minDate = "2013-06-01",
#'   maxDate = "2013-06-07", 
#'   resolution = "800m",
#'   keepZip = FALSE
#' )
#' 
#' # will fail - both minDate and dates specified:
#' get_prism_dailys(
#'   type = "ppt", 
#'   minDate = "2013-06-01", 
#'   dates = "2013-06-14", 
#'   keepZip = FALSE
#' )
#' 
#' # will fail - minDate without maxDate:
#' get_prism_dailys(
#'   type = "ppt", 
#'   minDate = "2013-06-01", 
#'   keepZip = FALSE
#' )
#' 
#' # will fail - invalid resolution:
#' get_prism_dailys(
#'   type = "tmean",
#'   dates = "2013-06-01",
#'   resolution = "1km",
#'   keepZip = FALSE
#' )
#' }
#'
#' @rdname get_prism_data
#'
#' @export
get_prism_dailys <- function(type, minDate = NULL, maxDate =  NULL, 
                             dates = NULL, keepZip = TRUE, 
                             service = NULL, resolution = "4km")
{
  prism_check_dl_dir()

  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)

  if( min(as.numeric(format(dates,"%Y"))) < 1981 ) { 
    stop("You must enter a date that is on or after Januyar 1, 1981.")
  }
  
  ### Check resolution
  if (is.null(resolution)) {
    stop("'resolution' must be '4km' or '800m'. See ?get_prism_monthlys for details.")
  }
  if (!resolution %in% c("4km", "800m")) {
    stop("'resolution' must be '4km' or '800m'. See ?get_prism_dailys for details.")
  }
  
  ## Get years
  years <- unique(format(dates,"%Y"))
  
  type <- match.arg(type, prism_vars())

  uri_dates <- gsub(pattern = "-",replacement = "",dates)
  uris <- gen_prism_url(uri_dates, type, resolution, service = service)
  
  download_pb <- txtProgressBar(min = 0, max = max(length(uris), 1), style = 3)
  
  if(length(uris) > 0){
    for(i in seq_along(uris)){
      prism_webservice(uri = uris[i],keepZip)
      setTxtProgressBar(download_pb, i)
    }
  } else {
    setTxtProgressBar(download_pb, max(length(uris), 1))
  }

  close(download_pb)
}



