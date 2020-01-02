orig_prism_path <- getOption("prism.path")
teardown(options(prism.path = orig_prism_path))
prism_set_dl_dir(tempdir())

# Check errors
test_that("get_prism_normals() errors correctly", {
  expect_error(
    get_prism_normals("vpdmin", "4km"),
    paste0("`mon` is `NULL` and `annual` is `FALSE`.\n",
    "Specify either monthly or/and annual data to download."),
    fixed = TRUE
  )
  
  expect_error(get_prism_normals("tmax", "400km", mon = 1))
  expect_error(get_prism_normals("tmaxtin", "4km", mon = 1))
  expect_error(
    get_prism_normals("tmin", "4km", mon = 0:3),
    "You must enter a month between 1 and 12"
  )
  expect_error(
    get_prism_normals("ppt", "800m", mon = 14, annual = TRUE),
    "You must enter a month between 1 and 12"
  )
})
