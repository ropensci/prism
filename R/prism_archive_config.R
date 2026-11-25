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

#' Set up a new PRISM archive
#'
#' Create or initialize an empty directory as a new PRISM archive, set its
#' download format and `keepZip` behavior, and save those settings in
#' `prism_archive.config`. When called without arguments in an interactive
#' session, prompts for the archive path, download format, and `keepZip`
#' setting. Otherwise, the format and `keepZip` defaults are the values
#' currently set in the R session. Use the existing directory and setting
#' functions to change an archive that already contains files.
#'
#' @param path The path to the new archive directory. It is created if it does
#'   not exist; an existing directory must be empty. When all arguments are
#'   omitted in an interactive session, you will be prompted for the path.
#' @param format Download format: `"geotiff"`, `"bil"`, or `"nc"`. Defaults to
#'   the current session format, or is prompted for when all arguments are
#'   omitted in an interactive session.
#' @param keepZip Logical. Keep downloaded ZIP files by default. Defaults to
#'   the current session setting, or is prompted for when all arguments are
#'   omitted in an interactive session.
#'
#' @return Invisibly returns the path to the new archive.
#'
#' @examples
#' \dontrun{
#' prism_archive_setup()
#' prism_archive_setup("~/prism-data", format = "geotiff", keepZip = TRUE)
#' }
#'
#' @seealso [prism_set_dl_dir()], [prism_set_format()],
#'   [prism_set_keepZip()], [prism_archive_save_config()]
#'
#' @export
prism_archive_setup <- function(
    path,
    format = prism_get_format(),
    keepZip = prism_get_keepZip()) {
  if (missing(path) && missing(format) && missing(keepZip) &&
      interactive()) {
    path <- trimws(
      prism_archive_setup_readline("Enter the path for the new PRISM archive: ")
    )
    if (!nzchar(path)) {
      stop("No archive path was entered.", call. = FALSE)
    }

    cat(
      "Choose a download format:\n",
      "  1 = geotiff\n",
      "  2 = bil\n",
      "  3 = nc\n",
      sep = ""
    )
    repeat {
      format_choice <- trimws(
        prism_archive_setup_readline("Enter 1, 2, or 3: ")
      )
      if (format_choice %in% c("1", "2", "3")) {
        format <- prism_formats[as.integer(format_choice)]
        break
      }
      cat("Invalid choice. Please enter 1, 2, or 3.\n")
    }

    cat(
      "Keep downloaded ZIP files?\n",
      "  1 = yes\n",
      "  2 = no\n",
      sep = ""
    )
    repeat {
      keep_zip_choice <- trimws(
        prism_archive_setup_readline("Enter 1 or 2: ")
      )
      if (keep_zip_choice %in% c("1", "2")) {
        keepZip <- identical(keep_zip_choice, "1")
        break
      }
      cat("Invalid choice. Please enter 1 or 2.\n")
    }
  }

  if (missing(path)) {
    stop(
      "`path` is required unless called without arguments ",
      "in an interactive session.",
      call. = FALSE
    )
  }
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !nzchar(path)) {
    stop("`path` must be a single, non-empty path.", call. = FALSE)
  }
  path <- path.expand(path)

  if (file.exists(path) && !dir.exists(path)) {
    stop("The archive path exists and is not a directory: ", path,
         call. = FALSE)
  }
  if (dir.exists(path) &&
      length(list.files(path, all.files = TRUE, no.. = TRUE)) > 0L) {
    stop(
      "The archive directory is not empty: ", path,
      ". `prism_archive_setup()` is for new archives; use the existing ",
      "directory and setting functions to manage an existing archive.",
      call. = FALSE
    )
  }

  format <- match.arg(format, prism_formats)
  if (!is.logical(keepZip) || length(keepZip) != 1L || is.na(keepZip)) {
    stop("`keepZip` should be a single, non-missing logical value.",
         call. = FALSE)
  }

  prism_set_dl_dir(path)
  prism_set_format(format)
  prism_set_keepZip(keepZip)
  prism_archive_save_config()

  invisible(path)
}

prism_archive_setup_readline <- function(prompt) {
  readline(prompt)
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
