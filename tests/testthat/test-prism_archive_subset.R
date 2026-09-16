
# prism_archive_subset() errors ------------------
test_that("prism_archive_subset() errors correctly", {
  # unsupported resolution
  expect_error(
    prism_archive_subset(
      "tmean", 
      "daily", 
      resolution = '1m', 
      minDate = "2013-06-07", 
      maxDate = "2013-06-10"
    ), 
    "`resolution` must be `NULL` or contain only: 4km, 800m."
  )
  expect_error(
    prism_archive_subset(
      "ppt", "daily", resolution = '400m', mon = 1, years = 1981:2011
    ), 
    "`resolution` must be `NULL` or contain only: 4km, 800m."
  )
  
  # unsupported variables
  expect_error(
    prism_archive_subset("tmaxx", "annual", resolution = '800m'), 
    "`type` must be `NULL` or contain only supported PRISM variables."
  )
  expect_error(
    prism_archive_subset("vpdmiin", "annual", resolution = '800m'), 
    "`type` must be `NULL` or contain only supported PRISM variables."
  )
  
  # unsupported time_step
  expect_error(
    prism_archive_subset("tmean", "ann", resolution = '800m'), 
    "`time_step` must be `NULL` or contain only: annual, monthly, daily."
  )
  expect_error(
    prism_archive_subset("tmean", "annual_normals", resolution = '800m'), 
    "`time_step` must be `NULL` or contain only: annual, monthly, daily."
  )
  # annual - unnecessary specifications
  expect_error(
    prism_archive_subset("tmean", "annual", mon = 1, resolution = '800m'),
    "`mon` cannot be used with `time_step = \"annual\"`."
  )
  expect_error(
    prism_archive_subset(
      "tmean", "annual", dates = "2018-01-01", resolution = '800m'
    ),
    "`minDate`, `maxDate`, and `dates` can only be used with `time_step = \"daily\"`."
  )
  expect_error(
    prism_archive_subset(
      "tmean", 
      "annual", 
      minDate = "2018-01-01", 
      maxDate = "2018-01-05", 
      resolution = '800m'
    ),
    "`minDate`, `maxDate`, and `dates` can only be used with `time_step = \"daily\"`."
  )

  
  # monthly - unnecessary specifications
  expect_error(
    prism_archive_subset(
      "tmean", "monthly", dates = "2018-01-01", resolution = '800m'
    ),
    "`minDate`, `maxDate`, and `dates` can only be used with `time_step = \"daily\"`."
  )
  expect_error(
    prism_archive_subset(
      "tmean", 
      "monthly",
      minDate = "2018-01-01",
      maxDate = "2018-01-05", 
      resolution = '800m'
    ),
    "`minDate`, `maxDate`, and `dates` can only be used with `time_step = \"daily\"`."
  )

  # normals - unecessary/incomplete specifications
  expect_warning(
    prism_archive_subset("tmean", "annual normals"),
    '`time_step = "annual normals"` is deprecated. Use `time_step = "annual", data_class = "normals"` instead.'
  )
  expect_warning(
    prism_archive_subset("tmean", "monthly normals"),
    '`time_step = "monthly normals"` is deprecated. Use `time_step = "monthly", data_class = "normals"` instead.'
  )
  expect_warning(expect_error(
    prism_archive_subset("tmean", "annual normals", resolution = "4pm"),
    "`resolution` must be `NULL` or contain only: 4km, 800m."
  ))
  expect_warning(expect_error(
    prism_archive_subset("tmean", "monthly normals", resolution = "800mm"),
    "`resolution` must be `NULL` or contain only: 4km, 800m."
  ))
  
  expect_warning(
    prism_archive_subset(
      'solclear', "daily normals", resolution = '4km', mon = 1:2),
    '`time_step = "daily normals"` is deprecated. Use `time_step = "daily", data_class = "normals"` instead.'
  )
  
  # daily unnecessary specifications
  expect_error(
    prism_archive_subset(
      "tmin", "daily", years = 1999, dates = "1999-01-01", resolution = "800m"
    ),
    "Use either `years`/`mon` or `minDate`/`maxDate`/`dates` when selecting daily datasets."
  )
  expect_error(
    prism_archive_subset(
      "tmin", "daily", mon = 3, minDate = "1999-01-01", resolution = "800m"
    ),
    "`minDate` and `maxDate` must be supplied together."
  )
  
  expect_error(
    prism_archive_subset(
      "tmin", 
      "daily", 
      mon = 3, 
      minDate = "1999-01-01", 
      resolution = '4km', 
      data_class = "normals"
    ),
    '`minDate` and `maxDate` must be supplied together.'
  )
})

test_that("prism_archive_subset validates incompatible inputs", {
  expect_error(
    expect_warning(prism_archive_subset(
      temp_period = "annual",
      mon = 1L
    )),
    "`mon` cannot be used"
  )
  
  expect_error(
    expect_warning(prism_archive_subset(
      temp_period = "daily",
      years = 2010L,
      dates = "2010-01-01"
    )),
    "either `years`/`mon` or `minDate`/`maxDate`/`dates`"
  )
  
  expect_error(
    expect_warning(prism_archive_subset(
      temp_period = "monthly normals",
      data_class = "time series"
    )),
    "`data_class`"
  )
  
  expect_error(
    prism_archive_subset(temp_period = "annual", time_step = "annual")
  )
})

# matches ls -----------------------------------------------
test_that("prism_archive_subset returns all archive entries without filters", {
  expect_setequal(
    prism_archive_subset(),
    prism_archive_ls()
  )
})

# prism_archive_subset() with test folders -------------
test_that("prism_archive_subset() works", {
  prism_set_dl_dir(tif_dl)
  
  expect_equal(
    prism_archive_subset(
      "ppt", "annual", resolution = "4km", data_class = "time series"
    ),
    prism_archive_subset("ppt", "annual", resolution = "4km", years = 2023:2025)
  )
  expect_warning(expect_equal(
    prism_archive_subset('ppt', 'annual normals', resolution = '4km'),
    "prism_ppt_us_25m_2020_avg_30y"
  ))
  
  expect_equal(
    expect_warning(
      prism_archive_subset('ppt', 'annual normals', resolution = '4km')
    ),
    prism_archive_subset(
      'ppt', 'annual', resolution = '4km', data_class = "normals"
    )
  )
  
  expect_equal(
    expect_warning(
      prism_archive_subset("ppt", temp_period = "annual")
    ),
    prism_archive_subset("ppt", time_step = "annual")
  )
  
  prism_set_dl_dir(asc_dl)
  expect_equal(
    prism_archive_subset("tmean", "monthly", resolution = "4km"),
    prism_archive_subset("tmean", "monthly", mon = 7, resolution = "4km")
  )

  prism_set_dl_dir(nc_dl)
  expect_equal(
    prism_archive_subset("tmin", "daily", resolution = "4km"),
    prism_archive_subset("tmin", "daily", mon = 7, resolution = "4km")
  )
  
  expect_equal(
    prism_archive_subset("tmin", "daily", resolution = "4km"),
    prism_archive_subset(
      "tmin", 
      "daily", 
      minDate = c("2025-06-01"), 
      maxDate = c('2025-08-31'), 
      resolution = "4km"
    )
  )
  
  prism_set_dl_dir(bil_dl)
  expect_equal(
    prism_archive_subset('tmax', 'annual', resolution = '4km'),
    prism_archive_subset('tmax', 'annual', years = 2020:2026, resolution = '4km')
  )
  
  expect_identical(
    prism_archive_subset("tmin", "daily", years = 2020, resolution = "4km"), 
    character(0)
  )
})

test_that("parse_archive_pd parses time-series and normal identifiers", {
  pd <- c(
    "prism_ppt_us_25m_2010",
    "prism_ppt_us_25m_201001",
    "prism_ppt_us_25m_20100115",
    "prism_ppt_us_25m_2020_avg_30y",
    "prism_ppt_us_25m_202001_avg_30y",
    "prism_ppt_us_25m_20200229_avg_30y"
  )
  
  out <- prism:::parse_archive_pd(pd)
  
  expect_identical(
    out$data_class,
    c(
      "time series",
      "time series",
      "time series",
      "normals",
      "normals",
      "normals"
    )
  )
  
  expect_identical(
    out$time_step,
    c(
      "annual",
      "monthly",
      "daily",
      "annual",
      "monthly",
      "daily"
    )
  )
  
  expect_identical(
    out$year,
    c(2010L, 2010L, 2010L, NA_integer_, NA_integer_, NA_integer_)
  )
  
  expect_identical(
    out$month,
    c(NA_integer_, 1L, 1L, NA_integer_, 1L, 2L)
  )
  
  expect_identical(
    out$date_start,
    as.Date(c(
      "2010-01-01",
      "2010-01-01",
      "2010-01-15",
      "2020-01-01",
      "2020-01-01",
      "2020-02-29"
    ))
  )
})

# normalize_archive_temp_period --------------------
#normalize_archive_temp_period <- function(temp_period, data_class)
test_that("normalize_archive_time_step() works", {
  # annual
  expect_identical(
    prism:::normalize_archive_time_step("annual", "normals"),
    list(time_step = "annual", data_class = "normals")
  )
  
  expect_warning(expect_identical(
    prism:::normalize_archive_time_step("annual normals", NULL),
    list(time_step = "annual", data_class = "normals")
  ))
  
  expect_warning(expect_identical(
    prism:::normalize_archive_time_step("annual normals", "normals"),
    list(time_step = "annual", data_class = "normals")
  ))
  
  # monthly
  expect_identical(
    prism:::normalize_archive_time_step("monthly", "normals"),
    list(time_step = "monthly", data_class = "normals")
  )
  
  expect_warning(expect_identical(
    prism:::normalize_archive_time_step("monthly normals", NULL),
    list(time_step = "monthly", data_class = "normals")
  ))
  
  expect_warning(expect_identical(
    prism:::normalize_archive_time_step("monthly normals", "normals"),
    list(time_step = "monthly", data_class = "normals")
  ))
  
  # daily
  expect_identical(
    prism:::normalize_archive_time_step("daily", "normals"),
    list(time_step = "daily", data_class = "normals")
  )
  
  expect_warning(expect_identical(
    prism:::normalize_archive_time_step("daily normals", NULL),
    list(time_step = "daily", data_class = "normals")
  ))
  
  expect_warning(expect_identical(
    prism:::normalize_archive_time_step("daily normals", "normals"),
    list(time_step = "daily", data_class = "normals")
  ))
})
