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
  test_that("Monthly stable download", {
    skip_on_cran()
#     # Download three months to make sure that the middle month is downloaded.
     get_prism_monthlys(type = "tmean", mon= 2:4, year = 2014, keepZip = FALSE)

  })
  
  test_that("Normals download properly", {
    skip_on_cran()
    #     # Download three months to make sure that the middle month is downloaded.
    get_prism_normals(type="ppt",resolution = "4km",mon = 1, keepZip=F)    
  })
  
  
  
  test_that("Directory listings work",{
    skip_on_cran()
    expect_equal(dim(ls_prism_data())[1],13)
    expect_equal(dim(ls_prism_data())[2],1)
    expect_equal(dim(ls_prism_data(absPath = T))[2],2)
    expect_equal(dim(ls_prism_data(name = T))[2],2)
    expect_equal(ls_prism_data(name = T)[1,2],"Jan 30-year normals - 4km resolution - Precipitation")
  }) 
  
  
  unlink(temp_dir_prism, recursive = TRUE)
 }, error = function(e){
   # Delete the temp folder on errors.
   unlink(temp_dir_prism, recursive = TRUE)
   stop("Download tests failed")
 })
