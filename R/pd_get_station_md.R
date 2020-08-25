#' Extract prism station metadata 
#' 
#' `pd_get_station_md()` extracts prism metadata on the stations used to 
#' generate the prism data. **The data must already be downloaded 
#' and available in the prism download folder.** "prism data", i.e., `pd` are 
#' the folder names returned by [prism_archive_ls()] or 
#' [prism_archive_subset()]. These functions get the name or date from these 
#' data, or convert these data to a file name.
#' 
#' Note that station metadata does not exist for "tmean" type or for any 
#' "annual" temporal periods. 
#' 
#' See [prism_archive_subset()] for further details
#' on specifying ranges of dates for different temporal periods.
#'
#' @inheritParams pd_get_name
#'
#' @return A `tbl_df` containing metadata on the stations used for the specified
#'   day and variable. The data frame contains the following columns: 
#'   "date", "prism_data", "type", "station", "name", "longitude",
#'   "latitude", "elevation", "network", "stnid"
#'   
#'   The "date" column is a character representation of the data. Monthly and
#'   annual data are given first day of month, and first month of year for
#'   reporting here. Monthly and annual normals are empty strings.
#'   
#' @seealso [prism_archive_subset()]
#' 
#' @examples 
#' \dontrun{
#' # download and then get meta data for January 1, 2010 precipitation
#' get_prism_dailys("ppt", dates = "2010-01-01")
#' pd <- prism_archive_subset("ppt", "daily", dates = "2010-01-01")
#' 
#' # will warn that 2010-01-02 is not found:
#' pd_get_station_md(pd)
#' }
#'   
#' @export

pd_get_station_md <- function(pd)
{
  prism_check_dl_dir()

  folders_to_get <- file.path(prism_get_dl_dir(), pd)
  folders_to_get <- pd[dir.exists(folders_to_get)]
  
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
          date = pd_get_date(x), 
          type = pd_get_type(x),
          prism_data = x
        ) %>% 
        dplyr::select(date, prism_data, type, station, name, longitude, 
                      latitude, elevation, network, stnid)
    }) %>% 
    dplyr::bind_rows()
  
  # check to make sure all pd show up in the meta data

  if (any(!(pd %in% zz$prism_data))) {
    
    dd <- pd %in% zz$prism_data
    if (!all(dd)) {
      missing <- pd[!dd]
      n <- length(missing)
      msg <- paste0("Not all prism data exist in the returned metadata.\n",
                    "  ", n, " data are missing:")
      if (n > 10) {
        msg <- paste0(msg, " (only the first 10 are printed)")
        missing <- missing[1:10]
      }
      
      msg <- paste0(msg, "\n  ", paste(missing, collapse = "\n  "), "\n\n  ",
                    "Are you sure those data have been downloaded?")
      warning(msg)
    }
  }
 
  zz
}

#' @inheritParams prism_archive_subset
#' 
#' @description 
#' `get_prism_station_md()` is a deprecated version of 
#' `pd_get_station_md()` that only works with daily prism data.
#' 
#' @export
#' @rdname pd_get_station_md
get_prism_station_md <- function(type, minDate = NULL, maxDate = NULL, 
                                 dates = NULL)
{
  .Deprecated("`pd_get_station_md()`")
  
  pd <- prism_archive_subset(
    type, 
    temp_period = "daily", 
    minDate = minDate, 
    maxDate = maxDate, 
    dates = dates
  )
  
  pd_get_station_md(pd)
}
