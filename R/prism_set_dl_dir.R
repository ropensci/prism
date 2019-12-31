#' Set prism download directory
#' 
#' Sets the directory that downloaded prism data will be unzipped into.
#' 
#' @param path The path that prism data will be unzipped into.
#' 
#' @param create Boolean that determines if the `path` will be created if it 
#'   does not already exist.
#'   
#' @export

prism_set_dl_dir <- function(path, create = TRUE)
{
  # Check if path exists, if it doesn't then create it
  if (!dir.exists(file.path(path)) & create) {
    message("creating ", path)
    dir.create(path, recursive = TRUE)
    if (!dir.exists(file.path(path))){
      options(prism.path = NULL)
      stop("Path invalid or permissions error.")
    }
  }
  
  options(prism.path = path)
  
  invisible(path)
}
