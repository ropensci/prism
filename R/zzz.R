#' @importFrom utils setTxtProgressBar txtProgressBar
#' @importFrom httr HEAD

.onAttach <- function(libname, pkgname){
  packageStartupMessage(
    "Be sure to set the download folder using `prism_set_dl_dir()`."
  )
}
