#' handle existing directory
#' @description create new directory for user if they don't have one to store prism files
#' @export

path_check <- function(){
  user_path <- NULL
  if(is.null(getOption('prism.path'))){
    message("You have not set a path to hold your prism files")
    user_path <- readline("Please enter the full path to download files to (hit enter to use default '~/prismtmp'): ")
    user_path <- ifelse(grepl("",user_path),paste(Sys.getenv("HOME"),"prismtmp",sep="/"),user_path)
  }
  if(!is.null(user_path)){
    user_path <- getOption('prism.path')
  }
  ## Check if path exists
  
  if(!file.exists(user_path)){
    dir.create(user_path)
  }
}
