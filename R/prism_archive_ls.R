#' List available prism data
#' 
#' `prism_archive_ls()` lists all available prism data (all variables and all 
#' temporal periods) that are available in the local archive, i.e., they 
#' have already been downloaded and are available in [prism_get_dl_dir()].
#' [prism_archive_subset()] can be used to subset the archive based on specified
#' variables and temporal periods.
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
  data <- data[grep("prism|PRISM", data)]
  
  data
}
