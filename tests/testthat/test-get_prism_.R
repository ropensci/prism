
# Check errors
test_that("get_prism_normals() errors correctly", {
  expect_error(
    get_prism_annual('solclear', 2010)
  )
  
  expect_error(get_prism_dailys('soltotal', '2010-01-01', '2010-01-02'))
  expect_error(get_prism_monthlys("solslope", mon = 1))

  ## Resolution errors (web services v2)
   expect_error(
    get_prism_dailys(type = "tmean", dates = "2013-06-01", resolution = "1km"),
    "'resolution' must be '4km' or '800m'"
  )
  
  expect_error(
    get_prism_monthlys(type = "ppt", years = 2023, mon = 6, resolution = "400m"),
    "'resolution' must be '4km' or '800m'"
  )
  
  expect_error(
    get_prism_annual(type = "tmax", years = 2023, resolution = "2km"),
    "'resolution' must be '4km' or '800m'"
  )
  
  # NEW: Test invalid resolution types
  expect_error(
    get_prism_dailys(type = "ppt", dates = "2013-06-01", resolution = 4),  # numeric instead of character
    "'resolution' must be '4km' or '800m'"
  )
  
  expect_error(
    get_prism_monthlys(type = "tmean", years = 2023, mon = 1, resolution = NULL),
    "'resolution' must be '4km' or '800m'"
  )
  
  expect_error(
    get_prism_normals(type = "solclear", mon = 1, resolution = '4km'),
    "Clear sky, sloped, and total solar radiation are only available in 800m."
  )
  
  expect_error(
    get_prism_normals(type = "soltrans", mon = 4, resolution = '4km'),
    "Clear sky, sloped, and total solar radiation are only available in 800m."
  )
})
