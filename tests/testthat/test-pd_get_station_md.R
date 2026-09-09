# asc folder should fail/return nothing
# bil folder should fail/return nothing
# nc should work
# tif should fail


# test works --------------------
exp_cols <- c("date","prism_data", "type", "station", "name", "longitude", 
              "latitude", "elevation", "network", "stnid")

avail_files <- rbind(c("ppt", "1981-01-01"), c("ppt", "1991-01-01"),
                     c("ppt", "2011-01-01"), c("tmin", "1981-01-01"),
                     c("tmin", "2011-06-15"))

test_that("pd_get_station_md() works", {
  prism_set_dl_dir(md_dl)
  pd <- prism_archive_ls()
  
  # checking this; if it fails you probably added or removed test data from the
  # test_that/prismdata/md_only folder
  expect_equal(length(pd), 4)

  expect_s3_class(
    x <- expect_message(pd_get_station_md(pd)),
    "tbl_df"
  )
  expect_gt(nrow(x), 0)
  expect_setequal(colnames(x), exp_cols)
  
  
  expect_s3_class(
    y <- expect_no_message(pd_get_station_md(prism_archive_subset(
      "soltrans", "monthly normals", resolution = '800m'
    ))),
    "tbl_df"
  )
  expect_setequal(colnames(y), exp_cols)
  
  expect_gt(nrow(x), nrow(y))
  
  # asc folder return nothing
  prism_set_dl_dir(asc_dl)
  expect_s3_class(
    x <- expect_message(pd_get_station_md(prism_archive_ls())),
    "tbl_df"
  )
  expect_equal(nrow(x), 0)
  
  # bil folder should return nothing
  prism_set_dl_dir(bil_dl)
  expect_s3_class(
    x <- expect_message(pd_get_station_md(prism_archive_ls())),
    "tbl_df"
  )
  expect_equal(nrow(x), 0)
  
  # nc should work
  prism_set_dl_dir(nc_dl)
  expect_s3_class(
    x <- expect_no_message(pd_get_station_md(prism_archive_ls())),
    "tbl_df"
  )
  expect_gt(nrow(x), 0)
  
  # tif should return nothing
  prism_set_dl_dir(tif_dl)
  expect_s3_class(
    x <- expect_message(pd_get_station_md(prism_archive_ls())),
    "tbl_df"
  )
  expect_equal(nrow(x), 0)
})

test_that("pd_get_station_md() fails correctly", {
  # we know we don't have todays data
  expect_error(pd_get_station_md(
    paste0("prism_tmax_us_25m_", format(Sys.Date(), "%Y%m%d"))
  ))
})
