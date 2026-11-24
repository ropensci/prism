orig_dl <- prism_get_dl_dir()
teardown({prism_set_dl_dir(orig_dl)})

test_that("get_prism_pd() errors correctly", {
  expect_error(get_prism_pd(1))
  expect_error(get_prism_pd(character(0)))
  expect_error(get_prism_pd(c("notpd", "not_pd")))
})

test_that("get_prism_pd() skips correctly", {
  prism_set_dl_dir(tif_dl)
  
  result <- evaluate_promise(get_prism_pd(prism_archive_ls()))
  
  expect_equal(result$result, character(0))
  expect_length(result$messages, length(prism_archive_ls()))
  expect_true(all(grepl(
    "already exists\\. Skipping downloading\\.", 
    result$messages)
  ))
})

test_that("parse_pd_df_for_url() works", {
  # annual/normal
  prism_set_dl_dir(tif_dl)
  x <- parse_archive_pd(prism_archive_ls())
  
  expect_s3_class(y <- parse_pd_df_for_url(x), "data.frame")
  expect_equal(ncol(x), ncol(y))
  expect_equal(nrow(x), nrow(y))
  
  expect_setequal(y$date, c(2023, 2024, 2025, 14))
  
  # daily
  prism_set_dl_dir(nc_dl)
  x <- parse_archive_pd(prism_archive_ls())
  
  expect_s3_class(y <- parse_pd_df_for_url(x), "data.frame")
  expect_equal(ncol(x), ncol(y))
  expect_equal(nrow(x), nrow(y))
  expect_equal(y$date, "20250704")
})