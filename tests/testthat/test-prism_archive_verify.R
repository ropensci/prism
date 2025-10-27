# the 2012-01-01 ppt is corrupt. Will check and see if it is found

# prism_set_dl_dir("prism_test")

test_that("corrupt file is found", {
  expect_equal(
    expect_warning(prism_archive_verify("ppt", "daily", 1991:2012, download_corrupt = FALSE, resolution = '4km')),
    "PRISM_ppt_stable_4kmD2_20120101_bil"
  )
})

test_that("returns true when all valid", {
  expect_true(prism_archive_verify("tmin", "daily", resolution = '4km'))
})

# check that url is correctly recreated

test_that("url is created correctly", {
  expect_equal(
    prism:::folder_to_url("PRISM_ppt_stable_4kmD2_20120101_bil"),
    "https://services.nacse.org/prism/data/get/us/4km/ppt/20120101?format=bil"
  )
  
  ff <- c("prism_ppt_us_25m_191501", 
          "prism_tmean_us_30s_20200101_avg_30y",
          "prism_ppt_us_25m_202001_avg_30y")
  f2 <- c(
    "https://services.nacse.org/prism/data/get/us/4km/ppt/191501?format=bil",
    "https://data.prism.oregonstate.edu/normals/us/800m/tmean/daily/prism_tmean_us_30s_20200101_avg_30y.zip",
    "https://data.prism.oregonstate.edu/normals/us/4km/ppt/monthly/prism_ppt_us_25m_202001_avg_30y.zip"
  )
  
  expect_equal(prism:::folder_to_url(ff), f2)
})
