#' Set/get whether zip files are kept after downloading
#' 
#' The PRISM data are downloaded as zip files and then unzipped. All PRISM
#' download functions have a logical argument that controls this for each
#' download. The user can set/change the default behavior rather than change it
#' in every call. The package default is `TRUE` to maintain previous behavior.
#' Use [prism_archive_save_config()] to save the current default in the selected
#' archive so it is restored when the archive is selected again. If a changed
#' setting conflicts with the active archive's saved configuration, the change
#' warns. Interactive sessions can answer `yes` to change this session only,
#' `no` to leave the current setting unchanged, or `cancel` to abort the call.
#' Non-interactive calls warn and proceed. Save the configuration again to
#' persist a changed setting.
#' 
#' @param keepZip Logical. Keep if `TRUE`; delete if `FALSE`.
#' 
#' @return `prism_get_keepZip()` returns the current value of `keepZip`. 
#'   `prism_set_keepZip()` invisibly returns the value if it is successfully set.
#'   An interactive `no` response returns the current value unchanged; `cancel`
#'   stops the call.
#' 
#' @export
prism_set_keepZip <- function(keepZip)
{
  if (length(keepZip) != 1 | !is.logical(keepZip)) {
    stop("`keepZip` should be a single logical value.")
  }

  if (!prism_archive_confirm_setting_change("keepZip", keepZip)) {
    return(invisible(prism_get_keepZip()))
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
