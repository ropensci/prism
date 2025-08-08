# the 2012-01-01 ppt is corrupt. Will check and see if it is found

# prism_set_dl_dir("prism_test")

test_that("corrupt file is found", {
  expect_equal(
    expect_warning(prism_archive_verify("ppt", "daily", 1991:2012, download_corrupt = FALSE)),
    "PRISM_ppt_stable_4kmD2_20120101_bil"
  )
})

test_that("returns true when all valid", {
  expect_true(prism_archive_verify("tmin", "daily"))
})

# check that url is correctly recreated

test_that("url is created correctly", {
  expect_equal(
    prism:::folder_to_url("PRISM_ppt_stable_4kmD2_20120101_bil"),
    "http://services.nacse.org/prism/data/public/4km/ppt/20120101"
  )
  
  ff <- c("PRISM_ppt_stable_4kmD2_20120101_bil", 
          "PRISM_ppt_30yr_normal_800mM2_02_bil",
          "PRISM_tmax_30yr_normal_4kmM2_annual_bil")
  f2 <- c(
    "http://services.nacse.org/prism/data/public/4km/ppt/20120101",
    "http://services.nacse.org/prism/data/public/normals/800m/ppt/02",
    "http://services.nacse.org/prism/data/public/normals/4km/tmax/14"
  )
  
  expect_equal(prism:::folder_to_url(ff), f2)
})
