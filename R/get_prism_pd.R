#' `get_prism_pd()` downloads PRISM data based on the folder names (`pd`) that
#' are created after downloading data. 
#' 
#' @param pd Character vector. Should be in the form 
#'   `"prism_[type]_[region]_[resolution]_[date]{_avg_30y}"`.
#'   
#' @examples \dontrun{
#' get_prism_pd("prism_ppt_us_25m_199107")
#' get_prism_pd(c("prism_ppt_us_25m_199107", "prism_ppt_us_25m_199108"))
#' 
#' # redownload out of date data
#' pd <- pd_check_versions()
#' get_prism_pd(pd, overwrite = TRUE)
#' }
#' 
#' #' @rdname get_prism_data
#'
#' @export
get_prism_pd <- function(pd, keepZip = prism_get_keepZip(), service = NULL,
                         overwrite = FALSE)
{
  prism_check_dl_dir()
  
  if (!is.character(pd) | length(pd) == 0) {
    stop("`pd` should be a character vector.")
  }
  
  if (!is.logical(overwrite) | length(overwrite) != 1) {
    stop("`overwrite` should be a single logical value.")
  }
  
  verify_pd(pd)
  
  pd_parse <- parse_archive_pd(pd) |>
    parse_pd_df_for_url()
  
  group_key <- paste(pd_parse[["type"]], pd_parse[["resolution"]], 
                     pd_parse[["ts_service"]], sep = "|")
  groups <- split(seq_len(nrow(pd_parse)), group_key)
  
  uris <- character(nrow(pd_parse))
  
  for (idx in groups) {
    first <- idx[1]
    uris[idx] <- gen_prism_url(
      dates      = pd_parse[["date"]][idx],
      type       = pd_parse[["type"]][first],
      resolution = pd_parse[["resolution"]][first],
      ts_service = pd_parse[["ts_service"]][first]
    )
  }
    
  download_pb <- txtProgressBar(
    min = 0,
    max = length(uris),
    style = 3
  )
  on.exit(close(download_pb), add = TRUE)
  
  counter <- 0
  
  ### Handle all years
  pd <- character(length(uris))
  
  if (length(uris) > 0) {    
    
    for (i in seq_along(uris)) {
      tmp_pd <- prism_webservice(
        uris[[i]], 
        keepZip = keepZip, 
        returnName = TRUE, 
        ts_service = pd_parse[["ts_service"]][[i]],
        overwrite = overwrite
      )
      
      if (!is.null(tmp_pd)) {
        pd[[i]] <- tmp_pd
      }
      
      setTxtProgressBar(download_pb, i)
    }
  }
  
  counter <- length(uris) + 1
  
  pd <- pd[nzchar(pd)]
  
  invisible(pd)
}

verify_pd <- function(pd) {
  
  types <- prism_vars(normals = TRUE)
  
  date_part <- paste(
    "\\d{4}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])",  # daily: YYYYMMDD
    "\\d{4}(0[1-9]|1[0-2])",                        # monthly: YYYYMM
    "\\d{4}",                                       # annual: YYYY
    sep = "|"
  )
  
  pattern <- paste0(
    "^prism_(", paste(types, collapse = "|"), ")_us_(25m|30s)_(",
    date_part, ")(_avg_30y)?$"
  )
  
  valid <- grepl(pattern, pd)
  
  if (!all(valid)) {
    bad <- pd[!valid]
    stop(
      sprintf(
        "The following value%s do not look like valid PRISM archive folder names:\n%s",
        if (length(bad) > 1) "s" else "",
        paste0("  - ", bad, collapse = "\n")
      ),
      call. = FALSE
    )
  }
  
  invisible(TRUE)
}

# assumes df in form returned by parse_archive_pd()
parse_pd_df_for_url <- function(df) 
{
  # add ts_service row
  df[["ts_service"]] <- ifelse(
    df[["data_class"]] == "normals", 
    "ftp_v2_normals_bil",
    ifelse(
      df[["data_class"]] == "time series", 
      "web_service_v2", 
      NA_character_
    )
  )
  
  # update dates row to be in format expected by gen_prism_url:
  normals_rows <- df[["data_class"]] == "normals"
  
  df[["date"]][normals_rows] <- stringr::str_remove(
    df[["date"]][normals_rows], 
    "^1991-2020-?"
  )
  # annual normals collapse to "" once "1991-2020" is stripped -> fill with "14"
  df[["date"]][(normals_rows & df[["date"]] == "")] <- "14"
  
  df[["date"]] <- stringr::str_remove_all(df[["date"]], "-")
  
  df
}