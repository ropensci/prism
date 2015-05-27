#' List available datasets
#' @description List the available data sets to load that have already been downloaded.
#' @param absPath TRUE if you want to return the absolute path.
#' @param name TRUE if you want file names and titles of data products.
#' @return list of downloaded prism datasets, OR a data.frame of downloaded datasets (if \code{name} == TRUE)
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
  if(absPath){
    files <- files[grep("zip", files, invert=TRUE)]
    return(paste(getOption('prism.path'), files, 
                 paste0(files, ".bil"), sep="/"))
  } else if(name){
    prismfilexml <- paste0(getOption('prism.path'), 
                           "/", ls_prism_data(), 
                           "/", ls_prism_data(), ".xml")
             
    meta_d <- sapply(prismfilexml, prism_md, simplify=FALSE)
    pname <- unlist(lapply(meta_d, function(x) x[2]))
    out <- as.data.frame(cbind(files[grep("zip", 
                                          files, 
                                          invert=TRUE)], 
                               pname))
    rownames(out) <- 1:dim(out)[1]
    colnames(out) <- c("File name", "Product name")
    return(out)
  } else {
    return(files[grep("zip", files, invert=TRUE)])
  }
}
