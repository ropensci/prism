#' Subsets PRISM folders on the disk
#' 
#' `prism_archive_subset()` returns PRISM dataset identifiers (`pd`) from the
#' current PRISM download directory that match the requested filters.
#'
#' `time_step` specifies the temporal time step: `"annual"`, `"monthly"`,
#' or `"daily"`. Use `data_class` to distinguish ordinary PRISM time-series
#' products from 30-year normals.
#'
#' For backwards compatibility, `"annual normals"`, `"monthly normals"`, and
#' `"daily normals"` are accepted as deprecated `temp_period` values. Use
#' `temp_period = "annual"`, `"monthly"`, or `"daily"` together with
#' `data_class = "normals"` instead.
#' 
#' @param type The type of data you want to subset. Must be "ppt", "tmean", 
#'   "tmin", "tmax", "tdmean", "vpdmin", "vpdmax", "solclear", "solslope", 
#'   "soltotal", or "soltrans". If `NULL`, all temporal periods are included.
#'   
#' @param time_step The temporal period to subset. Must be "annual", 
#'   "monthly", or "daily". If `NULL`, all temporal periods are included. 
#'   Previous versions also accepted "daily normals, "monthly normals", or 
#'   "annual normals". These options are now deprecated in favor of using 
#'   `data_class` = "normals" argument. 
#'
#' @param years Valid numeric year, or vector of years. If `NULL`, all years are
#'   included.
#' 
#' @param mon Valid numeric month, or vector of months. If `NULL`, all months 
#'   are included.
#' 
#' @param minDate Date to start subsetting daily data. Must be specified in 
#'   a valid iso-8601 (e.g. YYYY-MM-DD) format. May be provided as either a 
#'   character or [base::Date] class.
#'   
#' @param maxDate Date to end subsetting daily data.  Must be specified in 
#'   a valid iso-8601 (e.g. YYYY-MM-DD) format. May be provided as either a 
#'   character or [base::Date] class.
#' 
#' @param dates A vector of daily dates to subset. Must be specified in 
#'   a valid iso-8601 (e.g. YYYY-MM-DD) format. May be provided as either a 
#'   character or [base::Date] class. Do not combine with `minDate` or 
#'   `maxDate`.
#' 
#' @param resolution The spatial resolution of the data, must be either "4km" or
#'   "800m". If `NULL`, all resolutions are included.
#'   
#' @param data_class Character vector of PRISM data classes to include:
#'   `"time series"` and/or `"normals"`. If `NULL`, both data classes are
#'   included.
#'   
#' @param temp_period Deprecated. Use `time_step` instead.
#'   
#' @return A character vector of the folders that meet the type and temporal
#'   period specified. `character(0)` is returned if no folders are found that
#'   meet the specifications.
#'   
#' @seealso [prism_archive_ls()]
#' 
#' @examples
#' \dontrun{
#' # All archived PRISM datasets.
#' prism_archive_subset()
#'
#' # All archived time-series datasets.
#' prism_archive_subset(data_class = "time series")
#'
#' # All archived monthly precipitation time-series grids.
#' prism_archive_subset(
#'   type = "ppt",
#'   temp_period = "monthly",
#'   data_class = "time series"
#' )
#'
#' # All archived January-February 4 km precipitation normals.
#' prism_archive_subset(
#'   type = "ppt",
#'   temp_period = "monthly",
#'   mon = 1:2,
#'   resolution = "4km",
#'   data_class = "normals"
#' )
#'
#' # All archived 800 m daily maximum-temperature grids for July-August 2010.
#' prism_archive_subset(
#'   type = "tmax",
#'   temp_period = "daily",
#'   years = 2010,
#'   mon = 7:8,
#'   resolution = "800m",
#'   data_class = "time series"
#' )
#'
#' # A specific range of daily time-series precipitation grids.
#' prism_archive_subset(
#'   type = "ppt",
#'   temp_period = "daily",
#'   minDate = "2010-07-01",
#'   maxDate = "2010-08-31",
#'   data_class = "time series"
#' )
#' }
#' 
#' @export
prism_archive_subset <- function(type = NULL, time_step = NULL, years = NULL, 
                                 mon = NULL, minDate = NULL, maxDate = NULL, 
                                 dates = NULL, resolution = NULL, 
                                 data_class = NULL, temp_period = NULL) 
{
  prism_check_dl_dir()
  
  if (!is.null(temp_period) & !is.null(time_step)) {
    stop(
      "`temp_period` and `time_step` cannot both be specified.",
      "\nPlease use only `time_step`",
      call. = FALSE
    )
  }
  
  if (!is.null(temp_period)) {
    warning(
      "`temp_period` has been deprecated in favor of `time_step`",
      "\n`temp_period` will be removed in a future release.",
      call. = FALSE
    )
    
    time_step <- temp_period
  }
  
  normalized <- normalize_archive_time_step(
    time_step = time_step,
    data_class = data_class
  )
  
  time_step <- normalized[["time_step"]]
  data_class <- normalized[["data_class"]]
  
  validate_archive_subset_args(
    type = type,
    time_step = time_step,
    years = years,
    mon = mon,
    minDate = minDate,
    maxDate = maxDate,
    dates = dates,
    resolution = resolution,
    data_class = data_class
  )
  
  filter_archive_pd(
    pd = prism_archive_ls(),
    type = type,
    time_step = time_step,
    years = years,
    mon = mon,
    minDate = minDate,
    maxDate = maxDate,
    dates = dates,
    resolution = resolution,
    data_class = data_class
  )
}

#' Filter PRISM archive dataset identifiers
#'
#' Applies archive-subsetting criteria to a supplied vector of PRISM dataset
#' identifiers. This is the pure internal implementation used by
#' prism_archive_subset().
#'
#' @param pd Character vector of PRISM dataset identifiers.
#' @param type Character vector of PRISM variables, or `NULL`.
#' @param temp_period Character vector containing `"annual"`, `"monthly"`,
#'   and/or `"daily"`, or `NULL`.
#' @param years Integer vector of years, or `NULL`.
#' @param mon Integer vector of months, or `NULL`.
#' @param minDate,maxDate Optional inclusive daily `Date` boundaries.
#' @param dates Optional vector of specific daily dates.
#' @param resolution Character vector containing `"4km"` and/or `"800m"`,
#'   or `NULL`.
#' @param data_class Character vector containing `"time series"` and/or
#'   `"normals"`, or `NULL`.
#'
#' @return A character vector of elements of `pd` that meet every supplied
#'   filtering condition.
#' @noRd
filter_archive_pd <- function(
    pd,
    type = NULL,
    time_step = NULL,
    years = NULL,
    mon = NULL,
    minDate = NULL,
    maxDate = NULL,
    dates = NULL,
    resolution = NULL,
    data_class = NULL
) {
  if (!length(pd)) {
    return(character())
  }
  
  archive_info <- parse_archive_pd(pd)
  
  keep <- rep(TRUE, nrow(archive_info))
  
  if (!is.null(type)) {
    keep <- keep & archive_info$type %in% type
  }
  
  if (!is.null(time_step)) {
    keep <- keep & archive_info$time_step %in% time_step
  }
  
  if (!is.null(resolution)) {
    keep <- keep & archive_info$resolution %in% resolution
  }
  
  if (!is.null(data_class)) {
    keep <- keep & archive_info$data_class %in% data_class
  }
  
  if (!is.null(years)) {
    keep <- keep & archive_info$year %in% years
  }
  
  if (!is.null(mon)) {
    keep <- keep & archive_info$month %in% mon
  }
  
  if (!is.null(dates)) {
    requested_dates <- as.Date(dates)
    
    keep <- keep &
      archive_info$time_step == "daily" &
      archive_info$date_start %in% requested_dates
  }
  
  if (!is.null(minDate)) {
    keep <- keep &
      archive_info$time_step == "daily" &
      archive_info$date_start >= as.Date(minDate)
  }
  
  if (!is.null(maxDate)) {
    keep <- keep &
      archive_info$time_step == "daily" &
      archive_info$date_start <= as.Date(maxDate)
  }
  
  archive_info$pd[keep]
}

# filter_folders <- function(folders, type, temp_period = NULL, years = NULL,
#                            mon = NULL, dates = NULL, resolution = NULL)
filter_folders <- function(folders, type, temp_period = NULL, years = NULL,
                           mon = NULL, dates = NULL, resolution = NULL)
{
  # filter down to only the requested type
  type_folders <- folders |> 
    stringr::str_subset(paste0("_", type, "_"))
  
  # filter by resolution if specified (applies to all temporal periods now)
  if (!is.null(resolution)) {
    if (resolution == "800m") {
      # For webservice v2: look for "30s", for webservice v1: look for "800m" 
      type_folders <- type_folders |>
        stringr::str_subset("(30s|800m)")
    } else if (resolution == "4km") {
      # For webservice v2: look for "25m", for webservice v1: look for "4km"
      type_folders <- type_folders |>
        stringr::str_subset("(25m|4km)")
    }
  }
  
  # filter down to the temporal period in question and then filter down to the
  # specified years/months/dates via the pattern
  pattern <- NULL
  if (temp_period == "annual") {
    # yearly ------------
    type_folders <- type_folders |>
      filter_folders_by_n(4) |>
      filter_no_normal()
    
    if (!is.null(years)) {
      pattern <- paste0("_", years)
    }
    
  } else if (temp_period == "monthly") {
    # monthly ------------
    type_folders <- type_folders |>
      filter_folders_by_n(6) |>
      filter_no_normal()
    
    if (!is.null(years)) {
      if (!is.null(mon)) {
        # years and mon are specified; paste them together and match those 
        # specified years and months
        pattern <- paste0(
          "_", as.vector(outer(years, mon_to_string(mon), paste0))
        )
      } else {
        # years are specified, but months are not, so get all months for the
        # specified year
        pattern <- paste0("_", years, "\\d{2}")
      }
    } else {
      # years are not specified
      if (!is.null(mon)) {
        # but months are, so get all the years for the specified months
        pattern <- paste0("_\\d{4}", mon_to_string(mon))
      }
    }
    
  } else if (temp_period == "daily") {
    # daily ------------
    type_folders <- type_folders |>
      filter_folders_by_n(8) |>
      filter_no_normal()
   
    if (is.null(dates)) {
      if (is.null(years)) {
        if (!is.null(mon)) {
          # months are specified, but years are not
          pattern <- paste0("_\\d{4}", mon_to_string(mon), "\\d{2}")
        }        
      } else {
        if (is.null(mon)) {
          # years are specified, months are not
          pattern <- paste0("_", years, "\\d{4}")
        } else {
          # years are specified, months are specified
          pattern <- paste0(
            "_", as.vector(outer(years, mon_to_string(mon), paste0)), "\\d{2}"
          )
        }
      }
      
    } else {
      # specific dates have been specified
      pattern <- paste0("_", dates)
    }
  } else if (temp_period == "daily normals") {
    # daily normals
    type_folders <- stringr::str_subset(
      type_folders, 
      "^.*_\\d{8}_avg_30y$"
    )
    
    if (!is.null(dates)) {
      # if dates are specified, get specific dates
      pattern <- paste0("_","2020", dates)
    } else if (isTRUE(years)) {
      pattern <- paste0("_", "2020", get_days_from_mon_ann(1:12, FALSE))
    } else {
      # otherwise, get all days for the specified months
      pattern <- paste0("_", "2020", get_days_from_mon_ann(mon, FALSE))
    }
  } else if (temp_period == "monthly normals") {
    # monthly normals
    type_folders <- stringr::str_subset(
      type_folders, 
      "^.*_\\d{6}_avg_30y$"
    )
    
    if (is.null(mon)) {
      # get all monthly
      pattern <- paste0("_", "2020", mon_to_string(1:12))
    } else {
      # get specified monthly
      pattern <- paste0("_", "2020", mon_to_string(mon) )
    }
    
  } else {
    # else it is annual_normals; just need to make sure that we remove any 
    # monthly normals
    type_folders <- stringr::str_subset(
      type_folders, 
      "^.*_\\d{4}_avg_30y$"
    )
  }
  
  # final filter by pattern -----------
  if (!is.null(pattern)) {
    pattern <- paste(pattern, collapse = "|")
    type_folders <- stringr::str_subset(type_folders, pattern)
  }
  
  type_folders
}

# based on yearly, monthly, daily, you expect a certain number of numbers in
# the folder name. This filters based on that number
filter_folders_by_n <- function(folders, n)
{
  web_service_version = ifelse(
    grepl('PRISM',folders),
    'v1','v2'
  )
  pattern <- paste0("_", "\\d{", n, "}", ifelse(web_service_version == 'v1', "_", "$")
  )
  stringr::str_subset(folders, pattern)
}

# remove folders that have "normal" in them
filter_no_normal <- function(folders)
{
  folders[!stringr::str_detect(folders, "normal")]
}

check_subset_folders_args <- function(type, temp_period, years, mon, minDate, 
                                      maxDate, dates, resolution) 
{
  both_norm <- c("monthly normals", "annual normals", "daily normals")
  
  # resolution must be specified 
  if (is.null(resolution))
    stop("`resolution` must be specified for all temporal periods")
  resolution <- match.arg(resolution, c("4km", "800m"))
  
  if (temp_period == "daily normals" & 
      type %in% c( "solclear", "solslope", "soltotal","soltrans")) {
    stop(
      'Daily normals are not available for clear sky, sloped, and total solar radiation; nor cloud transmittance.'
    )
  }
  
  # day specifications only for daily
  if (
    !(temp_period %in% c("daily", "daily normals")) & 
    any(!is.null(minDate), !is.null(maxDate), !is.null(dates))
  )
    stop("`minDate`, `maxDate`, and/or `dates` should only be specified when `temp_period` is 'daily'")
  
  # if annual normals, then no years or months should be specified
  if (temp_period == "annual normals" & any(!is.null(years), !is.null(mon)))
    stop("No need to specify `years` or `mon` when subsetting 'annual normals'")
  
  if (temp_period == "monthly normals" & !is.null(years)) 
    stop("No need to specify `years` for 'monthly normals'")
  
  if (temp_period == "annual" & !is.null(mon))
    stop("No need to specify `mon` for 'annual' `temp_period`")
 
  if (temp_period %in% c("daily", "daily normals") & (!is.null(mon) | !is.null(years)) & 
      (!is.null(dates) | !is.null(minDate) | !is.null(maxDate)))
    stop("Only specify `years`/`mon` or `minDate`/`maxDate`/`dates`")
}

#' Normalize legacy temporal-period values
#'
#' @param time_step A temporal-period value supplied to
#'   prism_archive_subset().
#' @param data_class A data-class value supplied to
#'   prism_archive_subset().
#'
#' @return A list containing normalized `time_step` and `data_class`.
#' @noRd
normalize_archive_time_step <- function(time_step, data_class) {
  legacy_periods <- c(
    "annual normals" = "annual",
    "monthly normals" = "monthly",
    "daily normals" = "daily"
  )
  
  if (is.null(time_step)) {
    return(list(
      time_step = time_step,
      data_class = data_class
    ))
  }
  
  is_legacy <- time_step %in% names(legacy_periods)
  
  if (!any(is_legacy)) {
    return(list(
      time_step = time_step,
      data_class = data_class
    ))
  }
  
  if (length(time_step) != 1L) {
    stop(
      "Deprecated normal temporal-period values cannot be combined with ",
      "other `time_step` values. Use `time_step` and `data_class` ",
      "separately.",
      call. = FALSE
    )
  }
  
  legacy_period <- time_step[[1]]
  new_period <- unname(legacy_periods[[legacy_period]])
  
  if (!is.null(data_class) &&
      !identical(data_class, "normals")) {
    stop(
      "`data_class` must be `\"normals\"` when using the deprecated ",
      "`time_step = \"", legacy_period, "\"` value.",
      call. = FALSE
    )
  }
  
  warning(
    "`time_step = \"", legacy_period, "\"` is deprecated. ",
    "Use `time_step = \"", new_period,
    "\", data_class = \"normals\"` instead.",
    call. = FALSE
  )
  
  list(
    time_step = new_period,
    data_class = "normals"
  )
}

#' Validate prism_archive_subset() arguments
#'
#' @param type Character vector of PRISM variables, or `NULL`.
#' @param time_step Character vector of temporal periods, or `NULL`.
#' @param years Numeric vector of years, or `NULL`.
#' @param mon Numeric vector of months, or `NULL`.
#' @param minDate,maxDate Optional daily date bounds.
#' @param dates Optional daily dates.
#' @param resolution Character vector of spatial resolutions, or `NULL`.
#' @param data_class Character vector of PRISM data classes, or `NULL`.
#'
#' @return Invisibly returns `TRUE`.
#' @noRd
validate_archive_subset_args <- function(
    type,
    time_step,
    years,
    mon,
    minDate,
    maxDate,
    dates,
    resolution,
    data_class
) {
  valid_type <- unique(c(
    prism_vars(normals = FALSE),
    prism_vars(normals = TRUE)
  ))
  
  if (!is.null(type)) {
    if (!is.character(type) ||
        !length(type) ||
        anyNA(type) ||
        !all(type %in% valid_type)) {
      stop(
        "`type` must be `NULL` or contain only supported PRISM variables.",
        call. = FALSE
      )
    }
  }
  
  valid_period <- c("annual", "monthly", "daily")
  
  if (!is.null(time_step)) {
    if (!is.character(time_step) ||
        !length(time_step) ||
        anyNA(time_step) ||
        !all(time_step %in% valid_period)) {
      stop(
        "`time_step` must be `NULL` or contain only: ",
        paste(valid_period, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
  }
  
  if (!is.null(years)) {
    if (!is.numeric(years) ||
        !length(years) ||
        anyNA(years) ||
        any(years != as.integer(years))) {
      stop(
        "`years` must be `NULL` or a non-missing integer vector.",
        call. = FALSE
      )
    }
  }
  
  if (!is.null(mon)) {
    if (!is.numeric(mon) ||
        !length(mon) ||
        anyNA(mon) ||
        any(mon != as.integer(mon)) ||
        any(mon < 1L | mon > 12L)) {
      stop(
        "`mon` must be `NULL` or integer values from 1 through 12.",
        call. = FALSE
      )
    }
  }
  
  valid_resolution <- c("4km", "800m")
  
  if (!is.null(resolution)) {
    if (!is.character(resolution) ||
        !length(resolution) ||
        anyNA(resolution) ||
        !all(resolution %in% valid_resolution)) {
      stop(
        "`resolution` must be `NULL` or contain only: ",
        paste(valid_resolution, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
  }
  
  valid_data_class <- c("time series", "normals")
  
  if (!is.null(data_class)) {
    if (!is.character(data_class) ||
        !length(data_class) ||
        anyNA(data_class) ||
        !all(data_class %in% valid_data_class)) {
      stop(
        "`data_class` must be `NULL` or contain one or both of: ",
        paste(valid_data_class, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
  }
  
  has_dates <- !is.null(dates)
  has_min_date <- !is.null(minDate)
  has_max_date <- !is.null(maxDate)
  
  if (has_dates && (has_min_date || has_max_date)) {
    stop(
      "Use either `dates` or `minDate`/`maxDate`, not both.",
      call. = FALSE
    )
  }
  
  if (xor(has_min_date, has_max_date)) {
    stop(
      "`minDate` and `maxDate` must be supplied together.",
      call. = FALSE
    )
  }
  
  has_daily_specification <- has_dates || has_min_date || has_max_date
  
  if (has_daily_specification &&
      !is.null(time_step) &&
      !identical(time_step, "daily")) {
    stop(
      "`minDate`, `maxDate`, and `dates` can only be used with ",
      "`time_step = \"daily\"`.",
      call. = FALSE
    )
  }
  
  if (has_daily_specification &&
      (!is.null(years) || !is.null(mon))) {
    stop(
      "Use either `years`/`mon` or `minDate`/`maxDate`/`dates` when ",
      "selecting daily datasets.",
      call. = FALSE
    )
  }
  
  if (!is.null(mon) &&
      !is.null(time_step) &&
      identical(time_step, "annual")) {
    stop(
      "`mon` cannot be used with `time_step = \"annual\"`.",
      call. = FALSE
    )
  }
  
  validate_archive_subset_dates(
    minDate = minDate,
    maxDate = maxDate,
    dates = dates
  )
  
  invisible(TRUE)
}

#' Validate daily-date arguments for prism_archive_subset()
#'
#' @param minDate,maxDate Optional inclusive daily date bounds.
#' @param dates Optional daily dates.
#'
#' @return Invisibly returns `TRUE`.
#' @noRd
validate_archive_subset_dates <- function(minDate, maxDate, dates) {
  supplied_dates <- c(minDate, maxDate, dates)
  
  if (!length(supplied_dates)) {
    return(invisible(TRUE))
  }
  
  supplied_dates <- as.character(supplied_dates)
  parsed_dates <- suppressWarnings(as.Date(supplied_dates))
  
  if (anyNA(parsed_dates)) {
    stop(
      "`minDate`, `maxDate`, and `dates` must be valid ISO-8601 ",
      "`YYYY-MM-DD` dates or `Date` objects.",
      call. = FALSE
    )
  }
  
  if (!is.null(minDate) &&
      !is.null(maxDate) &&
      as.Date(minDate) > as.Date(maxDate)) {
    stop(
      "`minDate` must be earlier than or equal to `maxDate`.",
      call. = FALSE
    )
  }
  
  invisible(TRUE)
}

#' Parse archived PRISM dataset identifiers
#'
#' @param pd A character vector of V2 PRISM dataset identifiers.
#'
#' @return A data frame containing parsed archive metadata.
#' @noRd
parse_archive_pd <- function(pd) {
  if (!is.character(pd) || anyNA(pd)) {
    stop(
      "`pd` must be a non-missing character vector.",
      call. = FALSE
    )
  }
  
  if (!length(pd)) {
    return(data.frame(
      pd = character(),
      type = character(),
      resolution = character(),
      data_class = character(),
      time_step = character(),
      date = character(),
      year = integer(),
      month = integer(),
      date_start = as.Date(character()),
      stringsAsFactors = FALSE
    ))
  }
  
  type <- pd_get_type(pd)
  resolution <- pd_get_resolution(pd)
  data_class <- pd_get_data_class(pd)
  time_step <- pd_get_time_step(pd)
  date <- pd_get_date(pd, complete = FALSE)
  
  is_time_series <- data_class == "time series"
  is_normals <- data_class == "normals"
  
  is_annual <- time_step == "annual"
  is_monthly <- time_step == "monthly"
  is_daily <- time_step == "daily"
  
  year <- rep(NA_integer_, length(pd))
  month <- rep(NA_integer_, length(pd))
  date_start <- as.Date(rep(NA_character_, length(pd)))
  
  # Time series:
  # annual:  YYYY
  # monthly: YYYY-MM
  # daily:   YYYY-MM-DD
  if (any(is_time_series)) {
    year[is_time_series] <- suppressWarnings(
      as.integer(substr(date[is_time_series], 1L, 4L))
    )
  }
  
  time_series_has_month <- is_time_series & (is_monthly | is_daily)
  
  if (any(time_series_has_month)) {
    month[time_series_has_month] <- suppressWarnings(
      as.integer(substr(date[time_series_has_month], 6L, 7L))
    )
  }
  
  annual_time_series <- is_time_series & is_annual
  monthly_time_series <- is_time_series & is_monthly
  daily_time_series <- is_time_series & is_daily
  
  if (any(annual_time_series)) {
    date_start[annual_time_series] <- as.Date(
      paste0(date[annual_time_series], "-01-01")
    )
  }
  
  if (any(monthly_time_series)) {
    date_start[monthly_time_series] <- as.Date(
      paste0(date[monthly_time_series], "-01")
    )
  }
  
  if (any(daily_time_series)) {
    date_start[daily_time_series] <- as.Date(
      date[daily_time_series]
    )
  }
  
  # Normals:
  # annual:  1991-2020
  # monthly: 1991-2020-MM
  # daily:   1991-2020-MM-DD
  #
  # Do not assign a single year to normals: 1991-2020 is a reference
  # interval, not an observation year. Month remains meaningful.
  normals_has_month <- is_normals & (is_monthly | is_daily)
  
  if (any(normals_has_month)) {
    month[normals_has_month] <- suppressWarnings(
      as.integer(substr(date[normals_has_month], 11L, 12L))
    )
  }
  
  annual_normals <- is_normals & is_annual
  monthly_normals <- is_normals & is_monthly
  daily_normals <- is_normals & is_daily
  
  # The date is an internal selection key only. A leap year preserves the
  # February 29 daily normal.
  if (any(annual_normals)) {
    date_start[annual_normals] <- as.Date("2020-01-01")
  }
  
  if (any(monthly_normals)) {
    date_start[monthly_normals] <- as.Date(
      paste0(
        "2020-",
        substr(date[monthly_normals], 11L, 12L),
        "-01"
      )
    )
  }
  
  if (any(daily_normals)) {
    date_start[daily_normals] <- as.Date(
      paste0(
        "2020-",
        substr(date[daily_normals], 11L, 12L),
        "-",
        substr(date[daily_normals], 14L, 15L)
      )
    )
  }
  
  data.frame(
    pd = pd,
    type = type,
    resolution = resolution,
    data_class = data_class,
    time_step = time_step,
    date = date,
    year = year,
    month = month,
    date_start = date_start,
    stringsAsFactors = FALSE
  )
}
