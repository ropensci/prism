
dl_folder <- file.path(tempdir(), "prism")
cur_path <- getOption("prism.path")
setup({prism_set_dl_dir(dl_folder)})
teardown({prism_set_dl_dir(cur_path)})


cat("\n\n***************************************")
cat("\nmake sure you run this 2x or less in any given day!!!!\n")
cat("****************************************\n")

#teardown(unlink(dl_folder, recursive = TRUE))

# skip flags -----------------
skip_normals <- TRUE
skip_annual <- TRUE
skip_monthly <- TRUE
skip_daily <- TRUE
skip_daily_3 <- TRUE
skip_daily_prov <- TRUE

# Normals ---------------
test_that("normals download", {
  skip_on_cran()
  skip_if(skip_normals)
  
  get_prism_normals("tmean", resolution = "4km", annual = TRUE)
  get_prism_normals("tmax", resolution = "4km", mon = 1)
  get_prism_normals("tmin", resolution = "4km", mon = 2)
  get_prism_normals("tdmean", resolution = "4km", mon = 6)
  get_prism_normals("vpdmin", resolution = "4km", mon = 12)
  get_prism_normals("vpdmax", resolution = "4km", mon = 9)
  get_prism_normals("ppt", resolution = "800m", mon = 11)
  get_prism_normals('solclear', '4km', mon = 1)
  get_prism_normals('solslope', '4km', annual = TRUE)
  get_prism_normals('soltotal', '800m', annual = TRUE)
  get_prism_normals('soltrans', '800m', mon = 3:4)
  get_prism_normals('ppt', '4km', NULL, FALSE, TRUE, c('0101', '0301'))
  get_prism_normals('ppt', '4km', 2, FALSE, TRUE, TRUE)
  get_prism_normals('tmean', '800m', NULL, FALSE, TRUE, as.Date('2000-07-04'))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmean_30yr_normal_4kmM5_annual_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_30yr_normal_4kmM5_annual_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmax_30yr_normal_4kmM5_01_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmax_30yr_normal_4kmM5_01_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmin_30yr_normal_4kmM5_02_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmin_30yr_normal_4kmM5_02_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tdmean_30yr_normal_4kmM5_06_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tdmean_30yr_normal_4kmM5_06_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmin_30yr_normal_4kmM5_12_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmin_30yr_normal_4kmM5_12_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmax_30yr_normal_4kmM5_09_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmax_30yr_normal_4kmM5_09_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_ppt_30yr_normal_800mM4_11_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_ppt_30yr_normal_800mM4_11_bil")
  ))
  
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_solclear_30yr_normal_4kmM3_01_bil")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_solslope_30yr_normal_4kmM3_annual_bil")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_soltotal_30yr_normal_800mM3_annual_bil")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_soltrans_30yr_normal_800mM3_03_bil")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_soltrans_30yr_normal_800mM3_04_bil")
  ))
  
  # daily normals
  expect_true(all(dir.exists(
    file.path(
      dl_folder, 
      paste0('PRISM_ppt_30yr_normal_4kmD1_02',sprintf("%02d",1:29), '_bil')
    )
  )))
  expect_true(all(dir.exists(file.path(
    dl_folder, 
    c('PRISM_ppt_30yr_normal_4kmD1_0101_bil', 
      'PRISM_ppt_30yr_normal_4kmD1_0301_bil')
  ))))
  expect_true(dir.exists(
    file.path(dl_folder, 'PRISM_tmean_30yr_normal_800mD1_0704_bil')
  ))
})

# annual -----------------------

test_that("annuals download", {
  skip_on_cran()
  skip_if(skip_annual)
  
  get_prism_annual("tmean", years = 2010)
  get_prism_annual("tmax",  years = 2011)
  get_prism_annual("tmin",  years = 2012)
  get_prism_annual("tdmean", years = 1944)
  get_prism_annual("vpdmin", years = 1982)
  get_prism_annual("vpdmax", years = 1933)
  get_prism_annual("ppt", years = 1999)
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_2010_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_2010_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmax_stable_4kmM3_2011_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmax_stable_4kmM3_2011_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmin_stable_4kmM3_2012_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmin_stable_4kmM3_2012_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tdmean_stable_4kmM3_1944_all_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tdmean_stable_4kmM3_1944_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmin_stable_4kmM3_1982_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmin_stable_4kmM3_1982_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmM3_1933_all_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmM3_1933_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmM3_1999_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmM3_1999_bil")
  ))
})

# monthly ----------------------

test_that("monthlys download", {
  skip_on_cran()
  skip_if(skip_monthly)
  
  get_prism_monthlys("tmean", years = 2010, mon = 1)
  get_prism_monthlys("tmax", years = 1983, mon = 12)
  get_prism_monthlys("tmin", years = 2015, mon = 9)
  get_prism_monthlys("tdmean", years = 2000, mon = 3)
  get_prism_monthlys("vpdmin", years = 2002, mon = 6)
  get_prism_monthlys("vpdmax", years = 1970, mon = 1)
  get_prism_monthlys("ppt", years = 1925, mon = 3)
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_201001_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_201001_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmax_stable_4kmM3_198312_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_201001_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmin_stable_4kmM3_201509_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_201001_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tdmean_stable_4kmM3_200003_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_201001_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmin_stable_4kmM3_200206_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmM3_201001_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmM3_1970_all_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmM3_197001_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmM2_1925_all_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmM2_192503_bil")
  ))
  
  # three consecutive --------------
  # Download three months to make sure that the middle month is downloaded.
  get_prism_monthlys(type = "tmean", mon = 2:4, year = 2014, keepZip = FALSE)
  for (i in 2:4) {
    expect_true(dir.exists(file.path(
      dl_folder, 
      paste0("PRISM_tmean_stable_4kmM3_2014", prism:::mon_to_string(i), "_bil")
    )))
  }
})

# daily ------------------------

test_that("daily download", {
  skip_on_cran()
  skip_if(skip_daily)
  
  get_prism_dailys("tmean", dates = "1981-01-01")
  get_prism_dailys("tmax", dates = "1985-02-20")
  get_prism_dailys("tmin", dates = "1991-06-01")
  get_prism_dailys("tdmean", dates = "1997-09-27")
  get_prism_dailys("vpdmax", dates = "2006-12-31")
  get_prism_dailys("vpdmin", dates = "2012-01-01")
  get_prism_dailys("ppt", dates = "2015-11-05")
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmD2_19810101_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_stable_4kmD2_19810101_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmax_stable_4kmD2_19850220_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmax_stable_4kmD2_19850220_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmin_stable_4kmD2_19910601_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmin_stable_4kmD2_19910601_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tdmean_stable_4kmD2_19970927_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tdmean_stable_4kmD2_19970927_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmD2_20061231_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmD2_20061231_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmin_stable_4kmD2_20120101_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmin_stable_4kmD2_20120101_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmD2_20151105_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmD2_20151105_bil")
  ))
})

# daily 3 in row ------------------
test_that("daily gets 3 in a row", {
  # Day = 13 to make sure months and days don't get confused.
  # Download three days to make sure that the middle day is downloaded.
  # Stable
  skip_on_cran()
  skip_if(skip_daily_3)
  
  get_prism_dailys(type = "tmean", minDate = "2014-01-13", 
                   maxDate = "2014-01-15",
                   keepZip = FALSE)
  get_prism_dailys(type = "ppt", minDate = "2000-06-13", maxDate = "2000-06-15",
                   keepZip = FALSE)
  
  for (i in 13:15) {
    expect_true(dir.exists(
      file.path(dl_folder, paste0("PRISM_ppt_stable_4kmD2_200006",i ,"_bil"))
    ))
    
    expect_true(dir.exists(
      file.path(dl_folder, paste0("PRISM_tmean_stable_4kmD2_201401", i,"_bil"))
    ))
  }
})

# daily provisional ------------------
today <- Sys.Date()
prov_date <- today - 7

test_that("daily provisional", {
  skip_on_cran()
  skip_if(skip_daily_prov)
  
  get_prism_dailys(type = "tmax", minDate = prov_date, maxDate = prov_date)
  
  expect_true(dir.exists(
    file.path(
      dl_folder,
      paste0(
        "PRISM_tmax_provisional_4kmD2_",
        stringr::str_remove_all(prov_date, "-"),
        "_bil"
      )
    )
  ))
})
