prism_set_dl_dir <- function(path, create = TRUE)
{
  ## Check if path exists
  if (!dir.exists(file.path(path)) & create) {
    dir.create(path)
    if (!dir.exists(file.path(path))){
      options(prism.path = NULL)
      stop("Path invalid or permissions error.")
    }
  }
  
  options(prism.path = path)
  
  invisible(path)
}