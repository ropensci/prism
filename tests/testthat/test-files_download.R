
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
skip_monthly_3 <- TRUE
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
      expected_pd = "prism_tmean_us_30s_20200704_avg_30y"
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
  
  annual_cases <- data.frame(
    type = c("tmean", "tmax", "tmin", "tdmean", "vpdmin", "vpdmax", "ppt"),
    year = c(2011, 2011, 2012, 1944, 1982, 1933, 1999),
    resolution = c(rep("4km", 6), "800m"),
    expected_pd = c("prism_tmean_us_25m_2011", "prism_tmax_us_25m_2011", 
                    "prism_tmin_us_25m_2012", "prism_tdmean_us_25m_1944",
                    "prism_vpdmin_us_25m_1982", "prism_vpdmax_us_25m_1933",
                    "prism_ppt_us_30s_1999")
  )
  
  for (i in seq_len(nrow(annual_cases))) {
    
    keepZip <- as.logical(i%%2)
    ff <- formats[[(i%%4 + 1)]]
    prism_set_format(ff)
    
    pd <- get_prism_annual(
      type = annual_cases[["type"]][[i]],
      years = annual_cases[["year"]][[i]],
      resolution = annual_cases[["resolution"]][[i]],
      keepZip = keepZip
    )
    
    expect_setequal(pd, annual_cases[["expected_pd"]][[i]])
    
    expect_observed_download(
      pd = pd,
      dl_dir = prism_get_dl_dir(),
      format = ff,
      keep_zip = keepZip,
      is_normal = FALSE
    )
  }
})

# monthly ----------------------
test_that("monthlys download", {
  skip_on_cran()
  skip_if(skip_monthly)
  
  monthly_cases <- data.frame(
    type = c("tmean", "tmax", "tmin", "tdmean", "vpdmin", "vpdmax", "ppt"),
    year = c(2010, 1983, 2015, 2000, 2002, 1970, 1925),
    month = c(1, 12, 9, 3, 6, 1, 3),
    resolution = c(rep("4km", 3), "800m", rep("4km", 3)),
    expected_pd = c("prism_tmean_us_25m_201001", "prism_tmax_us_25m_198312", 
                    "prism_tmin_us_25m_201509", "prism_tdmean_us_30s_200003",
                    "prism_vpdmin_us_25m_200206", "prism_vpdmax_us_25m_197001",
                    "prism_ppt_us_25m_192503")
  )
  
  for (i in seq_len(nrow(monthly_cases))) {
    
    keepZip <- as.logical(i%%2)
    ff <- formats[[(i%%4 + 1)]]
    prism_set_format(ff)
    
    pd <- get_prism_monthlys(
      type = monthly_cases[["type"]][[i]],
      years = monthly_cases[["year"]][[i]],
      mon = monthly_cases[["month"]][[i]],
      resolution = monthly_cases[["resolution"]][[i]],
      keepZip = keepZip
    )
    
    expect_setequal(pd, monthly_cases[["expected_pd"]][[i]])
    
    expect_observed_download(
      pd = pd,
      dl_dir = prism_get_dl_dir(),
      format = ff,
      keep_zip = keepZip,
      is_normal = FALSE
    )
  }
})

# monthly 3 ----------------------
test_that("monthly works with multiple months", {
  skip_on_cran()
  skip_if(skip_monthly_3)
  
  # three consecutive --------------
  # Download three months to make sure that the middle month is downloaded.
  prism_set_format("geotiff")
  pd <- get_prism_monthlys(
    type = "tmean", mon = 2:4, year = 2012, keepZip = FALSE
  )
  
  expect_setequal(pd, paste0("prism_tmean_us_25m_2012", sprintf("%02d", 2:4)))
  
  for (i in 1:3) {
    expect_observed_download(
      pd = pd[i],
      dl_dir = prism_get_dl_dir(),
      format = "geotiff",
      keep_zip = FALSE,
      is_normal = FALSE
    )
  }
})

# daily ------------------------
test_that("daily download", {
  skip_on_cran()
  skip_if(skip_daily)
  
  daily_cases <- data.frame(
    type = c("tmean", "tmax", "tmin", "tdmean", "vpdmin", "vpdmax", "ppt"),
    date = c("1981-01-01", "1985-02-20", "1991-06-01", "1997-09-27", 
             "2006-12-31", "2012-01-01", "2015-11-05"),
    resolution = c("800m", rep("4km", 6)),
    expected_pd = c("prism_tmean_us_30s_19810101", "prism_tmax_us_25m_19850220", 
                    "prism_tmin_us_25m_19910601", "prism_tdmean_us_25m_19970927",
                    "prism_vpdmin_us_25m_20061231", 
                    "prism_vpdmax_us_25m_20120101","prism_ppt_us_25m_20151105")
  )
  
  for (i in seq_len(nrow(daily_cases))) {
    
    keepZip <- as.logical(i%%2)
    ff <- formats[[(i%%4 + 1)]]
    prism_set_format(ff)
    
    pd <- get_prism_dailys(
      type = daily_cases[["type"]][[i]],
      dates = daily_cases[["date"]][[i]],
      resolution = daily_cases[["resolution"]][[i]],
      keepZip = keepZip
    )
    
    expect_setequal(pd, daily_cases[["expected_pd"]][[i]])
    
    expect_observed_download(
      pd = pd,
      dl_dir = prism_get_dl_dir(),
      format = ff,
      keep_zip = keepZip,
      is_normal = FALSE
    )
  }
})

# daily 3 in row ------------------
test_that("daily gets 3 in a row", {
  # Day = 13 to make sure months and days don't get confused.
  # Download three days to make sure that the middle day is downloaded.
  skip_on_cran()
  skip_if(skip_daily_3)
  prism_set_format("geotiff")
  
  daily_cases <- data.frame(
    type = c("tmean", "ppt"),
    minDate = c("2014-01-13", "2000-06-13"),
    maxDate = c("2014-01-15", "2000-06-15")
  )
  
  expected_pd <- list(
    paste0("prism_tmean_us_25m_201401", sprintf("%02d", 13:15)),
    paste0("prism_ppt_us_25m_200006", sprintf("%02d", 13:15))
  )
  
  stopifnot(nrow(daily_cases) == length(expected_pd))
  
  for (i in seq_len(nrow(daily_cases))) {
  
    pd <- get_prism_dailys(
      type = daily_cases[["type"]][[i]], 
      minDate = daily_cases[["minDate"]][[i]], 
      maxDate = daily_cases[["maxDate"]][[i]],
      keepZip = FALSE
    )
    
    expect_setequal(pd, expected_pd[[i]])
    
    for (p in pd) {
      expect_observed_download(
        pd = p,
        dl_dir = prism_get_dl_dir(),
        format = "geotiff",
        keep_zip = FALSE,
        is_normal = FALSE
      )
    }
  }
})

