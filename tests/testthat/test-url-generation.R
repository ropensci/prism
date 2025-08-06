test_that("URL generation works with new web service", {
  # Basic functionality
  urls <- prism:::gen_prism_url_v2(c("20230601", "20230602"), "tmean")
  
  expect_length(urls, 2)
  expect_true(all(grepl("^https://services.nacse.org/prism/data/get", urls)))
  expect_true(all(grepl("tmean", urls)))
  expect_true(all(grepl("format=bil", urls)))
})

test_that("URL generation handles different parameters", {
  # Test 800m resolution
  url_800m <- prism:::gen_prism_url_v2("20230601", "ppt", resolution = "800m")
  expect_match(url_800m, "/800m/")
  
  # Test different format
  url_nc <- prism:::gen_prism_url_v2("20230601", "tmax", format = "nc")
  expect_match(url_nc, "format=nc")
  
  # Test long-term dataset
  url_lt <- prism:::gen_prism_url_v2("20230601", "tmin", dataset_type = "lt")
  expect_match(url_lt, "/lt\\?")
})

test_that("URL generation validates inputs", {
  # Invalid date format
  expect_error(
    prism:::gen_prism_url_v2("2023-06-01", "tmean"),
    "Dates must be in YYYYMMDD \\(daily\\), YYYYMM \\(monthly\\), YYYY \\(annual\\), MM \\(monthly normals\\), or MMDD \\(daily normals\\) format"
  )
  
  # Invalid climate variable
  expect_error(
    prism:::gen_prism_url_v2("20230601", "invalid_var"),
    "must be one of.*ppt.*tmin.*tmax"
  )
  
  # Invalid resolution
  expect_error(
    prism:::gen_prism_url_v2("20230601", "tmean", resolution = "1km"),
    "must be one of.*800m.*4km"
  )
  
  # Invalid format
  expect_error(
    prism:::gen_prism_url_v2("20230601", "tmean", format = "pdf"),
    "must be one of.*nc.*asc.*bil"
  )
})

test_that("URL generation produces expected format", {
  url <- prism:::gen_prism_url_v2("20230615", "ppt", resolution = "4km", format = "bil")
  
  expected_pattern <- "^https://services\\.nacse\\.org/prism/data/get/us/4km/ppt/20230615\\?format=bil$"
  expect_match(url, expected_pattern)
})

