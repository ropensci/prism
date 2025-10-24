# Web Service v2  ---------------------------------------------------------------

test_that("URL generation works with new web service", {
  # Basic functionality
  urls <- prism:::gen_prism_url(c("20230601", "20230602"), "tmean")
  
  expect_length(urls, 2)
  expect_true(all(grepl("^https://services.nacse.org/prism/data/get", urls)))
  expect_true(all(grepl("tmean", urls)))
  expect_true(all(grepl("format=bil", urls)))
})

test_that("URL generation handles different parameters", {
  # Test 800m resolution
  url_800m <- prism:::gen_prism_url("20230601", "ppt", resolution = "800m")
  expect_match(url_800m, "/800m/")
  
  # Test different format
  url_nc <- prism:::gen_prism_url("20230601", "tmax", format = "nc")
  expect_match(url_nc, "format=nc")
  
  # Test long-term dataset
  url_lt <- prism:::gen_prism_url("20230601", "tmin", dataset_type = "lt")
  expect_match(url_lt, "/lt\\?")
})

test_that("URL generation validates inputs", {
  # Invalid date format
  expect_error(
    prism:::gen_prism_url("2023-06-01", "tmean"),
    "Dates must be in YYYYMMDD \\(daily\\), YYYYMM \\(monthly\\), YYYY \\(annual\\), MM \\(monthly normals\\), or MMDD \\(daily normals\\) format"
  )
  
  # Invalid resolution
  expect_error(
    prism:::gen_prism_url("20230601", "tmean", resolution = "1km"),
    "must be one of.*800m.*4km"
  )
  
  # Invalid format
  expect_error(
    prism:::gen_prism_url("20230601", "tmean", format = "pdf"),
    "must be one of.*nc.*asc.*bil"
  )
})

test_that("URL generation produces expected format", {
  url <- prism:::gen_prism_url("20230615", "ppt", resolution = "4km", format = "bil")
  
  expected_pattern <- "^https://services\\.nacse\\.org/prism/data/get/us/4km/ppt/20230615\\?format=bil$"
  expect_match(url, expected_pattern)
})


# FTP Normals_Bil  ---------------------------------------------------------------


test_that("FTP normals service generates correct URLs", {
  # Test monthly normals (MM format)
  urls_monthly_normals <- prism:::gen_prism_url(
    c("01", "06", "12"), "tmean", 
    service = "ftp_v2_normals_bil"
  )
  expect_length(urls_monthly_normals, 3)
  expect_true(all(grepl("^https://data\\.prism\\.oregonstate\\.edu/normals", urls_monthly_normals)))
  expect_true(all(grepl("tmean", urls_monthly_normals)))
  
  # Test daily normals (MMDD format)  
  urls_daily_normals <- prism:::gen_prism_url(
    c("0101", "0301", "1225"), "ppt",
    service = "ftp_v2_normals_bil" 
  )
  expect_length(urls_daily_normals, 3)
  expect_true(all(grepl("normals", urls_daily_normals)))
  
  # Test annual normals (special case "14" -> "annual")
  url_annual_normals <- prism:::gen_prism_url(
    "14", "tmax",
    service = "ftp_v2_normals_bil"
  )
  expect_length(url_annual_normals, 1)
  expect_true(grepl("normals", url_annual_normals))
})

test_that("FTP normals service handles different resolutions", {
  # Test 4km resolution with normals
  url_normals_4km <- prism:::gen_prism_url(
    "01", "ppt", resolution = "4km",
    service = "ftp_v2_normals_bil"
  )
  expect_true(grepl("normals", url_normals_4km))
  expect_true(grepl("4km", url_normals_4km))
  
  # Test 800m resolution with normals
  url_normals_800m <- prism:::gen_prism_url(
    "03", "tdmean", resolution = "800m",
    service = "ftp_v2_normals_bil"
  )
  expect_true(grepl("normals", url_normals_800m))
  expect_true(grepl("800m", url_normals_800m))
})

test_that("FTP normals service handles all climate variables", {
  valid_types <- c("tmean", "tmax", "tmin", "tdmean", "ppt", "vpdmin", "vpdmax")
  
  for (var_type in valid_types) {
    url <- prism:::gen_prism_url(
      "06", var_type, 
      service = "ftp_v2_normals_bil"
    )
    expect_true(grepl("normals", url))
    expect_true(grepl(var_type, url))
  }
})


