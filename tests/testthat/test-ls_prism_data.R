
test_that("Directory listings work",{
  skip_on_cran()
  expect_equal(dim(ls_prism_data()), c(7, 1))
  expect_equal(dim(ls_prism_data(absPath = TRUE)),c(7, 2))
  expect_equal(dim(ls_prism_data(name = TRUE)), c(7, 2))
}) 