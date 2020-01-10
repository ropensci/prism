
test_that("Directory listings work",{
  skip_on_cran()
  expect_equal(dim(ls_prism_data())[1],5)
  expect_equal(dim(ls_prism_data())[2],1)
  expect_equal(dim(ls_prism_data(absPath = TRUE))[2],2)
  expect_equal(dim(ls_prism_data(name = TRUE))[2],2)
}) 