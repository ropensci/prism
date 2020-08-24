test_that("`prism_image()` works", {
  expect_s3_class(
    gg <- prism_image("PRISM_ppt_stable_4kmD2_19910101_bil"), 
    "gg"
  )
  expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  
  expect_s3_class(
    gg <- prism_image("PRISM_tdmean_stable_4kmM3_200512_bil", "redblue"), 
    "gg"
  )
  expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
  
  both <- c("PRISM_ppt_stable_4kmD2_19910101_bil", 
            "PRISM_tdmean_stable_4kmM3_200512_bil")
  expect_error(prism_image(both))
  expect_error(prism_image("PRISM_ppt_stable_4kmD2_19870214_bil"))
})
