#' Set/get whether zip files are kept after downloading
#' 
#' The PRISM data are downloaded as zip files and then unzipped. All of the 
#' [get_prism_*()`](get_prism_data) functions have a logical argument that 
#' controls this for each download. These functions let the user set/change the 
#' default behavior rather than change it in every call to `get_prism_*()`. The
#' package default is `TRUE` to maintain previous, default behavior. 
#' 
#' @param keepZip Logical. Keep if `TRUE`; delete if `FALSE`.
#' 
#' @return `prism_get_keepZip()` returns the current value of `keepZip`. 
#'   `prism_set_keepZip()` invisibly returns the value if it is successfully set.
#' 
#' @export
prism_set_keepZip <- function(keepZip)
{
  if (length(keepZip) != 1 | !is.logical(keepZip)) {
    stop("`keepZip` should be a single logical value.")
  }
  
  options(prism.keepZip = keepZip)
  invisible(keepZip)
}

#' @export
#' @rdname prism_set_keepZip
prism_get_keepZip <- function()
{
  return(getOption('prism.keepZip'))
}
