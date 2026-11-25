#' @importFrom utils setTxtProgressBar txtProgressBar
#' @importFrom httr HEAD

.onAttach <- function(libname, pkgname){
  packageStartupMessage(
    "Be sure to set the download folder using `prism_set_dl_dir()`.",
    "\nBy default, PRISM data are downloaded in BIL format to maintain ",
    "compatibility with previous package versions.",
    "\nConsider using GeoTIFF for new downloads: it is generally more ",
    "storage-efficient and is used for 30-year normals.",
    "\nA future release is planned to make GeoTIFF the default. ",
    "See ?prism_set_format for more details."
  )
}

.onLoad <- function(libname, pkgname) {
  if (is.null(getOption("prism.format"))) {
    options(prism.format = "bil")
  }
  
  if (is.null(getOption("prism.keepZip"))) {
    options(prism.keepZip = TRUE)
  }
}
