#' Check whether files in a PRISM archive are the latest release
#'
#' PRISM continually revises recent monthly and daily grids as more station
#' data becomes available. Each local file's release number is stored in its
#' `.bil.aux.xml`/header metadata as `PRISM_DATASET_RELEASE_NUMBER`. This
#' function compares that number against the release/grid count reported by
#' the PRISM release-date web service and flags files that have a newer
#' release available online.
#'
#' Monthly data is considered "final" once `PRISM_DATASET_RELEASE_NUMBER >= 7`
#' and daily data once it is `>= 8`; those files are not queried online (they
#' are marked `"current"` directly). Everything below that threshold is
#' checked against the web service.
#'
#' The release-date web service only supports monthly and daily time steps.
#' Annual time series and normals have no release-date endpoint, so rows
#' with `time_step == "annual"` or a normals `data_class` are never queried;
#' they are marked `"not_supported"` regardless of their release number,
#' since we have no way to confirm whether a newer version exists.
#'
#' The web service uses two different date-key formats depending on the
#' PRISM `time_step`:
#' \itemize{
#'   \item monthly: `services.nacse.org/.../<type>/<YYYYMM>[/<YYYYMM>]` --
#'     one response row per *month*.
#'   \item daily: `services.nacse.org/.../<type>/<YYYYMMDD>[/<YYYYMMDD>]` --
#'     one response row per *day*.
#' }
#' Both support a date range as two path segments, so this function batches
#' all flagged files for a given `(type, resolution, time_step)` combination
#' into a single request spanning their min/max date.
#'
#' @param pd A `pd` object as returned by [prism_archive_ls()] or
#'   [prism_archive_subset()]. If `NULL` (the default), the full local
#'   archive is used, i.e. `pd_check_versions()` is equivalent to
#'   `pd_check_versions(prism_archive_ls())`.
#' @param quiet If `FALSE` (default), prints a message summarizing how many
#'   files were queried against the web service.
#'
#' @return A data frame (the same one produced by `parse_archive_pd()`, with
#'   `pd` and `release_number` columns added) plus a `status` column with one
#'   of `"current"`, `"update_available"`, `"not_supported"`, or
#'   `"check_failed"` for every row in `pd`.
#'
#' @examples
#' \dontrun{
#' # Check everything already downloaded
#' status_df <- pd_check_versions()
#'
#' # Check only a subset
#' pd <- prism_archive_subset("tmax", "monthly", years = 2015:2020)
#' status_df <- pd_check_versions(pd)
#' }
#' @export
pd_check_versions <- function(pd = NULL, quiet = FALSE) {

  if (is.null(pd)) {
    pd <- prism_archive_ls()
  }

  if (length(pd) == 0) {
    stop("`pd` is empty; nothing to check.", call. = FALSE)
  }

  # --- 1. base metadata frame -------------------------------------------
  meta <- parse_archive_pd(pd)
  meta$pd <- pd

  # --- 2. release number per file ----------------------------------------
  md <- pd_get_md(pd)
  
  release_col <- if ("PRISM_DATASET_RELEASE_NUMBER" %in% names(md)) {
    md[["PRISM_DATASET_RELEASE_NUMBER"]]
  } else {
    rep(NA_character_, nrow(md))
  }
  
  meta[["release_number"]] <- suppressWarnings(as.integer(release_col))

  # --- 3. carve out time steps the release-date service doesn't support ----
  # NOTE: confirm these match the exact values parse_archive_pd() uses in
  # your package for annual data and normals (data_class here is a
  # placeholder for whatever column/value flags normals in your archive).
  unsupported <- meta[["time_step"]] == "annual" | 
    meta[["data_class"]] == "normals"

  meta[["status"]] <- ifelse(
    is.na(meta[["release_number"]]), 
    "check_failed", 
    "current"
  )
  meta[["status"]][unsupported] <- "not_supported"

  # --- 4. which of the remaining rows need a web check ---------------------
  needs_check <- !unsupported & with(meta,
    (time_step == "monthly" & release_number < 7) |
    (time_step == "daily"   & release_number < 8)
  )

  if (!any(needs_check, na.rm = TRUE)) {
    if (!quiet) 
      message(
        "No supported files below the finalized release threshold; nothing to query online."
      )
    
    return(meta)
  }

  # date-key format depends on time_step: monthly -> YYYYMM, daily -> YYYYMMDD
  meta[["date_key"]] <- NA_character_
  
  supported <- !unsupported
  
  meta[["date_key"]][supported] <- ifelse(
    meta[["time_step"]][supported] == "monthly",
    format(as.Date(meta[["date"]][supported]), "%Y%m"),
    format(as.Date(meta[["date"]][supported]), "%Y%m%d")
  )

  check_rows <- meta[needs_check, , drop = FALSE]

  # --- 5. batch queries by (type, resolution, time_step) -------------------
  combos <- unique(check_rows[c("type", "resolution", "time_step")])

  grid_lookup <- list()  # keyed by "type|resolution|time_step|date_key" -> grid_count

  for (i in seq_len(nrow(combos))) {
    ty   <- combos$type[i]
    res  <- combos$resolution[i]
    step <- combos$time_step[i]

    sub <- check_rows[check_rows$type == ty &
                       check_rows$resolution == res &
                       check_rows$time_step == step, ]

    keys <- sort(unique(sub$date_key))
    min_k <- keys[1]
    max_k <- keys[length(keys)]

    resp <- tryCatch(
      prism_release_date_query(type = ty, resolution = res, time_step = step,
                                min_key = min_k, max_key = max_k),
      error = function(e) NULL
    )

    if (is.null(resp)) {
      if (!quiet) {
        warning(sprintf("Release-date query failed for %s / %s / %s (%s-%s)",
                         ty, res, step, min_k, max_k), call. = FALSE)
      }
      next
    }

    for (r in seq_len(nrow(resp))) {
      key <- paste(ty, res, step, resp$date_key[r], sep = "|")
      grid_lookup[[key]] <- resp$grid_count[r]
    }
  }

  # --- 6. compare and fill status -----------------------------------------
  n_checked <- 0L
  for (i in which(needs_check)) {
    key <- paste(meta[["type"]][i], meta[["resolution"]][i],
                 meta[["time_step"]][i], meta[["date_key"]][i], sep = "|")
    gc <- grid_lookup[[key]]

    if (is.null(gc) || is.na(gc)) {
      meta[["status"]][i] <- "check_failed"
      next
    }

    n_checked <- n_checked + 1L
    meta[["status"]][i] <- if (meta[["release_number"]][i] < gc) {
      "update_available"
    } else {
      "current"
    }
  }

  meta$date_key <- NULL

  if (!quiet) {
    n_unsupported <- sum(unsupported)
    message(sprintf(
      "Checked %d file(s) against the PRISM release-date service; %d flagged as update_available. %d annual/normals file(s) skipped (not supported by the service).",
      n_checked, sum(meta$status == "update_available", na.rm = TRUE), n_unsupported
    ))
  }

  meta
}

#' Query the PRISM release-date web service for a date/month range
#'
#' @param type PRISM variable/type, e.g. "tmax", "tmin", "ppt".
#' @param resolution PRISM grid resolution, e.g. "4km" or "800m".
#' @param time_step "monthly" or "daily"; determines whether keys are
#'   formatted `YYYYMM` or `YYYYMMDD`. Annual and normals are not supported
#'   by this endpoint and must be filtered out before calling this function.
#' @param min_key,max_key Character date keys (already formatted to match
#'   `time_step`) bounding the query. If equal, only a single
#'   month/day is requested.
#' @param region PRISM region code; defaults to `"us"`.
#'
#' @return A data frame with columns `release_date`, `completion_date`,
#'   `type`, `grid_count`, `url`, and `date_key` (formatted to match
#'   `time_step`, derived from `release_date`).
#' @keywords internal
#' @noRd
prism_release_date_query <- function(type, resolution, time_step,
                                      min_key, max_key, region = "us") {

  if (!time_step %in% c("monthly", "daily")) {
    stop("The PRISM release-date service only supports monthly and daily ",
         "time steps; got: ", time_step, call. = FALSE)
  }

  base <- "https://services.nacse.org/prism/data/get/releaseDate"

  url <- if (min_key == max_key) {
    file.path(base, region, resolution, type, min_key)
  } else {
    file.path(base, region, resolution, type, min_key, max_key)
  }

  resp <- httr::GET(url)
  httr::stop_for_status(resp, task = "query PRISM release-date service")
  
  txt <- httr::content(resp, as = "text", encoding = "UTF-8")
  lines <- strsplit(txt, "\n")[[1]]
  lines <- lines[nzchar(trimws(lines))]

  if (length(txt) == 0) {
    stop("Empty response from PRISM release-date service: ", url, call. = FALSE)
  }

  fields <- strsplit(txt, "\\s+")

  key_fmt <- if (time_step == "monthly") "%Y%m" else "%Y%m%d"

  data.frame(
    release_date    = vapply(fields, `[`, character(1), 1),
    completion_date = vapply(fields, `[`, character(1), 2),
    type            = vapply(fields, `[`, character(1), 3),
    grid_count      = as.integer(vapply(fields, `[`, character(1), 4)),
    url             = vapply(fields, `[`, character(1), 5),
    stringsAsFactors = FALSE
  ) |>
    transform(date_key = format(as.Date(release_date), key_fmt))
}
