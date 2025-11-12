
# test works --------------------
exp_cols <- c("date","prism_data", "type", "station", "name", "longitude", 
              "latitude", "elevation", "network", "stnid")

avail_files <- rbind(c("ppt", "1981-01-01"), c("ppt", "1991-01-01"),
                     c("ppt", "2011-01-01"), c("tmin", "1981-01-01"),
                     c("tmin", "2011-06-15"))

test_that("pd_get_station_md() works", {
  for (i in seq_len(nrow(avail_files))) {
    expect_warning(expect_s3_class(
      x <- pd_get_station_md(prism_archive_subset(
        avail_files[i, 1], 
        "daily", 
        dates = avail_files[i, 2],
        resolution = '4km'
      )),
      "tbl_df"
    ))
    expect_gt(nrow(x), 0, label = avail_files[i,])
    expect_true(all(colnames(x) %in% exp_cols))
    expect_true(all(exp_cols %in% colnames(x)))
  }
  
  expect_warning(expect_s3_class(
    x <- pd_get_station_md(prism_archive_subset(
      "tdmean", "monthly", years = 2005:2006, mon = 11:12, resolution = '4km'
    )),
    "tbl_df"
  ))
  
  expect_equal(nrow(x), 3242 + 3255)
})

test_that("pd_get_station_md() fails correctly", {
  expect_warning(prism_archive_subset("ppt", "daily normals", resolution = "4km", mon = 3))
  expect_error(expect_warning(pd_get_station_md(pd)))
})
