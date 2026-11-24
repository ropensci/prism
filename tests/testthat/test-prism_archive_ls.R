

test_that("Directory listings work",{
  skip_on_cran()
  
  for (ff in c("geotiff", "bil", "nc")) {
    prism_set_dl_dir(file.path(
      tempdir(), 
      'prismdata', 
      ifelse(ff == 'geotiff', 'tif', ff)
    ))
    
    expect_length(x <- prism_archive_ls(), ifelse(ff == 'geotiff', 4, ifelse(ff == 'bil', 2, 1)))
  }
}) 
