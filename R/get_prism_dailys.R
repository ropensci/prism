#' Download daily prism data
#' @description Download daily data from the prism project at 4km grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#' @param minDate a valid iso-8601 (e.g. YYYY-MM-DD) date to start to download data.
#' @param maxDate  a valid iso-8601 (e.g. YYYY-MM-DD) date to end downloading data.
#' @param dates a vector of iso-8601 formatted dates to download data for, can also be a single date.
#' @param keepZip if true, leave the downloaded zip files in your 'prism.path', if FALSE, they will be deleted
#' @details Dates must be in the proper format or downloading will not work properly, you can either enter a date range via minDate and maxDate, or a vector of dates, but not both. You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
  #' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)
#' @export
get_prism_dailys <- function(type, minDate = NULL, maxDate =  NULL, dates = NULL, keepZip = TRUE){
  
  if(!is.null(dates) && !is.null(maxDate)){
    stop("You can enter a date range or a vector of dates, but not both")
  }
  
  if(is.null(dates)){
    dates <- seq(as.Date(minDate),as.Date(maxDate),by="days")
  }
  
  
  ### parameter and error handling
  
  type <- match.arg(type, c("ppt","tmean","tmin","tmax"))
 
  download_pb <- txtProgressBar(min = 0, max = length(dates), style = 3)
  
  base <- "ftp://prism.nacse.org/daily"
  
  for(i in 1:length(dates)){
    #parse date
    dstring <- strsplit(as.character(dates[i]),"-")[[1]]
    if(as.numeric(dstring[1]) < 1981){stop("You must ask for data after 1981")}
    full_path <- paste(base,paste(type,dstring[1],sep="/"),sep="/")
    fileName <- paste("PRISM_",type,"_stable_4kmD1_",paste(dstring,collapse=""),"_bil.zip",sep="")
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
