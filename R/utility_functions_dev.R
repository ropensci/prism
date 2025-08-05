#' Generate PRISM v2 Web Service URLs
#'
#' Creates URLs for the new PRISM web service API (v2) that replaced the old
#' public data service. This function generates URLs compatible with the current
#' PRISM web service endpoint structure.
#'
#' @param dates Character vector of dates in YYYYMMDD format (no hyphens)
#' @param type Character string specifying the climate variable. One of:
#'   "ppt" (precipitation), "tmin" (minimum temperature), "tmax" (maximum temperature),
#'   "tmean" (mean temperature), "tdmean" (mean dewpoint), "vpdmin" (minimum vapor pressure deficit),
#'   "vpdmax" (maximum vapor pressure deficit)
#' @param resolution Character string specifying spatial resolution. One of:
#'   "800m", "4km". 
#'   Default is "4km". Note: 400m not yet implemented by PRISM so
#'   we do not include it as a valid option.
#' @param region Character string specifying the geographic region. One of:
#'   "us" (CONUS).
#'   Default is "us". Note: Only CONUS currently available. , "ak" (Alaska), 
#'   "hi" (Hawaii), "pr" (Puerto Rico) have not yet been added to web services.
#' @param format Optional character string specifying output format. One of:
#'   "nc" (netCDF), "asc" (ASCII Grid), "bil" (BIL format). If NULL (default),
#'   returns BIL format.
#' @param dataset_type Character string specifying dataset type. One of:
#'   "an" (all networks, default) or "lt" (long-term networks). Only applies
#'   to monthly 800m data.
#'
#' @return Character vector of URLs for the PRISM v2 web service
#'
#' @details
#' This function generates URLs following the new PRISM web service syntax:
#' https://services.nacse.org/prism/data/get/<region>/<resolution>/<element>/<date>
#'
#' The function performs input validation to ensure:
#' \itemize{
#'   \item Dates are in proper YYYYMMDD format (8 digits)
#'   \item Climate variables are supported
#'   \item Resolution and region combinations are valid
#' }
#'
#' For long-term (LT) datasets, "/lt" is appended to the URL before any format options.
#' Format options are appended as query parameters (e.g., "?format=nc").
#'
#' @examples
#' # Generate URLs for daily temperature data
#' dates <- c("20130601", "20130602", "20130603")
#' urls <- gen_prism_url_v2(dates, "tmean")
#'
#' # Generate URLs with specific resolution and format
#' urls <- gen_prism_url_v2(dates, "ppt", resolution = "800m", format = "nc")
#'
#' # Generate URLs for long-term monthly data
#' monthly_dates <- c("201306", "201307")
#' urls <- gen_prism_url_v2(monthly_dates, "tmax", resolution = "800m", dataset_type = "lt")
#' }
#'
#' @noRd
gen_prism_url_v2 <- function(dates, 
                             type, 
                             resolution = "4km", 
                             region = "us", 
                             format = "bil", 
                             dataset_type = "an") {
  
 
  
  # Validate resolution
  valid_resolutions <- c("800m", "4km")
  if (!resolution %in% valid_resolutions) {
    stop("'resolution' must be one of: ", paste(valid_resolutions, collapse = ", "))
  }
  
  # Validate region
  valid_regions <- c("us")
  if (!region %in% valid_regions) {
    stop("'region' must be one of: ", paste(valid_regions, collapse = ", "))
  }
  
  # Validate format
  if (!is.null(format)) {
    valid_formats <- c("nc", "asc", "bil")
    if (!format %in% valid_formats) {
      stop("'format' must be one of: ", paste(valid_formats, collapse = ", "))
    }
  }
  
  # Validate dataset type
  valid_dataset_types <- c("an", "lt")
  if (!dataset_type %in% valid_dataset_types) {
    stop("'dataset_type' must be one of: ", paste(valid_dataset_types, collapse = ", "))
  }
  
  # Warn about unimplemented features
  if (resolution == "400m") {
    warning("400m resolution is not yet implemented by PRISM web service")
  }
  
  if (region != "us") {
    warning("Only CONUS ('us') region is currently available. Other regions not yet implemented.")
  }
  
  # Base URL structure
  base_url <- "https://services.nacse.org/prism/data/get"
  
  # Generate URLs for each date
  urls <- paste(base_url, region, resolution, type, dates, sep = "/")
  
  # Add dataset type if LT (long-term)
  if (dataset_type == "lt") {
    urls <- paste0(urls, "/lt")
  }
  
  # Add format parameter (defaults to BIL)
  if (!is.null(format)) {
    urls <- paste0(urls, "?format=", format)
  }
  
  return(urls)
}