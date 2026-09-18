# necessary for testing this function using local_mocked_bindings()
interactive <- NULL
select.list <- NULL

#' Update stale files in a PRISM archive
#'
#' `prism_archive_update()` checks release status via [pd_check_versions()] and 
#' re-downloads any files flagged as `"update_available"`. It is essentially a
#' convenience wrapper for a user calling something along the lines of:
#' ```
#' x <- pd_check_versions()
#' pd_to_update <- x[["pd"]][x[["status"]] == "update_available"]
#' get_prism_pd(pd_to_update, overwrite = TRUE)
#' ```
#' 
#' When run interactively, the user is given a choice on which `pd` to update. 
#' When not interactive, all `pd` that are found that need updated, are updated.
#'
#' @param pd A `pd` object to check and update. If `NULL` (the default), the
#'   full local archive is used via [prism_archive_ls()].
#'   
#' @param keepZip,quiet Passed through to [get_prism_pd()] / 
#'   [pd_check_versions()].
#'
#' @return Invisibly returns the `pd` values that were actually re-downloaded
#'   (an empty character vector if nothing needed updating).
#'   
#' @examples \dontrun{
#' # update the entire archive
#' prism_archive_update()
#' 
#' # update only precipitation data
#' pd <- prism_archive_subset(type = "ppt")
#' prism_archive_update(pd)
#' }
#' 
#' @importFrom utils select.list
#'   
#' @export
prism_archive_update <- function(pd = NULL, keepZip = prism_get_keepZip(), quiet = FALSE) {
  
  if (!is.null(pd)) {
    if (length(pd) == 0 || !is.character(pd)) {
      stop("`pd` should be a character vector.")
    }
    verify_pd(pd)
  } else {
    pd <- prism_archive_ls()
  }
  
  status_df <- pd_check_versions(pd, quiet = quiet)
  outdated <- status_df[["pd"]][status_df[["status"]] == "update_available"]
  
  if (length(outdated) == 0) {
    if (!quiet) message("Everything checked is already at the latest release. Nothing to update.")
    return(invisible(character(0)))
  }
  
  to_update <- outdated
  
  if (interactive()) {
    choices <- c("All", "None", outdated)
    selection <- select.list(
      choices,
      multiple = TRUE,
      graphics = FALSE,
      title = sprintf(
        "%d file(s) have a newer release available. Select which to update:",
        length(outdated)
      )
    )
    
    if (length(selection) == 0 || "None" %in% selection) {
      if (!quiet) message("No files selected. Nothing updated.")
      return(invisible(character(0)))
    }
    
    to_update <- if ("All" %in% selection) outdated else selection
  }
  
  if (!quiet) {
    message(
      sprintf("Updating %d file(s) with a newer release available...", 
              length(to_update))
    )
  }
  
  invisible(get_prism_pd(to_update, keepZip = keepZip, overwrite = TRUE))
}
