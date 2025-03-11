# Need to make test data smaller to pass CRAN polices (< 5MB)
# so will read in the PRISM data, trim to smaller geographic area, and replace
# original files in tests/testthat/prism_test

library(raster)
library(prism)
library(maps)

# unzip data -------------------------------------
# the dl directory is the test file directory
dl_dir <- file.path("data-raw/prism/")
#prism_set_dl_dir(dl_dir)

# need to unzip all the zip files, then delete the unzipped folder when exiting
avail_ppt <- paste0(
  "PRISM_ppt_stable_4kmD2_",
  c("19910101", "20110101"),
  "_bil"
)
avail_tmin <- paste0(
  "PRISM_tmin_stable_4kmD2_",
  c("19810101", "20110615"),
  "_bil"
)

avail_tdmean <- paste0("PRISM_tdmean_stable_4kmM3_2005", 11:12, "_bil")

avail_vpdmin <- "PRISM_vpdmin_30yr_normal_4kmM4_annual_bil"

avail_daily_normal <- "PRISM_ppt_30yr_normal_4kmD1_0301_bil"

all_avail <- c(avail_tmin, avail_ppt, avail_tdmean, avail_vpdmin)

all_avail <- avail_daily_normal

for (ff in all_avail) {
  utils::unzip(
    file.path(dl_dir, paste0(ff, ".zip")), 
    exdir = file.path(dl_dir, ff)
  )
}

# subset of states -------------------------------
ss <- sf::st_as_sf(maps::map(
  "state", 
  c("california"),
  plot = FALSE
)) 

ss <- raster::extent(ss)

# read prism data ---------------------
for (ff in all_avail) {
  print(ff)
  bil_file <- file.path("data-raw/prism", ff, paste0(ff,".bil"))
  
  f1 <- raster::raster(bil_file)
  
  # crop
  f1 <- raster::crop(f1, ss)
  
  # save file --------------------
  writeRaster(f1, bil_file, overwrite = TRUE)
}

# zip new files ------------------
orig_wd <- getwd()
on.exit(setwd(orig_wd))

for (ff in all_avail) {
  setwd(file.path(dl_dir, ff))
  
  all_files <- list.files(".")
  tmp_zip <- paste0(ff, ".zip")
  
  zip(tmp_zip, all_files)
  
  setwd(orig_wd)
  file.copy(
    file.path(dl_dir, ff, tmp_zip), 
    file.path("data-raw/small_prism", tmp_zip)
  )
}

message("Now delete the unzipped folders in data-raw/prism.")
message("And then copy/paste the folders in data-raw/small_prism into tests/testthat/prism_test.")
