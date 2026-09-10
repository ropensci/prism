# TODO: this should fail with the ppt 20120101 that is intentionally bad

o_format <- prism_get_format()
o_dir <- prism_get_dl_dir()
teardown({
  prism_set_dl_dir(o_dir)
  prism_set_format(o_format)
})

test_that("`pd_image()` works", {
  
  for (ff in prism:::prism_formats) {
    prism_set_format(ff)
    prism_set_dl_dir(file.path(
      tempdir(),'prismdata', ifelse(ff == 'geotiff', 'tif', ff)
    ))
    
    # get 1 file
    pd <- prism_archive_ls()[1]
    
    expect_s3_class(
      gg <- pd_image(pd, draw = FALSE), 
      "gg"
    )
    expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
    
    expect_s3_class(
      gg <- pd_image(pd, "redblue", draw = FALSE), 
      "gg"
    )
    expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
    
    # fails if more than 1 is sent to it
    expect_error(pd_image(rep(pd,2)))
    
    # fails if draw is not in correct format
    expect_error(pd_image(pd, draw = "false"))
    expect_error(pd_image(pd, draw = c(TRUE, FALSE)))
    expect_error(pd_image(pd, draw = NA))
    expect_error(pd_image(pd, draw = NULL))
  }
  
})
