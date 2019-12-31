#' Download PRISM via webservice
#' 
#' This is the workhorse function that will access the web service to download 
#' files.
#' 
#' @param uri a valid PRISM webservice URI
#' 
#' @param keepZip TRUE or FALSE, keep zip files once they have been unzipped
#' 
#' @param returnName TRUE or FALSE, if TRUE the name of the file that was 
#'   downloaded is returned
#'   
#' @param pre81_months Numeric vector of months that will be downloaded, if 
#'   downloading data before 1981. This is so that the existance of the data can
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
#' 
#' @export

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
        download.file(url = uri, destfile = outFile, mode = "wb", quiet = TRUE), 
        error = function(e){
          downloaded <<- FALSE
        })
      tryNumber <- tryNumber + 1
    }
  
    if (!downloaded) {
      warning(paste0("Downloading failed"))
    } else {
      suppressWarnings(unzip(outFile, exdir = strsplit(outFile, ".zip")[[1]]))
      if(!keepZip){
        file.remove(outFile)
      }
    }
  }
  
  if (returnName) {
    return(fn)
  }
}
