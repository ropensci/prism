#' (Defunct) Clean the prism data by removing early and provisional data
#' 
#' `prism_archive_clean()` is defunct. PRISM download identifiers no
#' longer distinguish early, provisional, and stable data, so the
#' function can no longer identify redundant archived datasets.
#'
#' Use [pd_check_versions()] to identify locally archived
#' daily and monthly grids for which PRISM has published a newer release.
#' Use [prism_archive_update()] to redownload available updates.
#' 
#' @export

prism_archive_clean <- function(...) {
  stop(
    "`prism_archive_clean()` is defunct because PRISM no longer provides ",
    "early, provisional, and stable dataset names. ",
    "Use `prism_archive_check_versions()` to identify available updates ",
    "and `prism_archive_update()` to download them.",
    call. = FALSE
  )
}

# TODO: remove this later. Leaving in case we can reuse for 
# prism_archive_update()
# determines which folders to remove based on UI
folders_to_remove <- function(x) {
  if (interactive()) {
    # prompts user to select folders to be removed
    # if there are more than 25, will only print the first 25, and will have 
    # options for 1st 25, or all. 
    msg <- "Please select the PRISM folders to remove:\n"
    choices <- paste("1: None", "2: All", sep = "\n")
    i <- 2
    if (length(x) > 25) {
      msg <- paste0(
        msg, "There are ", length(x), 
        " folders to be removed, but only the first 25 are options.\n"
      )
      
      choices <- paste(
        "1: None", "2: Only the 25 shown below.", 
        "3: All (even those not listed below).", sep = "\n"
      )
      i <- 3
    }
    
    msg <- paste0(msg, "\n", choices)
    n <- min(25, length(x))
    
    choices <- paste(paste0(seq(n) + i, ": ", x[seq(n)]), collapse = "\n")
    msg <- paste0(msg, "\n", choices, "\n")
    cat(msg)
    
    ui <- readline("Enter choices seperated by commas: ")
    
    # remove any white space and split by commas
    ui <- as.numeric(stringr::str_split(
      stringr::str_remove_all(ui, " "), 
      ",", 
      simplify = TRUE
    ))
    
    if (1 %in% ui) {
      x <- NULL
      message("No folders will be removed.\n")
    } else {
      del_i <- ui - i
      
      if (-1 %in% del_i) {
        # delete only first 25
        x <- x[1:25]
      }
      else if (!(0 %in% del_i)) {
        # delete those specified by user
        x <- x[del_i]
      } 
      # else delete all (don't need to reset x)
    }
  }
  
  x
}
