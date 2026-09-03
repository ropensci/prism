#' Perform action on "prism data"
#' 
#' "prism data", i.e., `pd` are the folder names returned by 
#' [prism_archive_ls()] or [prism_archive_subset()]. These functions get the 
#' name or date from these data, or convert these data to a file name.
#' 
#' @description
#' `pd_get_name()` extracts a long, human readable name from the prism
#' data.
#' 
#' @param pd "prism data" as a character vector.  
#' 
#' @return `pd_get_name()` and `pd_get_date()` return a character vector of 
#' names/dates.
#' 
#' @examples \dontrun{
#' # Assumes 2000-2002 annual precipitation data is already downloaded
#' pd <- prism_archive_subset(
#'   'ppt', 'annual', years = 2000:2002, resolution = '4km'
#' )
#' pd_get_name(pd)
#' ## [1] "2000 - 4km resolution - Precipitation" "2001 - 4km resolution - Precipitation"
#' ## [3] "2002 - 4km resolution - Precipitation"
#' 
#' pd_get_date(pd)
#' ## [1] "2000" "2001" "2002"
#' 
#' pd_get_type(pd)
#' ## [1] "ppt" "ppt" "ppt"
#' 
#' pd_to_file(pd[1])
#' ## [1] "C:/prismdir/prism_ppt_us_25m_2000/prism_ppt_us_25m_2000.tif"
#' }
#' 
#' @export
#' @rdname pd_get
pd_get_name <- function(pd) {
  normals <- pd_is_normal(pd)
  
  pd_strp <- pd
  pd_strp[normals] <- stringr::str_remove(pd_strp[normals], "_avg_30y")
  pd_parse <- stringr::str_split(pd_strp, "_", simplify = TRUE)
  
  type <- pd
  
  if (any(!normals)) {
    type[!normals] <- unname(
      prism_var_names(normals = FALSE)[pd_parse[!normals,2]]
    )
  }
  
  if (any(normals)) {
    type[normals] <- unname(
      prism_var_names(normals = TRUE)[pd_parse[normals, 2]]
    )
  }
  
  res <- ifelse(
    pd_parse[,4] == "25m",
    "4km resolution",
    ifelse(
      pd_parse[,4] == "30s",
      "800m resolution",
      "400m resolution"
    )
  )
  
  
  dates <- rep('', nrow(pd_parse))
  
  if (any(!normals)) {
    dd <- pd_get_date(pd[!normals]) |>
      format_prism_time()
    dates[!normals] <- dd
  }
  
  # normals date conversion
  if (any(normals)) {
    dd_norm <- pd_get_date(pd[normals]) |>
      format_prism_normals_time()
    
    dates[normals] <- dd_norm
  }
  
  out <- paste(dates, res, type, sep = ' - ')
  out
}

format_prism_normals_time <- function(x) {
  n <- nchar(x)
  
  if (any(!n %in% c(9L, 12L, 15L))) {
    bad <- unique(x[!n %in% c(9L, 12L, 15L)])
    
    stop(
      "`x` must contain dates in YYYY-YYYY, YYYY-YYYY-MM, or YYYY-YYYY-MM-DD format. ",
      "Invalid value(s): ",
      paste(bad, collapse = ", "),
      call. = FALSE
    )
  }
  
  out <- n
  annual <- n == 9L
  monthly <- n == 12L
  daily <- n == 15L
  
  if (any(annual)) {
    out[annual] <- "Annual 30-year normals"
  }
  
  if (any(monthly) | any(daily)) {
    x_parse <- stringr::str_split(x, "-", simplify = TRUE)
    
    out[monthly] <- paste(
      month.abb[as.numeric(x_parse[monthly, 3])], "30-year normals"
    )
    out[daily] <- paste(
      month.abb[as.numeric(x_parse[daily, 3])], 
      x_parse[daily, 4], 
      "30-year normals"
    )
  }
  out
}

format_prism_time <- function(x) {
  n <- nchar(x)
  
  if (any(!n %in% c(4L, 7L, 10L))) {
    bad <- unique(x[!n %in% c(4L, 7L, 10L)])
    
    stop(
      "`x` must contain dates in YYYY, YYYY-MM, or YYYY-MM-DD format. ",
      "Invalid value(s): ",
      paste(bad, collapse = ", "),
      call. = FALSE
    )
  }
  
  out <- x
  
  monthly <- n == 7L
  daily <- n == 10L
  
  if (any(monthly)) {
    out[monthly] <- format(
      as.Date(paste0(x[monthly], "-01")),
      "%b %Y"
    )
  }
  
  if (any(daily)) {
    out[daily] <- format(
      as.Date(x[daily]),
      "%b %d, %Y"
    )
  }
  
  out
}

#' @param legacy Boolean. If `TRUE`, then maintains the convention in v0.30 
#'   and earlier. See description for details.
#'   
#' @description 
#' `pd_get_date()` extracts the date from the prism data. Returns a date that 
#' matches the timestep of the prism data. For annual data a year is returned, 
#' for monthly data year-month is returned, and for daily data year-month-day. 
#' For normals, the 30-year range is returned + the month and day, as 
#' approriate.
#' 
#' If `legacy = TRUE`, date is returned in yyyy-mm-dd format. For monthly data, 
#' dd is 01 and for annual data mm is also 01. For normals, an empty character 
#' is returned.
#' 
#' @export
#' @rdname pd_get
pd_get_date <- function(pd, legacy = FALSE) {
  if (legacy) {
    message("`legacy=TRUE` maintains the behavior in v0.3.0 and earlier.", 
    "\nThe legacy paramter will be removed in a future release.")
  }
  
  normals <- pd_is_normal(pd)
  
  pd_strp <- pd
  pd_strp[normals] <- stringr::str_remove(pd_strp[normals], "_avg_30y")
  
  parsed_pd <- stringr::str_split(pd_strp, "_", simplify = TRUE)
  
  dates <- parsed_pd[,5]
  # add hyphens, as appropriate
  dates <- stringr::str_replace(
    dates, 
    "^(\\d{4})(\\d{2})(\\d+)$", "\\1-\\2-\\3"
  )
  dates <- stringr::str_replace(dates, "^(\\d{4})(\\d+)$", "\\1-\\2")
  
  # deal with normals
  dates[normals] <- paste0("1991-", dates[normals])
  
  # and now deal with legacy
  if (legacy) {
    # change normals to ""
    if (any(normals))
      dates[normals] <- ""
    
    # add "01" to monthly and "01-01" to daily
    ts <- pd_get_time_step(pd)
    annual <- ts == "annual"
    monthly <- ts == "monthly"
    if (any(annual))
      dates[annual] <- paste0(dates[annual], "-01-01")
    
    if (any(monthly))
      dates[monthly] <- paste0(dates[monthly], "-01")
  }
  
  dates
}

#' @description `pd_get_type()` parses the variable from the prism data.
#' 
#' @return `pd_get_type()` returns a character vector of prism variable types,
#' e.g., 'ppt'.
#' 
#' @export
#' @rdname pd_get
pd_get_type <- function(pd) {
  
  vapply(pd, function(x) {
    web_service_version <- ifelse(grepl("PRISM", x), "v1", "v2")
    if (web_service_version == 'v1'){
      p <- stringr::str_remove(x, "PRISM_")
      p <- stringr::str_split(p, "_", simplify = TRUE)
      return(p[,1])
    }
    if (web_service_version == 'v2'){
      parts <- strsplit(x, "_")[[1]]
      return(parts[2])
    }
  }, character(1), USE.NAMES = FALSE)
}

#' @description `pd_get_time_step()` parses the time step from the prism data.
#' 
#' @return `pd_get_time_step()` returns a character vector of time steps. One 
#' of: "daily", "monthly", "annual", "daily normals", "monthly normals", 
#' "annual normals".
#' 
#' @export
#' @rdname pd_get
pd_get_time_step <- function(pd) {
  num_to_ts <- c(`4` = 'annual', `6` = 'monthly', `8` = 'daily')
  
  normals <- pd_is_normal(pd)
  pd[normals] <- stringr::str_remove(pd[normals], "_avg_30y")
  
  parsed_pd <- stringr::str_split(pd, "_", simplify = TRUE)
  n <- nchar(parsed_pd[,5])
  
  ts_out <- unname(num_to_ts[as.character(n)])
  
  if (anyNA(ts_out)) {
    bad <- unique(n[is.na(ts_out)])
    
    stop(
      "Could not determine PRISM time step from date-token length: ",
      paste(bad, collapse = ", "),
      ". Expected 4 (annual), 6 (monthly), or 8 (daily).",
      call. = FALSE
    )
  }
  
  ts_out[normals] <- paste(ts_out[normals], "normals")
  
  ts_out
}

pd_is_normal <- function(pd) {
  stringr::str_detect(pd, 'avg_30y')
}

#' name parse
#' @description parse the directory name into relevant metadata (name or date)
#' 
#' @param p a prism file directory or bil file
#' 
#' @param returnDate TRUE or FALSE. If TRUE, an ISO date is returned. By default
#'   years will come back with YYYY-01-01 and months as YYYY-MM-01
#'   
#' @return a properly parsed string of human readable names
#' @noRd

pr_parse <- function(p,returnDate = FALSE){
  ## Get webservice version of file
  web_service_version = ifelse(p[1]=='PRISM', 'v1', 'v2')
  ## Extract the climate variable
  type <- p[2]
  ## Extract the date the data is for
  normals <- FALSE
  
  if(grepl("normal",paste(p,collapse=""))){
    if(grepl("annual",paste(p,collapse=""))) {
      mon <- "Annual"
    } else {
      # monthly or daily
      mon <- p[length(p) - 1]
      
      if (grepl("^\\d{2}$", mon)) {
        # monthly
        mon <- month.abb[as.numeric(mon)]
      } else if (grepl("^\\d{4}$", mon)) {
        # daily
        m <- substr(mon, 1, 2)  # First two characters
        d <- substr(mon, nchar(mon) - 1, nchar(mon))
        
        mon <- paste(month.name[as.numeric(m)], as.numeric(d))
      } else {
        # error
        stop("Cannot correctly parse the pd name.")
      }
      
    }
    ds <- paste(mon,"30-year normals",sep=" ")
    normals <- TRUE
  } else {
   
    d <- ifelse(web_service_version=='v1', p[length(p)-1], p[length(p)])
    yr <- substr(d,1,4)
    mon <- substr(d,5,6)
    day <- substr(d,7,8)
    
    ## Get resolution
    ### Create date string
    ds <- ifelse(
      !is.na(month.abb[as.numeric(mon)]),
      paste(month.abb[as.numeric(mon)],day,yr,sep=" "),
      paste(yr,sep=" ")
    )
  }
  
  if (web_service_version == 'v1'){
    ures <- ifelse(
      grepl("4km",paste(p,collapse="")),
      "4km resolution",
      "800m resolution"
    )
  } else {
    ures <- ifelse(
      grepl("25m",paste(p,collapse="")),
      "4km resolution",
      ifelse(
        grepl("30s",paste(p,collapse="")),
        "800m resolution",
        "400m resolution"
      )
    )
  }
  
  type <- unname(prism_var_names(normals = normals)[type])

  md_string <- paste(ds,ures,type,sep = " - ")
  if(!returnDate){
    out <- md_string
  } else {
    if (normals) {
      out <- ""
    } else {
      out <- paste(
        yr, 
        ifelse(nchar(mon) > 0, mon, "01"), 
        ifelse(nchar(day) > 0, day, "01"), 
        sep = "-"
      )
    }
  }
  
  out
}

#' @description 
#' `pd_to_file()` converts prism data to a fully specified file, i.e., the
#' full path to the file in the prism archive. A warning is posted if the 
#' file does not exist in the local prism archive. 
#' 
#' @param pd prism data character vector. 
#' 
#' @return `pd_to_file()` returns a character vector with the full path to the 
#' bil file.
#' 
#' @export
#' @rdname pd_get
pd_to_file <- function(pd) {

  normals <- pd_is_normal(pd)
  
  fext <- pd
  # normals are only ever geotiff
  if (any(normals)) {
    fext[normals] <- '.tif' 
  } 
  
  if (any(!normals)) {
    fext[!normals] <- unname(prism_format_file_ext())
  }
  
  pfile <- normalizePath(file.path(
    prism_get_dl_dir(), pd, paste0(pd, fext)
  ))
  
  pfile
}
