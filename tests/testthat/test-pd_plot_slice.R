lat_lon <- c(-105.2797, 40.0176) # boulder 

o_format <- prism_get_format()
o_dir <- prism_get_dl_dir()
teardown({
  prism_set_dl_dir(o_dir)
  prism_set_format(o_format)
})

test_that("pd_plot_slice() works", {
  
  # test tif seperately b/c multiple files
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
  
  for (ff in c("bil", "asc", "nc")) {
    prism_set_dl_dir(file.path(tempdir(),'prismdata', ff))
    prism_set_format(ff)
    expect_s3_class(
      gg <- pd_plot_slice(
        prism_archive_ls(),
        lat_lon
      ), 
      "gg"
    )
    expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  }
  # TODO: update to fail with the bad prism data
  # bad <- c("PRISM_tdmean_stable_4kmM3_200511_bil", 
  #          "PRISM_ppt_stable_4kmD2_19910101_bil")
  # 
  # expect_error(pd_plot_slice(bad, lat_lon))
})
