#' Download prism data
#' 
#' Download grid cell data from the 
#' [prism project](https://prism.nacse.org/). Temperature (min, max, 
#' and mean), mean dewpoint temperature, precipitation, and vapor pressure 
#' deficit (min and max) can be downloaded for annual (`get_prism_annual()`), 
#' monthly (`get_prism_monthlys()`), daily (`get_prism_dailys()`), and 30-year
#' averages (`get_prism_normals()`). Data are available at 4km and 800m 
#' resolution for daily, monthly, and annual data. Normals can also be 
#' downloaded at 800m resolution.
#' 
#' @param type The type of data to download. Must be "ppt", "tmean", "tmin", 
#'   "tmax", "tdmean", "vpdmin", or "vpdmax". "solclear", "solslope", 
#'   "soltotal", and "soltrans" are also available only for 
#'   `get_prism_normals()`. Note that `tmean == mean(tmin, tmax)`.
#'   
#' @param years a valid numeric year, or vector of years, to download data for. 
#'   
#' @param keepZip if `TRUE`, leave the downloaded zip files in your 
#'   'prism.path', if `FALSE`, they will be deleted.
#'   
#' @param keep_pre81_months Deprecated
#'   
#' @param service Either `NULL` (default) or a URL provided by PRISM staff
#'   for subscription-based service. Example:
#'   "http://services.nacse.org/prism/data/subscription/800m". To use the
#'	 subscription option, you must use an IP address registered with PRISM
#'   staff. When `NULL`, the new PRISM web service endpoints are used based on 
#'   the specified resolution.
#'
#' @param resolution Character string specifying spatial resolution. One of 
#'   "4km" or "800m". Default is "4km". Note that "400m" resolution is planned 
#'   but not yet available from the PRISM web service.
#'
#' @details 
#' A valid download directory must exist before downloading any prism data. This
#' can be set using [prism_set_dl_dir()] and can be verified using 
#' [prism_check_dl_dir()].
#' 
#' @section Annual and Monthly:
#' 
#' Annual and monthly prism data are available from 1895 to present. For 
#' 1895-1980 data, monthly and annual data are grouped together in one download 
#' file; `keep_pre81_months` determines if the other months/yearly data are kept
#' after the download.  Data will be downloaded for all specified months (`mon`)
#' in all the `years` in the supplied vectors.
#' 
#' Data are available at two spatial resolutions: 4km (approximately 2.5 
#' arc-minutes) and 800m. The 4km resolution covers the entire CONUS and is 
#' suitable for most applications. The 800m resolution provides higher spatial 
#' detail but results in larger file sizes and longer download times.
#' 
#' @return Nothing is returned - an error will occur if download is not 
#'   successful.
#' 
#' @examples \dontrun{
#' # Get all annual average temperature data from 1990 to 2000 at default resolution
#' get_prism_annual(type = "tmean", years = 1990:2000, keepZip = FALSE)
#' 
#' # Get annual precipitation for multiple years at 800m resolution
#' get_prism_annual(
#'   type = "ppt", 
#'   years = 2020:2022, 
#'   resolution = "800m",
#'   keepZip = FALSE
#' )
#' 
#' # Get single year of annual temperature data at high resolution
#' get_prism_annual(
#'   type = "tmax",
#'   years = 2023,
#'   resolution = "800m",
#'   keepZip = TRUE
#' )
#' 
#' # will fail - invalid resolution:
#' get_prism_annual(
#'   type = "tmean",
#'   years = 2023,
#'   resolution = "1km",
#'   keepZip = FALSE
#' )
#' }
#' 
#' @rdname get_prism_data
#' 
#' @export
get_prism_annual <- function(type, years, keepZip = TRUE, 
                             keep_pre81_months = NULL, service = NULL,
                             resolution = "4km")
{
  ### parameter and error handling
  
  prism_check_dl_dir()
  type <- match.arg(type, prism_vars())
  
  ### Check year
  if(!is.numeric(years)){
    stop("You must enter a numeric year from 1895 onwards.")
  }
  
  if(any(years < 1895)){
    stop("You must enter a year from 1895 onwards.")
  }
  
  ### Check resolution
  if (is.null(resolution)) {
    stop("'resolution' must be '4km' or '800m'. See ?get_prism_annual for details.")
  }
  if (!resolution %in% c("4km", "800m")) {
    stop("'resolution' must be '4km' or '800m'. See ?get_prism_annual for details.")
  }
  
  if (!is.null(keep_pre81_months)) {
    warning('`keep_pre81_months` is deprecated and no longer has any effect. It will be removed in a future release.')
  }
  
  uris <- vector()
  
  uris <- gen_prism_url(years, type, resolution, service = service)

  download_pb <- txtProgressBar(
    min = 0,
    max = length(uris),
    style = 3
  )
  
  counter <- 0
  
  ### Handle all years
  if(length(uris) > 0){    
    
    for(i in seq_along(uris)) {
      prism_webservice(uris[i], keepZip)
      setTxtProgressBar(download_pb, i)
    }
  }
  
  counter <- length(uris) + 1
  
  close(download_pb)
}
