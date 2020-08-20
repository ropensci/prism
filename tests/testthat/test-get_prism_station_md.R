
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
  expect_error(get_prism_station_md("tmean", dates = "2019-01-01"))
  expect_error(
    get_prism_station_md("tmax", dates = "2018-01-01"),
    paste0(
      "None of the requested dates are available.\n", 
      "  You must first download the daily data using `get_prism_dailys()`."
    ),
    fixed = TRUE
  )
  
  expect_warning(
    expect_s3_class(
      get_prism_station_md(
        avail_files[1, 1], 
        minDate = avail_files[1, 2], 
        maxDate = as.Date(avail_files[1, 2]) + 19
      ), 
      "tbl_df"
    )
  )
  
  expect_warning(
    expect_s3_class(
      get_prism_station_md(
        avail_files[2, 1], 
        minDate = avail_files[2, 2], 
        maxDate = as.Date(avail_files[2, 2]) + 1
      ), 
      "tbl_df"
    )
  )
})
