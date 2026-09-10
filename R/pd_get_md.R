#' Get prism metadata
#'
#' Retrieves prism metadata from the specified prism data. "prism data", i.e.,
#' `pd` are the folder names returned by [prism_archive_ls()] or
#' [prism_archive_subset()]. A warning is provided if the specified prism data 
#' do not exist in the archive.
#'
#' @details
#' The metadata includes a subset of the the following variables from the 
#' .info.txt file for daily, monthly, and annual, time series and normals data:
#' - PRISM_DATASET_FILENAME
#' - PRISM_DATASET_CREATE_DATE
#' - PRISM_DATASET_TYPE
#' - PRISM_DATASET_VERSION
#' - PRISM_CODE_VERSION
#' - PRISM_DATASET_REMARKS
#' - PRISM_SOURCE_FILENAME
#' - PRISM_SOURCE_CREATE_DATE
#' - PRISM_DATASET_RELEASE_NUMBER
#'
#' Additionally, two local variables are added identifying where the file is
#' located on the local system:
#' - file_path
#' - folder_path
#' 
#' Not all metadata includes all variables, so only the variables that are 
#' included in the specified `pd` are included in the returned data frame. If
#' not all variables are found in all of the `pd`, `NAs` are introduced into 
#' the missing variables.  
#'
#' @inheritParams pd_get_name
#'
#' @return data.frame containing metadata for all specified prism data.
#' 
#' @examples\dontrun{
#' #' # Assumes 2000-2002 annual precipitation data is already downloaded
#' pd <- prism_archive_subset('ppt', 'annual', years = 2000:2002)
#' df <- pd_get_md(pd)
#' head(df)
#' }
#'
#' @export
pd_get_md <- function(pd) {
  prism_check_dl_dir()

  final_txt_full <- normalizePath(file.path(
    prism_get_dl_dir(),
    pd,
    paste0(pd, ".info.txt")
  ))

  missing_files <- !file.exists(final_txt_full)
  
  if (all(missing_files)) {
    stop("No .info.txt files exist to obtain metadata from.", call. = FALSE)
  }
  
  if (any(missing_files)) {
    warning(
      "Could not find .info.txt file(s): ",
      paste(final_txt_full[missing_files], collapse = ", "),
      call. = FALSE
    )
  }
  
  final_txt_full <- final_txt_full[!missing_files]
  pd <- pd[!missing_files]
  
  out <- lapply(seq_along(final_txt_full), function(i) {
    lines <- readLines(
      final_txt_full[i],
      warn = FALSE,
      encoding = "UTF-8"
    )
    
    lines <- lines[nzchar(lines)]
    
    if (!length(lines)) {
      warning(
        "The metadata file is empty: ",
        final_txt_full[i],
        call. = FALSE
      )
      
      return(data.frame(
        file_path = final_txt_full[i],
        folder_path = file.path(prism_get_dl_dir(), pd[i]),
        stringsAsFactors = FALSE
      ))
    }
    
    fields <- stringr::str_split_fixed(lines, ": ", n = 2)
    
    if (any(!nzchar(fields[, 1])) || any(!nzchar(fields[, 2]))) {
      warning(
        "Some lines in ", final_txt_full[i],
        " could not be parsed as `KEY: VALUE` metadata.",
        call. = FALSE
      )
    }
    
    fields <- fields[nzchar(fields[, 1]), , drop = FALSE]
    
    values_by_name <- split(fields[, 2], fields[, 1])
    
    md <- vapply(
      values_by_name,
      paste,
      collapse = ";\n",
      FUN.VALUE = character(1)
    )
    
    out <- as.data.frame(
      as.list(md),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    
    out$file_path <- final_txt_full[i]
    out$folder_path <- file.path(prism_get_dl_dir(), pd[i])
    
    out
  })
  
  out <- dplyr::bind_rows(out)
  
  out
}


