# Need to make test data smaller to pass CRAN polices (< 5MB)
# so will read in the PRISM data, trim to smaller geographic area, and replace
# original files in tests/testthat/prism_test

library(terra)
library(sf)
library(prism)
library(maps)

# bil - annual tmax
# asci - monthly tmean
# nc - daily tmin
# geotiff - annual precip * 3
# geotiff - 30-year normal annual precip


# download data
bil_dir <- file.path("data-raw/prism/bil")
asc_dir <- file.path("data-raw/prism/asc")
nc_dir <- file.path("data-raw/prism/nc")
tif_dir <- file.path("data-raw/prism/tif")
dl_dir <- file.path("data-raw/prism")

prism_set_dl_dir(bil_dir)
prism_set_format('bil')
get_prism_annual("tmax", 2025)

prism_set_dl_dir(asc_dir)
prism_set_format('asc')
get_prism_monthlys('tmean', 2025, 7)

prism_set_dl_dir(nc_dir)
prism_set_format('nc')
get_prism_dailys('tmin', dates = "2025-07-04")

prism_set_dl_dir(tif_dir)
prism_set_format('geotiff')
get_prism_annual('ppt', 2023:2025)
get_prism_normals('ppt', '4km', annual = TRUE)

# unzip data -------------------------------------
# need to unzip all the zip files, then delete the unzipped folder when exiting
all_avail <- list.files(dl_dir, recursive = TRUE)

for (ff in all_avail) {
  tmp_folder <- stringr::str_remove(ff, "\\.zip$")
  
  utils::unzip(
    file.path("data-raw/prism", ff), 
    exdir = file.path(dl_dir, tmp_folder)
  )
}


# crop/trim the prism data
# Boulder County boundary ------------------------------------------------
# `maps::map("county")` identifies counties as "state,county".

boulder_county <- sf::st_as_sf(
  maps::map(
    database = "county",
    regions = "colorado,boulder",
    fill = TRUE,
    plot = FALSE
  )
)

# `maps` coordinates are longitude/latitude.
sf::st_crs(boulder_county) <- "EPSG:4326"

# Crop and save data -------------------------------------------------
# `all_avail` should be your vector of PRISM-data folder names.
# Example:
# all_avail <- c(
#   "prism_ppt_us_25m_201001",
#   "prism_tmax_us_25m_20020703"
# )

write_prism_fixture <- function(r, filename, format) {
  switch(
    format,
    bil = terra::writeRaster(
      r,
      filename = filename,
      filetype = "EHdr",
      overwrite = TRUE
    ),
    
    asc = terra::writeRaster(
      r,
      filename = filename,
      filetype = "AAIGrid",
      overwrite = TRUE
    ),
    
    tif = terra::writeRaster(
      r,
      filename = filename,
      filetype = "GTiff",
      overwrite = TRUE
    ),
    
    nc = terra::writeCDF(
      r,
      filename = filename,
      overwrite = TRUE
    ),
    
    stop(
      "Unsupported output format: `", format, "`.",
      call. = FALSE
    )
  )
}

all_avail <- stringr::str_remove(all_avail, ".zip")

for (ff in all_avail[4:7]) {
  message("Cropping: ", ff)
  
  fext <- stringr::str_remove(ff, "/.*$")
  tmp_folder <- stringr::str_remove(ff, ".*/")
  
  bil_file <- file.path(
    "data-raw",
    "prism",
    ff,
    paste0(tmp_folder, ".", fext)
  )
  
  # Read the real PRISM BIL raster.
  r <- terra::rast(bil_file)
  
  # Reproject Boulder County to the raster CRS.
  boulder_vect <- terra::project(
    terra::vect(boulder_county),
    terra::crs(r)
  )
  
  # Crop to the county extent, then set cells outside the county to NA.
  r_small <- terra::crop(r, boulder_vect)
  r_small <- terra::mask(r_small, boulder_vect)
  
  # `EHdr` writes the BIL payload and the accompanying .hdr file.
  write_prism_fixture(
    r_small,
    filename = bil_file,
    format = fext
  )
  
  r_check <- terra::rast(bil_file)
  
  stopifnot(
    terra::ncell(r_check) > 0L,
    any(!is.na(terra::values(r_check, mat = FALSE)))
  )
}

# zip new files ------------------
orig_wd <- getwd()
on.exit(setwd(orig_wd))

for (ff in all_avail[2:7]) {
  fext <- stringr::str_remove(ff, "/.*$")
  tmp_folder <- stringr::str_remove(ff, ".*/")
  
  setwd(file.path(dl_dir, ff))
  
  all_files <- list.files(".")
  tmp_zip <- paste0(tmp_folder, ".zip")
  
  zip(tmp_zip, all_files)
  
  setwd(orig_wd)
  file.copy(
    file.path(dl_dir, ff, tmp_zip), 
    file.path("data-raw/small_prism", fext, tmp_zip)
  )
}

message("Now delete the unzipped folders in data-raw/prism.")
message("And then copy/paste the folders in data-raw/small_prism into tests/testthat/prism_test.")
