#' Extract prsim metadata 
#' 
#' Extracts prism metadata on the stations used to generate a particular day 
#' and variable. This only extracts metadata from daily PRISM data. The daily 
#' data must already be downloaded and available in the "prism.path". 
#'
#' @inheritParams get_prism_dailys
#'
#' @return A `tbl_df` containing metadata on the stations used for the specified
#'   day and variable.
#'   
#' @export

get_prism_station_md <- function(type, minDate = NULL, maxDate = NULL, 
                                 dates = NULL)
{
  prism_check_dl_dir()
  type <- match.arg(type, prism_vars())
  dates <- gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  folders_to_get <- prism_subset_folders(type, "daily", dates = dates)
  if(length(folders_to_get) == 0){
    stop(
      "None of the requested dates are available.\n", 
      "You must first download the daily data."
    )
  }

  folders_to_get %>% 
    purrr::map(function(x){
      fn <- file.path(getOption("prism.path"), x, paste0(x, ".stn.csv"))
      var_names <- readr::read_lines(fn, n_max = 1, skip = 1)
      if (var_names == "Station,Name,Longitude,Latitude,Elevation(m),Network,stnid"){
        out_df <- readr::read_csv(file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), skip = 1, 
                                  progress = FALSE, 
                        col_types = readr::cols(
                          Station = readr::col_character(),
                          Name = readr::col_character(),
                          Longitude = readr::col_double(),
                          Latitude = readr::col_double(),
                          `Elevation(m)` = readr::col_double(),
                          Network = readr::col_character(),
                          stnid = readr::col_character()
                        )) %>% 
          dplyr::rename(station = Station, name = Name, longitude = Longitude, 
                        latitude = Latitude, elevation = `Elevation(m)`, 
                        network = Network)
      } else if(var_names == "ID,NAME,LON,LAT,ELEV(m),Network,stnid"){
        out_df <- readr::read_csv(file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), skip = 1, 
                                  progress = FALSE, 
                                  col_types = readr::cols(
                                    ID = readr::col_character(),
                                    NAME = readr::col_character(),
                                    LON = readr::col_double(),
                                    LAT = readr::col_double(),
                                    `ELEV(m)` = readr::col_double(),
                                    Network = readr::col_character(),
                                    stnid = readr::col_character()
                                  )) %>% 
          dplyr::rename(station = ID, name = NAME, longitude = LON, 
                        latitude = LAT, elevation = `ELEV(m)`, 
                        network = Network)
      }  else if(var_names == "Station,Name,Longitude,Latitude,Elevation(m),Network"){
        out_df <- readr::read_csv(file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), skip = 1, 
                                  progress = FALSE, 
                                  col_types = readr::cols(
                                    Station = readr::col_character(),
                                    Name = readr::col_character(),
                                    Longitude = readr::col_double(),
                                    Latitude = readr::col_double(),
                                    `Elevation(m)` = readr::col_double(),
                                    Network = readr::col_character()
                                  )) %>% 
          dplyr::rename(station = Station, name = Name, longitude = Longitude, 
                        latitude = Latitude, elevation = `Elevation(m)`, 
                        network = Network) %>% 
          dplyr::mutate(stnid = NA_character_)
      } else if (var_names == "Station,Name,Longitude,Latitude,Elevation(m),Network,station_id") {
        out_df <- readr::read_csv(file.path(getOption("prism.path"), x, paste0(x, ".stn.csv")), skip = 1, 
                                  progress = FALSE, 
                                  col_types = readr::cols(
                                    Station = readr::col_character(),
                                    Name = readr::col_character(),
                                    Longitude = readr::col_double(),
                                    Latitude = readr::col_double(),
                                    `Elevation(m)` = readr::col_double(),
                                    Network = readr::col_character(),
                                    station_id = readr::col_character()
                                  )) %>% 
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
        dplyr::mutate(date = x %>% stringr::str_extract("[0-9]{8}") %>% lubridate::ymd(), 
                      type = type) %>% 
        dplyr::select(date, type, station, name, longitude, latitude, elevation, network, stnid)
    }) %>% 
    dplyr::bind_rows()
}

