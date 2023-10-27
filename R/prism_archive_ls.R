#' List available prism data
#' 
#' `prism_archive_ls()` lists all available prism data (all variables and all 
#' temporal periods) that are available in the local archive, i.e., they 
#' have already been downloaded and are available in [prism_get_dl_dir()].
#' [prism_archive_subset()] can be used to subset the archive based on specified
#' variables and temporal periods.
#' 
#' @details 
#' `prism_archive_ls()` only returns the values found in the `files` column as 
#' returned by `ls_prism_data()`. To replicate
#' the behavior of `ls_prism_data()`, use [pd_get_name()] and 
#' [pd_to_file()] with the output of `prism_archive_ls()`
#' 
#' @return  `prism_archive_ls()` returns a character vector.
#' 
#' @examples \dontrun{
#' # Get prism data names, used in many other prism* functions 
#' get_prism_dailys(
#'   type="tmean", 
#'   minDate = "2013-06-01", 
#'   maxDate = "2013-06-14", 
#'   keepZip = FALSE
#' )
#' prism_archive_ls()
#' }
#' 
#' @seealso [prism_archive_subset()]
#' 
#' @export

prism_archive_ls <- function() {
  prism_check_dl_dir()
  
  # list.dirs will inherently not include .zip and .txt files
  data <- list.dirs(prism_get_dl_dir(), full.names = FALSE, recursive = FALSE)

  # Attempt to ensure that only PRISM folders are counted. 
  data <- data[grep("PRISM", data)]
  
  data
}

#' @description `ls_prism_data()` is a deprecated version of `prism_data_ls()`. 
#' 
#' @param absPath TRUE if you want to return the absolute path.
#' 
#' @param name TRUE if you want file names and titles of data products.
#' 
#' @return `ls_prism_data()` returns a data frame. It can have 1-3 columns, but
#' always has the `files` column. `abs_path` and `product_name` columns are 
#' added if `absPath` and `name` are `TRUE`, respectively.
#' 
#' @export
#' @rdname prism_archive_ls
ls_prism_data <- function(absPath = FALSE, name = FALSE){
  .Deprecated("`prism_archive_ls()`")
  
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
    meta_d <- pd_get_name(files)
    out$product_name <- meta_d
  }
    
  out
}


