
orig_format <- prism_get_format()
teardown({prism_set_format(orig_format)})

tst_mat <- read.csv(
  file.path(test_path(), "fixtures", "pd_get-test_matrix.csv")
)

# Hard coded prism folder names rather than relying on those in the testing 
# folders (for simplicity)
tst_files <- tst_mat$pd

# normals is used to subset multiple tests
normals <- prism:::pd_is_normal(tst_files)

test_that("internal is_normal() works", {
  expect_identical(normals, tst_mat$is_normal)
})

test_that("pd_get_name() works.", {
  exp <- tst_mat$full_name
  
  expect_identical(pd_get_name(tst_files), exp)
  expect_identical(pd_get_name(tst_files[normals]), exp[normals])
  expect_identical(pd_get_name(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_name(tst_files[1]), exp[1])
  expect_identical(pd_get_name(tst_files[3]), exp[3])
})

test_that("pd_get_date() works.", {
  exp <- tst_mat$date
  exp_legacy <- tst_mat$date_legacy
  
  expect_identical(pd_get_date(tst_files), exp)
  expect_identical(pd_get_date(tst_files, legacy = TRUE), exp_legacy)
  
  expect_identical(pd_get_date(tst_files[normals]), exp[normals])
  expect_identical(pd_get_date(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_date(tst_files[1]), exp[1])
  expect_identical(pd_get_date(tst_files[3]), exp[3])
})

test_that("pd_get_type() works.", {
  exp <- tst_mat$type
  
  expect_identical(pd_get_type(tst_files), exp)
  expect_identical(pd_get_type(tst_files[normals]), exp[normals])
  expect_identical(pd_get_type(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_type(tst_files[1]), exp[1])
  expect_identical(pd_get_type(tst_files[3]), exp[3])
})

test_that("pd_to_file() works.", {
  
  pd_to_file_and_split <- function(x) {
    # because files won't be found
    expect_warning(tmp <- pd_to_file(x))
    # replace \\ with / if it is there so splitting works
    tmp <- stringr::str_replace_all(tmp, "\\\\", "/")
    tmp <- stringr::str_split(tmp, "/", simplify = TRUE)
    
    tmp
  }
  
  expected_ext <- c(
    geotiff = "tif",
    bil = "bil",
    asc = "asc",
    nc = "nc"
  )
  
  for (ff in c('bil', 'geotiff', 'asc', 'nc')) {
  
    prism_set_format(ff)
    
    tmp <- pd_to_file_and_split(tst_files)
    
    expect_identical(tmp[,ncol(tmp) - 1], tst_files)
    
    expect_identical(
      tmp[!normals,ncol(tmp)], 
      paste0(tst_files[!normals], ".", expected_ext[[ff]])
    )
    
    # normals always use .tif
    expect_identical(
      tmp[normals, ncol(tmp)], 
      paste0(tst_files[normals], '.tif')
    )
  }
  
  # won't redo entire loop but will try a couple by them selves
  prism_set_format('nc')
  tmp <- pd_to_file_and_split(tst_files[3])

  expect_identical(tmp[,ncol(tmp) - 1], tst_files[3])
  expect_identical(
    tmp[1, ncol(tmp)], 
    paste0(tst_files[3], '.tif')
  )
  
  prism_set_format('geotiff')
  tmp <- pd_to_file_and_split(tst_files[2])
  
  expect_identical(tmp[,ncol(tmp) - 1], tst_files[2])
  expect_identical(
    tmp[1, ncol(tmp)], 
    paste0(tst_files[2], '.tif')
  )
})

test_that("pd_to_files(): bundled observed raster fixtures are readable", {
  for (ff in c('bil', 'geotiff', 'asc', 'nc')) {
    
    prism_set_format(ff)
    prism_set_dl_dir(file.path(
      tempdir(), "prismdata", ifelse(ff == "geotiff", "tif", ff)
    ))
    
    for (pd in prism_archive_ls()) {
      file <- pd_to_file(pd)
      expect_true(file.exists(file))
      
      r <- terra::rast(file)
      
      expect_s4_class(r, "SpatRaster")
      expect_gt(terra::ncell(r), 0L)
      expect_true(any(!is.na(terra::values(r, mat = FALSE))))
    }
    
  }

})

test_that("pd_get_time_step() works.", {
  exp <- tst_mat$time_step
  
  expect_identical(pd_get_time_step(tst_files), exp)
  expect_identical(pd_get_time_step(tst_files[normals]), exp[normals])
  expect_identical(pd_get_time_step(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_time_step(tst_files[1]), exp[1])
  expect_identical(pd_get_time_step(tst_files[3]), exp[3])
})

test_that("pd_get_data_class() works.", {
  exp <- tst_mat$data_class
  
  expect_identical(pd_get_data_class(tst_files), exp)
  expect_identical(pd_get_data_class(tst_files[normals]), exp[normals])
  expect_identical(pd_get_data_class(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_data_class(tst_files[1]), exp[1])
  expect_identical(pd_get_data_class(tst_files[3]), exp[3])
})

test_that("pd_get_resolution() works.", {
  exp <- tst_mat$resolution
  
  expect_identical(pd_get_resolution(tst_files), exp)
  expect_identical(pd_get_resolution(tst_files[normals]), exp[normals])
  expect_identical(pd_get_resolution(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_resolution(tst_files[1]), exp[1])
  expect_identical(pd_get_resolution(tst_files[3]), exp[3])
})
