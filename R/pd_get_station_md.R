#' Extract prism station metadata 
#' 
#' `prism_data_get_station_md()` extracts prism metadata on the stations used to 
#' generate a particular day and variable. **The data must already be downloaded 
#' and available in the prism download folder.** 
#' 
#' Note that station metadata does not exist for "tmean" type or for any 
#' "annual" temporal periods. 
#' 
#' See [prism_archive_subset()] for further details
#' on specifying ranges of dates for different temporal periods.
#'
#' @param type The type of data to download. Must be "ppt", "tmin", "tmax", 
#'   "tdmean", "vpdmin", or "vpdmax".
#'   
#' @param temp_period The temporal period to subset. Must be "monthly", "daily", 
#'   "monthly normals", or "annual normals".
#'
#' @inheritParams get_prism_dailys
#'
#' @return A `tbl_df` containing metadata on the stations used for the specified
#'   day and variable. The data frame contains the following columns: 
#'   "date", "temp_period", "type", "station", "name", "longitude",
#'   "latitude", "elevation", "network", "stnid"
#'   
#'   The "date" column is a character with the longest specified date possible
#'   based on the input. For example, it will be yyyy-mm if getting monthly 
#'   data, and will be yyyy-mm-dd for daily data. It is only mm for monthly 
#'   normals, and it is an empty string for annual normals.
#'   
#' @seealso [prism_archive_subset()]
#' 
#' @examples 
#' \dontrun{
#' # download and then get meta data for January 1, 2010 precipitation
#' get_prism_dailys("ppt", dates = "2010-01-01")
#' prism_data_get_station_md("ppt", "daily", dates = "2010-01-01")
#' 
#' # will warn that 2010-01-02 is not found:
#' prism_data_get_station_md(
#'   "ppt", 
#'   "daily", 
#'   minDate = "2010-01-01", 
#'   maxDate = "2010-01-02"
#' )
#' }
#'   
#' @export

prism_data_get_station_md <- function(type, temp_period, years = NULL, 
                                      mon = NULL, minDate = NULL, 
                                      maxDate = NULL, dates = NULL,
                                      resolution = NULL)
{
  prism_check_dl_dir()
  type <- match.arg(type, prism_vars()[prism_vars() != "tmean"])
  #dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  
  folders_to_get <- prism_archive_subset(type, temp_period, years = years, 
                                         mon = mon, minDate = minDate, 
                                         maxDate = maxDate, dates = dates,
                                         resolution = resolution)
  if (length(folders_to_get) == 0) {
    stop(
      "None of the requested dates are available.\n", 
      "  You must first download the data using `get_prism_*()`."
    )
  }
  
  zz <- folders_to_get %>% 
    purrr::map(function(x){
      fn <- file.path(getOption("prism.path"), x, paste0(x, ".stn.csv"))
      var_names <- readr::read_lines(fn, n_max = 1, skip = 1)
      if (var_names == "Station,Name,Longitude,Latitude,Elevation(m),Network,stnid"){
        out_df <- suppressWarnings(readr::read_csv(
          file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), 
          skip = 1, 
          progress = FALSE, 
          col_types = readr::cols(
            Station = readr::col_character(),
            Name = readr::col_character(),
            Longitude = readr::col_double(),
            Latitude = readr::col_double(),
            `Elevation(m)` = readr::col_double(),
            Network = readr::col_character(),
            stnid = readr::col_character()
          )
        )) %>% 
          dplyr::rename(station = Station, name = Name, longitude = Longitude, 
                        latitude = Latitude, elevation = `Elevation(m)`, 
                        network = Network)
      } else if(var_names == "ID,NAME,LON,LAT,ELEV(m),Network,stnid"){
        out_df <- readr::read_csv(
          file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), 
          skip = 1, 
          progress = FALSE, 
          col_types = readr::cols(
            ID = readr::col_character(),
            NAME = readr::col_character(),
            LON = readr::col_double(),
            LAT = readr::col_double(),
            `ELEV(m)` = readr::col_double(),
            Network = readr::col_character(),
            stnid = readr::col_character()
          )
        ) %>% 
          dplyr::rename(station = ID, name = NAME, longitude = LON, 
                        latitude = LAT, elevation = `ELEV(m)`, 
                        network = Network)
      }  else if(var_names == "Station,Name,Longitude,Latitude,Elevation(m),Network"){
        out_df <- readr::read_csv(
          file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), 
          skip = 1, 
          progress = FALSE, 
          col_types = readr::cols(
            Station = readr::col_character(),
            Name = readr::col_character(),
            Longitude = readr::col_double(),
            Latitude = readr::col_double(),
            `Elevation(m)` = readr::col_double(),
            Network = readr::col_character()
          )
        ) %>%
          dplyr::rename(station = Station, name = Name, longitude = Longitude, 
                        latitude = Latitude, elevation = `Elevation(m)`, 
                        network = Network) %>% 
          dplyr::mutate(stnid = NA_character_)
      } else if (var_names == "Station,Name,Longitude,Latitude,Elevation(m),Network,station_id") {
        out_df <- readr::read_csv(
          file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), 
          skip = 1, 
          progress = FALSE, 
          col_types = readr::cols(
            Station = readr::col_character(),
            Name = readr::col_character(),
            Longitude = readr::col_double(),
            Latitude = readr::col_double(),
            `Elevation(m)` = readr::col_double(),
            Network = readr::col_character(),
            station_id = readr::col_character()
          )
        ) %>% 
          dplyr::rename(station = Station, name = Name, longitude = Longitude, 
                        latitude = Latitude, elevation = `Elevation(m)`, 
                        network = Network, stnid = station_id)
      }
      else{
        stop(
          "Metadata file does not appear to be formatted as expected.\n",
          "Please check that the .stn.csv file exists and is from prism.\n",
          "If it is, please file an issue at github.com/ropensci/prism and include the .stn.csv file."
        )
      }
      out_df %>% 
        dplyr::mutate(
          date = folder_to_date(x, temp_period), 
          type = type,
          temp_period = temp_period
        ) %>% 
        dplyr::select(date, temp_period, type, station, name, longitude, 
                      latitude, elevation, network, stnid)
    }) %>% 
    dplyr::bind_rows()
  
  # check to make sure all dates show up in the meta data
  all_dates <- get_all_possible_dates(temp_period, years = years, mon = mon, 
                               minDate = minDate, maxDate = maxDate, 
                               dates = dates)

  if (length(all_dates) != 1 && any(all_dates != "")) {
    all_dates <- all_dates[all_dates != ""]
    dd <- all_dates %in% zz$date
    if (!all(dd)) {
      missing <- all_dates[!dd]
      n <- length(missing)
      msg <- paste0("Not all requested dates exist in the returned metadata.\n",
                    "  ", n, " date(s) are missing:")
      if (n > 10) {
        msg <- paste0(msg, " (only the first 10 are printed)")
        missing <- missing[1:10]
      }
      
      msg <- paste0(msg, "\n  ", paste(missing, collapse = "\n  "), "\n\n  ",
                    "Are you sure those days have been downloaded?")
      warning(msg)
    }
  }
 
  zz
}

#' @description 
#' `get_prism_station_md()` is a deprecated version of 
#' `prism_data_get_station_md()`
#' 
#' @export
#' @rdname prism_data_get_station_md
get_prism_station_md <- function(type, temp_period, years = NULL, mon = NULL, 
                                 minDate = NULL, maxDate = NULL, dates = NULL,
                                 resolution = NULL)
{
  .Deprecated("`prism_data_get_station_md()`")
  
  prism_data_get_station_md(type, temp_period, years = years, mon = mon, 
                            minDate = minDate, maxDate = maxDate, dates = dates,
                            resolution = resolution)
}

folder_to_date <- function(folder, temp_period) {
  if (temp_period %in% c("annual", "monthly", "daily")) {
    pattern <- "_\\d{4,}_"
    
    dd <- stringr::str_extract(folder, pattern) %>%
      stringr::str_replace_all("_", "")
    
    # add in hyphens after 4th and 6th characters
    # split between year and month
    i <- nchar(dd)
    i <- i > 4
    stringr::str_sub(dd[i], 5, 4) <- "-"
    
    # now add in between month and day
    i <- nchar(dd)
    i <- i > 7
    stringr::str_sub(dd[i], 8, 7) <- "-"
   
  } else if (temp_period == "monthly normals") {
    pattern <- "_\\d{2}_"
    
    dd <- stringr::str_extract(folder, pattern) %>%
      stringr::str_replace_all("_", "")
    
  } else if (temp_period == "annual normals") {
    dd <- ""
  }
  
  dd
}

# returns "" if it is not possible to determine contrained set of dates. 
# in that case, the calling function will not check to see that all dates 
# exist. 
get_all_possible_dates <- function(temp_period, years = NULL, mon = NULL, 
                                   minDate = NULL, maxDate = NULL, dates = NULL)
{
  if (temp_period == "annual normals") {
    return("")
  }
  
  if (temp_period == "daily") {
    if (!is.null(dates) || !is.null(minDate)) {
      dd <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
    } else if (!is.null(years)) {
      if (is.null(mon)) {
        mon <- 1:12
      }
      
      min_date <- paste0(min(years), "-", min(mon), "-01")
      max_date <- paste0(max(years), "-", max(mon))
      last_day <- lubridate::days_in_month(paste0(max_date, "-01"), "%Y-%m-%d")
      max_date <- paste(max_date, last_day, sep = "-")
      
      dd <- gen_dates(minDate = min_date, maxDate = max_date, dates = NULL)
      
    } else {
      # impossible to find constrained version of all possible dates, so return
      # ""
      dd <- ""
    }
    
  } else if (temp_period == "monthly") {
    if (is.null(years)) {
      dd <- ""
    } else {
      if (is.null(mon)) {
        mon <- 1:12
      }
      
      mon <- sprintf("%02d", mon)
      dd <- expand.grid(years, mon)
      dd <- paste(dd[,1], dd[,2], sep = "-")
    }
    
  } else if (temp_period == "annual") {
    if (is.null(years)) {
      dd <- ""
    } else {
      dd <- years
    }
  } else {
    # monthly normals
    if (is.null(mon)) {
      mon <- 1:12
    }
    
    dd <- sprintf("%02d", mon)
  }
  
  as.character(dd)
}

