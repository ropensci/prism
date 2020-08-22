
# test works --------------------
exp_cols <- c("date","temp_period", "type", "station", "name", "longitude", 
              "latitude", "elevation", "network", "stnid")

avail_files <- rbind(c("ppt", "1981-01-01"), c("ppt", "1991-01-01"),
                     c("ppt", "2011-01-01"), c("tmin", "1981-01-01"),
                     c("tmin", "2011-06-15"))

test_that("prism_data_get_station_md() works", {
  for (i in seq_len(nrow(avail_files))) {
    expect_s3_class(
      x <- prism_data_get_station_md(
        avail_files[i, 1], 
        "daily", 
        dates = avail_files[i, 2]
      ),
      "tbl_df"
    )
    expect_gt(nrow(x), 0, label = avail_files[i,])
    expect_true(all(colnames(x) %in% exp_cols))
    expect_true(all(exp_cols %in% colnames(x)))
  }
  
  expect_warning(expect_s3_class(
    x <- prism_data_get_station_md(
      "tdmean", "monthly", years = 2005:2006, mon = 11:12
    ),
    "tbl_df"
  ))
  
  expect_equal(nrow(x), 3242 + 3255)
})

# errors -------------------------
test_that("get_prism_station_md() errors", {
  expect_error(
    prism_data_get_station_md("weird", "daily", dates = "2018-01-01")
  )
  expect_error(
    prism_data_get_station_md("tmean", "daily", dates = "2019-01-01")
  )
  expect_error(prism_data_get_station_md("ppt", "annual", years = 2000))
  expect_error(
    prism_data_get_station_md("tmax", "daily", dates = "2018-01-01"),
    paste0(
      "None of the requested dates are available.\n", 
      "  You must first download the data using `get_prism_*()`."
    ),
    fixed = TRUE
  )
  
  expect_warning(
    expect_s3_class(
      prism_data_get_station_md(
        avail_files[1, 1], 
        "daily",
        minDate = avail_files[1, 2], 
        maxDate = as.Date(avail_files[1, 2]) + 19
      ), 
      "tbl_df"
    )
  )
  
  expect_warning(
    expect_s3_class(
      prism_data_get_station_md(
        avail_files[2, 1], 
        "daily",
        minDate = avail_files[2, 2], 
        maxDate = as.Date(avail_files[2, 2]) + 1
      ), 
      "tbl_df"
    )
  )
})
