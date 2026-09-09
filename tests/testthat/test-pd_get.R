
orig_format <- prism_get_format()
teardown({prism_set_format(orig_format)})

# Hard coded prism folder names rather than relying on those in the testing 
# folders (for simplicity)
tst_files <- c(
  "prism_ppt_us_25m_19670615", 
  "prism_tmin_us_25m_202004", 
  "prism_tmin_us_30s_2020_avg_30y", 
  "prism_tmax_us_25m_2019", 
  "prism_vpdmin_us_25m_196710", 
  "prism_vpdmax_us_25m_202004_avg_30y",
  "prism_ppt_us_25m_20200301_avg_30y",
  "prism_ppt_us_30s_1981",
  "prism_tmean_us_30s_200004", 
  "prism_tmean_us_30s_20140603",
  "prism_tmean_us_25m_1999",
  "prism_tmean_us_25m_201001",
  "prism_tmean_us_25m_20130113"
)

normals <- c(FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, rep(FALSE, 6))


exp <- c(
  "Jun 15, 1967 - 4km resolution - Precipitation", 
  "Apr 2020 - 4km resolution - Minimum temperature", 
  "Annual 30-year normals - 800m resolution - Minimum temperature", 
  "2019 - 4km resolution - Maximum temperature", 
  "Oct 1967 - 4km resolution - Minimum vapor pressure deficit", 
  "Apr 30-year normals - 4km resolution - Maximum vapor pressure deficit",
  "Mar 01 30-year normals - 4km resolution - Precipitation",
  "1981 - 800m resolution - Precipitation",
  "Apr 2000 - 800m resolution - Mean temperature",
  "Jun 03, 2014 - 800m resolution - Mean temperature",
  "1999 - 4km resolution - Mean temperature",
  "Jan 2010 - 4km resolution - Mean temperature",
  "Jan 13, 2013 - 4km resolution - Mean temperature"
)


test_that("pd_get_name() works.", {
  expect_identical(pd_get_name(tst_files), exp)
  expect_identical(pd_get_name(tst_files[normals]), exp[normals])
  expect_identical(pd_get_name(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_name(tst_files[1]), exp[1])
  expect_identical(pd_get_name(tst_files[3]), exp[3])
})

exp_legacy <- c("1967-06-15", "2020-04-01", "", "2019-01-01", "1967-10-01", 
                "", "", "1981-01-01", "2000-04-01", "2014-06-03", "1999-01-01", 
                "2010-01-01", "2013-01-13")

exp <- c("1967-06-15", "2020-04", "1991-2020", "2019", "1967-10", 
         "1991-2020-04", "1991-2020-03-01", "1981", "2000-04", "2014-06-03", 
         "1999", "2010-01", "2013-01-13")

test_that("pd_get_date() works.", {
  expect_identical(pd_get_date(tst_files), exp)
  expect_identical(pd_get_date(tst_files, legacy = TRUE), exp_legacy)
  
  expect_identical(pd_get_date(tst_files[normals]), exp[normals])
  expect_identical(pd_get_date(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_date(tst_files[1]), exp[1])
  expect_identical(pd_get_date(tst_files[3]), exp[3])
})

exp <- c('ppt', 'tmin', 'tmin', 'tmax', 'vpdmin', 'vpdmax', 'ppt', 
         'ppt', 'tmean', 'tmean', 'tmean', 'tmean', 'tmean')

test_that("pd_get_type() works.", {
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

exp <- c("daily", "monthly", "annual", "annual", "monthly", 
         "monthly", "daily", "annual", "monthly", "daily", 
         "annual", "monthly", "daily")

test_that("pd_get_time_step() works.", {
  expect_identical(pd_get_time_step(tst_files), exp)
  expect_identical(pd_get_time_step(tst_files[normals]), exp[normals])
  expect_identical(pd_get_time_step(tst_files[!normals]), exp[!normals])
  expect_identical(pd_get_time_step(tst_files[1]), exp[1])
  expect_identical(pd_get_time_step(tst_files[3]), exp[3])
})
