#' Stack Prism files
#' @description Create a stack of prism files
#' @param prismfile a vector of file names returned by ls_prism_data()
#' @examples \dontrun{
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)
#' mystack <- prism_stack(ls_prism_data()[1:14])
#' }
#' @export

prism_stack <- function(prismfile){
  prismfile <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".bil",sep="")
  masterRaster <- stack(raster(prismfile[1]))
  for(i in 2:length(prismfile)){
    masterRaster<-  addLayer(masterRaster,raster(prismfile[i]))  
  }
  return(masterRaster)
}