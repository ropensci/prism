
#' helper function for handling months
#' @description Handle numeric month to string conversions
#' @param month a numeric vector of months (month must be > 0 and <= 12)
#' @return a character vector (same length as \code{month}) with 2 char month 
#'   strings.
#' @examples \dontrun{
#'   mon_to_string(month = c(1, 3, 2))
#'   mon_to_string(month = 12)
#' }
#' @noRd
mon_to_string <- function(month)
{
  out <- vector()
  for(i in seq_along(month)){
    if(month[i] < 1 || month[i] > 12) {
      stop("Please enter a valid numeric month")
    }
    if(month[i] < 10){ out[i] <- paste("0",month[i],sep="")}
    else { out[i] <- paste0(month[i]) }
  }
  return(out)
}

prism_not_downloaded <- function(zipfiles, lgl = FALSE)
{
  file_bases <- stringr::str_remove(zipfiles, '.zip')
  which_downloaded <- vapply(
    file_bases, 
    find_prism_file, 
    FUN.VALUE = logical(1)
  )
  
  if(lgl){
    return(!which_downloaded)
  } else {
    return(zipfiles[!which_downloaded])    
  }
}

#' Generate PRISM v2 Web Service URLs
#'
#' Creates URLs for the new PRISM web service API (v2) that replaced the old
#' public data service. This function generates URLs compatible with the current
#' PRISM web service endpoint structure.
#'
#' @param dates Character vector of dates in YYYYMMDD format (no hyphens)
#' @param type Character string specifying the climate variable. One of:
#'   "ppt" (precipitation), "tmin" (minimum temperature), "tmax" (maximum 
#'   temperature), "tmean" (mean temperature), "tdmean" (mean dewpoint), 
#'   "vpdmin" (minimum vapor pressure deficit), "vpdmax" (maximum vapor pressure 
#'   deficit)
#' @param resolution Character string specifying spatial resolution. One of:
#'    "800m", "4km". Default is "4km". Note: 400m not yet implemented by PRISM.
#' @param region Character string specifying the geographic region. One of:
#'   "us" (CONUS), "ak" (Alaska), "hi" (Hawaii), "pr" (Puerto Rico).
#'   Default is "us". Note: Only CONUS currently available.
#' @param format Optional character string specifying output format: "geotiff"
#'   (Cloud Optimized GeoTIFF), "bil" (BIL format), or "nc" (netCDF). Defaults
#'   to `prism_get_format()`, which is BIL unless changed by the user.
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
#' For long-term (LT) datasets, "/lt" is appended to the URL before any format 
#' options. Format options are appended as query parameters 
#' (e.g., "?format=nc").
#'
#' @examples
#' \dontrun{
#' # Generate URLs for daily temperature data
#' dates <- c("20130601", "20130602", "20130603")
#' urls <- gen_prism_url(dates, "tmean")
#'
#' # Generate URLs with specific resolution and format
#' urls <- gen_prism_url(dates, "ppt", resolution = "800m", format = "nc")
#'
#' # Generate URLs for long-term monthly data
#' monthly_dates <- c("201306", "201307")
#' urls <- gen_prism_url(
#'   monthly_dates, "tmax", resolution = "800m", dataset_type = "lt"
#' )
#' }
#'
#' @seealso \code{\link{get_prism_dailys}} for downloading daily PRISM data
#'
#' @noRd
gen_prism_url <- function(dates, type, resolution = "4km", region = "us",
                          format = prism_get_format(), dataset_type = "an",
                          service = NULL) {
  
  # Input validation
  if (missing(dates) || missing(type)) {
    stop("Both 'dates' and 'type' arguments are required")
  }
  
  # Validate date format: YYYY/YYYYMM/YYYYMMDD (time-series) or MM/MMDD (normals)
  if (!all(grepl("^(\\d{4}(\\d{2}(\\d{2})?)?|\\d{2}(\\d{2})?)$", dates))) {
    stop("Dates must be in YYYYMMDD (daily), YYYYMM (monthly), YYYY (annual), MM (monthly normals), or MMDD (daily normals) format")
  }
  
  # Validate resolution
  valid_resolutions <- c( "800m", "4km")
  if (!resolution %in% valid_resolutions) {
    stop(
      "'resolution' must be one of: ", 
        paste(valid_resolutions, collapse = ", ")
    )
  }
  
  # Validate region
  valid_regions <- c("us", "ak", "hi", "pr")
  if (!region %in% valid_regions) {
    stop("'region' must be one of: ", paste(valid_regions, collapse = ", "))
  }
  
  # Validate format
  if (!format %in% prism_formats) {
    stop("'format' must be one of: ", paste(prism_formats, collapse = ", "))
  }
  
  # Validate dataset type
  valid_dataset_types <- c("an", "lt")
  if (!dataset_type %in% valid_dataset_types) {
    stop(
      "'dataset_type' must be one of: ", 
      paste(valid_dataset_types, collapse = ", ")
    )
  }
  
  # Warn about unimplemented features
  if (resolution == "400m") {
    warning("400m resolution is not yet implemented by PRISM web service")
  }
  
  if (region != "us") {
    warning("Only CONUS ('us') region is currently available. Other regions not yet implemented.")
  }
  
  base_url <- if (is.null(service)) {
    "https://services.nacse.org/prism/data/get"
  } else {
    service
  }

  urls <- paste(base_url, region, resolution, type, dates, sep = "/")

  if (dataset_type == "lt") {
    urls <- paste0(urls, "/lt")
  }

  if (format != "geotiff") {
    urls <- paste0(urls, "?format=", format)
  }

  urls
}

#' Generate URLs for 30-year PRISM normals
#' @noRd
gen_prism_normals_url <- function(dates, type, resolution = "4km", region = "us") {
  if (missing(dates) || missing(type)) {
    stop("Both 'dates' and 'type' arguments are required")
  }

  valid_resolutions <- c("800m", "4km")
  if (!resolution %in% valid_resolutions) {
    stop("'resolution' must be one of: ", paste(valid_resolutions, collapse = ", "))
  }

  base_url <- "https://data.prism.oregonstate.edu/normals"
  rmap <- c("4km" = "25m", "800m" = "30s")

  vapply(dates, function(date) {
    time_scale <- if (nchar(date) == 2) "monthly" else "daily"
    date_str <- if (identical(date, "14")) "" else date

    filename <- paste(
      "prism", type, region, rmap[[resolution]],
      paste0("2020", date_str), "avg", "30y.zip",
      sep = "_"
    )

    paste(base_url, region, resolution, type, time_scale, filename, sep = "/")
  }, character(1), USE.NAMES = FALSE)
}

# return TRUE if all file(s) are found for the specified base_file
find_prism_file <- function(base_file)
{
  # Look inside the folder for the selected output format.
  # Won't be able to check for all other files. Unlikely to matter.
  ext <- prism_format_file_ext()
  pattern <- paste0("^", base_file, gsub("\\.", "\\\\.", ext), "$")
  ls_folder <- list.files(
    prism_get_dl_dir(), pattern = pattern, recursive = TRUE
  )
  
  length(ls_folder) > 0
}

#' Checks to see if the dates (days) specified are within the available Prism 
#' record
#' 
#' Prism daily record begins January 1, 1895, and assumes that it ends 
#' yesterday, i.e., \code{Sys.Date() - 1}.
#' 
#' @param dates a vector of dates (class Date)
#' 
#' @return \code{TRUE} if all values in \code{dates} are within the available 
#' Prism record. Otherwise, returns \code{FALSE}
#' 
#' @keywords internal
#' 
#' @noRd
is_within_daily_range <- function(dates)
{
  # day the record starts
  minDay <- as.Date("1895-01-01") # need to verify
  # assume data has posted for yesterday
  #** may want to enhance this computation to see if it works for people using
  # this in other time zones. Probably not critical since it will eventually 
  # throw an error on downloading, but this will help catch it earlier
  maxDay <- Sys.Date() - 1 # also need to verify this is accurate 
  
  # all dates need to be within range
  all(dates <= maxDay & dates >= minDay)
}

#' Processes dates as this appears many times
#' 
#' Given either a vector of \code{dates} or a \code{minDate} and 
#' \code{maxDate}, return a vector of class Date. 
#' 
#' @inheritParams get_prism_dailys
#' @return Vector of dates
#' 
#' @noRd

gen_dates <- function(minDate, maxDate, dates){
  if(all(is.null(dates), is.null(minDate), is.null(maxDate)))
    stop("You must specify either a date range (minDate and maxDate) or a vector of dates")
  
  if((!is.null(dates) && !is.null(maxDate)) | 
     (!is.null(dates) && !is.null(minDate))) {
    stop("You can enter a date range or a vector of dates, but not both")
  }
  
  if((!is.null(maxDate) & is.null(minDate)) | 
     (!is.null(minDate) & is.null(maxDate))) {
    stop(
      "Both minDate and maxDate must be specified if specifying a date range"
    )
  }
  
  if(!is.null(dates)){
    # make sure it is cast as a date if it was provided as a character
    dates <- as.Date(dates)
    
    if(!is_within_daily_range(dates))
      stop("Please ensure all dates fall within the valid Prism data record")
  }
  
  if(is.null(dates)){
    minDate <- as.Date(minDate)
    maxDate <- as.Date(maxDate)
    
    if(minDate > maxDate){
      stop("Your minimum date must be less than your maximum date")
    }
    
    if(!is_within_daily_range(c(minDate, maxDate)))
      stop("Please ensure minDate and maxData are within the available Prism data record")
    
    dates <- seq(minDate, maxDate, by="days")
  }
  dates
}

# --------------- extract_version Roxygen tags
# Get the resolution text string
# @description To account for the ever changing name structure, here we will 
#   scrape the HTTP directory listing and grab it instead of relying on hard 
#   coded strings that need changing
# @param type the type of data you're downloading, should be tmax, tmin etc...
# @param temporal The temporal resolution of the data, monthly, daily, etc...
# @param yr the year of data that's being requested, in numeric form
#extract_version <- function(type, temporal, yr){
#  base <- paste0("ftp://prism.nacse.org/", temporal, "/", type, "/", yr, "/")
##  dirlist <- RCurl::getURL(base, ftp.use.epsv = FALSE, dirlistonly = TRUE)
#  # Get the first split and take the last element
#  sp1 <- unlist(strsplit(dirlist, "PRISM_"))
#  sp2 <- unlist(strsplit(sp1[length(sp1)], "zip"))[1]
# Now we have an exemplar listing
#  sp1 <- unlist(strsplit(sp2, "stable_"))[2]
#  sp2 <- unlist(strsplit(sp1, "_[0-9]{4,8}"))
#  return(sp2[1])
#}

#' Returns the available prism variables.
#' @noRd
prism_vars <- function(normals = FALSE)
{
  x <- c("ppt", "tmean", "tmin", "tmax", "vpdmin", "vpdmax", "tdmean",
         "solslope", "soltotal")
  
  if (isTRUE(normals)) {
    x <- c(x, "solclear", "soltrans")
  }
  
  x
}

# maps prism variables and names
prism_var_names <- function(normals = FALSE) {
  x <- c("Precipitation", "Mean temperature", "Minimum temperature", 
         "Maximum temperature", "Minimum vapor pressure deficit",
         "Maximum vapor pressure deficit", "Mean dew point temperature",
         "Solar radiation (sloped)", "Solar radiation (total)")
  
  if (isTRUE(normals)) {
    x <- c(x, "Solar radiation (clear sky)", "Cloud transmittance")
  }
  
  names(x) <- prism_vars(normals = normals)

  x
}
