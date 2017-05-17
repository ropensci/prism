#' @title Delete early / provisional PRISM data if replaced by provisional / stable data.
#' @description Searches the download folder for duplicated PRISM data
#' and keeps only the newest version.
#' @inheritParams get_prism_dailys
#' @importFrom dplyr bind_rows
#' @return NULL
#' @export
del_early_prov <- function(type, minDate = NULL, maxDate = NULL, dates = NULL){
  path_check()
  dates <- prism:::gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  md <- prism:::get_metadata(type = type, dates = dates)
  md <- lapply(md, function(x){
    names(x) <- stringr::str_replace(names(x), "_DATASET", "")
    x
  })
  mddf <- dplyr::bind_rows(md)
  mddf$dates_str <- stringr::str_extract(mddf$PRISM_FILENAME, 
                                         "[0-9]{8}")
  
  duplicates <- mddf$dates_str[duplicated(mddf$dates_str)]
  for(dup in duplicates){
    dups <- mddf[mddf$dates_str == dup,]
    dups$dates_num <- as.numeric(dups$dates_str)
    
    # This assumes that the files are in order of date modified
    to_delete <- 1:(NROW(dups) - 1)
    
    unlink(dups$folder_path[to_delete], recursive = TRUE)
    # Check if the folder was deleted.
    if(file.exists(file.path(dups$file_path[to_delete], ".."))){
      warning(paste0("Unable to remove folder ", file.path(dups$file_path[to_delete], ".."),
                     ". Check permissions."))
    }
  }
  NULL
}
