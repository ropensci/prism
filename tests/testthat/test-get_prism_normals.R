
# Check errors ---------------------------------------
test_that("get_prism_normals() errors correctly", {
  expect_warning(expect_error(
    get_prism_normals("vpdmin", "4km"),
    paste0("`mon` and `day` are `NULL` and `annual` is `FALSE`.\n",
    "Specify either daily and/or monthly and/or annual data to download."),
    fixed = TRUE
  ))
  
  expect_warning(expect_error(get_prism_normals("tmax", "400km", mon = 1)))
  expect_warning(expect_error(get_prism_normals("tmaxtin", "4km", mon = 1)))
  expect_warning(expect_error(
    get_prism_normals("tmin", "4km", mon = 0:3),
    "You must enter a month between 1 and 12"
  ))
  expect_warning(expect_error(
    get_prism_normals("ppt", "800m", mon = 14, annual = TRUE),
    "You must enter a month between 1 and 12"
  ))
  
  expect_warning(expect_error(
    get_prism_normals('ppt')
  ))
  
  expect_warning(expect_error(
    get_prism_normals('solclear', '4km', NULL, FALSE, TRUE, c('0101', '0301'))
  ))
})

# test the helper function --------------------------
test_that('get_prism_normals() helper functions parse things correctly', {
  # days_in_month()
  expect_equal(prism:::days_in_month(1), 31)
  expect_equal(prism:::days_in_month(c(1,2,3)), c(31, 29, 31))
  expect_equal(prism:::days_in_month(c(10, 12, 6)), c(31, 31, 30))
  
  # check_parse_day()
  expect_equal(
    prism:::check_parse_day(as.Date(c('2000-01-31', '2000-02-01'))),
    c('0131', '0201')
  )
  
  # years are ignored
  expect_equal(
    prism:::check_parse_day(as.Date(c('2000-01-31', '2000-02-01'))),
    prism:::check_parse_day(as.Date(c('2019-01-31', '2019-02-01')))
  )
  
  expect_equal(
    prism:::check_parse_day(c('01-31', '02-01')),
    c('0131', '0201')
  )
  
  expect_equal(
    prism:::check_parse_day(c('0131', '0201')),
    c('0131', '0201')
  )
  
  expect_error(prism:::check_parse_day(c('01-31', '02-30')))
  expect_error(prism:::check_parse_day(c('20000101')))
  
  # get_days_from_mon_ann
  expect_equal(
    get_days_from_mon_ann(1, FALSE),
    format(as.Date('2000-01-01')+seq(0, 30), "%m%d")
  )
  # 2024 is a leap year
  expect_equal(
    get_days_from_mon_ann(1:2, FALSE),
    format(as.Date('2024-01-01')+seq(0, 59), "%m%d")
  )
  expect_equal(
    get_days_from_mon_ann(1:2, TRUE),
    format(as.Date('2024-01-01')+seq(0, 365), "%m%d")
  )
})
