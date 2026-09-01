# TODO: test tst_files only normals and tst_files no normals

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

exp <- c(
  "Jun 15 1967 - 4km resolution - Precipitation", 
  "Apr  2020 - 4km resolution - Minimum temperature", 
  "Annual 30-year normals - 800m resolution - Minimum temperature", 
  "2019 - 4km resolution - Maximum temperature", 
  "Oct  1967 - 4km resolution - Minimum vapor pressure deficit", 
  "Apr 30-year normals - 4km resolution - Maximum vapor pressure deficit",
  "March 1 30-year normals - 4km resolution - Precipitation",
  "1981 - 800m resolution - Precipitation",
  "Apr  2000 - 800m resolution - Mean temperature",
  "Jun 03 2014 - 800m resolution - Mean temperature",
  "1999 - 4km resolution - Mean temperature",
  "Jan  2010 - 4km resolution - Mean temperature",
  "Jan 13 2013 - 4km resolution - Mean temperature"
)


test_that("pd_get_name() works.", {
  expect_identical(pd_get_name(tst_files), exp)
})

exp_legacy <- c("1967-06-15", "2020-04-01", "", "2019-01-01", "1967-10-01", 
                "", "", "1981-01-01", "2000-04-01", "2014-06-03", "1999-01-01", 
                "2010-01-01", "2013-01-13")

exp <- c("1967-06-15", "2020-04", "1991-2020", "2019", "1967-10", 
         "1991-2020-04", "1991-2020-03-01", "1981", "2000-04", "2014-06-03", 
         "1999", "2010", "2013-01-13")

test_that("pd_get_date() works.", {
  expect_identical(pd_get_date(tst_files), exp)
})

exp <- c('ppt', 'tmin', 'tmean', 'tmax', 'vpdmin', 'vpdmax', 'ppt', 
         'ppt', 'tmean', 'tmean', 'tmean', 'tmean', 'tmean')
test_that("pd_get_type() works.", {
  expect_identical(pd_get_type(tst_files), exp)
})

test_that("pd_to_file() works.", {
  t2 <- c(tst_files[7], 
                 "prism_tdmean_us_25m_200511",
                 "prism_vpdmin_us_25m_202001_avg_30y")
  tmp <- pd_to_file(t2)
  # replace \\ with / if it is there so splitting works
  tmp <- stringr::str_replace_all(tmp, "\\\\", "/")
  tmp <- stringr::str_split(tmp, "/", simplify = TRUE)
  
  expect_identical(tmp[,ncol(tmp) - 1], t2)
  expect_identical(tmp[,ncol(tmp)], paste0(t2, ".bil"))
})

exp <- c("daily", "monthly", "annual normals", "annual", "monthly", 
         "monthly normals", "daily normals", "annual", "monthly", "daily", 
         "annual", "monthly", "daily")

test_that("pd_get_time_step() works.", {
  expect_identical(pd_get_time_step(tst_files), exp)
})
