# live smoke test: 2 downloads from PRISM web service
library(testthat) # b/c anticipate running from GH actions by itself

test_that("live PRISM observed and normals smoke test", {
  skip_on_cran()
  
  if (!identical(Sys.getenv("RUN_PRISM_LIVE_TESTS"), "true")) {
    skip("Set RUN_PRISM_LIVE_TESTS=true to run live PRISM smoke tests.")
  }
  
  old_dir <- prism_get_dl_dir()
  old_format <- prism_get_format()
  
  live_dir <- tempdir()
  
  teardown({
    prism_set_dl_dir(old_dir)
    prism_set_format(old_format)
    unlink(live_dir, recursive = TRUE, force = TRUE)
  })
  
  prism_set_dl_dir(file.path(live_dir, "prismdata"))
  prism_set_format("geotiff")
  
  mm <- "ppt"
  nn <- "tmin"
  
  get_prism_monthlys(
    type = mm,
    years = 2010,
    mon = 1,
    keepZip = FALSE
  )
  
  get_prism_normals(
    type = nn,
    resolution = "4km",
    annual = TRUE,
    keepZip = FALSE
  )
  
  pd_observed <- prism_archive_subset(
    mm, temp_period = "monthly", resolution = "4km"
  )
  
  pd_normal <- prism_archive_subset(
    nn, "annual normals", resolution = "4km"
  )
  
  expect_length(pd_observed, 1L)
  expect_length(pd_normal, 1L)
  
  observed_file <- pd_to_file(pd_observed)
  normal_file <- pd_to_file(pd_normal)
  
  expect_true(file.exists(observed_file))
  expect_true(file.exists(normal_file))
  
  observed_r <- terra::rast(observed_file)
  normal_r <- terra::rast(normal_file)
  
  expect_s4_class(observed_r, "SpatRaster")
  expect_s4_class(normal_r, "SpatRaster")
  
  expect_gt(terra::ncell(observed_r), 0L)
  expect_gt(terra::ncell(normal_r), 0L)
  
  expect_true(nchar(terra::crs(observed_r)) > 0L)
  expect_true(nchar(terra::crs(normal_r)) > 0L)
})
