#' Subsets PRISM folders on the disk
#' 
#' `prism_subset_folders()` subsets the PRISM folders stored on disk by type, 
#' temporal period, and date. It looks through all of the PRISM data that have
#' been downloaded in the "prism.path" and returns the subset based on 
#' `type`, `temp_period`, and specified dates.
#' 
#' `temp_period` must be specifed so the function can distinguish between 
#' wanting annual data or wanting monthly data for a specified year. For example
#' `prism_subset_folders("tmean", "annual", years = 2012)` would provide only 
#' one folder: the annual tmean folder. However, 
#' `prism_subset_folders("tmean", "monthly", years = 2012)` would provide 12
#' folders: each monthly tmean folder for 2012. 
#' 
#' `temp_period`, `years`, and `mon` can be combined in various different ways 
#' to obtain different groupings of data. `years`, `mon`, and the daily 
#' specifiers (`minDate`/`maxDate` or `dates`) are optional. Not specifying any
#' of those would result in getting all annual, monthly, or daily data. 
#' 
#' `minDate`/`maxDate` or `dates` should only be specified for a `temp_period` 
#' of "daily". Additionally, only `dates`, or `minDate` and `maxDate`, should be
#' specified, but all three should not be specified.
#' 
#' @param type The type of data you want to subset. Must be "ppt", "tmean", 
#'   "tmin", "tmax", "tdmean", "vpdmin", or "vpdmax".
#'   
#' @param temp_period The temporal period to subset. Must be "annual", 
#'   "monthly", "daily", "monthly normals", or "annual normals".
#'
#' @param years Valid numeric year, or vector of years.
#' 
#' @param mon Valid numeric month, or vector of months.
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
#'   character or [base::Date] class.
#' 
#' @param resoultion The spatial resolution of the data, must be either "4km" or
#'   "800m". Should only be specified for `temp_period` of "normals".
#' 
#' @export
prism_subset_folders <- function(type, temp_period, years = NULL, mon = NULL, 
                                 minDate = NULL, maxDate = NULL, dates = NULL, 
                                 resolution = NULL) 
{
  prism_check_dl_dir()
  
  type <- match.arg(type, prism_vars())
  temp_period <- match.arg(
    temp_period, 
    c("annual", "monthly", "daily", "monthly normals", "annual normals")
  )
  
  check_subset_folders_args(
    type, temp_period, years, mon, minDate, maxDate, dates, resolution
  ) 
  
  all_dates <- NULL
  if (!is.null(dates) | !is.null(minDate)) {
    all_dates <- gen_dates(minDate, maxDate, dates)
    all_dates <- gsub("-", "", all_dates)
  }
  
  # get all folder names
  #prism_folders <- list.files(getOption("prism.path"))
  prism_folders <- ls_prism_data()[["files"]]
  
  ff <- filter_folders(prism_folders, type, temp_period, years, mon, all_dates,
                       resolution)
  
  ff
}

filter_folders <- function(folders, type, temp_period = NULL, years = NULL,
                           mon = NULL, dates = NULL, resolution = NULL)
{
  # filter down to only the requested type
  type_folders <- folders %>% 
    stringr::str_subset(paste0("_", type, "_"))
  
  # filter down to the temporal period in question and then filter down to the
  # specified years/months/dates via the pattern
  pattern <- NULL
  if (temp_period == "annual") {
    # yearly ------------
    type_folders <- type_folders %>%
      filter_folders_by_n(4)
    
    if (!is.null(years)) {
      pattern <- paste0("_", years, "_")
    }
    
  } else if (temp_period == "monthly") {
    # monthly ------------
    type_folders <- type_folders %>%
      filter_folders_by_n(6)
    
    if (!is.null(years)) {
      if (!is.null(mon)) {
        # years and mon are specified; paste them together and match those 
        # specified years and months
        pattern <- paste0(
          "_", as.vector(outer(years, mon_to_string(mon), paste0)), "_"
        )
      } else {
        # years are specified, but months are not, so get all months for the
        # specified year
        pattern <- paste0("_", years, "\\d{2}_")
      }
    } else {
      # years are not specified
      if (!is.null(mon)) {
        # but months are, so get all the years for the specified months
        pattern <- paste0("_\\d{4}", mon_to_string(mon), "_")
      }
    }
    
  } else if (temp_period == "daily") {
    # daily ------------
    type_folders <- type_folders %>%
      filter_folders_by_n(8)
   
    if (is.null(dates)) {
      if (is.null(years)) {
        if (!is.null(mon)) {
          # months are specified, but years are not
          pattern <- paste0("_\\d{4}", mon_to_string(mon), "\\d{2}_")
        }        
      } else {
        if (is.null(mon)) {
          # years are specified, months are not
          pattern <- paste0("_", years, "\\d{4}_")
        } else {
          # years are specified, months are specified
          pattern <- paste0(
            "_", as.vector(outer(years, mon_to_string(mon), paste0)), "\\d{2}_"
          )
        }
      }
      
    } else {
      # specific dates have been specified
      pattern <- paste0("_", dates, "_")
    }
  } else if (temp_period == "monthly_normals") {
    # normals
    type_folders <- stringr::str_subset(
      type_folders, 
      paste0("_30yr_normal_", resolution)
    )
    
    if (is.null(mon)) {
      # get all monthly
      pattern <- paste0("_", mon_to_string(1:12), "_")
    } else {
      # get specified monthly
      pattern <- paste0("_", mon_to_string(mon), "_")
    }
    
  } else {
    # else it is annual_normals; just need to make sure that we remove any 
    # monthly normals
    type_folders <- stringr::str_subset(
      type_folders, 
      paste0("_30yr_normal_", resolution)
    ) %>%
      stringr::str_subset("_annual_")
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
  pattern <- paste0("_", "\\d{", n, "}", "_")
  stringr::str_subset(folders, pattern)
}

check_subset_folders_args <- function(type, temp_period, years, mon, minDate, 
                                      maxDate, dates, resolution) 
{
  both_norm <- c("monthly normals", "annual normals")
  
  # resolution only specified for normals and must be specified
  if (temp_period %in% both_norm & is.null(resolution))
    stop("`resolution` must be specified when `temp_period` is 'normals'")
  
  if (!(tmp_period %in% both_norm) & !is.null(resolution))
    stop("`resolution` should only be specified when `temp_period` is 'normals'")
  
  # day specifications only for daily
  if (temp_period != "daily" & any(!is.null(minDate), !is.null(maxDate), !is.null(dates)))
    stop("`minDate`, `maxDate`, and/or `dates` should only be specified when `temp_period` is 'daily'")
  
  # if annual normals, then no years or months should be specified
  if (temp_period == "annual normals" & any(!is.null(years), !is.null(mon)))
    stop("No need to specify `years` or `mon` when subsetting 'annual normals'")
  
  if (temp_period == "monthly normals" & !is.null(years)) 
    stop("No need to specify `years` for 'monthly normals'")
  
  if (temp_period == "annual" & !is.null(mon))
    stop("No need to specify `mon` for 'annual' `temp_period`")
}
