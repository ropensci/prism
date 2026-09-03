# TODO: this should fail with the ppt 20120101 that is intentionally bad

test_that("`pd_image()` works", {
  
  for (ff in prism:::prism_formats) {
    prism_set_format(ff)
    prism_set_dl_dir(file.path(tempdir(),'prismdata', ifelse(ff == 'geotiff', 'tif', ff)))
    
    # get 1 file
    pd <- prism_archive_ls()[1]
    
    expect_s3_class(
      gg <- pd_image(pd), 
      "gg"
    )
    expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
    
    expect_s3_class(
      gg <- pd_image(pd, "redblue"), 
      "gg"
    )
    expect_s3_class(ggplot2::ggplot_build(gg), "ggplot_built")
    
    # fails if more than 1 is sent to it
    expect_error(pd_image(rep(pd,2)))
  }
  
})
