f1 <- normalizePath(file.path(tempdir(), "prism", "new"), mustWork = FALSE)
f2 <- normalizePath(file.path(tempdir(), "prism2"), mustWork = FALSE)
f3 <- normalizePath(file.path(tempdir(), "*$.txt"), mustWork = FALSE)

orig_prism_path <- getOption("prism.path")
teardown(options(prism.path = orig_prism_path))

test_that("prism_set_dl_dir() works", {
  expect_equal(prism_set_dl_dir(f1), normalizePath(f1))
  expect_true(dir.exists(f1))
  expect_equal(prism_get_dl_dir(), normalizePath(f1))
  expect_equal(prism_set_dl_dir(f2), normalizePath(f2))
  expect_true(dir.exists(f2))
  expect_equal(prism_get_dl_dir(), normalizePath(f2))
})

test_that("prism_set_dl_dir() fails correctly on windows", {
  skip_on_travis()
  skip_on_os(c("mac", "linux", "solaris"))
  expect_warning(expect_error(prism_set_dl_dir(f3)))
})
