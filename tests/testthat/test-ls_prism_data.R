
n_files <- 8

test_that("Directory listings work",{
  skip_on_cran()
  expect_equal(dim(ls_prism_data()), c(n_files, 1))
  expect_equal(dim(ls_prism_data(absPath = TRUE)),c(n_files, 2))
  expect_equal(dim(ls_prism_data(name = TRUE)), c(n_files, 2))
}) 
