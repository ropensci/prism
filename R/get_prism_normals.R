#' Download data for 30 year normals of climate variables
#' @description Download data from the prism project for 30 year normals at 4km or 800m grid cell resolution for precipitation, mean, min and max temperature
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", or "tmax".
#' @param resolution The spatial resolution of the data, must be either "4km" or "800m"
#' @param month a numeric value for month, can be a numeric vector of months.
#' @param annual if TRUE download annual data
#' @param keepZip if TRUE, leave the downloaded zip files in your 'prism.path', if FALSE, they will be deleted
#' @details You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' @examples \dontrun{
#' ### Get 30 year normal values for rainfall
#' get_prism_normals(type="ppt",resolution = "4km",month = 1, keepZip=F)
#' 
#' }
#' @export
get_prism_normals <- function(type, resolution, month =  NULL , annual =  FALSE,  keepZip = TRUE){
  
  ### parameter and error handling
  
  type <- match.arg(type, c("ppt","tmean","tmin","tmax"))
  res<- match.arg(resolution, c("4km","800m"))
  
  if(!is.null(month)){
    month <- mon_to_string(month)
    files <- vector()
    for(i in 1:length(month)){
      files <- c(files,paste("PRISM_",type,"_30yr_normal_", res,"M2_",month[i],"_bil.zip",sep=""))
    }
  } else if(annual){
    files <- paste("PRISM_",type,"_30yr_normal_", res,"M2_annual_bil.zip",sep="")    
  } 
  
  
  base <- "ftp://prism.nacse.org"
  full_path <- paste(base,paste("normals_",res,sep=""),type,"",sep="/")
  ## Trim files
  files <- prism_check(files)
  mpb <- txtProgressBar(min = 0, max = length(month), style = 3)
  
  for(i in 1:length(files)){
    outFile <- paste(options("prism.path"),files[i],sep="/")
    if(length(files>0)){
      download.file(url = paste(full_path,files[i],sep=""), destfile = outFile, method = "curl",quiet=T)
      unzip(outFile, exdir = strsplit(outFile,".zip")[[1]] ) 
      setTxtProgressBar(mpb, i)
      if(!keepZip){
        file.remove(outFile)
        }
    }
  }
  close(mpb)
  
  
}

#' helper function for handling months
#' @description Handle numeric month to string conversions
#' @export
mon_to_string <- function(month){
  out <- vector()
  for(i in 1:length(month)){
    if(month[i] < 1 || month[i] > 12){stop("Please enter a valid numeric month")}
    if(month[i] < 10){ out[i] <- paste("0",month[i],sep="")}
    else { out[i] <- paste0(month[i]) }
  }
  return(out)
}

#' Helper function to check if files already exist
#' @description check if files exist
#' @export

prism_check <- function(f){
  out <- ls_prism_data()
  f <- unlist(sapply(f,strsplit,split=".zip"))
  tf <- unlist(lapply(sapply(f,grepl,x=out,simplify=F),sum))
  return(names(tf)[!tf])
}
