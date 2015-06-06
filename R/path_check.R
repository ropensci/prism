#' handle existing directory
#' @description create new directory for user if they don't have one to store prism files
#' @export
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
