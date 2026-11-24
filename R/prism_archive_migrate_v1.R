# Necessary for testing these functions using local_mocked_bindings().
interactive <- NULL
select.list <- NULL

#' Detect and migrate legacy PRISM archive folders
#'
#' `prism_archive_migrate_v1()` finds folders created by the pre-September 2025
#' PRISM API and converts their legacy names into current PRISM data (`pd`) names.
#' Selected folders are re-downloaded with [get_prism_pd()] and removed only after
#' the corresponding V2 folder is available.
#'
#' @param path Character string giving the PRISM archive directory. Defaults to
#'   [prism_get_dl_dir()].
#' @param action Controls migration. `NULL` prompts in interactive sessions;
#'   `"all"` or `"update"` migrates every recognized V1 folder; `"none"` does
#'   nothing; or supply a character vector of V1 folder names to migrate.
#' @param keepZip Passed to [get_prism_pd()].
#' @param quiet Logical; suppress informational messages.
#'
#' @return Invisibly returns a data frame describing the migration status of each
#'   recognized V1 folder.
#'
#' @export
prism_archive_migrate_v1 <- function(path = prism_get_dl_dir(),
                                     action = NULL,
                                     keepZip = prism_get_keepZip(),
                                     quiet = FALSE) {
  if (!is.character(path) || length(path) != 1 || is.na(path) || !nzchar(path)) {
    stop("`path` must be a single non-empty character string.", call. = FALSE)
  }

  if (!dir.exists(path)) {
    stop("`path` does not exist: ", path, call. = FALSE)
  }

  candidates <- prism_find_v1_folders(path)

  if (!length(candidates)) {
    if (!quiet) message("No legacy V1 PRISM folders found. Nothing to migrate.")
    return(invisible(prism_migration_result(character(0), character(0))))
  }

  if (is.null(action)) {
    if (!interactive()) {
      stop(
        "Legacy V1 folders found. Use `action = \"all\"`, `action = \"none\"`, ",
        "or supply folder names explicitly in non-interactive sessions.",
        call. = FALSE
      )
    }

    choices <- c("All", "None", candidates)
    selection <- select.list(
      choices,
      multiple = TRUE,
      graphics = FALSE,
      title = sprintf(
        "Select legacy PRISM folders to migrate (%d found):",
        length(candidates)
      )
    )

    if (length(selection) == 0 || "None" %in% selection) {
      action <- "none"
    } else if ("All" %in% selection) {
      action <- "all"
    } else {
      action <- selection
    }
  }

  if (identical(action, "none")) {
    if (!quiet) message("No folders selected. Nothing migrated.")
    return(invisible(prism_migration_result(
      candidates,
      rep(NA_character_, length(candidates)),
      rep("skipped", length(candidates))
    )))
  }

  if (is.character(action) && length(action) == 1 && action %in% c("all", "update")) {
    selected <- candidates
  } else {
    if (!is.character(action) || anyNA(action) || !length(action)) {
      stop(
        "`action` must be NULL, \"all\", \"update\", \"none\", or a character vector of folder names.",
        call. = FALSE
      )
    }

    unknown <- setdiff(action, candidates)
    if (length(unknown)) {
      stop(
        "Unknown or unsupported V1 folder(s):\n",
        paste0("  - ", unknown, collapse = "\n"),
        call. = FALSE
      )
    }

    selected <- unique(action)
  }

  converted <- vapply(selected, function(folder) {
    prism_v1_folder_to_v2_pd(folder)
  }, character(1), USE.NAMES = FALSE)

  unsupported <- is.na(converted)
  unsupported_folders <- selected[unsupported]

  if (length(unsupported_folders)) {
    for (folder in unsupported_folders) {
      warning("Could not migrate unsupported or unrecognized V1 folder: ", folder,
              call. = FALSE)
    }
  }

  selected <- selected[!unsupported]
  converted <- converted[!unsupported]
  if (!length(selected)) {
    return(invisible(prism_migration_result(
      unsupported_folders,
      rep(NA_character_, length(unsupported_folders)),
      rep("unsupported", length(unsupported_folders))
    )))
  }

  unique_converted <- unique(converted)

  if (!quiet) {
    message(sprintf("Migrating %d V1 folder(s)...", length(selected)))
  }

  downloaded <- tryCatch(
    get_prism_pd(unique_converted, keepZip = keepZip, overwrite = TRUE),
    error = function(error) error
  )

  if (inherits(downloaded, "error")) {
    warning("V1 migration failed: ", conditionMessage(downloaded), call. = FALSE)
    downloaded <- character(0)
  }

  downloaded <- as.character(downloaded)

  result_v1 <- character(length(selected))
  result_v2 <- character(length(selected))
  result_status <- rep("failed", length(selected))

  for (i in seq_along(selected)) {
    v1_folder <- selected[[i]]
    v2_pd <- converted[[i]]

    v2_folder <- file.path(path, v2_pd)
    downloaded_successfully <- v2_pd %in% downloaded || dir.exists(v2_folder)

    if (downloaded_successfully) {
      old_folder <- file.path(path, v1_folder)
      unlink(old_folder, recursive = TRUE, force = TRUE)
      if (dir.exists(old_folder)) {
        result_status[[i]] <- "failed"
      } else {
        result_status[[i]] <- "migrated"
      }
    }

    result_v1[[i]] <- v1_folder
    result_v2[[i]] <- v2_pd
  }

  result_v1 <- c(result_v1, unsupported_folders)
  result_v2 <- c(result_v2, rep(NA_character_, length(unsupported_folders)))
  result_status <- c(result_status, rep("unsupported", length(unsupported_folders)))

  invisible(prism_migration_result(result_v1, result_v2, result_status))
}

prism_migration_result <- function(v1_folder, v2_pd,
                                   status = rep("skipped", length(v1_folder))) {
  data.frame(
    v1_folder = v1_folder,
    v2_pd = v2_pd,
    status = status,
    stringsAsFactors = FALSE
  )
}

prism_find_v1_folders <- function(path) {
  folders <- list.dirs(path, full.names = FALSE, recursive = FALSE)
  folders <- folders[nzchar(folders)]

  valid <- vapply(folders, function(folder) {
    !is.na(prism_v1_folder_to_v2_pd(folder))
  }, logical(1), USE.NAMES = FALSE)

  folders[valid]
}

prism_v1_folder_to_v2_pd <- function(folder) {
  pattern <- paste0(
    "^PRISM_(", paste(prism_vars(normals = FALSE), collapse = "|"),
    ")_[^_]+_(4km|800m|400m)[A-Za-z0-9]*_(",
    "\\d{4}|\\d{6}|\\d{8}",
    ")_(bil|tif|nc|asc)$"
  )

  if (!grepl(pattern, folder)) return(NA_character_)

  parts <- strsplit(folder, "_", fixed = TRUE)[[1]]
  type <- parts[[2]]
  resolution_token <- parts[[4]]
  date <- parts[[5]]

  if (grepl("^4km", resolution_token)) {
    resolution <- "25m"
  } else if (grepl("^800m", resolution_token)) {
    resolution <- "30s"
  } else if (grepl("^400m", resolution_token)) {
    resolution <- "15s"
  } else {
    return(NA_character_)
  }

  paste("prism", type, "us", resolution, date, sep = "_")
}
