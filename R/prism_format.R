prism_formats <- c('geotiff', 'bil', 'nc')

#' Set/get the PRISM grid download format
#' 
#' The PRISM web service provides PRISM grids in Cloud Optimized GeoTIFF 
#' (geotiff), bil, and netCDF (nc) format. 
#' `prism_set_format()` lets the user specify the format that will be used by 
#' the package, while `prism_get_format()` returns the format currently being 
#' used. BIL is the default to maintain compatibility with previous package
#' versions. GeoTIFF is recommended for new archives because it is generally
#' more storage-efficient and is the format used for 30-year normals. A future
#' release is planned to make GeoTIFF the default. Users should choose one
#' format and stick with it; the package is not set up to
#' handle a PRISM data download directory that has multiple formats in it.
#' Use [prism_archive_save_config()] to save the current format in the selected
#' archive so it is restored when the archive is selected again. If a changed
#' format conflicts with the active archive's saved configuration, the change
#' warns. Interactive sessions can answer `yes` to change this session only,
#' `no` to leave the current format unchanged, or `cancel` to abort the call.
#' Non-interactive calls warn and proceed. Save the configuration again to
#' persist a changed format.
#' 
#' @param data_format One of 'geotiff', 'bil', or 'nc'
#' 
#' @return Invisibly returns the selected format. An interactive `no` response
#'   returns the current format unchanged; `cancel` stops the call.
#' 
#' @export
prism_set_format <- function(data_format)
{
  data_format <- match.arg(data_format, prism_formats)

  if (!prism_archive_confirm_setting_change("format", data_format)) {
    return(invisible(prism_get_format()))
  }

  options(prism.format = data_format)
  invisible(data_format)
}

#' @export
#' @rdname prism_set_format
prism_get_format <- function()
{
  return(getOption('prism.format'))
}

# returns the current file extension; can't use prism_get_format directly b/c
# it uses geotiff insead of tif
prism_format_file_ext <- function()
{
  fext <- c('geotiff' = '.tif', 'bil' = '.bil', 'nc' = '.nc')
  
  unname(fext[prism_get_format()])
}
