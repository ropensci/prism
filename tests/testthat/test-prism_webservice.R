test_that("check_zip_file() works", {
  expect_true(prism:::check_zip_file(file.path("prism_test", "good.zip")))
  expect_equal(
    prism:::check_zip_file(file.path("prism_test", "bad.zip")),
    "You have tried to download the file PRISM_tmin_stable_4kmM3_198712_bil.zip more than twice in one day (Pacific local time).  Note that repeated offenses may result in your IP address being blocked."
  )
})

setup({
  utils::unzip("prism_test/good.zip", exdir = "prism_test/good")
  suppressWarnings(
    utils::unzip("prism_test/empty.zip", exdir = "prism_test/empty")
  )
})

teardown({
  unlink("prism_test/good", recursive = TRUE)
  unlink("prim_test/empty", recursive = TRUE)
})

test_that("check_unzipped_folder() works", {
  expect_warning(prism:::check_unzipped_folder("prism_test/empty", "blah"))
  expect_identical(
    prism:::check_unzipped_folder("prism_test/good", "blah"), 
    "prism_test/good"
  )
})
