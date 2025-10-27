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
#' @returns Invisibly returns `path`
#'
#' @examples
#' \dontrun{
#' prism_set_dl_dir('.')
#' prism_set_dl_dir('~/prism_data')
#' }
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
  
  prism_dl_dir_check_for_v1(path)
  
  options(prism.path = path)
  invisible(path)
}

#' @description 
#' `prism_get_dl_dir()` gets the folder that prism data will be saved to. It is
#' a wrapper around `getOption("prism.path")` so the user does not have to 
#' remember the option name. 
#' 
#' @examples
#' prism_get_dl_dir()
#' 
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
#' download location. If not in interactive mode and it has not been set then 
#' it will stop and post an error. 
#' 
#' @examples
#' \dontrun{
#' prism_check_dl_dir()
#' }
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
        "Please enter the full or relative path to download files to: "
      )
      
      if (nchar(user_path) == 0)
        stop("You did not enter a path. Please call `prism_set_dl_dir()` again.")
      
      # User may have input path with quotes. Remove these.
      user_path <- gsub(pattern = c("\"|'"), "", user_path)
      # Deal with relative paths
      user_path <- normalizePath(user_path, winslash = "/", mustWork = FALSE)
      
    } else {
      stop(paste(
        "prism.path has not been set and this is being called non interactively.",
        "You must set the prism download directory using `prism_set_dl_dir()`"
      ))
    }
    
    # check that specified path exists. if it does not confirm from user that
    # they do want to create the folder
    if (!dir.exists(user_path)) {
      cat("The folder does not exist.\n")
      repeat {
        
        cat("Press 1 to create the folder or 2 to cancel: ")
        user_input <- as.integer(readline())
        
        if (is.na(user_input)) {
          cat("Invalid input. Please enter 1 or 2.\n")
        } else if (user_input == 1) {
          cat(user_path, "will be created.\n")
          break
        } else if (user_input == 2) {
          cat("Cancelling setting the prism download folder.\n")
          stop("prism download folder is not set, and user canclled creating the folder.")
        } else {
          cat("Invalid input. Please enter 1 or 2.\n")
        }
      }
    } 
    
    prism_set_dl_dir(user_path, create = TRUE)
  } else {
    prism_dl_dir_check_for_v1(user_path)
  }
  
  invisible(user_path)
}

prism_dl_dir_check_for_v1 <- function(user_path) {
  ff <- list.dirs(user_path)
  
  if(any(c(
    grepl('PRISM', ff),
    grepl('stable', ff),
    grepl('4kmD2', ff),
    grepl('4kmM3', ff)
  ))) {
    warning(paste(
      "The specified PRISM download directory appears to have data from the pre September 2025 API.",
      "We recommend either starting a new download directory for the new API and/or",
      "deleting and redownloading all data from the new API.",
      sep = '\n'
    ))
  }
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