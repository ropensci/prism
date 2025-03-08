#' Subsets PRISM folders on the disk
#' 
#' `prism_archive_subset()` subsets the PRISM folders stored on disk by type, 
#' temporal period, and date. It looks through all of the PRISM data that have
#' been downloaded in the prism archive ([prism_get_dl_dir()]) and returns the 
#' subset based on the specified `type`, `temp_period`, and dates.
#' 
#' `temp_period` must be specified so the function can distinguish between 
#' wanting annual data or wanting monthly data for a specified year. For example
#' `prism_archive_subset("tmean", "annual", years = 2012)` would provide only 
#' one folder: the annual average temperature for 2012. However, 
#' `prism_archive_subset("tmean", "monthly", years = 2012)` would provide 12
#' folders: each monthly tmean folder for 2012. 
#' 
#' `temp_period`, `years`, and `mon` can be combined in various different ways 
#' to obtain different groupings of data. `years`, `mon`, and the daily 
#' specifiers (`minDate`/`maxDate` or `dates`) are optional. Not specifying any
#' of those would result in getting all annual, monthly, or daily data. 
#' 
#' `minDate`/`maxDate` or `dates` should only be specified for a `temp_period` 
#' of "daily". Additionally, only `dates`, or `minDate` and `maxDate`, should be
#' specified, but all three should not be specified. Nor should the daily 
#' arguments be combined with `years` and/or `mon`. For example, if daily 
#' folders are desired, then specify `years` and/or `mon` to get all days for 
#' those years and months **or** specify the specific dates using 
#' `minDate`/`maxDate` or `dates` 
#' 
#' @param type The type of data you want to subset. Must be "ppt", "tmean", 
#'   "tmin", "tmax", "tdmean", "vpdmin", "vpdmax", "solclear", "solslope", 
#'   "soltotal", or "soltrans".
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
#' @param resolution The spatial resolution of the data, must be either "4km" or
#'   "800m". Should only be specified for `temp_period` of "normals".
#'   
#' @return A character vector of the folders that meet the type and temporal
#'   period specified. `character(0)` is returned if no folders are found that
#'   meet the specifications.
#'   
#' @seealso [prism_archive_ls()]
#' 
#' @examples 
#' \dontrun{
#' # get all annual tmin
#' prism_archive_subset("tmin", "annual")
#' # get only 2000-2015 annual tmin
#' prism_subset_folder("tmin", "annual", years = 2000:2015)
#' 
#' # get monthly precipitation for 2000-2010
#' prism_archive_subset("ppt", "monthly", years = 2000:2010)
#' # get only June-August monthly precip data for 2000-2010
#' prism_archive_subset("ppt", "monthly", years = 2000:2010, mon = 6:8)
#' 
#' # get all daily tmax for July-August in 2010
#' prism_archive_subset("tmax", "daily", years = 2010, mon = 7:8)
#' # same as:
#' prism_archive_subset(
#'   "tmax", 
#'   "daily", 
#'   minDate = "2010-07-01", 
#'   maxDate = "2010-08-31"
#' )
#' 
#' # get the 4km 30-year average precip for January and February
#' prism_archive_subset("ppt", "monthly normals", mon = 1:2, resolution = "4km")
#' }
#' 
#' @export
prism_archive_subset <- function(type, temp_period, years = NULL, mon = NULL, 
                                 minDate = NULL, maxDate = NULL, dates = NULL, 
                                 resolution = NULL) 
{
  prism_check_dl_dir()
  
  temp_period <- match.arg(
    temp_period, 
    c("annual", "monthly", "daily", "monthly normals", "annual normals",
      "daily normals")
  )
  
  normals <- grepl("normals", temp_period)
  
  type <- match.arg(type, prism_vars(normals = normals))
  
  check_subset_folders_args(
    type, temp_period, years, mon, minDate, maxDate, dates, resolution
  ) 
  
  all_dates <- NULL
  if (!is.null(dates) | !is.null(minDate)) {
    all_dates <- gen_dates(minDate, maxDate, dates)
    if (temp_period == "daily normals") {
      # if daily normals instead of daily, then remove years
      all_dates <- substring(all_dates, 6)
    }
    all_dates <- gsub("-", "", all_dates)
  }
  
  # get all folder names
  prism_folders <- prism_archive_ls()
  
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
  } else if (temp_period == "daily normals") {
    # daily normals
    type_folders <- stringr::str_subset(
      type_folders, 
      paste0("_30yr_normal_", resolution)
    )
    
    if (!is.null(dates)) {
      # if dates are specified, get specific dates
      pattern <- paste0("_", dates, "_")
    } else if (isTRUE(years)) {
      pattern <- paste0("_", get_days_from_mon_ann(1:12, FALSE), "_")
    } else {
      # otherwise, get all days for the specified months
      pattern <- paste0("_", get_days_from_mon_ann(mon, FALSE), "_")
    }
  } else if (temp_period == "monthly normals") {
    # monthly normals
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
  both_norm <- c("monthly normals", "annual normals", "daily normals")

  # resolution only specified for normals and must be specified
  if (temp_period %in% both_norm) {
    if (is.null(resolution))
      stop("`resolution` must be specified when subsetting normals")
    resolution <- match.arg(resolution, c("4km", "800m"))
  }
  
  if (!(temp_period %in% both_norm) & !is.null(resolution))
    stop(
      "`resolution` should only be specified when `temp_period` is 'normals'"
    )
  
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
