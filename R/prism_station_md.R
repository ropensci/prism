#' Extract metadata on the stations used to generate a particular day/variable
#'
#' @param type The type of data to get metadata for, must be "ppt", "tmean", "tmin", or "tmax".
#' @param minDate a valid iso-8601 (e.g. YYYY-MM-DD) date. The first date to extract metadata for.
#' @param maxDate  a valid iso-8601 (e.g. YYYY-MM-DD) date. The last date to extract metadata for. 
#' @param dates a vector of iso-8601 formatted dates to extract metadata for, can also be a single date.
#'
#' @return A \code{tbl_df} containing metadata on the stations used for each day/variable.
#' @export
#'
#' @examples
get_prism_station_md <- function(type, minDate = NULL, maxDate =  NULL, dates = NULL){
  prism:::path_check()
  dates <- prism:::gen_dates(minDate = minDate, maxDate = maxDate, dates = dates)
  folders_to_get <- subset_prism_folders(type = type, dates = dates)
  if(length(folders_to_get) == 0){
    stop("None of the requested dates are available.")
  }
  folders_to_get %>% 
    purrr::map(function(x){
      fn <- file.path(getOption("prism.path"), x, paste0(x, ".stn.csv"))
      if(readr::read_lines(fn, n_max = 1, skip = 1) == "Station,Name,Longitude,Latitude,Elevation(m),Network,stnid"){
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
      } else if(readr::read_lines(fn, n_max = 1, skip = 1) == "ID,NAME,LON,LAT,ELEV(m),Network,stnid"){
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
      }  else if(readr::read_lines(fn, n_max = 1, skip = 1) == "Station,Name,Longitude,Latitude,Elevation(m),Network"){
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
      } else{
        browser()
      }
      out_df %>% 
        dplyr::mutate(date = x %>% stringr::str_extract("[0-9]{8}") %>% lubridate::ymd(), 
                      type = type) %>% 
        dplyr::select(date, type, station, name, longitude, latitude, elevation, network, stnid)
    }) %>% 
    dplyr::bind_rows()
}

