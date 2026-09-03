lat_lon <- c(-105.2797, 40.0176) # boulder 

test_that("pd_plot_slice() works", {
  prism_set_dl_dir(file.path(tempdir(),'prismdata', 'tif'))
  prism_set_format('geotiff')
  
  expect_s3_class(
    gg <- pd_plot_slice(
      prism_archive_subset("ppt", "annual", years = 2023:2025, resolution = '4km'),
      lat_lon
    ), 
    "gg"
  )
  expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  
  prism_set_dl_dir(file.path(tempdir(),'prismdata', 'nc'))
  prism_set_format('nc')
  expect_s3_class(
    gg <- pd_plot_slice(
      prism_archive_subset("tmin", "daily", years = 2025, resolution = '4km'),
      lat_lon
    ), 
    "gg"
  )
  expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  
  # TODO: update to fail with the bad prism data
  # bad <- c("PRISM_tdmean_stable_4kmM3_200511_bil", 
  #          "PRISM_ppt_stable_4kmD2_19910101_bil")
  # 
  # expect_error(pd_plot_slice(bad, lat_lon))
})
