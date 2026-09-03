# unable to test the interactive mode, but can check that it fails when not set
# and not interactive, or works when set

orig_prism_path <- prism_get_dl_dir()
teardown(options(prism.path = orig_prism_path))

prism_set_dl_dir(tempdir())

test_that("prism_check_dl_dir() works if path is set", {
  expect_equal(prism_check_dl_dir(), tempdir())
})

options(prism.path = NULL)
test_that("prism_check_dl_dir() fails if path is not set", {
  expect_error(prism_check_dl_dir())
})
