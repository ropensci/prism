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
  
  if (!is.character(pd)) {
    stop("`pd` must be a character vector of PRISM-data folder names.")
  }
  
  if (length(pd) == 0L) {
    stop("`pd` must contain at least one PRISM-data folder name.")
  }
  
  # Keep only requested folders that currently exist. Continue as long as at
  # least one requested PRISM-data folder is available locally.
  pd_path <- file.path(prism_get_dl_dir(), pd)
  folder_exists <- dir.exists(pd_path)
  
  if (!any(folder_exists)) {
    stop(
      "None of the requested PRISM-data folders are available.\n",
      "  You must first download the data using `get_prism_*()`."
    )
  }
  
  if (any(!folder_exists)) {
    missing <- pd[!folder_exists]
    n_missing <- length(missing)
    
    display_missing <- utils::head(missing, 10L)
    msg <- paste0(
      n_missing,
      " requested PRISM-data folder",
      if (n_missing == 1L) "" else "s",
      " do not exist and will be skipped:\n  ",
      paste(display_missing, collapse = "\n  ")
    )
    
    if (n_missing > 10L) {
      msg <- paste0(msg, "\n  ...")
    }
    
    warning(msg, call. = FALSE)
  }
  
  pd <- pd[folder_exists]
  pd_path <- pd_path[folder_exists]
  
  # Determine whether each locally available folder actually contains the
  # station metadata file named after its PRISM-data folder.
  stn_csv <- file.path(pd_path, paste0(pd, ".stn.csv"))
  has_stn_csv <- file.exists(stn_csv)
  
  # Derive metadata needed to index `stn_csv_matrix`. Replace only these
  # helper names if the package uses different pd_get_* function names.
  pd_info <- data.frame(
    prism_data = pd,
    time_step = pd_get_time_step(pd),
    variable = pd_get_type(pd),
    resolution = pd_get_resolution(pd),
    data_class = pd_get_data_class(pd),
    stringsAsFactors = FALSE
  )
  
  # Verify that the parsed characteristics exist in the expectation matrix
  # before indexing it. An NA expectation denotes an unsupported / untested
  # combination and is not treated as an expected absence.
  matrix_dims <- dimnames(stn_csv_matrix)
  
  in_matrix <- with(
    pd_info,
    time_step %in% matrix_dims$time_step &
      variable %in% matrix_dims$variable &
      resolution %in% matrix_dims$resolution &
      data_class %in% matrix_dims$data_class
  )
  
  expects_stn_csv <- rep(NA, length(pd))
  
  if (any(in_matrix)) {
    ii <- which(in_matrix)
    
    expects_stn_csv[ii] <- stn_csv_matrix[cbind(
      match(pd_info$time_step[ii], matrix_dims$time_step),
      match(pd_info$variable[ii], matrix_dims$variable),
      match(pd_info$resolution[ii], matrix_dims$resolution),
      match(pd_info$data_class[ii], matrix_dims$data_class)
    )]
  }
  
  # A value that cannot be indexed or is NA in the matrix has no declared
  # expectation. Warn separately so package-maintenance gaps are visible.
  if (anyNA(expects_stn_csv)) {
    unknown <- pd[is.na(expects_stn_csv)]
    n_unknown <- length(unknown)
    
    display_unknown <- utils::head(unknown, 10L)
    msg <- paste0(
      "No station-CSV expectation is defined for ",
      n_unknown,
      " PRISM-data folder",
      if (n_unknown == 1L) "" else "s",
      ":\n  ",
      paste(display_unknown, collapse = "\n  ")
    )
    
    if (n_unknown > 10L) {
      msg <- paste0(msg, "\n  ...")
    }
    
    warning(msg, call. = FALSE)
  }
  
  # The product has a station CSV even though the capability matrix says it
  # should not. Still read it: the physical file is authoritative.
  unexpected_found <- has_stn_csv & !is.na(expects_stn_csv) &
    !expects_stn_csv
  
  if (any(unexpected_found)) {
    found <- pd[unexpected_found]
    n_found <- length(found)
    
    display_found <- utils::head(found, 10L)
    msg <- paste0(
      "Found a `.stn.csv` file for ",
      n_found,
      " PRISM-data folder",
      if (n_found == 1L) "" else "s",
      " where station metadata was not expected:\n  ",
      paste(display_found, collapse = "\n  ")
    )
    
    if (n_found > 10L) {
      msg <- paste0(msg, "\n  ...")
    }
    
    warning(msg, call. = FALSE)
  }
  
  # The product capability matrix expects a station CSV, but the downloaded
  # directory does not contain it. It cannot be read, so it is skipped.
  expected_missing <- !has_stn_csv & !is.na(expects_stn_csv) &
    expects_stn_csv
  
  if (any(expected_missing)) {
    missing_stn <- pd[expected_missing]
    n_missing_stn <- length(missing_stn)
    
    display_missing_stn <- utils::head(missing_stn, 10L)
    msg <- paste0(
      "Did not find an expected `.stn.csv` file for ",
      n_missing_stn,
      " PRISM-data folder",
      if (n_missing_stn == 1L) "" else "s",
      ":\n  ",
      paste(display_missing_stn, collapse = "\n  "),
      "\n\n  The PRISM-data folder may be incomplete. Try downloading ",
      "the product again with `get_prism_*()`."
    )
    
    if (n_missing_stn > 10L) {
      msg <- paste0(msg, "\n  ...")
    }
    
    warning(msg, call. = FALSE)
  }
  
  expected_absent <- !has_stn_csv &
    !is.na(expects_stn_csv) &
    !expects_stn_csv
  
  if (any(expected_absent)) {
    no_metadata <- pd[expected_absent]
    n_no_metadata <- length(no_metadata)
    
    shown <- utils::head(no_metadata, 10L)
    
    msg <- paste0(
      "Station metadata are not available for ",
      n_no_metadata,
      " requested PRISM-data folder",
      if (n_no_metadata == 1L) "" else "s",
      ":\n  ",
      paste(shown, collapse = "\n  ")
    )
    
    if (n_no_metadata > 10L) {
      msg <- paste0(msg, "\n  ...")
    }
    
    message(msg)
  }
  
  pd_to_read <- pd[has_stn_csv]
  
  if (!length(pd_to_read)) {
    return(dplyr::tibble())
  }
  
  dplyr::bind_rows(lapply(pd_to_read, read_md_csv))
}

# there are 4 different ways the metadata csv files are formatted. This function
# reads each of those different formats, and wrangles them into the same format
# with a consistent set of header names
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
  out_df |> 
    dplyr::mutate(
      date = pd_get_date(x, complete = FALSE), 
      type = pd_get_type(x),
      prism_data = x
    ) |> 
    dplyr::select(date, prism_data, type, station, name, longitude, 
                  latitude, elevation, network, stnid)
}

# stn_csv_matrix[time_step, type, resolution, data_class]
# created with data-raw/create_station_md_matrix/make_stn_csv.matrix.R
stn_csv_matrix <- 
  structure(
    c(FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, 
      FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, 
      TRUE, TRUE, FALSE, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
      NA, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, 
      TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 
      TRUE, FALSE, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
      FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, 
      FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, 
      TRUE, FALSE, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
      FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, 
      FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, 
      TRUE, FALSE, NA, FALSE, FALSE, NA, FALSE, FALSE, NA, TRUE, FALSE, 
      NA, TRUE, FALSE), 
    dim = c(time_step = 3L, variable = 11L, resolution = 2L, data_class = 2L), 
    dimnames = list(
      time_step = c("daily", "monthly", "annual"), 
      variable = c("tmean", "tmin", "tmax", "tdmean", "ppt", "vpdmin", "vpdmax", 
                   "solclear", "solslope", "soltotal", "soltrans"), 
      resolution = c("4km", "800m"), 
      data_class = c("time series", "normals")
    )
  )
