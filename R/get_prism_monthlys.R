#' Download monthly prism data
#' @description Download monthly data from the prism project 
#' at 4km grid cell resolution for precipitation, mean, min, and max temperature
#' @inheritParams get_prism_dailys
#' @param years a valid numeric years, or vector of years, 
#' to download data for. If no month is specified, years 
#' averages for that years will be downloaded
#' @param month a valid numeric month, or vector of months.
#' @param keepZip if true, leave the downloaded zip files 
#' in your 'prism.path', if FALSE, they will be deleted
#' @details Data is available from 1891 until 2014, however you have to download all 
#' data for years prior to 1981.  
#' Therefore if you enter a vector of years that bounds 1981, 
#' you will automatically download all data for all years in the vector.  
#' If the "all" parameter is set to TRUE, it will override any months 
#' entered and download all data. Data will be downloaded for all months 
#' in all the years in the vectors supplied. You must make sure 
#' that you have set up a valid download directory.  
#' This must be set as options(prism.path = "YOURPATH")
#' @examples \dontrun{
#' ### Get all the data for January from 1990 to 2000
#' get_prism_monthlys(type="tmean", years = 1990:2000, month = 1, keepZip=F)
#' }
#' @export
get_prism_monthlys <- function(type, years = NULL, month = NULL, keepZip = TRUE){
  ### parameter and error handling
  ## Set the frequency to get the file name listing
  freq <- "monthly"
  
  path_check()
  type <- match.arg(type, c("ppt", "tmean", "tmin", "tmax", "all"))
  if (type == "all") {
    get_prism_monthlys(type = "ppt", years = years, month = month, 
                       keepZip = keepZip)
    get_prism_monthlys(type = "tmin", years = years, month = month, 
                       keepZip = keepZip)
    get_prism_monthlys(type = "tmax", years = years, month = month, 
                       keepZip = keepZip)
  } else {
    
    ### Check months
    if(!is.numeric(month)) {
      stop("You must enter a numeric month between 1 and 12")
    }
    
    if(any(month < 1 | month > 12)) {
      stop("You must enter a month between 1 and 12")
    }
    
    ### Check year
    if(!is.numeric(years)){
      stop("You must enter a numeric year from 1895 onwards.")
    }
    
    ### Check months
    if(any(years < 1895)){
      stop("You must enter a year from 1895 onwards.")
    }
    

    
    # Handle data after 1980
    download_pb <- txtProgressBar(min = 0, max = length(years) * length(month), style = 3)
    base <- "ftp://prism.nacse.org/monthly"

    for(i in 1:length(years)){
      # parse date
      full_path <- paste(base, type, years[i], sep = "/")
      
      if(years[i] > 1980) {

        fileName <- get_filenames(type,freq,years[i])
        ### subset the list of files down to the ones we want to download
        match_list <- paste(years[i],formatC(month, width = 2, format = "d", flag = "0"),sep="")
        
        fileName <- grep(paste(match_list,collapse="|"),fileName,value = TRUE)
        ### Check for existing file names  that are already downloaded
        fileName <- prism_check(fileName)
        
          if(length(fileName) >= 1){
            
            for(j in 1:length(fileName)) {
            outFile <- paste(options("prism.path"), fileName[j], sep="/")
            tryNumber <- 1
            downloaded <- FALSE
            
            if (Sys.info()["sysname"] == "Windows") {
              current_net2_status <- setInternet2(NA)
              setInternet2(FALSE)
            }
            while(tryNumber < 11 & !downloaded){
              downloaded <- TRUE
              tryCatch(
                download.file(url = paste(full_path, fileName[j], sep = "/"), 
                              destfile = outFile, mode = "wb", quiet = TRUE), 
                error = function(e){
                  downloaded <<- FALSE
                })
              tryNumber <- tryNumber + 1
            }
            if (Sys.info()["sysname"] == "Windows") {
              setInternet2(current_net2_status)
            }
            if (!downloaded) {
              warning(paste0("Downloading failed for type = ", type, ", month = ", month[j],
                             ", and year = ", years[i]))
            } else {
              unzip(outFile, exdir = strsplit(outFile, ".zip")[[1]])
              if(!keepZip){
                file.remove(outFile)
              }
            }
          
          setTxtProgressBar(download_pb, counter)
          counter <- counter + 1
            }
          }
      } else {
        # Handle years before 1981.
        # The whole year's worth of data needs to be downloaded, 
        # then extracted, and copied into the main directory.

        fileName <- get_filenames(type,freq,years[i])
        
                  outFile <- paste(options("prism.path"), fileName, sep="/")
          
          if (Sys.info()["sysname"] == "Windows") {
            current_net2_status <- setInternet2(NA)
            setInternet2(FALSE)
          }
          tryNumber <- 1
          downloaded <- FALSE
          while(tryNumber < 11 & !downloaded){
            downloaded <- TRUE
            tryCatch({
              download.file(url = paste(full_path, fileName, sep="/"),
                            destfile = outFile, quiet=TRUE, mode = "wb")
            }, error = function(e) {
              downloaded <<- FALSE
            })
            tryNumber <- tryNumber + 1
          }
          if (Sys.info()["sysname"] == "Windows") {
            setInternet2(current_net2_status)
          }
          
          if (!downloaded){
            warning(paste0("Downloading failed for type = ", type, ", month = ", month[j],
                           ", and years = ", years[i]))
          } else {
            unzip(outFile, exdir = strsplit(outFile,".zip")[[1]])
            if(!keepZip){
              file.remove(outFile)
            }
          }
          if(!keepZip & file.exists(outFile)){
            file.remove(outFile)
          }
          # Now process the data by month
          # First get the name of the directory with the data
          all_file <- strsplit(fileName, '[.]')[[1]][1]
          to_split <- sapply(month, function(x) gsub("_all", sprintf("%02d", x), all_file))
          process_zip(all_file, to_split)
        
        setTxtProgressBar(download_pb, i)
      }
    }
    close(download_pb)
  }
}

