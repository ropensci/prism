#' Extract prism station metadata 
#' 
#' `pd_get_station_md()` extracts prism metadata on the stations used to 
#' generate the prism data. **The data must already be downloaded 
#' and available in the prism download folder.** "prism data", i.e., `pd` are 
#' the folder names returned by [prism_archive_ls()] or 
#' [prism_archive_subset()].
#' 
#' Note that station metadata does not exist for "tmean" type, any 
#' "annual" temporal periods, nor for daily normals. 
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
  
  # remove tmean from folders
  tmean <- stringr::str_detect(pd, "_tmean_")
  if (any(tmean)) {
    message("Removing tmean from specified `pd`.\n", 
            "Station metadata does not exist for tmean.")
    pd <- pd[!tmean]
  }
  
  # remove daily normals
  pattern <- "^PRISM_.*?_30yr_normal_.*?_\\d{4}_bil$"
  dn <- stringr::str_detect(pd, pattern)
  if (any(dn)) {
    message("Removing daily normals from `pd`.\n",
            "Station metadata does not exist for daily normals.")
    pd <- pd[!dn]
  }

  folders_to_get <- file.path(prism_get_dl_dir(), pd)
  folders_to_get <- pd[dir.exists(folders_to_get)]
  
  if (length(folders_to_get) == 0) {
    stop(
      "None of the requested dates are available.\n", 
      "  You must first download the data using `get_prism_*()`."
    )
  }
  
  zz <- folders_to_get %>% 
    lapply(read_md_csv) %>% 
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

# there are 4 different ways the metadata csv files are formatted. This function
# reads each of those different formats, and wrangles them into the same format
# with a consisent set of header names
# x should be a .bil file name
read_md_csv <- function(x) {
  fn <- file.path(getOption("prism.path"), x, paste0(x, ".stn.csv"))
  var_names <- readr::read_lines(fn, n_max = 1, skip = 1)
  
  # these are the 4 known ways that the metadata csv might be formatted
  v1 <- "Station,Name,Longitude,Latitude,Elevation(m),Network,stnid"
  v2 <- "ID,NAME,LON,LAT,ELEV(m),Network,stnid"
  v3 <-  "Station,Name,Longitude,Latitude,Elevation(m),Network"
  v4 <- "Station,Name,Longitude,Latitude,Elevation(m),Network,station_id"
  
  if (!any(var_names == v1, var_names == v2, var_names == v3, var_names == v4)){
    stop(
      "Metadata file does not appear to be formatted as expected.\n",
      "  Please check that the .stn.csv file exists and is from prism.\n",
      "  If it is, please file an issue at github.com/ropensci/prism and include the .stn.csv file."
    )
  }
  
  # reads and assigns type to any of the expected column names (not all will
  # exist in every csv file)
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
      stnid = readr::col_character(),
      ID = readr::col_character(),
      NAME = readr::col_character(),
      LON = readr::col_double(),
      LAT = readr::col_double(),
      `ELEV(m)` = readr::col_double(),
      station_id = readr::col_character()
    )
  ))
  
  if (var_names == v2) {
    out_df <- dplyr::rename(out_df, station = ID, name = NAME, longitude = LON, 
                            latitude = LAT, elevation = `ELEV(m)`, 
                            network = Network)
  } else {
    if (exists('station_id', out_df)) {
      out_df <- dplyr::rename(out_df, stnid = station_id)
    }
    
    if (!exists('stnid', out_df)) {
      # if stnid does not exist, add it with NA
      out_df <- dplyr::mutate(out_df, stnid = NA_character_)
    }
    
    out_df <- dplyr::rename(out_df, station = Station, name = Name, 
                            longitude = Longitude, latitude = Latitude, 
                            elevation = `Elevation(m)`, network = Network)
  }
  
  # add in the date and variable and file name to the data frame and then 
  # select specific columns
  out_df %>% 
    dplyr::mutate(
      date = pd_get_date(x), 
      type = pd_get_type(x),
      prism_data = x
    ) %>% 
    dplyr::select(date, prism_data, type, station, name, longitude, 
                  latitude, elevation, network, stnid)
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
