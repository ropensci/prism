o_format <- prism_get_format()
o_dir <- prism_get_dl_dir()
teardown({
  prism_set_dl_dir(o_dir)
  prism_set_format(o_format)
})

test_that("pd_stack() works", {
  # test tiff separately b/c it has multiple files
  prism_set_dl_dir(file.path(tempdir(), 'prismdata', "tif"))
  prism_set_format("geotiff")
  
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
  
  # 1 year - verify both the legacy and updated normals API
  legacy_mm <- expect_warning(
    prism_archive_subset("ppt", "annual normals", resolution = "4km"),
    '`time_step = "annual normals"` is deprecated. Use `time_step = "annual", data_class = "normals"` instead.'
  )
  updated_mm <- expect_no_warning(
    prism_archive_subset(
      "ppt", "annual", data_class = "normals", resolution = "4km"
    )
  )
  
  expect_identical(legacy_mm, updated_mm)
  
  expect_s4_class(x <- pd_stack(updated_mm), "SpatRaster")
  expect_equal(dim(x)[3], length(updated_mm))
  expect_setequal(names(x), updated_mm)
  
  expect_gt(terra::ncell(x), 0L)
  expect_true(all(terra::res(x) > 0))
  expect_true(nchar(terra::crs(x)) > 0L)
  
  # combo month and days
  cc <- c(dd, updated_mm)
  expect_s4_class(x <- pd_stack(cc), "SpatRaster")
  expect_equal(dim(x)[3], length(cc))
  expect_setequal(names(x), cc)
  
  expect_gt(terra::ncell(x), 0L)
  expect_true(all(terra::res(x) > 0))
  expect_true(nchar(terra::crs(x)) > 0L)
  
  # test all other formats; they only have 1 file/format
  for (ff in c("nc", "bil")) {
    prism_set_dl_dir(file.path(tempdir(), 'prismdata', ff))
    prism_set_format(ff)
    
    dd <- prism_archive_ls()
    
    expect_s4_class(x <- pd_stack(dd), "SpatRaster")
    expect_equal(dim(x)[3], length(dd))
    
    # terra handles names of nc diferently
    if (ff != "nc")
      expect_setequal(names(x), dd)
    
    expect_gt(terra::ncell(x), 0L)
    expect_true(all(terra::res(x) > 0))
    expect_true(nchar(terra::crs(x)) > 0L)
  }
})
