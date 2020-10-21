#' Download PRISM via web service
#' 
#' This is the workhorse function that accesses the web service to download 
#' files. It is called by the get_prism_*() functions. 
#' 
#' @param uri a valid PRISM web service URI
#' 
#' @param keepZip TRUE or FALSE, keep zip files once they have been unzipped
#' 
#' @param returnName TRUE or FALSE, if TRUE the name of the file that was 
#'   downloaded is returned
#'   
#' @param pre81_months Numeric vector of months that will be downloaded, if 
#'   downloading data before 1981. This is so that the existence of the data can
#'   be correctly checked, as the file includes all monthly data for a given 
#'   year.
#' 
#' @examples 
#' \dontrun{
#' # Get the January 2001 mean temperature
#' prism_webservice(
#'   "http://services.nacse.org/prism/data/public/4km/tmean/200001", 
#'   keepZip = FALSE
#' )
#' }
#' @noRd

prism_webservice <- function(uri, keepZip = FALSE, returnName = FALSE, 
                             pre81_months = NULL)
{
  ## Get file name
  x <- httr::HEAD(uri)
  fn <- x$headers[["content-disposition"]]
  fn <- regmatches(fn, regexpr('\\"[a-zA-Z0-9_\\.]+', fn))
  fn <- substr(fn, 2, nchar((fn)))
  
  if (length(prism_not_downloaded(fn, pre81_months = pre81_months)) == 0) {
    message("\n", fn, " already exists. Skipping downloading.")
    return(NULL)
  } else {
  
    outFile <- paste(options("prism.path"), fn, sep="/")
    
    tryNumber <- 1
    downloaded <- FALSE
    
    while(tryNumber < 11 & !downloaded){
      downloaded <- TRUE
      tryCatch(
        utils::download.file(
          url = uri, 
          destfile = outFile, 
          mode = "wb", 
          quiet = TRUE
        ), 
        error = function(e){
          downloaded <<- FALSE
        })
      tryNumber <- tryNumber + 1
    }
  
    if (!downloaded) {
      warning(paste0("Downloading failed"))
    } else {
      
      # check and make sure the download file is actually a zip file. If it 
      # is not a zip file, then likely an error b/c of too many attempts to 
      # download the same file
      is_zip <- check_zip_file(outFile)
      if (!is.logical(is_zip)) {
        # is_zip is an error message
        warning(is_zip)
        # convert the file to .txt (store error message)
        new_file <- stringr::str_replace(outFile, ".zip", ".txt")
        file.rename(outFile, new_file)
        return(NULL)
      }
      
      ofolder <- strsplit(outFile, ".zip")[[1]]
      suppressWarnings(
        utils::unzip(outFile, exdir = ofolder)
      )
      
      # make sure unzipped folder is not empty
      check_unzipped_folder(ofolder, uri)
      
      if (!keepZip) {
        file.remove(outFile)
      }
    }
  }
  
  if (returnName) {
    return(fn)
  }
}

# x is the file to check. 
# returns TRUE if it is a zip file, and otherwiser returns text that was read
check_zip_file <- function(x) {
  zfile <- readLines(x, warn = FALSE)
  
  # zip files have "PK\....." in their first line
  is_zip <- grepl("^PK\003\004", zfile[1])
  
  if (is_zip) {
    return(is_zip)
  } else{
    return(zfile)
  }
}

# check to see that there are files in the unzipped folder
check_unzipped_folder <- function(x, uri) {
  if (length(list.files(x)) == 0) {
    warning(
      "Something went wrong and the unzipped folder is empty.\n",
      "You might try downloading manually by browsing to the following url:\n",
      uri
    )
  }
  
  invisible(x)
}
