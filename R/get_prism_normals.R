#' Download data for 30 year normals of climate variables
#' 
#' @description Download data from the prism project for 30 year normals at 4km 
#'   or 800m grid cell resolution for precipitation; mean, min and max 
#'   temperature; clear sky, sloped, and total solar radiation; and cloud
#'   transmittance.  
#'   
#' @param resolution The spatial resolution of the data, must be either "4km" 
#'   or "800m".
#' 
#' @param annual if `TRUE` download annual normals.
#' 
#' @param day Download daily normals. If `TRUE`, then download all daily data
#'   for the specified months or entire year (if `annual` is `TRUE`). Individual
#'   days can be specified as a `Date` object, where the year is ignored or
#'   specified as characters in "mm-dd" or "mmdd" form. 
#' 
#' @section Normals:
#' 
#' 30-year normals are currently computed using 1991-2020 and are available at 
#' 4km and 800m resolution. See 
#' [https://prism.nacse.org/normals/](https://prism.nacse.org/normals/).
#' If `mon` is specified and `annual` is `TRUE`, then monthly and annual normal 
#' data will be downloaded. Clear sky, sloped, and total solar radiation; and 
#' cloud transmittance are not available for daily normals.
#' 
#' @examples \dontrun{
#' # Get 30 year normal values for January rainfall
#' get_prism_normals(type = "ppt", resolution = "4km", mon = 1, keepZip = FALSE)
#' 
#' # Get monthly (every month) and annual 30-year normals for mean temperature
#' get_prism_normals(
#'   type = "tmean", 
#'   resolution = "800m", 
#'   mon = 1:12, 
#'   annual = TRUE,
#'   keepZip = FALSE
#' )
#' 
#' # Get daily precip normals for January 1 and March 1
#' get_prism_normals('ppt', '4km', NULL, FALSE, TRUE, c('0101', '0301'))
#' 
#' # Get daily precip normals for all of February
#' get_prism_normals('ppt', '4km', 2, FALSE, TRUE, TRUE)
#' 
#' # Get July 2nd average temperature 30-year average
#' get_prism_normals('tmean', '800m', NULL, FALSE, TRUE, as.Date('2000-07-02'))
#' }
#' 
#' @rdname get_prism_data
#' 
#' @export
get_prism_normals <- function(type, resolution, mon = NULL, annual = FALSE,  
                              keepZip = TRUE, day = NULL)
{
  ### parameter and error handling
  prism_check_dl_dir()
  type <- match.arg(type, prism_vars(normals = TRUE))
  resolution <- match.arg(resolution, c("4km","800m"))
  
  if (is.null(mon) & !annual & is.null(day)) {
    stop(
      "`mon` and `day` are `NULL` and `annual` is `FALSE`.\n",
      "Specify either daily and/or monthly and/or annual data to download."
    )
  }
  
  if (!is.null(day) & 
      type %in% c( "solclear", "solslope", "soltotal","soltrans")) {
    stop(
      'Daily normals are not available for clear sky, sloped, and total solar radiation; nor cloud transmittance.'
    )
  }
  
  call_mon <- c()
  if(!is.null(mon)){
    if(any(mon < 1 | mon > 12)) {
      stop("You must enter a month between 1 and 12")
    }
    call_mon <- mon_to_string(mon)
  } 
  
  if (annual) {
    call_mon <- c(call_mon, "14")
  }
  
  if (!is.null(day)) {
    # check that day is specified correctly
    if (isTRUE(day)) {
      if (is.null(mon) & !annual) {
        stop(
          "If `day` is `TRUE`, then eith `mon`, or `annual` need to be specified too."
        )
      } else {
        # day will be created to fill all annual/mon values
        call_mon <- c(call_mon, get_days_from_mon_ann(mon, annual))
      }
    } else {
      # need to check that day is specified correctly & parse to correct format
      call_mon <- c(call_mon, check_parse_day(day))
    }
  }
 
  # stemp <- "http://services.nacse.org/prism/data/public/normals"
  # uris <- gen_prism_url(call_mon, type, stemp, resolution) 
  uris <- gen_prism_url_v2(call_mon, type, resolution,
                           service = 'ftp_v2_normals_bil') 
  
  mpb <- txtProgressBar(min = 0, max =length(uris), style = 3)
 
  for(i in seq_along(uris)){
    prism_webservice(uris[i],keepZip, service = 'ftp_v2_normals_bil' )
    setTxtProgressBar(mpb, i)
    
  }
  
  close(mpb)
}

get_days_from_mon_ann <- function(mon, annual) 
{
  if (isTRUE(annual)) {
    mon <- 1:12
  } 
  
  dd <- days_in_month(mon)
  
  all_days <- c()
  
  for (i in seq_along(mon)) {
    tmp <- sprintf("%02d", mon[i])
    tmp <- paste0(tmp, sprintf("%02d", 1:dd[i]))
    all_days <- c(all_days, tmp)
  }
  
  all_days
}

days_in_month <- function(x) 
{
  ifelse(x %in% c(1, 3, 5, 7, 8, 10, 12), 31,
         ifelse(x == 2, 29, 30))
}

check_parse_day <- function(dd)
{
  # if its a Date, then strip off Year
  if (inherits(dd, 'Date')) {
    dd <- format(dd, "%m%d")
  } else {
    # assume its a string, strip off the - and then check that it is in 
    # expected range
    dd <- gsub("-", "", dd)
    if (!all(dd %in% get_days_from_mon_ann(NULL, TRUE))) {
      stop("`day` was specified in a character and includes some invalid month day combinations")
    }
  }
  
  dd
}
