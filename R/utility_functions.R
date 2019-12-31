
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

#' Check if prism files exist
#' 
#' Helper function to check if files already exist in the specified "prism.path"
#' 
#' `prism_check()` is deprecated. Use `prism_not_downloaded()` instead.
#' 
#' @inheritParams prism_webservice
#' 
#' @param prismfiles a list of full prism file names ending in ".zip". 
#' 
#' @param lgl `TRUE` returns a logical vector indicating those
#'   not yet downloaded; `FALSE` returns the file names that are not yet 
#'   downloaded.
#' 
#' @return a character vector of file names that are not yet downloaded
#'   or a logical vector indication those not yet downloaded.
#' 
#' @export
prism_not_downloaded <- function(prismfiles, lgl = FALSE, pre81_months = NULL)
{
  file_bases <- unlist(sapply(prismfiles, strsplit, split=".zip"))
  which_downloaded <- sapply(
    file_bases, 
    find_prism_file, 
    pre81_months = pre81_months
  )
  
  if(lgl){
    return(!which_downloaded)
  } else {
    return(prismfiles[!which_downloaded])    
  }
}

#' @export
#' 
#' @rdname prism_not_downloaded
prism_check <- function(prismfiles, lgl = FALSE, pre81_months = NULL)
{
  .Deprecated(
    "`prism_not_downloaded()`"
  )
  
  prism_not_downloaded(prismfiles, lgl = FALSE, pre81_months = NULL)
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
  tmpwd <- list.files(paste(options("prism.path")[[1]], pfile, sep="/"))
  
  # Remove all.xml file
  file.remove(paste(
    options("prism.path")[[1]], 
    pfile, 
    grep("all", tmpwd, value = TRUE), 
    sep="/"
  ))
  
  # Get new list of files after removing all.xml
  tmpwd <- list.files(paste(options("prism.path")[[1]], pfile, sep="/"))
  
  fstrip <- strsplit(tmpwd, "\\.")
  fstrip <- unlist(lapply(fstrip, function(x) return(x[1])))
  unames <- unique(fstrip)
  unames <- unames[unames %in% name]
  for(j in 1:length(unames)){
    newdir <- paste(options("prism.path")[[1]], unames[j], sep="/")
    tryCatch(
      dir.create(newdir), 
      error = function(e) e,
      warning = function(w) {
        warning(paste(newdir, "already exists. Overwriting existing data."))
      }
    )
    
    f2copy <- grep(unames[j], tmpwd, value = TRUE)
    sapply(f2copy, function(x){
      file.copy(from = paste(options("prism.path")[[1]], pfile, x, sep="/"),
                to = paste(newdir, x, sep="/"))
    })
    sapply(f2copy, function(x){
      file.remove(paste(options("prism.path")[[1]], pfile, x, sep="/"))
    })
    # We lose all our metadata, so we need to rewrite it
  }
  # Remove all files so the directory can be created.
  # Update file list
  tmpwd <- list.files(paste(options("prism.path")[[1]], pfile, sep="/"))
  ## Now loop delete them all
  sapply(tmpwd, function(x){
    file.remove(paste(options("prism.path")[[1]], pfile, x, sep="/"))
  })
  unlink(paste(options("prism.path")[[1]], pfile, sep="/"), recursive = TRUE)
}

#' @title Get PRISM metadata
#' 
#' @description Retrieves PRISM metadata for a given type and date range. The 
#'   information is retrieved from the .info.txt file.
#'   
#' @inheritParams get_prism_dailys
#' 
#' @return list of data.frames containing metadata. If only one date is 
#'   requested, the function returns the data.frame.
#' 
#' @noRd
get_metadata <- function(type, dates = NULL, minDate = NULL, maxDate = NULL)
{
  path_check()
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  dates_str <- gsub("-", "", dates)
  prism_folders <- list.files(path = getOption("prism.path"))
  type_folders <- grep(type, prism_folders, value = TRUE)
  dates_type_folders <- stringr::str_extract(
    type_folders, 
    "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
  )
  
  final_folders <- type_folders[which(dates_type_folders %in% dates_str)]
  final_folders <- final_folders[!stringr::str_detect(final_folders, ".zip")]
  final_txt_full <- file.path(
    getOption("prism.path"), 
    final_folders, 
    paste0(final_folders, ".info.txt")
  )
  
  if(length(final_txt_full) == 0){
    stop("No files exist to obtain metadata from.")
  }
  out <- lapply(1:length(final_txt_full), function(i) {
    readin <- tryCatch(
      utils::read.delim(
        final_txt_full[i], 
        sep = "\n", 
        header = FALSE, 
        stringsAsFactors = FALSE
      ),
      error = function(e) {
        warning(e)
        warning(paste0(
          "Problem opening ", 
          final_txt_full[i], 
          ". The folder may exist without the .info.text file inside it."
        ))
      }
    )
    str_spl <- unlist(stringr::str_split(as.character(readin[[1]]), ": "))
    
    names_md <- str_spl[seq(from = 1, to = length(str_spl), by = 2)]
    data_md <- str_spl[seq(from = 2, to = length(str_spl), by = 2)]
    out <- matrix(data_md, nrow = 1)
    out <- as.data.frame(out, stringsAsFactors = FALSE)
    names(out) <- names_md
    out$file_path <- final_txt_full[i]
    out$folder_path <- file.path(getOption("prism.path"), final_folders[i])
    out
  })
  if(length(out) == 1){
    return(out[[1]])
  } else {
    return(out)
  }
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

#' Subsets prism folders on the disk by type and date
#' 
#' Looks through all of the PRISM data that is downloaded in your 
#' `prism.path` and returns the subset based on `type` and `dates`.
#' 
#' @param type The type of data you want to subset. Should be tmax, tmin, tmean, 
#' ppt, vpdmin, or vpdmax
#' @param dates A vector of the dates you wish to subset as a string
#' 
subset_prism_folders <- function(type, dates){
  path_check()
  dates_str <- gsub("-", "", dates)
  prism_folders <- list.files(getOption("prism.path"))
  
  type_folders <- prism_folders %>% 
    stringr::str_subset(paste0("_", type, "_"))
  # Use D2 for ppt
  if(type == "ppt"){
    type_folders <- type_folders %>% 
      stringr::str_subset("4kmD2_")
  } else {
    type_folders <- type_folders %>% 
      stringr::str_subset("4kmD1_")
  }
  # Don't want zips
  type_folders <- type_folders[!stringr::str_detect(type_folders, ".zip")]
  
  type_folders %>% 
    stringr::str_subset(paste(dates_str, collapse = "|"))
}

#' Returns the available prism variables.
#' @noRd
prism_vars <- function(all_var = FALSE)
{
  c("ppt", "tmean", "tmin", "tmax", "vpdmin", "vpdmax", "tdmean")
}
