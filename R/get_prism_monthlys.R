#' @param mon a valid numeric month, or vector of months. Required for 
#'   `get_prism_monthlys()`. Can be `NULL` for `get_prism_normals()`.
#'
#' @param resolution Character string specifying spatial resolution. One of 
#'   "4km" or "800m". Default is "4km". Note that "400m" resolution is planned 
#'   but not yet available from the PRISM web service.
#' 
#' @examples \dontrun{
#' # Get all the precipitation data for January from 1990 to 2000 at 4km resolution
#' get_prism_monthlys(type = "ppt", years = 1990:2000, mon = 1, keepZip = FALSE)
#' 
#' # Get January-December 2005 monthly precipitation at default resolution
#' get_prism_monthlys(type = "ppt", years = 2005, mon = 1:12, keepZip = FALSE)
#' 
#' # Get high-resolution monthly temperature data for summer months
#' get_prism_monthlys(
#'   type = "tmean", 
#'   years = 2023, 
#'   mon = 6:8, 
#'   resolution = "800m",
#'   keepZip = FALSE
#' )
#' 
#' # Get multiple years of winter precipitation at 800m resolution
#' get_prism_monthlys(
#'   type = "ppt",
#'   years = 2020:2022,
#'   mon = c(12, 1, 2),
#'   resolution = "800m",
#'   keepZip = TRUE
#' )
#' 
#' # will fail - invalid resolution:
#' get_prism_monthlys(
#'   type = "ppt",
#'   years = 2023,
#'   mon = 6,
#'   resolution = "1km",
#'   keepZip = FALSE
#' )
#' }
#' 
#' @rdname get_prism_data
#' 
#' @export
get_prism_monthlys <- function(type, years, mon = 1:12, keepZip = TRUE,
                               keep_pre81_months = NULL, service = NULL, 
                               resolution = "4km")
{
  ### parameter and error handling
  prism_check_dl_dir()
  type <- match.arg(type, prism_vars())
 
  ### Check mon
  if(!is.numeric(mon)) {
    stop("You must enter a numeric month between 1 and 12")
  }
  
  if(any(mon < 1 | mon > 12)) {
    stop("You must enter a month between 1 and 12")
  }
  
  ### Check year
  if(!is.numeric(years)){
    stop("You must enter a numeric year from 1895 onwards.")
  }
  
  if(any(years < 1895)){
    stop("You must enter a year from 1895 onwards.")
  }
  
  ### Check resolution
  if (is.null(resolution)) {
    stop("'resolution' must be '4km' or '800m'. See ?get_prism_monthlys for details.")
  }
  if (!resolution %in% c("4km", "800m")) {
    stop("'resolution' must be '4km' or '800m'. See ?get_prism_monthlys for details.")
  }
  
  if (!is.null(keep_pre81_months)) {
    warning('`keep_pre81_months` is deprecated and no longer has any effect. It will be removed in a future release.')
  }
  
  uris <- vector()
  
  if (is.null(service)) {
	  service <- "http://services.nacse.org/prism/data/public/4km"
  }

  if (length(years)) {
    uri_dates <- apply(
      expand.grid(years, mon_to_string(mon)),
      1,
      function(x) {paste(x[1], x[2], sep="")}
    )

    # uris_post81 <- gen_prism_url(uri_dates_post81, type, service)
    uris <- gen_prism_url(uri_dates, type, resolution)
  }
    
  download_pb <- txtProgressBar(
    min = 0,
    max = length(uris),
    style = 3
  )

  ### Handle all data
  if(length(uris) > 0){    
      for(i in seq_along(uris)){
        prism_webservice(uris[i],keepZip)
        setTxtProgressBar(download_pb, i)
    }
  }
 
  close(download_pb)
}
