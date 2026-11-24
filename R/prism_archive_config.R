#' Save PRISM archive settings
#'
#' Save the current download format and `keepZip` setting to
#' `prism_archive.config` in the directory returned by [prism_get_dl_dir()].
#' The file is loaded automatically when that directory is selected with
#' [prism_set_dl_dir()]. Calling this function again replaces the existing
#' configuration file. Changes made later with [prism_set_format()] or
#' [prism_set_keepZip()] affect the current session only; call this function
#' again to save those changes.
#'
#' @return Invisibly returns the path to the configuration file.
#'
#' @seealso [prism_set_dl_dir()], [prism_set_format()],
#'   [prism_set_keepZip()]
#'
#' @export
prism_archive_save_config <- function() {
  path <- prism_get_dl_dir()

  if (is.null(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("Set the PRISM download directory before saving its config.",
         call. = FALSE)
  }
  if (!dir.exists(path)) {
    stop("The PRISM download directory does not exist: ", path,
         call. = FALSE)
  }

  data_format <- prism_get_format()
  if (length(data_format) != 1L || is.na(data_format) ||
      !data_format %in% prism_formats) {
    stop("The current PRISM format is invalid and cannot be saved.",
         call. = FALSE)
  }

  keep_zip <- prism_get_keepZip()
  if (length(keep_zip) != 1L || !is.logical(keep_zip) || is.na(keep_zip)) {
    stop("The current `keepZip` setting is invalid and cannot be saved.",
         call. = FALSE)
  }

  config_file <- file.path(path, "prism_archive.config")
  config <- data.frame(
    format = data_format,
    keepZip = as.character(keep_zip),
    stringsAsFactors = FALSE
  )
  write.dcf(config, file = config_file)

  message("Saved PRISM archive configuration to ", config_file)
  invisible(config_file)
}

prism_archive_read_config <- function(path) {
  config_file <- file.path(path, "prism_archive.config")
  if (!file.exists(config_file)) {
    return(NULL)
  }

  config <- read.dcf(config_file)
  required_fields <- c("format", "keepZip")
  if (nrow(config) != 1L || !all(required_fields %in% colnames(config))) {
    stop(
      "Invalid PRISM archive configuration in ", config_file,
      ". Expected one record with `format` and `keepZip` fields.",
      call. = FALSE
    )
  }

  data_format <- unname(config[1L, "format"])
  if (is.na(data_format) || !data_format %in% prism_formats) {
    stop(
      "Invalid `format` in PRISM archive configuration: ",
      data_format,
      ". Expected one of: ",
      paste(prism_formats, collapse = ", "),
      call. = FALSE
    )
  }

  keep_zip <- unname(config[1L, "keepZip"])
  if (is.na(keep_zip) || !keep_zip %in% c("TRUE", "FALSE")) {
    stop(
      "Invalid `keepZip` in PRISM archive configuration: ",
      keep_zip,
      ". Expected `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  list(
    format = data_format,
    keepZip = identical(keep_zip, "TRUE")
  )
}

prism_archive_confirm_setting_change <- function(setting, value) {
  path <- prism_get_dl_dir()
  if (is.null(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    return(TRUE)
  }

  config <- prism_archive_read_config(path)
  if (is.null(config) || identical(unname(value), config[[setting]])) {
    return(TRUE)
  }

  if (identical(setting, "format")) {
    warning(
      "The active PRISM archive is configured to use '", config$format,
      "' for downloads. Changing the session format to '", value,
      "' is session-only and will not update the saved configuration. This ",
      "may leave a mixture of file types in the archive, which the package ",
      "is not designed to handle.",
      call. = FALSE,
      immediate. = TRUE
    )
    question <- "Change the download format for this session only? [yes/no/cancel]: "
  } else {
    warning(
      "The active PRISM archive is configured with `keepZip` = ",
      config$keepZip, ". Changing it to ", value,
      " is session-only and does not update the saved configuration; call ",
      "`prism_archive_save_config()` to save it.",
      call. = FALSE,
      immediate. = TRUE
    )
    question <- "Change `keepZip` for this session only? [yes/no/cancel]: "
  }

  if (!interactive()) {
    return(TRUE)
  }

  repeat {
    response <- tolower(trimws(readline(question)))
    if (identical(response, "yes")) {
      return(TRUE)
    }
    if (identical(response, "no") || !nzchar(response)) {
      message("Setting change declined; the current value is unchanged.")
      return(FALSE)
    }
    if (identical(response, "cancel")) {
      stop("Setting change cancelled by user.", call. = FALSE)
    }

    cat("Please answer yes, no, or cancel.\n")
  }
}
