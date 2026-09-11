
dl_folder <- file.path(tempdir(), "prism")
cur_path <- prism_get_dl_dir()
cur_format <- prism_get_format()
setup({prism_set_dl_dir(dl_folder)})
teardown({
  prism_set_dl_dir(cur_path)
  prism_set_format(cur_format)
})


cat("\n\n***************************************")
cat("\nmake sure you run this 2x or less in any given day!!!!\n")
cat("****************************************\n")

# skip flags -----------------
skip_normals <- TRUE
skip_annual <- TRUE
skip_monthly <- TRUE
skip_daily <- TRUE
skip_daily_3 <- TRUE

expect_observed_download <- function(pd, dl_dir, format, keep_zip, is_normal) {
  if (is_normal) {
    expected_ext <- c(
      geotiff = "tif",
      bil = "tif",
      asc = "tif",
      nc = "tif"
    )
  } else {
    expected_ext <- c(
      geotiff = "tif",
      bil = "bil",
      asc = "asc",
      nc = "nc"
    )
  }
  
  expect_true(dir.exists(file.path(dl_dir, pd)))
  
  zip_path <- file.path(dl_dir, paste0(pd, ".zip"))
  
  if (keep_zip) {
    expect_true(file.exists(zip_path))
  } else {
    expect_false(file.exists(zip_path))
  }
  
  raster_file <- pd_to_file(pd)
  
  expect_true(file.exists(raster_file))
  expect_identical(tools::file_ext(raster_file), expected_ext[[format]])
  
  r <- terra::rast(raster_file)
  values <- terra::values(r, mat = FALSE)
  
  expect_s4_class(r, "SpatRaster")
  expect_gt(terra::ncell(r), 0L)
  expect_true(any(!is.na(values)))
}


formats <- c("geotiff", "bil", "asc", "nc")

# Normals ---------------
test_that("normals download", {
  skip_on_cran()
  skip_if(skip_normals)
  
  normal_cases <- list(
    list(
      args = list(
        type = "tmean",
        resolution = "4km",
        mon = 1
      ),
      expected_pd = "prism_tmean_us_25m_202001_avg_30y"
    ),
    list(
      args = list(
        type = "tmax",
        resolution = "4km",
        annual = TRUE
      ),
      expected_pd = "prism_tmax_us_25m_2020_avg_30y"
    ),
    list(
      args = list(
        type = "tmin",
        resolution = "4km",
        mon = 2
      ),
      expected_pd = "prism_tmin_us_25m_202002_avg_30y"
    ),
    list(
      args = list(
        type = "tdmean",
        resolution = "4km",
        mon = 6
      ),
      expected_pd = "prism_tdmean_us_25m_202006_avg_30y"
    ),
    list(
      args = list(
        type = "vpdmin",
        resolution = "4km",
        mon = 12
      ),
      expected_pd = "prism_vpdmin_us_25m_202012_avg_30y"
    ),
    list(
      args = list(
        type = "vpdmax",
        resolution = "4km",
        mon = 9
      ),
      expected_pd = "prism_vpdmax_us_25m_202009_avg_30y"
    ),
    list(
      args = list(
        type = "ppt",
        resolution = "800m",
        mon = 11
      ),
      expected_pd = "prism_ppt_us_30s_202011_avg_30y"
    ),
    list(
      args = list(
        type = "solclear",
        resolution = "800m",
        mon = 1
      ),
      expected_pd = "prism_solclear_us_30s_202001_avg_30y"
    ),
    list(
      args = list(
        type = "solslope",
        resolution = "800m",
        annual = TRUE
      ),
      expected_pd = "prism_solslope_us_30s_2020_avg_30y"
    ),
    list(
      args = list(
        type = "soltotal",
        resolution = "800m",
        annual = TRUE
      ),
      expected_pd = "prism_soltotal_us_30s_2020_avg_30y"
    ),
    list(
      args = list(
        type = "soltrans",
        resolution = "800m",
        mon = 3:4
      ),
      expected_pd = c(
        "prism_soltrans_us_30s_202003_avg_30y",
        "prism_soltrans_us_30s_202004_avg_30y"
      )
    ),
    list(
      args = list(
        type = "ppt",
        resolution = "4km",
        mon = NULL,
        annual = FALSE,
        day = c('0101', '0301')
      ),
      expected_pd = c("prism_ppt_us_25m_20200101_avg_30y",
                      "prism_ppt_us_25m_20200301_avg_30y")
    ),
    list(
      args = list(
        type = "ppt",
        resolution = "4km",
        mon = 2,
        annual = FALSE,
        day = TRUE
      ),
      expected_pd = c(paste0(
        "prism_ppt_us_25m_202002", sprintf("%02d", 1:29), "_avg_30y"
      ), "prism_ppt_us_25m_202002_avg_30y")
    ),
    list(
      args = list(
        type = "tmean",
        resolution = "800m",
        mon = NULL,
        annual = FALSE,
        day = as.Date('2000-07-04')
      ),
      expected_pd = "prism_tmean_us_25m_20200704_avg_30y"
    )
  )
  
  # add keepZip and format inside loop
  for (i in seq_len(length(normal_cases))) {
    case <- normal_cases[[i]]
    
    # set keep_zip and format
    ff <- formats[(i%%4 + 1)]
    case[["args"]][["keepZip"]] <- as.logical(i%%2)
    
    prism_set_format(ff)
    pd <- do.call(get_prism_normals, case[["args"]])
    expect_setequal(pd, case[["expected_pd"]])
    
    for (p in pd) {
      expect_observed_download(
        pd = p, 
        dl_dir = prism_get_dl_dir(), 
        format = prism_get_format(), 
        keep_zip = case[["args"]][["keepZip"]],
        is_normal = TRUE
      )
    }
  }
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
    file.path(dl_folder, "prism_tmean_us_25m_2010.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_2010")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tmax_us_25m_2011.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmax_us_25m_2011")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tmin_us_25m_2012.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmin_us_25m_2012")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tdmean_us_25m_1944.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tdmean_us_25m_1944")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_vpdmin_us_25m_1982.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_vpdmin_us_25m_1982")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_vpdmax_us_25m_1933.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_vpdmax_us_25m_1933")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_ppt_us_25m_1999.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_ppt_us_25m_1999")
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
    file.path(dl_folder, "prism_tmean_us_25m_201001.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_201001")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tmax_us_25m_198312.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_201001")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tmin_us_25m_201509.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_201001")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tdmean_us_25m_200003.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_201001")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_vpdmin_us_25m_200206.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_201001")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_vpdmax_us_25m_197001.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_vpdmax_us_25m_197001")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_ppt_us_25m_192503.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_ppt_us_25m_192503")
  ))
  
  # three consecutive --------------
  # Download three months to make sure that the middle month is downloaded.
  get_prism_monthlys(type = "tmean", mon = 2:4, year = 2014, keepZip = FALSE)
  for (i in 2:4) {
    expect_true(dir.exists(file.path(
      dl_folder, 
      paste0("prism_tmean_us_25m_2014", prism:::mon_to_string(i), "")
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
    file.path(dl_folder, "prism_tmean_us_25m_19810101.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmean_us_25m_19810101")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tmax_us_25m_19850220.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmax_us_25m_19850220")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tmin_us_25m_19910601.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tmin_us_25m_19910601")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_tdmean_us_25m_19970927.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_tdmean_us_25m_19970927")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_vpdmax_us_25m_20061231.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_vpdmax_us_25m_20061231")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_vpdmin_us_25m_20120101.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_vpdmin_us_25m_20120101")
  ))
  
  expect_true(file.exists(
    file.path(dl_folder, "prism_ppt_us_25m_20151105.zip")
  ))
  expect_true(dir.exists(
    file.path(dl_folder, "prism_ppt_us_25m_20151105")
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
      file.path(dl_folder, paste0("prism_ppt_us_25m_200006",i ,""))
    ))
    
    expect_true(dir.exists(
      file.path(dl_folder, paste0("prism_tmean_us_25m_201401", i,""))
    ))
  }
})

