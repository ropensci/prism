# tests/testthat/test-prism-release-date.R
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
  
  with_mock_dir("prism-daily-tmin", {
    result2 <- prism_release_date_query(
      type = "tmin",
      resolution = "800m", 
      time_step = "daily",
      min_key = "20260901", 
      max_key = "20260915"
    )
  })
  
  expect_equal(nrow(result2), 15)
  expect_equal(unique(result2$grid_count), 1)
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
