# get current prism path, store it, so it can be reverted after tests
cur_prism <- getOption("prism.path")
options("prism.path.tmp" = cur_prism)

# the dl directory is the test file directory
dl_dir <- file.path("prism_test")
prism_set_dl_dir(dl_dir)

# need to unzip all the zip files, then delete the unzipped folder when exiting
avail_ppt <- paste0(
  "PRISM_ppt_stable_4kmD2_",
  c("19810101", "19910101", "20110101", "20120101"),
  "_bil"
)
avail_tmin <- paste0(
  "PRISM_tmin_stable_4kmD2_",
  c("19810101", "20110615"),
  "_bil"
)

avail_tdmean <- paste0("PRISM_tdmean_stable_4kmM3_2005", 11:12, "_bil")

avail_vpdmin <- "PRISM_vpdmin_30yr_normal_4kmM4_annual_bil"

all_avail <- c(avail_tmin, avail_ppt, avail_tdmean, avail_vpdmin)

for (ff in all_avail) {
  utils::unzip(
    file.path(dl_dir, paste0(ff, ".zip")), 
    exdir = file.path(dl_dir, ff)
  )
}
