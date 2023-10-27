
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
  for(i in 1:length(month)){
    if(month[i] < 1 || month[i] > 12) {
      stop("Please enter a valid numeric month")
    }
    if(month[i] < 10){ out[i] <- paste("0",month[i],sep="")}
    else { out[i] <- paste0(month[i]) }
  }
  return(out)
}

prism_not_downloaded <- function(zipfiles, lgl = FALSE, pre81_months = NULL)
{
  file_bases <- stringr::str_remove(zipfiles, '.zip')
  which_downloaded <- vapply(
    file_bases, 
    find_prism_file, 
    FUN.VALUE = logical(1),
    pre81_months = pre81_months
  )
  
  if(lgl){
    return(!which_downloaded)
  } else {
    return(zipfiles[!which_downloaded])    
  }
}

# x can be vector of years/ months/datee
# will return value that is same length as x
gen_prism_url <- function(x, type, service, resolution = NULL) 
{
  if (is.null(resolution)) {
    paste(service, type, x, sep = "/")
  } else {
    paste(service, resolution, type, x, sep = "/")
  }
}

#' Check if prism files exist
#' 
#' Helper function to check if files already exist in the prism download 
#' directory. Determines if files have **not** been downloaded yet, i.e., 
#' returns `TRUE` if they do not exist. 
#' 
#' @param prismfiles a list of full prism file names ending in ".zip". 
#' 
#' @param lgl `TRUE` returns a logical vector indicating those
#'   not yet downloaded; `FALSE` returns the file names that are not yet 
#'   downloaded.
#'   
#' @param pre81_months Numeric vector of months that will be downloaded, if 
#'   downloading data before 1981. This is so that the existence of the data can
#'   be correctly checked, as the file includes all monthly data for a given 
#'   year.
#' 
#' @return a character vector of file names that are not yet downloaded
#'   or a logical vector indication those not yet downloaded.
#' @export
#' 
prism_check <- function(prismfiles, lgl = FALSE, pre81_months = NULL)
{
  .Deprecated(
    msg = paste0(
      "`prism_check()` will be removed in the next release.\n", 
      "If you need this function, please file a bug at https://github.com/ropensci/prism/issues."
    )
  )
  
  prism_not_downloaded(prismfiles, lgl = lgl, pre81_months = pre81_months)
}

# return TRUE if all file(s) are found for the specified base_file
find_prism_file <- function(base_file, pre81_months)
{
  # Look inside the folder to see if the .bil is there
  # Won't be able to check for all other files. Unlikely to matter.
  if (is.null(pre81_months)) {
    ls_folder <- list.files(file.path(getOption("prism.path"), base_file))
    found_file <- any(grepl("\\.bil", ls_folder))
  } else {
    # check for all the monthly data. If any of the monthly data do not exist
    # will need to download the entire file again.
    # pre81_months can be vector of months, or "". "" represents the annual data
    annual <- pre81_months[pre81_months == ""]
    monthly <- pre81_months[pre81_months != ""]
    all_months <- c()
    if (length(annual) > 0)
      all_months <- c(all_months, "")
    if (length(monthly) > 0)
      all_months <- c(all_months, mon_to_string(monthly))
    
    found_file <- TRUE
    for (m in all_months) {
      ls_folder <- gsub(pattern = "_all", replacement = m, x = base_file)
      ls_folder <- list.files(file.path(getOption("prism.path"), ls_folder))
      found_file <- found_file & any(grepl("\\.bil", ls_folder))
    }
  }
  
  found_file
}

#' Process pre 1980 files
#' @description Files that come prior to 1980 come in one huge zip.  This will 
#'   cause them to mimic all post 1980 downloads
#'   
#' @param pfile the name of the file, should include "all", that is unzipped
#' 
#' @param name a vector of names of files that you want to save.
#' 
#' @details This should match all other files post 1980
#' 
#' @examples \dontrun{
#' process_zip(
#'   'PRISM_tmean_stable_4kmM2_1980_all_bil',
#'   'PRISM_tmean_stable_4kmM2_198001_bil'
#' )
#' 
#' process_zip(
#'   'PRISM_tmean_stable_4kmM2_1980_all_bil',
#'   c('PRISM_tmean_stable_4kmM2_198001_bil',
#'   'PRISM_tmean_stable_4kmM2_198002_bil')
#' )
#' }
#' 
#' @noRd
process_zip <- function(pfile, name) 
{
  tmpwd <- list.files(file.path(prism_get_dl_dir(), pfile))
  
  # Remove all.xml file
  file.remove(file.path(
    prism_get_dl_dir(), 
    pfile, 
    grep("all", tmpwd, value = TRUE)
  ))
  
  # Get new list of files after removing all.xml
  tmpwd <- list.files(file.path(prism_get_dl_dir(), pfile))
  
  fstrip <- strsplit(tmpwd, "\\.")
  fstrip <- unlist(lapply(fstrip, function(x) return(x[1])))
  unames <- unique(fstrip)
  unames <- unames[unames %in% name]
  for(j in 1:length(unames)){
    newdir <- file.path(prism_get_dl_dir(), unames[j])
    tryCatch(
      dir.create(newdir), 
      error = function(e) e,
      warning = function(w) {
        warning(paste(newdir, "already exists. Overwriting existing data."))
      }
    )
    
    f2copy <- grep(unames[j], tmpwd, value = TRUE)
    
    file.copy(
      from = file.path(prism_get_dl_dir(), pfile, f2copy),
      to = file.path(newdir, f2copy)
    )
    
    file.remove(file.path(prism_get_dl_dir(), pfile, f2copy))
    # We lose all our metadata, so we need to rewrite it
  }
  # Remove all files so the directory can be created.
  # Update file list
  tmpwd <- list.files(file.path(prism_get_dl_dir(), pfile))
  ## Now loop delete them all
  file.remove(file.path(prism_get_dl_dir(), pfile, tmpwd))
  
  unlink(file.path(prism_get_dl_dir(), pfile), recursive = TRUE)
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
  
  if((!is.null(dates) && !is.null(maxDate)) | (!is.null(dates) && !is.null(minDate))){
    stop("You can enter a date range or a vector of dates, but not both")
  }
  
  if((!is.null(maxDate) & is.null(minDate)) | (!is.null(minDate) & is.null(maxDate))){
    stop("Both minDate and maxDate must be specified if specifying a date range")
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
prism_vars <- function()
{
  c("ppt", "tmean", "tmin", "tmax", "vpdmin", "vpdmax", "tdmean")
}

# maps prism variables and names
prism_var_names <- function() {
  x <- c("Precipitation", "Mean temperature", "Minimum temperature", 
         "Maximum temperature", "Minimum vapor pressure deficit",
         "Maximum vapor pressure deficit", "Mean dew point temperature")
  
  names(x) <- prism_vars()

  x
}
