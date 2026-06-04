#' @importFrom utils setTxtProgressBar txtProgressBar
#' @importFrom httr HEAD

.onAttach <- function(libname, pkgname){
  packageStartupMessage(
    "Be sure to set the download folder using `prism_set_dl_dir()`.",
    "\nBy default, prism data are downloaded in GeoTIFF format. ",
    "See ?prism_set_format for more details."
  )
  
  options(prism.format = "geotiff")
}
