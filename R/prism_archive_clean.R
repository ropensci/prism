#' Clean the prism data by removing early and provisional data
#' 
#' `prism_archive_clean()` 'cleans' the prism download data by removing early 
#' and/or provisional data if newer (provisional or stable) data also exist 
#' for the same variable and temporal period. Stable data are newer than 
#' provisional data that are newer than early data; only the newest data are
#' kept when the "clean" is performed.
#' 
#' `prism_archive_clean()` prompts the user to verify the folders that should be
#' removed when R is running in interactive mode. Otherwise, all data that are 
#' identified to be older than the newest available data are removed. 
#' 
#' Daily data are considered "early" for the current month. The previous six 
#' months are provisional data. After six months data are considered stable. 
#' Thus early data only exist for daily data, while there can be monthly (and 
#' presumably yearly) provisional data. 
#' 
#' @inheritParams prism_archive_subset
#' 
#' @return Invisibly returns vector of all deleted folders.
#' 
#' @examples \dontrun{
#' # delete any provisional annual precipitation data from 2000-2023
#' # del_files will containg any deleted files
#' del_files <- prism_archive_clean('ppt', 'annual', 2000:2023)
#' }
#' 
#' @export

prism_archive_clean <- function(type, temp_period, years = NULL, mon = NULL, 
                             minDate = NULL, maxDate = NULL, dates = NULL) {
  prism_check_dl_dir()
  
  pd <- prism_archive_subset(type, temp_period, years = years, mon = mon, 
                          minDate = minDate, maxDate = maxDate, dates = dates)
  
  # identify folders for removal ----------------
  # find any folders with "early"
  early <- pd[stringr::str_detect(pd, "_early_")]
  delete <- c()
  if (length(early) > 0) {
    # replace _early_ with _provisional_ and _stable_ and see if those folders
    # exist. if so, delete early version
    prov <- stringr::str_replace(early, "_early_", "_provisional_")
    stable <- stringr::str_replace(early, "_early_", "_stable_")
    
    delete <- early[file.exists(file.path(prism_get_dl_dir(), prov))]
    delete2 <- early[file.exists(file.path(prism_get_dl_dir(), stable))]
    delete <- unique(c(delete, delete2))
  }
  
  # now find provisional and see if they have stable versions
  prov <- pd[stringr::str_detect(pd, "_provisional_")]
  delete2 <- c()
  if (length(prov) > 0) {
    stable <- stringr::str_replace(prov, "_provisional_", "_stable_")
    
    delete2 <- prov[file.exists(file.path(prism_get_dl_dir(), stable))]
  }
  
  delete <- unique(c(delete, delete2))
  
  # return if nothing to delete
  if (length(delete) == 0) {
    return(invisible(NULL))
  }
  
  # otherwise, continue to remove the early/provisional folders
  # prompt user to accept -----------------------
  delete <- folders_to_remove(delete)
  
  # remove --------------------------------------
  
  del_paths <- file.path(prism_get_dl_dir(), delete)
  unlink(del_paths, recursive = TRUE)
  
  # post warning regarding any folders that were supposed to be deleted, but
  # could not be removed
  
  del_i <- dir.exists(del_paths)
  no_delete <- delete[del_i]
  delete <- delete[!del_i]
  if (length(no_delete) > 0) {
    warning(
      paste0(
        "Unable to remove the following folders. Check permissions.",
        paste("\n  -", no_delete, collapse = "\n  - ")
      )
    )
  }
  
  invisible(delete)
}

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

#' @description 
#' `del_early_prov()` is a deprecated version of `prism_archive_clean()` that 
#' only works for daily data, and does not prompt the user to confirm which 
#' folders should be removed.
#' 
#' @inheritParams get_prism_dailys
#' @export
#' @rdname prism_archive_clean
del_early_prov <- function (type, minDate = NULL, maxDate = NULL, dates = NULL) 
{
  .Deprecated("`prism_archive_clean()`")
  prism_check_dl_dir()
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, 
                             dates = dates)
  pd <- prism_archive_subset(type = type, temp_period = "daily", dates = dates)
  mddf <- pd_get_md(pd)

  mddf$dates_str <- stringr::str_extract(mddf$PRISM_DATASET_FILENAME, 
                                         "[0-9]{8}")
  duplicates <- mddf$dates_str[duplicated(mddf$dates_str)]
  
  out <- NULL
  
  for (dup in duplicates) {
    dups <- mddf[mddf$dates_str == dup, ]
    dups$dates_num <- as.numeric(dups$dates_str)
    dups$priority <- sapply(dups$folder_path, function(x){
      if(stringr::str_detect(x, "stable")){
        return(1)
      } else if (stringr::str_detect(x, "provisional")){
        return(2)
      } else if (stringr::str_detect(x, "early")){
        return(3)
      }
    })
    dups$to_delete <- dups$priority > min(dups$priority)
    if(sum(!dups$to_delete) > 1){
      # Here, there is more than one of the highest priority
      # Just assume the later one is newer
      dups$new_to_delete <- dups$to_delete
      dups$new_to_delete[!dups$to_delete] <- TRUE
      ll <- length(dups$to_delete[!dups$to_delete])
      dups$new_to_delete[!dups$to_delete][ll] <- FALSE
      dups$to_delete <- dups$new_to_delete
    }
    unlink(dups$folder_path[dups$to_delete], recursive = TRUE)
    tmp <- lapply(dups$folder_path[dups$to_delete], function(x){
      if(file.exists(x)) {
        warning(paste0("Unable to remove folder ", x, ". Check permissions."))
      } else {
        x
      }
    })
    
    out <- c(out, unlist(tmp))
  }
  
  invisible(out)
}
