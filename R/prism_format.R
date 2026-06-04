prism_formats <- c('geotiff', 'bil', 'asc', 'nc')

#' Set/get the PRISM grid download format
#' 
#' The PRISM web service provides PRISM grids in Cloud Optimized GeoTIFF 
#' (geotiff), bil, ASCII Grid (asc), and netCDF (nc) format. 
#' `prism_set_format()` lets the user specify the format that will be used by 
#' the package, while `prism_get_format()` returns the format currently being 
#' used. GeoTIFF is the default used by the package. It is recommended that 
#' users choose one format and stick with it. The package is not setup to 
#' handle a PRISM data download directory that has multiple formats in it.  
#' 
#' @param data_foramt One of 'geotiff', 'bil', 'asc', or 'nc'
#' 
#' @return Invisibly returns data_format if it is valid.
#' 
#' @export
prism_set_format <- function(data_format)
{
  data_format <- match.arg(data_format, prism_formats)
  options(prism.format = data_format)
  invisible(data_format)
}

#' @export
#' @rdname prism_set_format
prism_get_format <- function()
{
  return(getOption('prism.format'))
}
