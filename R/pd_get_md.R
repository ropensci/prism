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

  if (length(final_txt_full) == 0) {
    stop("No files exist to obtain metadata from.")
  }
  out <- lapply(seq_along(final_txt_full), function(i) {
    readin <- tryCatch(
      utils::read.delim(
        final_txt_full[i],
        sep = "\n",
        header = FALSE,
        stringsAsFactors = FALSE
      ),
      error = function(e) {
        warning(e)
        warning(paste0(
          "Problem opening ",
          final_txt_full[i],
          ". The folder may exist without the .info.text file inside it."
        ))
      }
    )
    str_spl <- stringr::str_split(
      as.character(readin[[1]]),
      ": ",
      n = 2,
      simplify = TRUE
    )

    names_md <- str_spl[, 1]
    data_md <- str_spl[, 2]
    out <- matrix(data_md, nrow = 1)
    out <- as.data.frame(out, stringsAsFactors = FALSE)
    names(out) <- names_md

    # add in two additional values (not found in .info.txt)
    out$file_path <- final_txt_full[i]
    out$folder_path <- file.path(prism_get_dl_dir(), pd[i])

    out
  })

  out <- dplyr::bind_rows(out)

  out
}
