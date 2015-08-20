library(raster)
 library(testthat)
 library(lubridate)
 library(RCurl)
 context("Downloads work")
 temp_dir_prism <- tempdir()
 options(prism.path = temp_dir_prism)
 tryCatch({
   test_that("Daily download works and gives reasonable output", {
     # Day = 13 to make sure months and days don't get confused.
     # Download three days to make sure that the middle day is downloaded.
     # Stable
     # Use min and max date as the code 
     get_prism_dailys(type = "all", minDate = "2014-01-13", maxDate = "2014-01-15",
                      dates = NULL, keepZip = FALSE)
#
#    get_prism_dailys(type = "tmean", minDate = "2014-01-13", maxDate = "2014-01-15",
#                     dates = NULL, keepZip = FALSE)
#     
#     # provisional
#     today <- Sys.Date()
#     get_prism_dailys(type = "tmax", minDate = as.character(today - 30), maxDate = as.character(today - 30),
#                     dates = NULL, keepZip = FALSE)
#     
#     match_grid <- function(type, date_str) {
#       expect_match({
#         my_message <- capture.output({
#           tmp <- readGDAL(file.path(getOption("prism.path"), paste0("PRISM_", type, "_stable_4kmD1_", date_str, "_bil"),
#                                     paste0("PRISM_", type, "_stable_4kmD1_", date_str, "_bil.bil")))
#         })
#         my_message[1]
#       }, "has GDAL driver EHdr")
#     }
#     for (type in c("tmax", "tmin", "tmean", "ppt")){
#       for (date_str in c("20140113", "20140114", "20140115")){
#         match_grid(type, date_str)
#       }
#     }
#   })
#   test_that("Monthly stable download works and gives reasonable output", {
#     # Download three months to make sure that the middle month is downloaded.
#     get_prism_monthlys(type = "all", month = 2:4, year = 2014, keepZip = FALSE)
#     get_prism_monthlys(type = "tmean", month = 2:4, year = 2014, keepZip = FALSE)
#     
#     match_grid <- function(type, date_str) {
#       expect_match({
#         folder_name <- paste0("PRISM_", type, "_stable_4kmM2_", date_str, "_bil")
#         my_message <- capture.output({
#           tmp <- readGDAL(file.path(getOption("prism.path"), folder_name,
#                                     paste0(folder_name, ".bil")))
#         })
#         my_message[1]
#       }, "has GDAL driver EHdr")
#     }
#     for (type in c("tmax", "tmin", "ppt", "tmean")){
#       for (date_str in c("201402", "201403", "201404")){
#         match_grid(type, date_str)
#       }
#     }
#   })
#   unlink(temp_dir_prism, recursive = TRUE)
# }, error = function(e){
#   # Delete the temp folder on errors.
#   unlink(temp_dir_prism, recursive = TRUE)
#   stop(e)
# })
