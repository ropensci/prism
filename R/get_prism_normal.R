#' Download data for 30 year normals of climate variables
#' @description Download data from the prism project for 30 year normals at 4km or 800m grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#' @param resolution The spatial resolution of the data, must be either "4km" or "800m"
#' @param month a numeric value for month, can be a numeric vector of months.
#' @param annual if true download annual data
#' @param all if true, download all data.  Be careful because this can take some time, these files can be 100's of megabytes.
#' @details You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' 
#' @export
get_prism_normal <- function(type, resolution, month =  NULL , annual =  FALSE, all = FALSE){
  
  ### parameter and error handling
  
  type <- match.args(type, c("ppt","tmean","tmin","tmax"))
  res<- match.args(resolution, c("4km","800m"))
  
  if(annual && all){
    stop("Annual data is included in all, both cannot be set to TRUE")
  }
  
  if(!is.null(month)){
    month <- mon_to_string(month)
    files <- vector()
    for(i in month){
      files <- c(files,paste("PRISM_",type,"_30yr_normal_", res,"M2_",i,"_bil.zip",sep=""))
    }
  } else if(annual){
    files <- paste("PRISM_",type,"_30yr_normal_", res,"M2_annual_bil.zip",sep="")    
  } else if(all){
    files <- paste("PRISM_",type,"_30yr_normal_", res,"M2_all_bil.zip",sep="")
  }
  
  
  base <- "ftp://prism.nacse.org"
  full_path <- paste(base,paste("normals_",res,sep=""),type,"",sep="/")
  
  outFile <- paste(options("prism.path"),files,sep="/")
  download.file(url = paste(full_path,files,sep=""), destfile = outFile, method = "curl")
  unzip(outFile, exdir = strsplit(outFile,".zip")[[1]] )  
  
  
}

#' helper function for handling months
#' @description Handle numeric month to string conversions
#' 
mon_to_string <- function(month){
  out <- vector()
  for(i in month){
    if(i < 1 || i > 12){stop("Please enter a valid numeric month")}
    if(i < 10){ out[i] <- paste("0",i,sep="")}
    else { out[i] <- paste0(i) }
  }
  return(out)
}