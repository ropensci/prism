
# Check errors
test_that("get_prism_normals() errors correctly", {
  expect_error(
    get_prism_annual('solclear', 2010)
  )
  
  expect_error(get_prism_dailys('soltotal', '2010-01-01', '2010-01-02'))
  expect_error(get_prism_monthlys("solslope", mon = 1))
})
