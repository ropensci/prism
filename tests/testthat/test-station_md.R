context("Station metadata")
test_that("get_prism_station_md works", {
  options(prism.path = "prism_test/")
  get_prism_station_md(type = "tmin", minDate = "1981-01-01", maxDate = "2015-01-01")
  get_prism_station_md(type = "ppt", minDate = "1981-01-01", maxDate = "2015-01-01")
})

# test_that("get_prism_station_md works for the complete prism dataset", {
#   options(prism.path = "E:/prism")
#   out <- purrr::map(1981:2016, function(x){
#     get_prism_station_md(type = "tmin", minDate = paste0(x, "-12-31"), maxDate = paste0(x, "-12-31"))
#     get_prism_station_md(type = "tmax", minDate = paste0(x, "-12-31"), maxDate = paste0(x, "-12-31"))
#     get_prism_station_md(type = "ppt", minDate = paste0(x, "-12-31"), maxDate = paste0(x, "-12-31"))
#   })
# })