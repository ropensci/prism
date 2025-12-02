
n_files <- 10

test_that("Directory listings work",{
  skip_on_cran()

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
