#' Download PRISM via webservice
#' @description This is the workhorse function that will access the web service to download files
#' @param uri a valid PRISM webservice URI
#' @param keepZip TRUE or FALSE, keep zip files once they have been unzipped
#' @param returnName TRUE or FALSE, if TRUE the name of the file that was downoaded is returned
#' @examples \dontrun{
#' ### Get all the data for January from 1990 to 2000
#' get_prism_annual(type="tmean", year = 1990:2000, keepZip=FALSE)
#' }
#' @importFrom httr HEAD
#' @export

prism_webservice <- function(uri,keepZip=FALSE, returnName = FALSE){
  ## Get file name
  x <- httr::HEAD(uri)
  fn <- x$headers$`content-disposition`
  fn <- regmatches(fn,regexpr('\\"[a-zA-Z0-9_\\.]+',fn))
  fn <- substr(fn,2,nchar((fn)))
  
  if(length(prism_check(fn)) == 0){
    return(NULL)
  } else{
  
  outFile <- paste(options("prism.path"), fn, sep="/")
  
  tryNumber <- 1
  downloaded <- FALSE
  
  while(tryNumber < 11 & !downloaded){
    downloaded <- TRUE
    tryCatch(
      download.file(url = uri,destfile = outFile, mode = "wb", quiet = TRUE), 
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
  
  if(returnName){
    return(fn)
  }
}
