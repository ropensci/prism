#' Download annual daily averages
#' @description Download annual daily average data from the prism project at 4km grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#' @param year a valid numeric year, or vector of years, to download data for.  If no month is specified, year averages for that year will be downloaded
#' @param keepZip if true, leave the downloaded zip files in your 'prism.path', if FALSE, they will be deleted
#' @details Data is available from 1891 until 2014, however you have to download all data for years prior to 1981.  Thefore if you enter a vector of years that bounds 1981, you will automatically download all data for all years in the vector.  If the "all" parameter is set to TRUE, it will override any months entered and download all data. Data will be downloaded for all months in all the years in the vectors supplied. You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' @examples \dontrun{
#' ### Get all the data for January from 1990 to 2000
#' get_prism_annual(type="tmean", year = 1990:2000, keepZip=F)
#' }
#' @export
get_prism_annual <- function(type, year = NULL ,keepZip = TRUE){
  
  ### parameter and error handling
  path_check()
  type <- match.arg(type, c("ppt","tmean","tmin","tmax"))
  

  
  ### Check year
  ### Check months
  
  if(!is.numeric(year)){
    stop("You must enter a numeric month between 1 and 12")
  }
  
  if(year < 1895 || month > 12){
    stop("You must enter a month between 1 and 12")
  }
  
  


if(min(as.numeric(year)) > 1980){
  download_pb <- txtProgressBar(min = 0, max = length(year), style = 3)
  
  base <- "ftp://prism.nacse.org/monthly"
  for(i in 1:length(year)){ 
    ystring <- as.character(year[i])
    
    full_path <- paste(base,paste(type,ystring,sep="/"),sep="/")
    
    fileName <- paste("PRISM_",type,"_stable_4kmM2_",ystring,"_bil.zip",sep="") 
    
    if(length(prism_check(fileName)) == 1){
      outFile <- paste(options("prism.path"),fileName,sep="/")
      
      download.file(url = paste(full_path,fileName,sep="/"), destfile = outFile,quiet=T)
      unzip(outFile, exdir = strsplit(outFile,".zip")[[1]] )   
      
      if(!keepZip){
        file.remove(outFile)
      }
    }
    setTxtProgressBar(download_pb, i)
  }
  
  close(download_pb)  
  
  
}