# the 2012-01-01 ppt is corrupt. Will check and see if it is found

# prism_set_dl_dir("prism_test")

test_that("corrupt file is found", {
  prism_set_dl_dir(corrupt_dl)
  prism_set_format('bil')
  
  expect_warning(expect_equal(
    prism_archive_verify(
      "ppt", "daily", 1991:2012, download_corrupt = FALSE, resolution = '4km'
    ),
    "prism_ppt_us_25m_20120101"
  ))
})

test_that("returns true when all valid", {
  prism_set_dl_dir(tif_dl)
  prism_set_format('geotiff')
  
  expect_true(prism_archive_verify("ppt", "annual", resolution = '4km'))
})

# check that url is correctly recreated

test_that("url is created correctly", {
  expect_equal(
    prism:::folder_to_url("prism_ppt_us_25m_20120101"),
    "https://services.nacse.org/prism/data/get/us/4km/ppt/20120101"
  )
  
  prism_set_format('bil')
  expect_equal(
    prism:::folder_to_url("prism_ppt_us_25m_20120101"),
    "https://services.nacse.org/prism/data/get/us/4km/ppt/20120101?format=bil"
  )
  
  prism_set_format('nc')
  ff <- c("prism_ppt_us_25m_191501", 
          "prism_tmean_us_30s_20200101_avg_30y",
          "prism_ppt_us_25m_202001_avg_30y")
  f2 <- c(
    "https://services.nacse.org/prism/data/get/us/4km/ppt/191501?format=nc",
    "https://data.prism.oregonstate.edu/normals/us/800m/tmean/daily/prism_tmean_us_30s_20200101_avg_30y.zip",
    "https://data.prism.oregonstate.edu/normals/us/4km/ppt/monthly/prism_ppt_us_25m_202001_avg_30y.zip"
  )
  
  expect_equal(prism:::folder_to_url(ff), f2)
})
