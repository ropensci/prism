exp_cols <- c(
  "PRISM_DATASET_FILENAME",     
  "PRISM_DATASET_CREATE_DATE",  
  "PRISM_DATASET_TYPE",         
  "PRISM_CODE_VERSION",         
  "PRISM_DATASET_REMARKS",
  "PRISM_DATASET_VERSION",
  "file_path",
  "folder_path",
  "PRISM_SOURCE_FILENAME",
  "PRISM_SOURCE_CREATE_DATE",
  "PRISM_DATASET_RELEASE_NUMBER"
)

test_that("pd_get_md() works", {
  prism_set_dl_dir(tif_dl)
  prism_set_format("geotiff")
  
  expect_s3_class(
    x <- pd_get_md(prism_archive_ls()),
    "data.frame"
  )
  expect_identical(dim(x), c(4L, 11L))
  expect_setequal(colnames(x), exp_cols)
  
  prism_set_dl_dir(nc_dl)
  prism_set_format("nc")
  expect_s3_class(
    x <- pd_get_md(
      prism_archive_ls()
    ), 
    "data.frame"
  )
  expect_identical(dim(x), c(1L, 11L))
  expect_setequal(colnames(x), exp_cols)
  
  prism_set_dl_dir(bil_dl)
  prism_set_format("bil")
  expect_s3_class(
    x <- pd_get_md(prism_archive_ls()), 
    "data.frame"
  )
  expect_identical(dim(x), c(1L, 11L))
  expect_setequal(colnames(x), exp_cols)
  
  prism_set_dl_dir(asc_dl)
  prism_set_format("asc")
  expect_s3_class(
    x <- pd_get_md(prism_archive_ls()),
    "data.frame"
  )
  expect_identical(dim(x), c(1L, 11L))
  expect_setequal(colnames(x), exp_cols)
  
  # test daily and monthly normals -------------
  prism_set_dl_dir(md_dl)
  prism_set_format('geotiff')
  expect_s3_class(
    x <- pd_get_md(prism_archive_ls()),
    "data.frame"
  )
  expect_identical(dim(x), c(2L, 8L))
  expect_contains(exp_cols, colnames(x))
})
