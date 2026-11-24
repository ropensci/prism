original_options <- options()[c("prism.path", "prism.format", "prism.keepZip")]
teardown(options(original_options))

test_that("archive config saves and restores format and keepZip", {
  archive <- tempfile("prism-config-")
  dir.create(archive)
  prism_set_dl_dir(archive)
  prism_set_format("nc")
  prism_set_keepZip(FALSE)

  config_file <- expect_message(
    prism_archive_save_config(),
    "Saved PRISM archive configuration"
  )
  expect_equal(config_file, file.path(archive, "prism_archive.config"))
  expect_true(file.exists(config_file))

  options(prism.format = "bil", prism.keepZip = TRUE)
  expect_message(
    prism_set_dl_dir(archive),
    "format = 'nc', keepZip = FALSE"
  )

  expect_equal(prism_get_format(), "nc")
  expect_false(prism_get_keepZip())
})

test_that("setting changes warn and do not update saved config", {
  skip_if(interactive())

  archive <- tempfile("prism-config-mismatch-")
  dir.create(archive)
  prism_set_dl_dir(archive)
  prism_set_format("bil")
  prism_set_keepZip(TRUE)
  prism_archive_save_config()

  expect_no_warning(prism_set_format("bil"))
  expect_no_warning(prism_set_keepZip(TRUE))
  expect_warning(prism_set_format("nc"), "session-only")
  expect_warning(prism_set_keepZip(FALSE), "session-only")

  saved_config <- read.dcf(file.path(archive, "prism_archive.config"))
  expect_equal(unname(saved_config[1L, "format"]), "bil")
  expect_equal(unname(saved_config[1L, "keepZip"]), "TRUE")
  expect_equal(prism_get_format(), "nc")
  expect_false(prism_get_keepZip())

  expect_message(prism_archive_save_config(), "Saved PRISM archive configuration")
  saved_config <- read.dcf(file.path(archive, "prism_archive.config"))
  expect_equal(unname(saved_config[1L, "format"]), "nc")
  expect_equal(unname(saved_config[1L, "keepZip"]), "FALSE")
})

test_that("setting an archive without config preserves current settings", {
  archive <- tempfile("prism-no-config-")
  dir.create(archive)
  prism_set_dl_dir(archive)
  prism_set_format("geotiff")
  prism_set_keepZip(FALSE)

  expect_equal(prism_get_format(), "geotiff")
  expect_false(prism_get_keepZip())
})

test_that("invalid archive config does not change current settings", {
  current_archive <- tempfile("prism-current-")
  invalid_archive <- tempfile("prism-invalid-")
  dir.create(current_archive)
  dir.create(invalid_archive)
  writeLines(
    c("format: invalid", "keepZip: TRUE"),
    file.path(invalid_archive, "prism_archive.config")
  )

  prism_set_dl_dir(current_archive)
  prism_set_format("bil")
  prism_set_keepZip(FALSE)

  expect_error(prism_set_dl_dir(invalid_archive), "Invalid `format`")
  expect_equal(prism_get_dl_dir(), current_archive)
  expect_equal(prism_get_format(), "bil")
  expect_false(prism_get_keepZip())
})
