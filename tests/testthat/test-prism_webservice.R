good_zip <- file.path(test_path("prism_test"), "good.zip")
bad_zip <- file.path(test_path("prism_test"), "bad.zip")
empty_zip <- file.path(test_path("prism_test"), "empty.zip")

test_that("check_zip_file() works", {
  expect_true(prism:::check_zip_file(good_zip))
  expect_equal(
    prism:::check_zip_file(bad_zip),
    "You have tried to download the file PRISM_tmin_stable_4kmM3_198712_bil.zip more than twice in one day (Pacific local time).  Note that repeated offenses may result in your IP address being blocked."
  )
})

good_dir <- file.path(test_path("prism_test"),"good")
empty_dir <- file.path(test_path("prism_test"),"empty")

setup({
  utils::unzip(good_zip, exdir = good_dir)
  suppressWarnings(
    utils::unzip(empty_zip, exdir = empty_dir)
  )
})

teardown({
  unlink(good_dir, recursive = TRUE)
  unlink(empty_dir, recursive = TRUE)
})

test_that("check_unzipped_folder() works", {
  expect_warning(prism:::check_unzipped_folder(empty_dir, "blah"))
  expect_identical(
    prism:::check_unzipped_folder(good_dir, "blah"), 
    good_dir
  )
})
