
n_files <- 10

test_that("Directory listings work",{
  skip_on_cran()
  
  expect_warning(expect_length(x <- prism_archive_ls(), n_files))
}) 
