
# sample folders -----------------
folders <- 
  c(
    "prism_ppt_us_25m_1965",
    "prism_ppt_us_25m_196501",
    "prism_ppt_us_25m_196502",
    "prism_ppt_us_25m_196503",
    "prism_ppt_us_25m_196504",
    "prism_ppt_us_25m_196505",
    "prism_ppt_us_25m_196506",
    "prism_ppt_us_25m_196507",
    "prism_ppt_us_25m_196508",
    "prism_ppt_us_25m_196509",
    "prism_ppt_us_25m_196510",
    "prism_ppt_us_25m_196511",
    "prism_ppt_us_25m_196512",
    
    "prism_ppt_us_25m_1967",
    "prism_ppt_us_25m_196701",
    "prism_ppt_us_25m_196702",
    "prism_ppt_us_25m_196703",
    "prism_ppt_us_25m_196704",
    "prism_ppt_us_25m_196705",
    "prism_ppt_us_25m_196706",
    "prism_ppt_us_25m_196707",
    "prism_ppt_us_25m_196708",
    "prism_ppt_us_25m_196709",
    "prism_ppt_us_25m_196710",
    "prism_ppt_us_25m_196711",
    "prism_ppt_us_25m_196712",
    
    "prism_ppt_us_25m_196901",
    "prism_ppt_us_25m_196902",
    
    "prism_ppt_us_25m_1970",
    "prism_ppt_us_25m_197001",
    "prism_ppt_us_25m_197002",
    "prism_ppt_us_25m_197003",
    "prism_ppt_us_25m_197004",
    "prism_ppt_us_25m_197005",
    "prism_ppt_us_25m_197006",
    "prism_ppt_us_25m_197007",
    "prism_ppt_us_25m_197008",
    "prism_ppt_us_25m_197009",
    "prism_ppt_us_25m_197010",
    "prism_ppt_us_25m_197011",
    "prism_ppt_us_25m_197012",
    
    "prism_tdmean_us_25m_201001",
    "prism_tdmean_us_25m_201002",
    
    "prism_tmean_us_25m_202001_avg_30y",
    "prism_tmean_us_25m_202002_avg_30y",
    "prism_tmean_us_25m_202003_avg_30y",
    "prism_tmean_us_25m_202004_avg_30y",
    "prism_tmean_us_25m_202005_avg_30y",
    "prism_tmean_us_25m_202006_avg_30y",
    "prism_tmean_us_25m_2020_avg_30y",
    
    "prism_tmean_us_25m_20130601",
    "prism_tmean_us_25m_20130602",
    "prism_tmean_us_25m_20130603",
    "prism_tmean_us_25m_20130604",
    "prism_tmean_us_25m_20130605",
    "prism_tmean_us_25m_20130606",
    "prism_tmean_us_25m_20130607",
    "prism_tmean_us_25m_20130608",
    "prism_tmean_us_25m_20130609",
    "prism_tmean_us_25m_20130610",
    "prism_tmean_us_25m_20130611",
    "prism_tmean_us_25m_20130612",
    "prism_tmean_us_25m_20130613",
    "prism_tmean_us_25m_20130614",
    
    "prism_tmean_us_25m_1965",
    "prism_tmean_us_25m_196502",
    "prism_tmean_us_25m_196503",
    "prism_tmean_us_25m_196504",
    "prism_tmean_us_25m_196505",
    "prism_tmean_us_25m_196506",
    "prism_tmean_us_25m_196507",
    "prism_tmean_us_25m_196508",
    "prism_tmean_us_25m_196509",
    "prism_tmean_us_25m_196510",
    "prism_tmean_us_25m_196511",
    "prism_tmean_us_25m_196512",
    
    "prism_tmean_us_25m_198201",
    "prism_tmean_us_25m_198301",
    "prism_tmean_us_25m_198401",
    "prism_tmean_us_25m_198501",
    "prism_tmean_us_25m_198601",
    "prism_tmean_us_25m_198701",
    "prism_tmean_us_25m_198801",
    "prism_tmean_us_25m_198901",
    "prism_tmean_us_25m_199001",
    "prism_tmean_us_25m_199101",
    "prism_tmean_us_25m_199201",
    "prism_tmean_us_25m_199301",
    "prism_tmean_us_25m_199401",
    "prism_tmean_us_25m_199501",
    "prism_tmean_us_25m_199601",
    "prism_tmean_us_25m_199701",
    "prism_tmean_us_25m_199801",
    "prism_tmean_us_25m_199901",
    "prism_tmean_us_25m_200001",
    "prism_tmean_us_25m_200101",
    "prism_tmean_us_25m_200201",
    "prism_tmean_us_25m_200301",
    "prism_tmean_us_25m_200401",
    "prism_tmean_us_25m_200501",
    "prism_tmean_us_25m_200601",
    "prism_tmean_us_25m_200701",
    "prism_tmean_us_25m_200801",
    "prism_tmean_us_25m_200901",
    "prism_tmean_us_25m_201001",
    "prism_tmean_us_25m_201101",
    "prism_tmean_us_25m_201102",
    "prism_tmean_us_25m_201201",
    "prism_tmean_us_25m_201202",
    "prism_tmean_us_25m_201301",
    "prism_tmean_us_25m_201302",
    "prism_tmean_us_25m_201401", 
    
    "prism_tmin_us_25m_202004_avg_30y",
    "prism_vpdmax_us_25m_20100101",
    "prism_vpdmin_us_25m_2010",
    
    "prism_tdmean_us_25m_202001_avg_30y",
    "prism_tdmean_us_25m_202002_avg_30y",
    "prism_tdmean_us_25m_202003_avg_30y",
    "prism_tdmean_us_25m_2020_avg_30y",
    
    "prism_tdmean_us_30s_202009_avg_30y",
    "prism_tdmean_us_30s_202010_avg_30y",
    "prism_tdmean_us_30s_2020_avg_30y",
    
    "prism_ppt_us_25m_20200101_avg_30y",
    "prism_ppt_us_25m_20200301_avg_30y",
    
    "prism_solclear_us_25m_202001_avg_30y",
    "prism_solclear_us_25m_202002_avg_30y",
    
    "prism_ppt_us_25m_1971",
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
  prism_set_dl_dir(tif_dl)
  
  expect_equal(
    prism_archive_subset("ppt", "annual", resolution = "4km"),
    prism_archive_subset("ppt", "annual", resolution = "4km", years = 2023:2025)
  )
  expect_equal(
    prism_archive_subset('ppt', 'annual normals', resolution = '4km'),
    "prism_ppt_us_25m_2020_avg_30y"
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
    c("prism_ppt_us_25m_1965", "prism_ppt_us_25m_1967",
      "prism_ppt_us_25m_1970", "prism_ppt_us_25m_1971",
      "prism_ppt_us_30s_2000", "prism_ppt_us_30s_2015")
  ))
  
  expect_true(all_in(
    filter_folders(folders, "ppt", "annual", years = c(1965, 1970)),
    c("prism_ppt_us_25m_1965", "prism_ppt_us_25m_1970")
  ))
})

# filter_folders monthly ------------------
test_that("prism:::filter_folders monthly", {
  expect_true(all_in(
    filter_folders(folders, "ppt", "monthly"),
    stringr::str_subset(folders, "_ppt") |> 
      stringr::str_subset("_\\d{6}$")
  ))
  
  expect_true(all_in(
    filter_folders(folders, "ppt", "monthly", years = c(1965, 1967), mon = 1:2),
    c("prism_ppt_us_25m_196501", "prism_ppt_us_25m_196502",
      "prism_ppt_us_25m_196701", "prism_ppt_us_25m_196702")
  ))
  
  expect_true(all_in(
    filter_folders(folders, "ppt", "monthly", mon = 1),
    c("prism_ppt_us_25m_196501", "prism_ppt_us_25m_196701",
      "prism_ppt_us_25m_196901", "prism_ppt_us_25m_197001")
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
    c(paste0("prism_tmean_us_25m_", tmp_days),'prism_tmean_us_30s_20130601')
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
      "prism_tdmean_us_25m_2020", prism:::mon_to_string(1:3), "_avg_30y"
    )
  ))
  
  expect_true(all_in(
    filter_folders(folders, "tdmean", "annual normals", resolution = "4km"),
    "prism_tdmean_us_25m_2020_avg_30y"
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
      "prism_tdmean_us_30s_2020", 
      prism:::mon_to_string(9:10), 
      "_avg_30y"
    )
  ))
  
  expect_true(all_in(
    filter_folders(folders, "tdmean", "annual normals", resolution = "800m"),
    "prism_tdmean_us_30s_2020_avg_30y"
  ))
  
  expect_equal(
    filter_folders(folders, "solclear", "monthly normals", resolution = "4km", 
                   mon = 1:2),
    c("prism_solclear_us_25m_202001_avg_30y",
      "prism_solclear_us_25m_202002_avg_30y")
  )
  
  # daily normals
  expect_equal(
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   years = FALSE),
    c("prism_ppt_us_25m_20200101_avg_30y", "prism_ppt_us_25m_20200301_avg_30y")
  )
  expect_equal(
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   years = FALSE),
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   mon = 1:3)
  )
  expect_equal(
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   years = FALSE),
    filter_folders(folders, "ppt", "daily normals", resolution = "4km", 
                   dates = c("0101", "0301"))
  )
  
})

