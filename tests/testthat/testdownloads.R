 library(testthat)
 library(RCurl)
 library(prism)
 context("Downloads work")
 temp_dir_prism <- tempdir()
 options(prism.path = temp_dir_prism)
 tryCatch({
   test_that("Daily download works and gives reasonable output", {
     skip_on_cran()
     # Day = 13 to make sure months and days don't get confused.
     # Download three days to make sure that the middle day is downloaded.
     # Stable
     # Use min and max date as the code 

    get_prism_dailys(type = "tmean", minDate = "2014-01-13", maxDate = "2014-01-14",
                     dates = NULL, keepZip = FALSE)
     get_prism_dailys(type = "tmin", minDate = "2014-01-13", maxDate = "2014-01-14",
                      dates = NULL, keepZip = FALSE)
     get_prism_dailys(type = "tmax", minDate = "2014-01-13", maxDate = "2014-01-14",
                      dates = NULL, keepZip = FALSE)
     get_prism_dailys(type = "ppt", minDate = "2014-01-13", maxDate = "2014-01-14",
                      dates = NULL, keepZip = FALSE)
     
     
    # provisional
     today <- Sys.Date()
     get_prism_dailys(type = "tmax", minDate = as.character(today - 30), maxDate = as.character(today - 30),
                     dates = NULL, keepZip = FALSE)

       })

  
  test_that("Normals download properly", {
    skip_on_cran()
    #     # Download three months to make sure that the middle month is downloaded.
    get_prism_normals(type="ppt",resolution = "4km",mon = 1, keepZip=F)    
  })
  
  unlink(temp_dir_prism, recursive = TRUE)
 }, error = function(e){
   # Delete the temp folder on errors.
   unlink(temp_dir_prism, recursive = TRUE)
   stop("Download tests failed")
 })
