
#' helper function for handling months
#' @description Handle numeric month to string conversions
#' @param month a numeric vector of months (month must be > 0 and <= 12)
#' @return a character vector (same length as \code{month}) with 2 char month strings.
#' @examples \dontrun{
#'   mon_to_string(month = c(1, 3, 2))
#'   mon_to_string(month = 12)
#' }
mon_to_string <- function(month){
  out <- vector()
  for(i in 1:length(month)){
    if(month[i] < 1 || month[i] > 12){stop("Please enter a valid numeric month")}
    if(month[i] < 10){ out[i] <- paste("0",month[i],sep="")}
    else { out[i] <- paste0(month[i]) }
  }
  return(out)
}

#' handle existing directory
#' @description create new directory for user if they don't have one to store prism files
#' @export
path_check <- function(){
  user_path <- NULL
  if(is.null(getOption('prism.path'))){
    message("You have not set a path to hold your prism files.")
    user_path <- readline("Please enter the full or relative path to download files to (hit enter to use default '~/prismtmp'): ")
    # User may have input path with quotes. Remove these.
    user_path <- gsub(pattern = c("\"|'"), "", user_path)
    # Deal with relative paths
    user_path <- ifelse(nchar(user_path) == 0,
                        paste(Sys.getenv("HOME"), "prismtmp", sep="/"),
                        file.path(normalizePath(user_path, winslash = "/")))
    options(prism.path = user_path)
  } else {
    user_path <- getOption('prism.path')
  }
  
  ## Check if path exists
  if(!file.exists(file.path(user_path))){
    dir.create(user_path)
    if (!file.exists(file.path(user_path))){
      message("Path invalid or permissions error.")
      options(prism.path = NULL)
    }
  }
}

#' Helper function to check if files already exist
#' @description check if files exist
#' @param prismfiles a list of full paths for prism files
#' @param lgl \code{TRUE} returns a logical vector indicating those
#' not yet downloaded; \code{FALSE}
#' returns the file names that are not yet downloaded.
#' @return a character vector of file names that are not yet downloaded
#' or a logical vector indication those not yet downloaded..
#' @export
prism_check <- function(prismfiles, lgl = FALSE){
  file_bases <- unlist(sapply(prismfiles, strsplit, split=".zip"))
  which_downloaded <- sapply(file_bases, function(base) {
    # Look inside the folder to see if the .bil is there
    # Won't be able to check for all other files. Unlikely to matter.
    ls_folder <- list.files(file.path(getOption("prism.path"), base))
    any(grepl("\\.bil", ls_folder))
  })
  if(lgl){
    return(!which_downloaded)
  } else {
    return(prismfiles[!which_downloaded])    
  }
}

#' Process pre 1980 files
#' @description Files that come prior to 1980 come in one huge zip.  This will cause them to mimic all post 1980 downloads
#' @param pfile the name of the file, should include "all", that is unzipped
#' @param name a vector of names of files that you want to save.
#' @details This should match all other files post 1980
#' @examples \dontrun{
#' process_zip('PRISM_tmean_stable_4kmM2_1980_all_bil','PRISM_tmean_stable_4kmM2_198001_bil')
#' process_zip('PRISM_tmean_stable_4kmM2_1980_all_bil',
#' c('PRISM_tmean_stable_4kmM2_198001_bil','PRISM_tmean_stable_4kmM2_198002_bil'))
#' }
process_zip <- function(pfile, name){
  tmpwd <- list.files(paste(options("prism.path")[[1]], pfile, sep="/"))
  
  # Remove all.xml file
  file.remove(paste(options("prism.path")[[1]], pfile, grep("all", tmpwd, value = T), sep="/"))
  
  # Get new list of files after removing all.xml
  tmpwd <- list.files(paste(options("prism.path")[[1]], pfile, sep="/"))
  
  fstrip <- strsplit(tmpwd, "\\.")
  fstrip <- unlist(lapply(fstrip, function(x) return(x[1])))
  unames <- unique(fstrip)
  unames <- unames[unames %in% name]
  for(j in 1:length(unames)){
    newdir <- paste(options("prism.path")[[1]], unames[j], sep="/")
    tryCatch(dir.create(newdir), error = function(e) e,
             warning = function(w){
               warning(paste(newdir, "already exists. Overwriting existing data."))
             })
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


#' Get the resolution text string
#' @description To account for the ever changing name structure, here we will scrape the HTTP directory listing and grab it instead of relying on hard coded strings that need changing
#' @param type the type of data you're downloading, should be tmax, tmin etc...
#' @param temporal The temporal resolution of the data, monthly, daily, etc...
#' @param yr the year of data that's being requested, in numeric form

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

