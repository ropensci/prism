orig_dl <- prism_get_dl_dir()
teardown({prism_set_dl_dir(orig_dl)})

# prism:::prism_release_date_query -------------------------------------
test_that("prism_release_date_query parses responses", {
  with_mock_dir("prism-monthly-tmax", {
    result <- prism_release_date_query(
      type = "tmax",
      resolution = "4km", 
      time_step = "monthly",
      min_key = "200904", 
      max_key = "200904"
    )
  })
  
  expect_equal(nrow(result), 1)
  expect_equal(result$grid_count, 7)
  expect_equal(result$date_key, "200904")
  
  result2 <- with_mock_dir("prism-daily-tmin", {
    prism_release_date_query(
      type = "tmin",
      resolution = "800m", 
      time_step = "daily",
      min_key = "20260901", 
      max_key = "20260915"
    )
  })
  
  expect_equal(nrow(result2), 15)
  expect_equal(unique(result2$grid_count), c(2,1))
  expect_equal(result2$date_key, paste0("202609", sprintf("%02d", 1:15)))
})


test_that("prism_release_date_query builds the correct URLs", {
  with_mock_api({
    expect_GET(
      prism_release_date_query("tmax", "4km", "monthly", "200904", "200904"),
      "https://services.nacse.org/prism/data/get/releaseDate/us/4km/tmax/200904"
    )
    
    expect_GET(
      prism_release_date_query("ppt", "800m", "daily", "20260901", "20260915"),
      "https://services.nacse.org/prism/data/get/releaseDate/us/800m/ppt/20260901/20260915"
    )
  })
})

# pd_check_versions --------------------------------------
test_that("pd_check_versions works on test pd", {
  expect_error(pd_check_versions(character(0)))
  
  # annual data
  prism_set_dl_dir(tif_dl)
  
  expect_message(expect_equal(
    x <- pd_check_versions(),
    pd_check_versions(prism_archive_subset(type = "ppt"))
  ))
  
  expect_equal(dim(x), c(4, 11))
  expect_equal(unique(x$status), "not_supported")
  
  # monthly data
  prism_set_dl_dir(asc_dl)
  
  expect_message(expect_equal(
    x <- pd_check_versions(),
    pd_check_versions(prism_archive_subset(type = "tmean"))
  ))
  
  expect_equal(dim(x), c(1, 11))
  expect_equal(unique(x$status), "current")
  
  # daily data
  prism_set_dl_dir(nc_dl)
  
  expect_message(expect_equal(
    x <- pd_check_versions(),
    pd_check_versions(prism_archive_subset(type = "tmin"))
  ))
  
  expect_equal(dim(x), c(1, 11))
  expect_equal(unique(x$status), "current")
})

test_that("pd_check_versions() works on mock and sparse data", {
  prism_set_dl_dir(check_versions_dl)
  
  with_mock_dir("prism-daily-ppt", {
    x <- pd_check_versions()
  })
  
  expect_equal(dim(x), c(9, 11))
  expect_equal(x$release_number, c(seq(8, 2, -1), 2, 2))
})
