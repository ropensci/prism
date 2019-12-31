# TODO: need to also skip all the downloads (get_prism_*) calls on CRAN.

dl_folder <- file.path(tempdir(), "prism")
setup({
  dir.create(dl_folder)
  options(prism.path = dl_folder)
})

cat("\n\n***************************************")
cat("\nmake sure you run this 2x or less in any given day!!!!\n")
cat("****************************************\n")

#teardown(unlink(dl_folder, recursive = TRUE))

# Normals ---------------
get_prism_normals("tmean", resolution = "4km", annual = TRUE)
get_prism_normals("tmax", resolution = "4km", mon = 1)
get_prism_normals("tmin", resolution = "4km", mon = 2)
get_prism_normals("tdmean", resolution = "4km", mon = 6)
get_prism_normals("vpdmin", resolution = "4km", mon = 12)
get_prism_normals("vpdmax", resolution = "4km", mon = 9)
get_prism_normals("ppt", resolution = "800m", mon = 11)

test_that("normals download", {
  skip_on_cran()
  #skip("skip normals")
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmean_30yr_normal_4kmM2_annual_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmean_30yr_normal_4kmM2_annual_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmax_30yr_normal_4kmM2_01_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmax_30yr_normal_4kmM2_01_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tmin_30yr_normal_4kmM2_02_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tmin_30yr_normal_4kmM2_02_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_tdmean_30yr_normal_4kmM2_06_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_tdmean_30yr_normal_4kmM2_06_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmin_30yr_normal_4kmM2_12_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmin_30yr_normal_4kmM2_12_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_vpdmax_30yr_normal_4kmM2_09_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_vpdmax_30yr_normal_4kmM2_09_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_ppt_30yr_normal_800mM2_11_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_ppt_30yr_normal_800mM2_11_bil")
  ))
})

# annual -----------------------
get_prism_annual("tmean", years = 2010)
get_prism_annual("tmax",  years = 2011)
get_prism_annual("tmin",  years = 2012)
get_prism_annual("tdmean", years = 1944)
get_prism_annual("vpdmin", years = 1982)
get_prism_annual("vpdmax", years = 1933)
get_prism_annual("ppt", years = 1999)


test_that("annuals download", {
  skip_on_cran()
  #skip("skip annual")
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
    file.path(dl_folder, "PRISM_tdmean_stable_4kmM3_1944_all_bil")
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
    file.path(dl_folder, "PRISM_vpdmax_stable_4kmM3_1933_all_bil")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmM3_1999_bil.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "PRISM_ppt_stable_4kmM3_1999_bil")
  ))
})

# monthly ----------------------
get_prism_monthlys("tmean", years = 2010, mon = 1)
get_prism_monthlys("tmax", years = 1983, mon = 12)
get_prism_monthlys("tmin", years = 2015, mon = 9)
get_prism_monthlys("tdmean", years = 2000, mon = 3)
get_prism_monthlys("vpdmin", years = 2002, mon = 6)
get_prism_monthlys("vpdmax", years = 1970, mon = 1)
get_prism_monthlys("ppt", years = 1925, mon = 3)

test_that("monthlys download", {
  skip_on_cran()
  #skip("skip monthly")
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
})

# daily ------------------------
get_prism_dailys("tmean", dates = "1981-01-01")
get_prism_dailys("tmax", dates = "1985-02-20")
get_prism_dailys("tmin", dates = "1991-06-01")
get_prism_dailys("tdmean", dates = "1997-09-27")
get_prism_dailys("vpdmax", dates = "2006-12-31")
get_prism_dailys("vpdmin", dates = "2012-01-01")
get_prism_dailys("ppt", dates = "2015-11-05")

test_that("daily download", {
  skip_on_cran()
  #skip("skip daily")
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
