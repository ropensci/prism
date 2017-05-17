#' @title Delete early / provisional PRISM data if replaced by provisional / stable data.
#' @description Searches the download folder for duplicated PRISM data
#' and keeps only the newest version.
#' @inheritParams get_prism_dailys
#' @importFrom dplyr bind_rows
#' @return NULL
#' @export
del_early_prov <- function (type, minDate = NULL, maxDate = NULL, dates = NULL) 
{
  path_check()
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, 
                             dates = dates)
  md <- get_metadata(type = type, dates = dates)
  md <- lapply(md, function(x) {
    names(x) <- stringr::str_replace(names(x), "_DATASET", 
                                     "")
    x
  })
  mddf <- dplyr::bind_rows(md)
  mddf$dates_str <- stringr::str_extract(mddf$PRISM_FILENAME, 
                                         "[0-9]{8}")
  duplicates <- mddf$dates_str[duplicated(mddf$dates_str)]
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
      dups$new_to_delete[!dups$to_delete][length(dups$to_delete[!dups$to_delete])] <- FALSE
      dups$to_delete <- dups$new_to_delete
    }
    unlink(dups$folder_path[dups$to_delete], recursive = TRUE)
    lapply(dups$folder_path[dups$to_delete], function(x){
      if(file.exists(x)) {
        warning(paste0("Unable to remove folder ", x, ". Check permissions."))
      }
    })
  }
  NULL
}
