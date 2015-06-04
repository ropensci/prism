#' List available datasets
#' @description List the available data sets to load that have already been downloaded.
#' @param absPath TRUE if you want to return the absolute path.
#' @param name TRUE if you want file names and titles of data products.
#' @return  a data frame of downloaded datasets 
#' @examples \dontrun{
#' ### Just get file names, used in many other prism* fxn
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)
#' ls_prism_data()
#' 
#' ### Get absolute path values for use with other data
#' ls_prism_data(absPath = T)
#' 
#' ### See prism files you have with title of data product
#' ls_prism_data(name=T)
#' }
#' @export

ls_prism_data <- function(absPath = F, name = F){
  if (is.null(getOption('prism.path'))) {
    path_check()
  }
  files <- list.files(getOption('prism.path'))
  files <- files[grep("zip", files, invert=TRUE)]
  fullPath <- paste(getOption('prism.path'), files, 
                    paste0(files, ".bil"), sep="/")
  meta_d <- unlist(prism_md(files))
  out <- data.frame(files,stringsAsFactors = F)
  
  if(absPath){
  out$abs_path <- fullPath
  } 
  
  if(name){
    out$product_name <- meta_d
   
  }
    return(out)
  
}
