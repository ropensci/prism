#' Set, check, and get prism download directory
#' 
#' `prism_set_dl_dir()` sets the directory that downloaded prism data will be 
#' saved to. The prism download directory is saved in the "prism.path" option.
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
  message("incoming path: ", path)
  
  path <- normalizePath(path, mustWork = FALSE)
  if (!dir.exists(file.path(path)) & create) {
    message("creating ", path)
    dir.create(path, recursive = TRUE)
    if (!dir.exists(file.path(path))){
      options(prism.path = NULL)
      stop("Path invalid or permissions error.")
    }
  }
  
  options(prism.path = path)
  message("outgoing path: ", path)
  invisible(path)
}

#' @description 
#' `prism_get_dl_dir()` gets the folder that prism data will be saved to. It is
#' a wrapper around `getOption("prism.path")` so the user does not have to 
#' remember the option name. 
#' 
#' @export
#' 
#' @rdname prism_set_dl_dir

prism_get_dl_dir <- function() {
  getOption("prism.path")
}

#' @description 
#' `prism_check_dl_dir()` checks that prism download folder has been set. If it 
#' has not been set, and in interactive mode, then prompt user to specify the 
#' download location. If not in interactive mode, and it has not been set, then 
#' set to "~/prismtmp".
#' 
#' @export
#' 
#' @rdname prism_set_dl_dir
prism_check_dl_dir <- function()
{
  user_path <-getOption("prism.path")
  if (is.null(user_path)) {
    if (interactive()) {
      message("You have not set a path to hold your prism files.")
      user_path <- readline(
        "Please enter the full or relative path to download files to or hit enter to use default ('~/prismtmp'): "
      )
      # User may have input path with quotes. Remove these.
      user_path <- gsub(pattern = c("\"|'"), "", user_path)
      # Deal with relative paths
      user_path <- ifelse(
        nchar(user_path) == 0,
        file.path(Sys.getenv("HOME"), "prismtmp"),
        file.path(normalizePath(user_path, winslash = "/"))
      )
    } else {
      stop(paste(
        "prism.path has not been set and this is being called non interactively.",
        "You must set the prism download directory using `prism_set_dl_dir()`"
      ))
      user_path <- file.path(Sys.getenv("HOME"), "prismtmp")
    }
    
    prism_set_dl_dir(user_path)
  }
  
  invisible(user_path)
}

#' @description 
#' `path_check()` is a deprecated version of `prism_check_dl_dir()`.
#' 
#' @export
#' @rdname prism_set_dl_dir
path_check <- function()
{
  .Deprecated("`prism_check_dl_dir()`")
  prism_check_dl_dir()
}