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

test_that("parse_archive_pd extracts V2 archive metadata", {
  out <- prism:::parse_archive_pd(test_archive_pd)
  
  expect_identical(out$pd, test_archive_pd)
  
  expect_identical(
    out$resolution,
    c(
      "4km", "800m",
      "4km", "4km", "800m", "800m",
      "4km", "4km", "4km", "800m",
      "4km", "800m",
      "4km", "4km", "800m", "800m",
      "4km", "4km", "800m"
    )
  )
  
  expect_identical(
    out$year,
    c(
      2010L, 2010L,
      2010L, 2010L, 2010L, 2010L,
      2010L, 2010L, 2010L, 2010L,
      rep(NA, 9)
    )
  )
  
  expect_identical(
    out$month,
    c(
      NA, NA,
      1L, 2L, 1L, 7L,
      1L, 1L, 2L, 7L,
      NA, NA,
      1L, 2L, 1L, 7L,
      1L, 2L, 7L
    )
  )
  
  expect_true(all(
    out$data_class %in% c("time series", "normals")
  ))
  
  expect_true(all(
    out$time_step %in% c("annual", "monthly", "daily")
  ))
})

test_that("parse_archive_pd parses a monthly time-series month", {
  pd <- "prism_tmean_us_25m_202507"
  
  out <- parse_archive_pd(pd)
  
  expect_identical(out$type, "tmean")
  expect_identical(out$resolution, "4km")
  expect_identical(out$data_class, "time series")
  expect_identical(out$time_step, "monthly")
  expect_identical(out$year, 2025L)
  expect_identical(out$month, 7L)
  expect_identical(out$date_start, as.Date("2025-07-01"))
})
