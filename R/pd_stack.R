#' Stack prism data
#' 
#' `pd_stack()` creates a raster stack from prism data. It is up to the user to
#' ensure that `pd` is of the expected variable and temporal period, i.e., the 
#' function does no checking and will stack data with different variables or
#' temporal periods.
#' 
#' @param pd,prismfile a vector of prism data returned by [prism_archive_ls()] 
#'   or [prism_archive_subset()].
#'   
#' @examples \dontrun{
#' get_prism_dailys(
#'   type="tmean", 
#'   minDate = "2013-06-01", 
#'   maxDate = "2013-06-14", 
#'   keepZip = FALSE
#' )
#' # get a raster stack of June 1-14 daily tmean
#' mystack <- prism_stack(prism_archive_subset(
#'   "tmean", 
#'   minDate = "2013-06-01", 
#'   maxDate = "2013-06-14"
#' ))
#' }
#' @export
pd_stack <- function(pd) {
  
  prismfile_fp <- pd_to_file(pd)
  
  masterRaster <- raster::stack(raster::raster(prismfile_fp[1]))
  if (length(prismfile_fp) > 1) {
    for (i in 2:length(prismfile_fp)) {
      masterRaster <- raster::addLayer(
        masterRaster,
        raster::raster(prismfile_fp[i])
      )  
    }
  }
  
  return(masterRaster)
}

prism_stack <- function(prismfile) {
  .Deprecated("`pd_stack()`") 
  
  pd_stack(prismfile)
}
