#' List available datasets
#' @description List the available data sets to load that have already been downloaded.
#' @details You must have set the path for downloaded data
#' @examples \dontrun{
#' ls_prism_data()
#' }
#' @export

ls_prism_data <- function(){
  files <- list.files(options("prism.path")[[1]])
  return(files[grep("zip",files,invert=T)])
}