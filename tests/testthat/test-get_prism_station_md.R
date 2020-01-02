# setup -------------------
orig_prism_path <- getOption("prism.path")
teardown(options(prism.path = orig_prism_path))

# the dl directory is the test file directory
dl_dir <- file.path("prism_test")
prism_set_dl_dir(dl_dir)

# need to unzip all the zip files, then delete the unzipped folder when exiting
avail_ppt <- paste0(
  "PRISM_ppt_stable_4kmD2_",
  c("19810101", "19910101", "20110101"),
  "_bil"
)
avail_tmin <- paste0(
  "PRISM_tmin_stable_4kmD2_",
  c("19810101", "20110615"),
  "_bil"
)

all_avail <- c(avail_tmin, avail_ppt)

for (ff in all_avail) {
  utils::unzip(
    file.path(dl_dir, paste0(ff, ".zip")), 
    exdir = file.path(dl_dir, ff)
  )
}

teardown({
  for (ff in all_avail) {
    unlink(file.path(dl_dir, ff), recursive = TRUE)
  }
})

# test works --------------------
exp_cols <- c("date", "type", "station", "name", "longitude", "latitude", 
              "elevation", "network", "stnid")

avail_files <- rbind(c("ppt", "1981-01-01"), c("ppt", "1991-01-01"),
                     c("ppt", "2011-01-01"), c("tmin", "1981-01-01"),
                     c("tmin", "2011-06-15"))

test_that("get_prism_station_md() works", {
  for (i in seq_len(nrow(avail_files))) {
    expect_s3_class(
      x <- get_prism_station_md(avail_files[i, 1], dates = avail_files[i, 2]),
      "tbl_df"
    )
    expect_gt(nrow(x), 0, label = avail_files[i,])
    expect_true(all(colnames(x) %in% exp_cols))
    expect_true(all(exp_cols %in% colnames(x)))
  }
})

# errors -------------------------
test_that("get_prism_station_md() errors", {
  expect_error(get_prism_station_md("weird", dates = "2018-01-01"))
  expect_error(
    get_prism_station_md("tmax", dates = "2018-01-01"),
    paste0("None of the requested dates are available.\n", 
    "You must first download the daily data.")
  )
})
