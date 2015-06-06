#' @title Get daily data file names for last 2 years  
#' @description Utility function to download all filenames
#' for the last two years. This is to determine which are
#' currently showing as provisional, early, or stable.
#' @inheritParams get_prism_dailys
#' @param frequency \code{character} for the frequency. One of
#' "daily" or "monthly". 
get_recent_filenames <- function(type, frequency) {
  frequency <- match.arg(frequency, c("daily", "monthly"))

  full_path_this <- paste("ftp://prism.nacse.org", frequency, 
                          type, year(Sys.Date()), "", sep = "/")
  filenames_this <- getURL(full_path_this, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames_this <- strsplit(filenames_this, split = "\r\n")[[1]]
  
  full_path_last <- paste("ftp://prism.nacse.org", frequency, 
                          type, year(Sys.Date()) - 1, "", sep = "/")
  filenames_last <- getURL(full_path_last, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  # Stores all the filenames for this and last year
  c(filenames_this, strsplit(filenames_last, split = "\r\n")[[1]])
}

#' helper function for handling months
#' @description Handle numeric month to string conversions
#' @param month a numeric vector of months (month must be > 0 and <= 12)
#' @return a character vector (same length as \code{month}) with 2 char month strings.
#' @examples
#' mon_to_string(month = c(1, 3, 2))
#' mon_to_string(month = 12)
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
#' @param prismfile a list of full paths for prism files
#' @return a character vector of file names that already exist
prism_check <- function(prismfile){
  file_bases <- unlist(sapply(prismfile, strsplit, split=".zip"))
  which_downloaded <- sapply(file_bases, function(base) {
    # Look inside the folder to see if the .bil is there
    # Won't be able to check for all other files. Unlikely to matter.
    ls_folder <- list.files(file.path(getOption("prism.path"), base))
    any(grepl("\\.bil", ls_folder))
  })
  prismfile[!which_downloaded]
}

#' Process pre 1980 files
#' @description Files that come prior to 1980 come in one huge zip.  This will cause them to mimic all post 1980 downloads
#' @param pfile the name of the file, should include "all", that is unzipped
#' @param name a vector of names of files that you want to save.
#' @details This should match all other files post 1980
#' @examples \dontrun{
#' process_zip('PRISM_tmean_stable_4kmM2_1980_all_bil','PRISM_tmean_stable_4kmM2_198001_bil')
#' process_zip('PRISM_tmean_stable_4kmM2_1980_all_bil',c('PRISM_tmean_stable_4kmM2_198001_bil','PRISM_tmean_stable_4kmM2_198002_bil'))
#' }
process_zip <- function(pfile,name){
  stop("Fix errors in process_zip")
  tmpwd <- list.files(paste(options("prism.path")[[1]],pfile,sep="/"))
  ##Remove all.xml file
  file.remove(paste(options("prism.path")[[1]],pfile,grep("all",tmpwd,value = T),sep="/"))
  ## Get new list of files after removing all.xml
  tmpwd <- list.files(paste(options("prism.path")[[1]],pfile,sep="/"))
  
  fstrip <- strsplit(tmpwd,"\\.")
  fstrip <- unlist(lapply(fstrip,function(x) return(x[1])))
  unames <- unique(fstrip)
  unames <- unames[unames%in%name]
  for(j in 1:length(unames)){
    newdir <- paste(options("prism.path")[[1]],unames[j],sep="/")
    dir.create(newdir)
    f2copy <- grep(unames[j],tmpwd,value=T)
    sapply(f2copy,function(x){file.copy(from = paste(options("prism.path")[[1]],pfile,x,sep="/"),to = paste(newdir,x,sep="/")) })
    sapply(f2copy,function(x){file.remove(paste(options("prism.path")[[1]],pfile,x,sep="/")) })
    
    
    ### We lose all our metadata, so we need to rewrite it
    
  }
  ### Remove all files so the directory can be created.
  ## Update file list
  tmpwd <- list.files(paste(options("prism.path")[[1]],pfile,sep="/"))
  ## Now loop delete them all
  sapply(tmpwd,function(x){
    file.remove(paste(options("prism.path")[[1]],pfile,x,sep="/"))
  })
  
  
  file.remove(paste(options("prism.path")[[1]],pfile,sep="/"),recursive = T)
  
  
}

