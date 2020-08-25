exp_cols <- c(
  "PRISM_DATASET_FILENAME",     
  "PRISM_DATASET_CREATE_DATE",  
  "PRISM_DATASET_TYPE",         
  "PRISM_CODE_VERSION",         
  "PRISM_DATASET_REMARKS",
  "PRISM_DATASET_VERSION",
  "file_path",
  "folder_path"
)

test_that("pd_get_md() works", {
  expect_s3_class(
    x <- pd_get_md(prism_archive_subset("ppt", "daily", year = 1981:2020)),
    "data.frame"
  )
  expect_identical(dim(x), c(3L, 8L))
  expect_setequal(colnames(x), exp_cols)
  
  expect_s3_class(
    x <- pd_get_md(prism_archive_subset("tdmean", "monthly", year = 2005, mon = 11:12)), 
    "data.frame"
  )
  expect_identical(dim(x), c(2L, 8L))
  expect_setequal(colnames(x), exp_cols)
  
  expect_s3_class(
    x <- pd_get_md(prism_archive_subset(
      "tmin", "daily", dates = c("1981-01-01", "2011-06-15")
    )), 
    "data.frame"
  )
  expect_identical(dim(x), c(2L, 8L))
  expect_setequal(colnames(x), exp_cols)
  
  expect_s3_class(
    y <- pd_get_md(prism_archive_subset("tmin", "daily", dates = "1981-01-01")), 
    "data.frame"
  )
  
  expect_identical(y, x[1,])
  
  expect_s3_class(
    x <- pd_get_md(
      prism_archive_subset("vpdmin", "annual normals", resolution = "4km")
    ), 
    "data.frame"
  )
  expect_identical(dim(x), c(1L, 8L))
  expect_setequal(colnames(x), exp_cols)
})
