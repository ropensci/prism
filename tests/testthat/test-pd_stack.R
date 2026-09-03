test_that("pd_stack() works", {
  prism_set_dl_dir(file.path(tempdir(), 'prismdata', 'tif'))
  prism_set_format('geotiff')
  
  # three years
  
  dd <- prism_archive_subset(
    "ppt", 
    "annual", 
    years = 2000:2026, 
    resolution = '4km'
  )
  
  expect_s4_class(x <- pd_stack(dd), "SpatRaster")
  expect_equal(dim(x)[3], length(dd))
  expect_setequal(names(x), dd)
  
  # 1 year
  mm <- prism_archive_subset(
    "ppt", "annual normals", resolution = '4km'
  )
  
  expect_s4_class(x <- pd_stack(mm), "SpatRaster")
  expect_equal(dim(x)[3], length(mm))
  expect_setequal(names(x), mm)
  
  # combo month and days
  cc <- c(dd, mm)
  expect_s4_class(x <- pd_stack(cc), "SpatRaster")
  expect_equal(dim(x)[3], length(cc))
  expect_setequal(names(x), cc)
})
