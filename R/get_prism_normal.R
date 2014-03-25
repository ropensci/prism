#' Download data for 30 year normals of climate variables
#' @description Download data from the prism project for 30 year normals at 4km or 800m grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#' @param resolution The spatial resolution of the data, must be either "4km" or "800m"
#' @details You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' 
get_prism_normal <- function(type, resolution){
  
  type <- match.args(type, c("ppt","tmean","tmin","tmax"))
  res<- match.args(resolution, c("4km","800m"))
  
  
}