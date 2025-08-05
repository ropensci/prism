#' Generate PRISM Web Service v2 URLs
#' 
#' Internal function that generates API endpoints for PRISM Web Service v2.
#' This function creates URLs following the new web service pattern:
#' https://services.nacse.org/prism/data/get/<region>/<resolution>/<element>/<date>
#' 
#' @param dates Character vector of dates in YYYYMMDD, YYYYMM, or YYYY format
#' @param element Character. PRISM variable: "ppt", "tmin", "tmax", "tmean", 
#'   "tdmean", "vpdmin", or "vpdmax"
#' @param region Character. Region code: "us" (CONUS), "hi" (Hawaii), 
#'   "ak" (Alaska), or "pr" (Puerto Rico). Default is "us". Note: only "us" 
#'   is currently implemented by PRISM.
#' @param resolution Character. Resolution: "400m", "800m", or "4km". 
#'   Default is "4km". Note: "400m" is not yet implemented by PRISM.
#' @param dataset_type Character. Dataset type: "an" (all networks, default) 
#'   or "lt" (long-term, only available for 800m monthly data)
#' @param format Character. Output format: "cog" (default, Cloud Optimized GeoTIFF), 
#'   "bil", "asc", or "nc". For backward compatibility with existing prism package
#'   functionality, "bil" is recommended.
#' @param base_url Character. Base URL for the PRISM web service. Default is
#'   "https://services.nacse.org/prism/data/get"
#' 
#' @return Character vector of URLs, same length as \code{dates}
#' 
#' @details 
#' This function generates URLs for the new PRISM Web Service v2 which will
#' replace the old service on September 30, 2025. The new service:
#' \itemize{
#'   \item Uses a unified URL pattern for all data types
#'   \item Defaults to COG (Cloud Optimized GeoTIFF) format
#'   \item Supports explicit format specification via query parameters
#'   \item Requires region and resolution parameters in the URL path
#' }
#' 
#' For backward compatibility with existing prism package functionality,
#' it's recommended to use \code{format = "bil"} to maintain the expected
#' BIL raster format.
#' 
#' @examples
#' \dontrun{
#' # Daily data URLs
#' gen_prism_url_v2("20240315", "tmin", resolution = "4km", format = "bil")
#' 
#' # Monthly data URLs  
#' gen_prism_url_v2("202403", "ppt", resolution = "800m", format = "bil")
#' 
#' # Annual data URLs
#' gen_prism_url_v2("2023", "tmean", format = "bil")
#' 
#' # Multiple dates
#' dates <- c("20240301", "20240302", "20240303")
#' gen_prism_url_v2(dates, "tmax", format = "bil")
#' 
#' # Long-term dataset (800m monthly only)
#' gen_prism_url_v2("202403", "tmin", resolution = "800m", 
#'                  dataset_type = "lt", format = "bil")
#' }
#' 
#' @noRd
gen_prism_url_v2 <- function(dates, 
                             element,
                             region = "us",
                             resolution = "4km", 
                             dataset_type = "an",
                             format = "bil",
                             base_url = "https://services.nacse.org/prism/data/get") {
  
  # Input validation
  if (missing(dates) || missing(element)) {
    stop("Both 'dates' and 'element' arguments are required")
  }
  
  # Validate element
  valid_elements <- c("ppt", "tmin", "tmax", "tmean", "tdmean", "vpdmin", "vpdmax")
  if (!element %in% valid_elements) {
    stop("element must be one of: ", paste(valid_elements, collapse = ", "))
  }
  
  # Validate region  
  valid_regions <- c("us", "hi", "ak", "pr")
  if (!region %in% valid_regions) {
    stop("region must be one of: ", paste(valid_regions, collapse = ", "))
  }
  
  # Validate resolution
  valid_resolutions <- c("400m", "800m", "4km")
  if (!resolution %in% valid_resolutions) {
    stop("resolution must be one of: ", paste(valid_resolutions, collapse = ", "))
  }
  
  # Validate dataset_type
  valid_dataset_types <- c("an", "lt")
  if (!dataset_type %in% valid_dataset_types) {
    stop("dataset_type must be one of: ", paste(valid_dataset_types, collapse = ", "))
  }
  
  # Validate format
  valid_formats <- c("cog", "bil", "asc", "nc")
  if (!format %in% valid_formats) {
    stop("format must be one of: ", paste(valid_formats, collapse = ", "))
  }
  
  # Warn about unimplemented features
  if (region != "us") {
    warning("Only region 'us' (CONUS) is currently implemented by PRISM web service")
  }
  
  if (resolution == "400m") {
    warning("Resolution '400m' is not yet implemented by PRISM web service")
  }
  
  if (dataset_type == "lt" && (resolution != "800m")) {
    warning("Long-term (lt) dataset is only available for 800m resolution monthly data")
  }
  
  # Build base URL components
  url_parts <- c(base_url, region, resolution, element, dates)
  base_urls <- apply(
    expand.grid(base_url, region, resolution, element, dates, 
                stringsAsFactors = FALSE),
    1, 
    function(x) paste(x, collapse = "/")
  )
  
  # Add dataset type if long-term
  if (dataset_type == "lt") {
    base_urls <- paste0(base_urls, "/lt")
  }
  
  # Add format parameter if not default COG
  if (format != "cog") {
    base_urls <- paste0(base_urls, "?format=", format)
  }
  
  return(base_urls)
}