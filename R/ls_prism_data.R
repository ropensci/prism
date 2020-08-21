#' List available datasets
#' @description List the available data sets to load that have already been downloaded.
#' @param absPath TRUE if you want to return the absolute path.
#' @param name TRUE if you want file names and titles of data products.
#' @return  a data frame of downloaded datasets 
#' @examples \dontrun{
#' ### Just get file names, used in many other prism* fxn
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=FALSE)
#' ls_prism_data()
#' 
#' ### Get absolute path values for use with other data
#' ls_prism_data(absPath = TRUE)
#' 
#' ### See prism files you have with title of data product
#' ls_prism_data(name=TRUE)
#' }
#' 
#' @seealso [prism_subset_folders()]
#' 
#' @export

ls_prism_data <- function(absPath = FALSE, name = FALSE){
  prism_check_dl_dir()
  
  files <- list.files(getOption('prism.path'))
  # remove zip files
  files <- files[grep("zip", files, invert = TRUE)]
  # Attempt to ensure that only PRISM files are counted. 
  files <- files[grep("PRISM", files)]
  fullPath <- file.path(getOption('prism.path'), files, 
                    paste0(files, ".bil"))
  
  out <- data.frame(files, stringsAsFactors = FALSE)
  
  if(absPath){
  out$abs_path <- fullPath
  } 
  
  if(name){
    meta_d <- prism_data_get_name(files)
    out$product_name <- meta_d
  }
    
  out
}
