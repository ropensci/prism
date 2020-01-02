# setup -------------------
orig_prism_path <- getOption("prism.path")
teardown(options(prism.path = orig_prism_path))

# the dl directory is the test file directory
dl_dir <- file.path("prism_test")
prism_set_dl_dir(dl_dir)

# need to unzip all the zip files, then delete the unzipped folder when exiting
avail_ppt <- paste0(
  "PRISM_ppt_stable_4kmD2_",
  c("19810101", "19910101", "20110101"),
  "_bil"
)
avail_tmin <- paste0(
  "PRISM_tmin_stable_4kmD2_",
  c("19810101", "20110615"),
  "_bil"
)

all_avail <- c(avail_tmin, avail_ppt)

for (ff in all_avail) {
  utils::unzip(
    file.path(dl_dir, paste0(ff, ".zip")), 
    exdir = file.path(dl_dir, ff)
  )
}

teardown({
  for (ff in all_avail) {
    unlink(file.path(dl_dir, ff), recursive = TRUE)
  }
})

test_that("Directory listings work",{
  skip_on_cran()
  expect_equal(dim(ls_prism_data())[1],5)
  expect_equal(dim(ls_prism_data())[2],1)
  expect_equal(dim(ls_prism_data(absPath = TRUE))[2],2)
  expect_equal(dim(ls_prism_data(name = TRUE))[2],2)
}) 