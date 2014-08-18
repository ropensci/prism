#' Download monthly prism data
#' @description Download monthly data from the prism project at 4km grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#' @param year a valid numeric year, or vector of years, to download data for.  If no month is specified, year averages for that year will be downloaded
#' @param month a valid numeric month, or vector of months, to download data for.
#' @param keepZip if true, leave the downloaded zip files in your 'prism.path', if FALSE, they will be deleted
#' @details Data is available from 1891 until 2014, however you have to download all data for years prior to 1981.  Thefore if you enter a vector of years that bounds 1981, you will automatically download all data for all years in the vector.  If the "all" parameter is set to TRUE, it will override any months entered and download all data. Data will be downloaded for all months in all the years in the vectors supplied. You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' @examples \dontrun{
#' ### Get all the data for January from 1990 to 2000
#' get_prism_monthlys(type="tmean", years = 1990:2000, months = 1, keepZip=F)
#' 
#' }
#' @export
get_prism_monthlys <- function(type, year = NULL, month = NULL ,keepZip = TRUE){

  ### parameter and error handling
  
  type <- match.arg(type, c("ppt","tmean","tmin","tmax"))

  
###
if(!all && min(as.numeric(year)) > 1980){
  download_pb <- txtProgressBar(min = 0, max = length(year) * length(month), style = 3)
  counter <- 1
  base <- "ftp://prism.nacse.org/monthly"
  for(i in 1:length(year)){ 
    for(j in 1:length(month)){
    #parse date
   ystring <- as.character(year[i])
     
    full_path <- paste(base,paste(type,ystring,sep="/"),sep="/")
    fileName <- paste("PRISM_",type,"_stable_4kmM2_",paste(ystring,mon_to_string(month[j]),sep=""),"_bil.zip",sep="")
    if(length(prism_check(fileName)) == 1){
      outFile <- paste(options("prism.path"),fileName,sep="/")
    
      download.file(url = paste(full_path,fileName,sep="/"), destfile = outFile, method = "curl",quiet=T)
      unzip(outFile, exdir = strsplit(outFile,".zip")[[1]] )   
    
      if(!keepZip){
        file.remove(outFile)
      }
    }
    setTxtProgressBar(download_pb, counter)
   counter <- counter + 1
  }
  }
  close(download_pb)
  
  }


### Handle years before 1981

if( min(as.numeric(years)) <= 1980){
  
  download_pb <- txtProgressBar(min = 0, max = length(years), style = 3)
  
  base <- "ftp://prism.nacse.org/monthly"
  for(i in 1:length(years)){ 

      ystring <- as.character(years[i])
      
      full_path <- paste(base,paste(type,ystring,sep="/"),sep="/")
      
      fileName <- paste("PRISM_",type,"_stable_4kmM2_",ystring,"_bil.zip",sep="")
      if(length(prism_check(fileName)) == 1){
        if(as.numeric(years[i]) > 1980){ fileName <- paste("PRISM_",type,"_stable_4kmM2_",ystring,"_all_bil.zip",sep="") }
        
        
        outFile <- paste(options("prism.path"),fileName,sep="/")
        
        download.file(url = paste(full_path,fileName,sep="/"), destfile = outFile, method = "curl",quiet=T)
        unzip(outFile, exdir = strsplit(outFile,".zip")[[1]] )   
        
        if(!keepZip){
          file.remove(outFile)
        }
      }
      setTxtProgressBar(download_pb, i)
    }

  close(download_pb)  
}

if(all && min(as.numeric(years)) > 1980){
  download_pb <- txtProgressBar(min = 0, max = length(years), style = 3)
  
  base <- "ftp://prism.nacse.org/monthly"
  for(i in 1:length(years)){ 
    ystring <- as.character(years[i])
    
    full_path <- paste(base,paste(type,ystring,sep="/"),sep="/")
    
    fileName <- paste("PRISM_",type,"_stable_4kmM2_",ystring,"_all_bil.zip",sep="") 
    
    if(length(prism_check(fileName)) == 1){
      outFile <- paste(options("prism.path"),fileName,sep="/")
      
      download.file(url = paste(full_path,fileName,sep="/"), destfile = outFile, method = "curl",quiet=T)
      unzip(outFile, exdir = strsplit(outFile,".zip")[[1]] )   
      
      if(!keepZip){
        file.remove(outFile)
      }
    }
    setTxtProgressBar(download_pb, i)
  }
  
  close(download_pb)  
  
  
  }
  
}

