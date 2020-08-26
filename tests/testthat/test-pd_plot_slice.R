test_that("pd_plot_slice() works", {
  expect_s3_class(
    gg <- pd_plot_slice(
      prism_archive_subset("ppt", "daily", years = 1981:2011),
      c(-73.2119, 44.4758)
    ), 
    "gg"
  )
  expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  
  expect_s3_class(
    gg <- pd_plot_slice(
      prism_archive_subset("tdmean", "monthly", years = 2005),
      c(-73.2119, 44.4758)
    ), 
    "gg"
  )
  expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  
  bad <- c("PRISM_tdmean_stable_4kmM3_200511_bil", 
           "PRISM_ppt_stable_4kmD2_19910101_bil")
  
  expect_error(pd_plot_slice(bad, c(-73.2119, 44.4758)))
})
