
n_files <- 10

test_that("Directory listings work",{
  skip_on_cran()
  expect_equal(dim(expect_warning(ls_prism_data())), c(n_files, 1))
  expect_equal(
    dim(expect_warning(ls_prism_data(absPath = TRUE))), 
    c(n_files, 2)
  )
  expect_equal(dim(expect_warning(ls_prism_data(name = TRUE))), c(n_files, 2))
  expect_equal(
    dim(expect_warning(y <- ls_prism_data(TRUE, TRUE))), 
    c(n_files, 3)
  )
  
  expect_warning(expect_length(x <- prism_archive_ls(), n_files))
  
  df <- data.frame(
    files = x,
    abs_path = pd_to_file(x),
    product_name = pd_get_name(x),
    stringsAsFactors = FALSE
  )
  
  y$abs_path <- normalizePath(y$abs_path)
  
  expect_identical(df, y)
}) 
