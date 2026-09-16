
test_archive_pd <- c(
  # Annual time series
  "prism_ppt_us_25m_2010",
  "prism_tmax_us_30s_2010",
  
  # Monthly time series
  "prism_ppt_us_25m_201001",
  "prism_ppt_us_25m_201002",
  "prism_ppt_us_30s_201001",
  "prism_tmax_us_30s_201007",
  
  # Daily time series
  "prism_ppt_us_25m_20100101",
  "prism_ppt_us_25m_20100102",
  "prism_ppt_us_25m_20100201",
  "prism_tmax_us_30s_20100715",
  
  # Annual normals
  "prism_ppt_us_25m_2020_avg_30y",
  "prism_tmax_us_30s_2020_avg_30y",
  
  # Monthly normals
  "prism_ppt_us_25m_202001_avg_30y",
  "prism_ppt_us_25m_202002_avg_30y",
  "prism_ppt_us_30s_202001_avg_30y",
  "prism_tmax_us_30s_202007_avg_30y",
  
  # Daily normals
  "prism_ppt_us_25m_20200101_avg_30y",
  "prism_ppt_us_25m_20200229_avg_30y",
  "prism_tmax_us_30s_20200715_avg_30y"
)

test_archive_pd_years <- c(
  "prism_ppt_us_25m_1965",
  "prism_ppt_us_25m_1967",
  "prism_ppt_us_25m_1970",
  "prism_ppt_us_25m_196501",
  "prism_ppt_us_25m_196502",
  "prism_ppt_us_25m_196701",
  "prism_ppt_us_25m_196702",
  "prism_ppt_us_25m_197001",
  "prism_ppt_us_25m_197002"
)

test_archive_pd_months <- c(
  "prism_tmean_us_25m_198201",
  "prism_tmean_us_25m_198202",
  "prism_tmean_us_25m_199601",
  "prism_tmean_us_25m_200001",
  "prism_tmean_us_25m_201001",
  "prism_tmean_us_25m_201102",
  "prism_tmean_us_25m_201201",
  "prism_tmean_us_25m_201202",
  "prism_tmean_us_25m_201301"
)

test_archive_pd_daily_months <- c(
  "prism_tmean_us_25m_20130601",
  "prism_tmean_us_25m_20130602",
  "prism_tmean_us_25m_20140601",
  "prism_tmean_us_25m_20140701",
  "prism_tmean_us_30s_20130601"
)

test_that("filter_archive_pd returns all supplied identifiers by default", {
  expect_identical(
    filter_archive_pd(test_archive_pd),
    test_archive_pd
  )
})

test_that("filter_archive_pd filters type, period, resolution, and data class", {
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      resolution = "4km",
      data_class = "time series"
    ),
    c(
      "prism_ppt_us_25m_201001",
      "prism_ppt_us_25m_201002"
    )
  )
  
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      resolution = "800m",
      data_class = "normals"
    ),
    "prism_ppt_us_30s_202001_avg_30y"
  )
})

test_that("filter_archive_pd filters time-series years and months", {
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      years = 2010L,
      mon = 1L,
      data_class = "time series"
    ),
    c(
      "prism_ppt_us_25m_201001",
      "prism_ppt_us_30s_201001"
    )
  )
  
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "daily",
      years = 2010L,
      mon = 2L,
      data_class = "time series"
    ),
    "prism_ppt_us_25m_20100201"
  )
})

test_that("filter_archive_pd filters normal products by month", {
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      mon = 1L,
      data_class = "normals"
    ),
    c(
      "prism_ppt_us_25m_202001_avg_30y",
      "prism_ppt_us_30s_202001_avg_30y"
    )
  )
  
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "daily",
      mon = 2L,
      data_class = "normals"
    ),
    "prism_ppt_us_25m_20200229_avg_30y"
  )
})

test_that("filter_archive_pd filters exact time-series dates", {
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      data_class = "time series",
      dates = as.Date(c("2010-01-01", "2010-02-01"))
    ),
    c(
      "prism_ppt_us_25m_20100101",
      "prism_ppt_us_25m_20100201"
    )
  )
})

test_that("filter_archive_pd filters inclusive daily date ranges", {
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "daily",
      data_class = "time series",
      minDate = as.Date("2010-01-02"),
      maxDate = as.Date("2010-02-01")
    ),
    c(
      "prism_ppt_us_25m_20100102",
      "prism_ppt_us_25m_20100201"
    )
  )
})

test_that("filter_archive_pd filters daily normals with a 2020 reference date", {
  expect_identical(
    filter_archive_pd(
      test_archive_pd,
      type = "ppt",
      time_step = "daily",
      data_class = "normals",
      dates = as.Date("2020-02-29")
    ),
    "prism_ppt_us_25m_20200229_avg_30y"
  )
})

test_that("filter_archive_pd filters a monthly time-series folder by month", {
  pd <- "prism_tmean_us_25m_202507"
  
  expect_identical(
    filter_archive_pd(
      pd = pd,
      type = "tmean",
      time_step = "monthly",
      resolution = "4km"
    ),
    pd
  )
  
  expect_identical(
    filter_archive_pd(
      pd = pd,
      type = "tmean",
      time_step = "monthly",
      resolution = "4km",
      mon = 7L
    ),
    pd
  )
  
  expect_identical(
    filter_archive_pd(
      pd = pd,
      type = "tmean",
      time_step = "monthly",
      resolution = "4km",
      mon = 6L
    ),
    character()
  )
})

test_that("filter_archive_pd filters annual time series by multiple years", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd_years,
      type = "ppt",
      time_step = "annual",
      data_class = "time series",
      years = c(1965L, 1970L)
    ),
    c(
      "prism_ppt_us_25m_1965",
      "prism_ppt_us_25m_1970"
    )
  )
})

test_that("filter_archive_pd filters monthly time series by years and months", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd_years,
      type = "ppt",
      time_step = "monthly",
      data_class = "time series",
      years = c(1965L, 1970L),
      mon = 2L
    ),
    c(
      "prism_ppt_us_25m_196502",
      "prism_ppt_us_25m_197002"
    )
  )
})

test_that("filter_archive_pd filters a month across all available years", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd_months,
      type = "tmean",
      time_step = "monthly",
      data_class = "time series",
      mon = 1L
    ),
    c(
      "prism_tmean_us_25m_198201",
      "prism_tmean_us_25m_199601",
      "prism_tmean_us_25m_200001",
      "prism_tmean_us_25m_201001",
      "prism_tmean_us_25m_201201",
      "prism_tmean_us_25m_201301"
    )
  )
})

test_that("filter_archive_pd returns all available monthly values for a year", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      data_class = "time series",
      years = 2010L
    ),
    c(
      "prism_ppt_us_25m_201001",
      "prism_ppt_us_25m_201002",
      "prism_ppt_us_30s_201001"
    )
  )
})

test_that("filter_archive_pd filters daily time series by month across years", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd_daily_months,
      type = "tmean",
      time_step = "daily",
      data_class = "time series",
      mon = 6L
    ),
    c(
      "prism_tmean_us_25m_20130601",
      "prism_tmean_us_25m_20130602",
      "prism_tmean_us_25m_20140601",
      "prism_tmean_us_30s_20130601"
    )
  )
})

test_that("filter_archive_pd supports vector-valued filters", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd,
      type = c("ppt", "tmax"),
      time_step = "annual",
      resolution = c("4km", "800m"),
      data_class = "time series"
    ),
    c(
      "prism_ppt_us_25m_2010",
      "prism_tmax_us_30s_2010"
    )
  )
})

test_that("filter_archive_pd supports multiple requested months", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      data_class = "time series",
      mon = c(1L, 2L)
    ),
    c(
      "prism_ppt_us_25m_201001",
      "prism_ppt_us_25m_201002",
      "prism_ppt_us_30s_201001"
    )
  )
})

test_that("filter_archive_pd returns character(0) when nothing matches", {
  expect_identical(
    filter_archive_pd(
      pd = test_archive_pd,
      type = "ppt",
      time_step = "monthly",
      data_class = "time series",
      years = 1999L
    ),
    character()
  )
})

test_that("filter_archive_pd returns character(0) for empty input", {
  expect_identical(
    filter_archive_pd(character()),
    character()
  )
})
