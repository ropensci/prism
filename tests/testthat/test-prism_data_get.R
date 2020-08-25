tst_files <- c(
  "PRISM_ppt_stable_4kmM2_19670615_bil", 
  "PRISM_tmin_provisional_4kmM3_202004_bil", 
  "PRISM_tmean_30yr_normal_800mM2_annual_bil", 
  "PRISM_tmax_provisional_4kmM3_2019_bil", 
  "PRISM_vpdmin_stable_4kmM2_196710_bil", 
  "PRISM_vpdmax_30yr_normal_4kmM2_04_bil"
)

exp <- c(
  "Jun 15 1967 - 4km resolution - Precipitation", 
  "Apr  2020 - 4km resolution - Minimum temperature", 
  "Annual 30-year normals - 800m resolution - Mean temperature", 
  "2019 - 4km resolution - Maximum temperature", 
  "Oct  1967 - 4km resolution - Minimum vapor pressure deficit", 
  "Apr 30-year normals - 4km resolution - Maximum vapor pressure deficit"
)

test_that("pd_get_name() works.", {
  expect_identical(pd_get_name(tst_files), exp)
  expect_identical(expect_warning(prism_md(tst_files)), exp)
})

exp <- c("1967-06-15", "2020-04-01", "", "2019-01-01", "1967-10-01", "")

test_that("pd_get_date() works.", {
  expect_identical(pd_get_date(tst_files), exp)
  expect_identical(expect_warning(prism_md(tst_files, TRUE)), exp)
})
