#' List available datasets
#' @description List the available data sets to load that have already been downloaded.
#' @param absPath TRUE if you want to return the absolute path.
#' @examples \dontrun{
#' ls_prism_data()
#' }
#' @export

ls_prism_data <- function(absPath = F){
  files <- list.files(options("prism.path")[[1]])
  if(absPath){
    files <- files[grep("zip",files,invert=T)]
    return(paste(options("prism.path")[[1]],files,paste(files,".bil",sep=""),sep="/"))
  } else {return(files[grep("zip",files,invert=T)])}

}