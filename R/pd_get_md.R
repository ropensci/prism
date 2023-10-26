#' Get prism metadata
#'
#' Retrieves prism metadata from the specified prism data. "prism data", i.e.,
#' `pd` are the folder names returned by [prism_archive_ls()] or
#' [prism_archive_subset()]. These functions get the name or date from these 
#' data, or convert these data to a file name. A warning is provided if the 
#' specified prism data do not exist in the archive.
#'
#' @details
#' The metadata includes the following variables from the .info.txt file for
#' daily, monthly, and annual data:
#' - PRISM_DATASET_FILENAME
#' - PRISM_DATASET_CREATE_DATE
#' - PRISM_DATASET_TYPE
#' - PRISM_DATASET_VERSION
#' - PRISM_CODE_VERSION
#' - PRISM_DATASET_REMARKS
#'
#' Additionally, two local variables are added identifying where the file is
#' located on the local system:
#' - file_path
#' - folder_path
#'
#' The annual and monthly normals data includes different keys in
#' the .info.txt, so they are renamed to be the same as those found in the
#' other temporal data. The keys/variables are renamed as follows:
#' - PRISM_FILENAME --> PRISM_DATASET_FILENAME
#' - PRISM_CREATE_DATE --> PRISM_DATASET_CREATE_DATE
#' - PRISM_DATASET --> PRISM_DATASET_TYPE
#' - PRISM_VERSION --> PRISM_CODE_VERSION
#' - PRISM_REMARKS --> PRISM_DATASET_REMARKS
#'
#' Additionally, the normals does not include PRISM_DATASET_VERSION, so that
#' variable is added with `NA` values.
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
  out <- lapply(1:length(final_txt_full), function(i) {
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

  # update column names for normals to match those from other time periods
  if (all(colnames(out) %in% names(normals_name_map()))) {
    # rename columns
    colnames(out) <- normals_name_map()[colnames(out)]
    # add empty column
    out[["PRISM_DATASET_VERSION"]] <- NA

    message(
      "Renaming variables for normals to match those for other temporal periods.\n",
      "See details in ?pd_get_md."
    )
  }

  out
}

normals_name_map <- function() {
  c(
    "PRISM_FILENAME" = "PRISM_DATASET_FILENAME",
    "PRISM_CREATE_DATE" = "PRISM_DATASET_CREATE_DATE",
    "PRISM_DATASET" = "PRISM_DATASET_TYPE",
    "PRISM_VERSION" = "PRISM_CODE_VERSION",
    "PRISM_REMARKS" = "PRISM_DATASET_REMARKS",
    "file_path" = "file_path",
    "folder_path" = "folder_path"
  )
}
