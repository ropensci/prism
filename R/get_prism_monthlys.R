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
#' # Get pre-1981 data (resolution applies to both pre and post-1981 data)
#' get_prism_monthlys(
#'   type = "tmax",
#'   years = 1975,
#'   mon = 7,
#'   resolution = "4km",
#'   keep_pre81_months = FALSE,
#'   keepZip = FALSE
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
                               keep_pre81_months = TRUE, service = NULL, 
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
  
  pre_1981 <- years[years<1981]
  post_1981 <- years[years>=1981]
  uris_pre81 <- vector()
  uris_post81 <- vector()
  
  if (is.null(service)) {
	  service <- "http://services.nacse.org/prism/data/public/4km"
  }
  
  if (length(pre_1981)) {
    # uris_pre81 <- gen_prism_url(pre_1981, type, service)
    uris_pre81 <- gen_prism_url(pre_1981, type, resolution)
  }

  if (length(post_1981)) {  
    uri_dates_post81 <- apply(
      expand.grid(post_1981,mon_to_string(mon)), 
      1, 
      function(x) {paste(x[1], x[2], sep="")}
    )
    
    # uris_post81 <- gen_prism_url(uri_dates_post81, type, service)
    uris_post81 <- gen_prism_url(uri_dates_post81, type, resolution)
  }
    
  download_pb <- txtProgressBar(
    min = 0,
    max = length(uris_post81) + length(uris_pre81),
    style = 3
  )
 
  counter <- 0

  ### Handle post 1981 data
  if(length(uris_post81) > 0){    
      for(i in seq_along(uris_post81)){
        prism_webservice(uris_post81[i],keepZip)
        setTxtProgressBar(download_pb, i)
    }
  }
    
  counter <- length(uris_post81)+1

  ### Handle pre 1981 files
  if (length(uris_pre81) > 0) {
  
    pre_files <- c()
    for (j in seq_along(uris_pre81)) {
      tmp <- prism_webservice(
        uris_pre81[j], 
        keepZip, 
        returnName = TRUE,
        pre81_months = mon
      )
      if (!is.null(tmp)) {
        pre_files <- c(pre_files, tmp)
      }
      setTxtProgressBar(download_pb, counter) 
      counter <- counter + 1
    }
    
    # Process pre 1981 files (unzip and keep monthly data)
    if (length(pre_files) > 0) {
      pre_files <- unlist(strsplit(pre_files,"\\."))
      pre_files <- pre_files[seq(1, length(pre_files), by = 2)]
      
      for (k in seq_along(pre_files)) {
        yr <- regmatches(pre_files[k], regexpr('[0-9]{4}', pre_files[k]))
        
        if (keep_pre81_months) {
          monstr <- c(mon_to_string(1:12), "")
        } else {
          monstr <- mon_to_string(mon)
        }
        
        to_split <- stringr::str_replace(pre_files[k], "_all", monstr)
        
        process_zip(pre_files[k], to_split)
      }
    }
  }

  close(download_pb)
}
