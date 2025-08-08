
# sample folders -----------------
folders <- 
  c("PRISM_ppt_stable_4kmM2_1965_bil", "PRISM_ppt_stable_4kmM2_196501_bil", 
  "PRISM_ppt_stable_4kmM2_196502_bil", "PRISM_ppt_stable_4kmM2_196503_bil", 
  "PRISM_ppt_stable_4kmM2_196504_bil", "PRISM_ppt_stable_4kmM2_196505_bil", 
  "PRISM_ppt_stable_4kmM2_196506_bil", "PRISM_ppt_stable_4kmM2_196507_bil", 
  "PRISM_ppt_stable_4kmM2_196508_bil", "PRISM_ppt_stable_4kmM2_196509_bil", 
  "PRISM_ppt_stable_4kmM2_196510_bil", "PRISM_ppt_stable_4kmM2_196511_bil", 
  "PRISM_ppt_stable_4kmM2_196512_bil", "PRISM_ppt_stable_4kmM2_1967_bil", 
  "PRISM_ppt_stable_4kmM2_196701_bil", "PRISM_ppt_stable_4kmM2_196702_bil", 
  "PRISM_ppt_stable_4kmM2_196703_bil", "PRISM_ppt_stable_4kmM2_196704_bil", 
  "PRISM_ppt_stable_4kmM2_196705_bil", "PRISM_ppt_stable_4kmM2_196706_bil", 
  "PRISM_ppt_stable_4kmM2_196707_bil", "PRISM_ppt_stable_4kmM2_196708_bil", 
  "PRISM_ppt_stable_4kmM2_196709_bil", "PRISM_ppt_stable_4kmM2_196710_bil", 
  "PRISM_ppt_stable_4kmM2_196711_bil", "PRISM_ppt_stable_4kmM2_196712_bil", 
  "PRISM_ppt_stable_4kmM2_196901_bil", 
  "PRISM_ppt_stable_4kmM2_196902_bil", "PRISM_ppt_stable_4kmM2_1970_bil", 
  "PRISM_ppt_stable_4kmM2_197001_bil", "PRISM_ppt_stable_4kmM2_197002_bil", 
  "PRISM_ppt_stable_4kmM2_197003_bil", "PRISM_ppt_stable_4kmM2_197004_bil", 
  "PRISM_ppt_stable_4kmM2_197005_bil", "PRISM_ppt_stable_4kmM2_197006_bil", 
  "PRISM_ppt_stable_4kmM2_197007_bil", "PRISM_ppt_stable_4kmM2_197008_bil", 
  "PRISM_ppt_stable_4kmM2_197009_bil", "PRISM_ppt_stable_4kmM2_197010_bil", 
  "PRISM_ppt_stable_4kmM2_197011_bil", "PRISM_ppt_stable_4kmM2_197012_bil", 
  "PRISM_ppt_stable_4kmM2_1971_bil", "PRISM_tdmean_stable_4kmM3_201001_bil", 
  "PRISM_tdmean_stable_4kmM3_201002_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_01_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_02_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_03_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_04_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_05_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_06_bil", 
  "PRISM_tmean_30yr_normal_4kmM2_annual_bil", 
  "PRISM_tmean_stable_4kmD2_20130601_bil", 
  "PRISM_tmean_stable_4kmD2_20130602_bil", 
  "PRISM_tmean_stable_4kmD2_20130603_bil", 
  "PRISM_tmean_stable_4kmD2_20130604_bil", 
  "PRISM_tmean_stable_4kmD2_20130605_bil", 
  "PRISM_tmean_stable_4kmD2_20130606_bil", 
  "PRISM_tmean_stable_4kmD2_20130607_bil", 
  "PRISM_tmean_stable_4kmD2_20130608_bil", 
  "PRISM_tmean_stable_4kmD2_20130609_bil", 
  "PRISM_tmean_stable_4kmD2_20130610_bil", 
  "PRISM_tmean_stable_4kmD2_20130611_bil", 
  "PRISM_tmean_stable_4kmD2_20130612_bil", 
  "PRISM_tmean_stable_4kmD2_20130613_bil", 
  "PRISM_tmean_stable_4kmD2_20130614_bil", 
  "PRISM_tmean_stable_4kmM3_1965_bil", 
  "PRISM_tmean_stable_4kmM3_196502_bil", 
  "PRISM_tmean_stable_4kmM3_196503_bil", "PRISM_tmean_stable_4kmM3_196504_bil", 
  "PRISM_tmean_stable_4kmM3_196505_bil", "PRISM_tmean_stable_4kmM3_196506_bil", 
  "PRISM_tmean_stable_4kmM3_196507_bil", "PRISM_tmean_stable_4kmM3_196508_bil", 
  "PRISM_tmean_stable_4kmM3_196509_bil", "PRISM_tmean_stable_4kmM3_196510_bil", 
  "PRISM_tmean_stable_4kmM3_196511_bil", "PRISM_tmean_stable_4kmM3_196512_bil", 
  "PRISM_tmean_stable_4kmM3_198201_bil", "PRISM_tmean_stable_4kmM3_198301_bil", 
  "PRISM_tmean_stable_4kmM3_198401_bil", "PRISM_tmean_stable_4kmM3_198501_bil", 
  "PRISM_tmean_stable_4kmM3_198601_bil", "PRISM_tmean_stable_4kmM3_198701_bil", 
  "PRISM_tmean_stable_4kmM3_198801_bil", "PRISM_tmean_stable_4kmM3_198901_bil", 
  "PRISM_tmean_stable_4kmM3_199001_bil", "PRISM_tmean_stable_4kmM3_199101_bil", 
  "PRISM_tmean_stable_4kmM3_199201_bil", "PRISM_tmean_stable_4kmM3_199301_bil", 
  "PRISM_tmean_stable_4kmM3_199401_bil", "PRISM_tmean_stable_4kmM3_199501_bil", 
  "PRISM_tmean_stable_4kmM3_199601_bil", "PRISM_tmean_stable_4kmM3_199701_bil", 
  "PRISM_tmean_stable_4kmM3_199801_bil", "PRISM_tmean_stable_4kmM3_199901_bil", 
  "PRISM_tmean_stable_4kmM3_200001_bil", "PRISM_tmean_stable_4kmM3_200101_bil", 
  "PRISM_tmean_stable_4kmM3_200201_bil", "PRISM_tmean_stable_4kmM3_200301_bil", 
  "PRISM_tmean_stable_4kmM3_200401_bil", "PRISM_tmean_stable_4kmM3_200501_bil", 
  "PRISM_tmean_stable_4kmM3_200601_bil", "PRISM_tmean_stable_4kmM3_200701_bil", 
  "PRISM_tmean_stable_4kmM3_200801_bil", "PRISM_tmean_stable_4kmM3_200901_bil", 
  "PRISM_tmean_stable_4kmM3_201001_bil", "PRISM_tmean_stable_4kmM3_201101_bil", 
  "PRISM_tmean_stable_4kmM3_201102_bil", "PRISM_tmean_stable_4kmM3_201201_bil", 
  "PRISM_tmean_stable_4kmM3_201202_bil", "PRISM_tmean_stable_4kmM3_201301_bil", 
  "PRISM_tmean_stable_4kmM3_201302_bil", "PRISM_tmean_stable_4kmM3_201401_bil", 
  "PRISM_tmin_30yr_normal_4kmM2_04_bil", 
  "PRISM_vpdmax_stable_4kmD2_20100101_bil", 
  "PRISM_vpdmin_stable_4kmM3_2010_bil", "PRISM_tdmean_30yr_normal_4kmM2_01_bil",
  "PRISM_tdmean_30yr_normal_4kmM2_02_bil", 
  "PRISM_tdmean_30yr_normal_4kmM2_03_bil",
  "PRISM_tdmean_30yr_normal_4kmM2_annual_bil",
  "PRISM_tdmean_30yr_normal_800mM2_09_bil", 
  "PRISM_tdmean_30yr_normal_800mM2_10_bil",
  "PRISM_tdmean_30yr_normal_800mM2_annual_bil",
  "PRISM_ppt_30yr_normal_4kmD1_0101_bil", 
  "PRISM_ppt_30yr_normal_4kmD1_0301_bil", 
  "PRISM_solclear_30yr_normal_4kmM3_01_bil",
  "PRISM_solclear_30yr_normal_4kmM3_02_bil",
  # Add webservice v2 files
  "prism_ppt_us_30s_19810101",
  "prism_ppt_us_30s_2000", 
  "prism_ppt_us_30s_20110101",
  "prism_ppt_us_30s_2015",
  "prism_tmean_us_25m_199601",
  "prism_tmean_us_25m_201001", 
  "prism_tmean_us_25m_201301",
  "prism_tmean_us_30s_198201",
  "prism_tmax_us_30s_2000",
  "prism_tmean_us_30s_20130601",
  "prism_tmean_us_30s_20130602",
  "prism_tmean_us_30s_201401",
  "prism_tmax_us_30s_2015"
  )

# all_in helper ----------------
all_in <- function(x, y) {
  all(x %in% y) & all(y %in% x)
}

# prism_archive_subset() errors ------------------
test_that("prism_archive_subset() errors correctly", {
  # missing resolution (now required for all files in webservice v2 migration)
  expect_error(
    prism_archive_subset("tmean", "daily", mon = 6), 
    "`resolution` must be specified for all temporal periods"
  )
  expect_error(
    prism_archive_subset("tmean", "annual", years = 2013), 
    "`resolution` must be specified for all temporal periods"
  )
  
  # unsupported resolution
  expect_error(
    prism_archive_subset("tmean", "daily", resolution = '1m', minDate = "2013-06-07", maxDate = "2013-06-10"), 
    "'arg' should be one of.*4km.*800m"
  )
  expect_error(
    prism_archive_subset("ppt", "daily", resolution = '400m', mon = 1, years = 1981:2011), 
    "'arg' should be one of.*4km.*800m"
  )
  
  # unsupported variables
  expect_error(
    prism_archive_subset("tmaxx", "annual", resolution = '800m'), 
    "'arg' should be one of"
  )
  expect_error(
    prism_archive_subset("vpdmiin", "annual", resolution = '800m'), 
    "'arg' should be one of"
  )
  
  # unsupported temp_period
  expect_error(
    prism_archive_subset("tmean", "ann", resolution = '800m'), 
    "'arg' should be one of"
  )
  expect_error(
    prism_archive_subset("tmean", "annual_normals", resolution = '800m'), 
    "'arg' should be one of"
  )
  # annual - unnecessary specifications
  expect_error(
    prism_archive_subset("tmean", "annual", mon = 1, resolution = '800m'),
    "No need to specify `mon` for 'annual' `temp_period`"
  )
  expect_error(
    prism_archive_subset("tmean", "annual", dates = "2018-01-01", resolution = '800m'),
    "`minDate`, `maxDate`, and/or `dates` should only be specified when `temp_period` is 'daily'"
  )
  expect_error(
    prism_archive_subset(
      "tmean", "annual", minDate = "2018-01-01", maxDate = "2018-01-05", resolution = '800m'
    ),
    "`minDate`, `maxDate`, and/or `dates` should only be specified when `temp_period` is 'daily'"
  )

  
  # monthly - unnecessary specifications
  expect_error(
    prism_archive_subset("tmean", "monthly", dates = "2018-01-01", resolution = '800m'),
    "`minDate`, `maxDate`, and/or `dates` should only be specified when `temp_period` is 'daily'"
  )
  expect_error(
    prism_archive_subset(
      "tmean", "monthly", minDate = "2018-01-01", maxDate = "2018-01-05", resolution = '800m'
    ),
    "`minDate`, `maxDate`, and/or `dates` should only be specified when `temp_period` is 'daily'"
  )
  expect_no_error(
    prism_archive_subset("tmean", "monthly", resolution = "800m"),
    ## Now all subset require resolution; this now expects to work
  )
  
  # normals - unecessary/incomplete specifications
  expect_error(
    prism_archive_subset("tmean", "annual normals"),
    "`resolution` must be specified for all temporal periods"
  )
  expect_error(
    prism_archive_subset("tmean", "monthly normals"),
    "`resolution` must be specified for all temporal periods"
  )
  expect_error(
    prism_archive_subset("tmean", "annual normals", resolution = "4pm"),
    "'arg' should be one of.*4km.*800m"
  )
  expect_error(
    prism_archive_subset("tmean", "monthly normals", resolution = "800mm"),
    "'arg' should be one of.*4km.*800m"
  )
  expect_error(
    prism_archive_subset(
      "tmean", "annual normals", resolution = "4km", years = 2015
    ),
    "No need to specify `years` or `mon` when subsetting 'annual normals'"
  )
  expect_error(
    prism_archive_subset(
      "tmean", "annual normals", resolution = "800m", mon = 1:12
    ),
    "No need to specify `years` or `mon` when subsetting 'annual normals'"
  )
  expect_error(
    prism_archive_subset(
      "tmean", "monthly normals", resolution = "4km", years = 2015
    ),
    "No need to specify `years` for 'monthly normals'"
  )
  
  expect_error(
    prism_archive_subset('solclear', "daily normals", resolution = '4km', 
                         mon = 1:2)
  )
  
  # daily unnecessary specifications
  expect_no_error(
    prism_archive_subset("ppt", "daily", resolution = "800m"),
    ## Webservice v2 all subset require resolution; this now expects to work
  )
  expect_error(
    prism_archive_subset("tmin", "daily", years = 1999, dates = "1999-01-01", resolution = "800m"),
    "Only specify `years`/`mon` or `minDate`/`maxDate`/`dates`"
  )
  expect_error(
    prism_archive_subset("tmin", "daily", mon = 3, minDate = "1999-01-01", resolution = "800m"),
    "Only specify `years`/`mon` or `minDate`/`maxDate`/`dates`"
  )
  
  expect_error(
    prism_archive_subset("tmin", "daily normals", mon = 3, 
                         minDate = "1999-01-01", resolution = '4km'),
    "Only specify `years`/`mon` or `minDate`/`maxDate`/`dates`"
  )
})

# prism_archive_subset() with test folders -------------
test_that("prism_archive_subset() works", {
  expect_equal(
    prism_archive_subset("ppt", "daily", resolution = "4km"),
    prism_archive_subset("ppt", "daily", resolution = "4km", years = c(1981, 1991, 2011, 2012))
  )
  expect_equal(
    prism_archive_subset("ppt", "daily", resolution = "4km"),
    prism_archive_subset("ppt", "daily", mon = 1, resolution = "4km")
  )
  expect_equal(
    prism_archive_subset("tmin", "daily", resolution = "4km"),
    prism_archive_subset("tmin", "daily", mon = c(1,6), resolution = "4km")
  )
  expect_equal(
    prism_archive_subset("tmin", "daily", resolution = "4km"),
    prism_archive_subset("tmin", "daily", years = c(1981, 2011), resolution = "4km")
  )
  expect_equal(
    prism_archive_subset("tmin", "daily", resolution = "4km"),
    prism_archive_subset("tmin", "daily", years = 1981:2011, resolution = "4km")
  )
  expect_true(all_in(
    prism_archive_subset("tmin", "daily", resolution = "4km"),
    c("PRISM_tmin_stable_4kmD2_19810101_bil", 
      "PRISM_tmin_stable_4kmD2_20110615_bil")
  ))
  
  expect_identical(
    prism_archive_subset("tmin", "daily", years = 2020, resolution = "4km"), 
    character(0)
  )
})

# filter_folders annual -----------------
#filter_folders(folders, type, temp_period, years, mon, dates, resolution)

test_that("prism:::filter_folders annual", {
  expect_equal(
    filter_folders(folders, "vpdmin", "annual"),
    filter_folders(folders, "vpdmin", "annual", 2010) 
  )
  expect_equal(
    filter_folders(folders, "tmean", "annual"),
    filter_folders(folders, "tmean", "annual", 1965) 
  )
  expect_true(all_in(
    filter_folders(folders, "ppt", "annual"),
    c("PRISM_ppt_stable_4kmM2_1965_bil", "PRISM_ppt_stable_4kmM2_1967_bil",
      "PRISM_ppt_stable_4kmM2_1970_bil", "PRISM_ppt_stable_4kmM2_1971_bil",
      "prism_ppt_us_30s_2000", "prism_ppt_us_30s_2015")
  ))
  
  expect_true(all_in(
    filter_folders(folders, "ppt", "annual", years = c(1965, 1970)),
    c("PRISM_ppt_stable_4kmM2_1965_bil", "PRISM_ppt_stable_4kmM2_1970_bil")
  ))
})

# filter_folders monthly ------------------
test_that("prism:::filter_folders monthly", {
  expect_true(all_in(
    filter_folders(folders, "ppt", "monthly"),
    stringr::str_subset(folders, "_ppt") %>% 
      stringr::str_subset("_\\d{6}_bil")
  ))
  
  expect_true(all_in(
    filter_folders(folders, "ppt", "monthly", years = c(1965, 1967), mon = 1:2),
    c("PRISM_ppt_stable_4kmM2_196501_bil", "PRISM_ppt_stable_4kmM2_196502_bil",
      "PRISM_ppt_stable_4kmM2_196701_bil", "PRISM_ppt_stable_4kmM2_196702_bil")
  ))
  
  expect_true(all_in(
    filter_folders(folders, "ppt", "monthly", mon = 1),
    c("PRISM_ppt_stable_4kmM2_196501_bil", "PRISM_ppt_stable_4kmM2_196701_bil",
      "PRISM_ppt_stable_4kmM2_196901_bil", "PRISM_ppt_stable_4kmM2_197001_bil")
  ))
  
  expect_length(filter_folders(folders, "ppt", "monthly", years = 1965), 12)
  expect_length(
    filter_folders(folders, "ppt", "monthly", years = 1965:1967), 
    24
  )
})

# filter_folders daily ------------------
tmp_days <- c("20130601", "20130605", "20130609", "20130614")
test_that("prism:::filter_folders annual", {
  expect_equal(
    filter_folders(folders, "vpdmax", "daily"),
    filter_folders(folders, "vpdmax", "daily", dates = "20100101") 
  )
  expect_equal(
    filter_folders(folders, "vpdmax", "daily"),
    filter_folders(folders, "vpdmax", "daily", years = 2010) 
  )
  expect_equal(
    filter_folders(folders, "vpdmax", "daily"),
    filter_folders(folders, "vpdmax", "daily", mon = 1) 
  )
  
  expect_equal(
    filter_folders(folders, "tmean", "daily"),
    filter_folders(folders, "tmean", "daily", years = 2013)
  )
  
  expect_equal(
    filter_folders(folders, "tmean", "daily"),
    filter_folders(folders, "tmean", "daily", mon = 6)
  )
  
  expect_equal(
    filter_folders(folders, "tmean", "daily"),
    filter_folders(folders, "tmean", "daily", years = 2013, mon = 6)
  )
  
  expect_true(all_in(
    filter_folders(folders, "tmean", "daily", dates = tmp_days),
    c(paste0("PRISM_tmean_stable_4kmD2_", tmp_days, "_bil"),'prism_tmean_us_30s_20130601')
  ))
})

# filter_folders normals ------------------
# TODO: check using both resolutions
test_that("prism:::filter_folders normals", {
  # 4km --------------
  expect_equal(
    filter_folders(folders, "tdmean", "monthly normals", resolution = "4km"),
    filter_folders(
      folders, 
      "tdmean", 
      "monthly normals", 
      mon = 1:3, 
      resolution = "4km"
    )
  )
  
  expect_true(all_in(
    filter_folders(folders, "tdmean", "monthly normals", resolution = "4km"),
    paste0(
      "PRISM_tdmean_30yr_normal_4kmM2_", prism:::mon_to_string(1:3), "_bil"
    )
  ))
  
  expect_true(all_in(
    filter_folders(folders, "tdmean", "annual normals", resolution = "4km"),
    "PRISM_tdmean_30yr_normal_4kmM2_annual_bil"
  ))
  
  # 800m --------------
  
  expect_equal(
    filter_folders(folders, "tdmean", "monthly normals", resolution = "800m"),
    filter_folders(
      folders, 
      "tdmean", 
      "monthly normals", 
      mon = 9:10, 
      resolution = "800m"
    )
  )
  
  expect_true(all_in(
    filter_folders(folders, "tdmean", "monthly normals", resolution = "800m"),
    paste0(
      "PRISM_tdmean_30yr_normal_800mM2_", 
      prism:::mon_to_string(9:10), 
      "_bil"
    )
  ))
  
  expect_true(all_in(
    filter_folders(folders, "tdmean", "annual normals", resolution = "800m"),
    "PRISM_tdmean_30yr_normal_800mM2_annual_bil"
  ))
  
  expect_equal(
    filter_folders(folders, "solclear", "monthly normals", resolution = "4km", 
                   mon = 1:2),
    c("PRISM_solclear_30yr_normal_4kmM3_01_bil",
      "PRISM_solclear_30yr_normal_4kmM3_02_bil")
  )
  
  # daily normals
  expect_equal(
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   years = TRUE),
    c("PRISM_ppt_30yr_normal_4kmD1_0101_bil", 
      "PRISM_ppt_30yr_normal_4kmD1_0301_bil")
  )
  expect_equal(
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   years = TRUE),
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   mon = 1:3)
  )
  expect_equal(
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   years = TRUE),
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   dates = c("0101", "0301"))
  )
  
})

