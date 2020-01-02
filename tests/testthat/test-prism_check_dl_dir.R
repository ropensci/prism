# unable to test the interactive mode, but can check that it fails when not set
# and not interactive, or works wehn set

orig_prism_path <- getOption("prism.path")
teardown(options(prism.path = orig_prism_path))

prism_set_dl_dir(tempdir())

test_that("prism_check_dl_dir() works if path is set", {
  expect_equal(prism_check_dl_dir(), normalizePath(tempdir()))
  expect_warning(expect_equal(path_check(), normalizePath(tempdir())))
})

options(prism.path = NULL)
test_that("prism_check_dl_dir() fails if path is not set", {
  expect_error(prism_check_dl_dir())
})
