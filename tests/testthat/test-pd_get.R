tst_files <- c(
  "PRISM_ppt_stable_4kmM2_19670615_bil", 
  "PRISM_tmin_provisional_4kmM3_202004_bil", 
  "PRISM_tmean_30yr_normal_800mM2_annual_bil", 
  "PRISM_tmax_provisional_4kmM3_2019_bil", 
  "PRISM_vpdmin_stable_4kmM2_196710_bil", 
  "PRISM_vpdmax_30yr_normal_4kmM2_04_bil",
  "PRISM_ppt_30yr_normal_4kmD1_0301_bil",
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
  "Annual 30-year normals - 800m resolution - Mean temperature", 
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
  expect_identical(expect_warning(prism_md(tst_files)), exp)
})

exp <- c("1967-06-15", "2020-04-01", "", "2019-01-01", "1967-10-01", "", "", 
         "1981-01-01", "2000-04-01", "2014-06-03", "1999-01-01", "2010-01-01", "2013-01-13")

test_that("pd_get_date() works.", {
  expect_identical(pd_get_date(tst_files), exp)
  expect_identical(expect_warning(prism_md(tst_files, TRUE)), exp)
})

exp <- c('ppt', 'tmin', 'tmean', 'tmax', 'vpdmin', 'vpdmax', 'ppt', 
         'ppt', 'tmean', 'tmean', 'tmean', 'tmean', 'tmean')
test_that("pd_get_type() works.", {
  expect_identical(pd_get_type(tst_files), exp)
})

test_that("pd_to_file() works.", {
  t2 <- c(tst_files[7], 
                 "PRISM_tdmean_stable_4kmM3_200511_bil",
                 "PRISM_vpdmin_30yr_normal_4kmM4_annual_bil")
  tmp <- pd_to_file(t2)
  # replace \\ with / if it is there so splitting works
  tmp <- stringr::str_replace_all(tmp, "\\\\", "/")
  tmp <- stringr::str_split(tmp, "/", simplify = TRUE)
  
  expect_identical(tmp[,ncol(tmp) - 1], t2)
  expect_identical(tmp[,ncol(tmp)], paste0(t2, ".bil"))
})
