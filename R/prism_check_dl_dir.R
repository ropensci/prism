#' Check that prism download folder has been set.
#' 
#' Checks that prism download folder has been set. If it has not been set, then
#' prompt user to specify the download locations, if in interactive mode. If 
#' not in interactive mode, and it has not been set, then set to "~/prismtmp".
#' 
#' @export
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

#' @export
#' @rdname prism_check_dl_dir
path_check <- function()
{
  .Deprecated("`prism_check_dl_dir()`")
  prism_check_dl_dir()
}