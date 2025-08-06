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
#'    "800m", "4km". Default is "4km". Note: 400m not yet implemented by PRISM.
#' @param region Character string specifying the geographic region. One of:
#'   "us" (CONUS), "ak" (Alaska), "hi" (Hawaii), "pr" (Puerto Rico).
#'   Default is "us". Note: Only CONUS currently available.
#' @param format Optional character string specifying output format. One of:
#'   "nc" (netCDF), "asc" (ASCII Grid), "bil" (BIL format), "cog" (Cloud Optimized GeoTIFF). 
#'   Default is "bil".
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
#' \dontrun{
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
#' @seealso \code{\link{get_prism_dailys}} for downloading daily PRISM data
#'
#' @noRd
gen_prism_url_v2 <- function(dates, type, resolution = "4km", region = "us", 
                             format = "bil", dataset_type = "an", service = "web_service_v2") {
  
  # Input validation
  if (missing(dates) || missing(type)) {
    stop("Both 'dates' and 'type' arguments are required")
  }
  
  # Validate date format: YYYY/YYYYMM/YYYYMMDD (time-series) or MM/MMDD (normals)
  if (!all(grepl("^(\\d{4}(\\d{2}(\\d{2})?)?|\\d{2}(\\d{2})?)$", dates))) {
    stop("Dates must be in YYYYMMDD (daily), YYYYMM (monthly), YYYY (annual), MM (monthly normals), or MMDD (daily normals) format")
  }
  
  # Validate climate variable
  valid_types <- c("ppt", "tmin", "tmax", "tmean", "tdmean", "vpdmin", "vpdmax")
  if (!type %in% valid_types) {
    stop("'type' must be one of: ", paste(valid_types, collapse = ", "))
  }
  
  # Validate resolution
  valid_resolutions <- c( "800m", "4km")
  if (!resolution %in% valid_resolutions) {
    stop("'resolution' must be one of: ", paste(valid_resolutions, collapse = ", "))
  }
  
  # Validate region
  valid_regions <- c("us", "ak", "hi", "pr")
  if (!region %in% valid_regions) {
    stop("'region' must be one of: ", paste(valid_regions, collapse = ", "))
  }
  
  # Validate format
  valid_formats <- c("nc", "asc", "bil", "cog")
  if (!format %in% valid_formats) {
    stop("'format' must be one of: ", paste(valid_formats, collapse = ", "))
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
  
  # Web service v2 -------------------------------------------------------------------------
  if (service == "web_service_v2"){

    ## Base URL
    base_url <- "https://services.nacse.org/prism/data/get"
    
    # Generate URLs for each date
    urls <- paste(base_url, region, resolution, type, dates, sep = "/")
    
    # Add dataset type if LT (long-term)
    if (dataset_type == "lt") {
      urls <- paste0(urls, "/lt")
    }
    
    # Add format parameter (COG is default so no parameter needed)
    if (format != "cog") {
      urls <- paste0(urls, "?format=", format)
    }
    
  }
  
  
  # FTP Normals_Bil -------------------------------------------------------------------------
  if (service == "ftp_v2_normals_bil") {
    
    # Function to get version available in Normals_bil FTP (this logic may be required to future proof against
    # changes in the normals versions in normals_bil folder). May deprecate once we shift to COG?
    get_current_version <- function(base_url, time_scale, resolution, type, date_str) {
      
      # Build directory URL
      dir_url <- paste(base_url, time_scale, resolution, type, sep = "/")
      
      # Recode Annual date_str
      date_str = ifelse(date_str == '14', 'annual', date_str)
      
      # Get directory listing using only httr
      tryCatch({
        response <- httr::GET(paste0(dir_url, "/"))
        if (httr::status_code(response) == 200) {
          content_html <- httr::content(response, "text", encoding = "UTF-8")
          
          # Use base regex to extract file links (no 
          # Look for href="filename.zip" patterns
          file_pattern <- paste0('href="[^"]*PRISM_', type, '_30yr_normal_', resolution, '[DM]\\d+_', date_str, '_bil\\.zip"')
          matches <- regmatches(content_html, gregexpr(file_pattern, content_html))[[1]]
          
          if (length(matches) > 0) {
            # Extract just the filename from href="filename"
            filename <- sub('href="([^"]*)"', '\\1', matches[1])
            return(paste(dir_url, filename, sep = "/"))
          } else {
            warning("No matching file found for: ", type, " ", resolution, " ", date_str)
            return(NULL)
          }
        } else {
          warning("Failed to access directory: ", dir_url)
          return(NULL)
        }
      }, error = function(e) {
        warning("Error accessing directory: ", e$message)
        return(NULL)
      })
    }
    
    ## Base URL
    base_url <- 'https://data.prism.oregonstate.edu/normals_bil'
    
    # Generate URLs for each date
    urls <- sapply(dates, function(date_str) {
      time_scale <- ifelse(nchar(date_str) == 2, 'monthly', 'daily')
      get_current_version(base_url, time_scale, resolution, type, date_str)
    }) %>% unname()
    
    # Remove any NULL entries
    urls <- urls[!sapply(urls, is.null)]
    
    return(urls)
  }
  
  return(urls)
}