#' @title Delete early / provisional PRISM data if replaced by provisional / stable data.
#' @description Searches the download folder for duplicated PRISM data
#' and keeps only the newest version.
#' @inheritParams get_prism_dailys
#' @importFrom dplyr bind_rows
#' @return NULL
del_early_prov <- function(type, minDate = NULL, maxDate = NULL, dates = NULL){
  path_check()
  browser()
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  md <- get_metadata(type = type, dates = dates)
  mddf <- dplyr::bind_rows(md)
  mddf$dates_str <- stringr::str_extract(mddf$PRISM_FILENAME, "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")
  
  duplicates <- mddf$dates_str[duplicated(mddf$dates_str)]
  for(dup in duplicates){
    dups <- mddf[mddf$dates_str == dup,]
    dups$dates_num <- as.numeric(dups$dates_str)
    to_delete <- which(dups$dates_num < max(dups$dates_num))
    if(length(to_delete) == 0){
      # This happens if the dates are all the same.
      to_delete <- 1:(NROW(dups) - 1)
    }
    unlink(dups$folder_path[to_delete], recursive = TRUE)
    # Check if the folder was deleted.
    if(file.exists(file.path(dups$file_path[to_delete], ".."))){
      warning(paste0("Unable to remove folder ", file.path(dups$file_path[to_delete], ".."),
                     ". Check permissions."))
    }
  }
  NULL
}
