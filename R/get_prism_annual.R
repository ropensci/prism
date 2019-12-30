#' Download annual daily averages
#' 
#' Download annual daily average data from the prism project at 4km grid cell 
#' resolution for precipitation, mean, min and max temperature
#' 
#' @param type The type of data to download, must be "ppt", "tmean", "tmin", 
#'   "tmax", or "all", which downloads "ppt", "tmin", and "tmax". Note that 
#'   tmean == mean(tmin, tmax).
#'   
#' @param years a valid numeric year, or vector of years, to download data for.  
#'   If no month is specified, year averages for that year will be downloaded.
#'   
#' @param keepZip if `TRUE`, leave the downloaded zip files in your 
#'   'prism.path', if `FALSE`, they will be deleted.
#'   
#' @details Data is available from 1891 until 2014, however you have to download 
#' all data for years prior to 1981.  Therefore if you enter a vector of years 
#' that bounds 1981, you will automatically download all data for all years in 
#' the vector.  If the "all" parameter is set to TRUE, it will override any 
#' months entered and download all data. Data will be downloaded for all months 
#' in all the years in the vectors supplied. You must make sure that you have 
#' set up a valid download directory.  This must be set as 
#' `options(prism.path = "YOURPATH")`.
#' 
#' @examples \dontrun{
#' ### Get all the data for January from 1990 to 2000
#' get_prism_annual(type="tmean", year = 1990:2000, keepZip=FALSE)
#' }
#' 
#' @importFrom utils download.file setTxtProgressBar txtProgressBar unzip
#' 
#' @export
get_prism_annual <- function(type, years = NULL ,keepZip = TRUE){
  ### parameter and error handling
  
  path_check()
  type <- match.arg(type, prism_vars())

  
    ### Check year
    if(!is.numeric(years)){
      stop("You must enter a numeric year from 1895 onwards.")
    }
    
    if(any(years < 1895)){
      stop("You must enter a year from 1895 onwards.")
    }
    
  
  pre_1981 <- years[years<1981]
  post_1981 <- years[years >= 1981]
  uris_pre81 <- vector()
  uris_post81 <- vector()
  
  if(length(pre_1981)){
    uris_pre81 <- sapply(pre_1981,function(x){paste("http://services.nacse.org/prism/data/public/4km",type,x,sep="/")})
  }
  
  if(length(post_1981)){  
    uris_post81 <- sapply(post_1981,function(x){paste("http://services.nacse.org/prism/data/public/4km",type,x,sep="/")})
  }
  
  
  download_pb <- txtProgressBar(min = 0, max = length(uris_post81) + length(uris_pre81) , style = 3)
  
  counter <- 0
  
  ### Handle post 1980 data
  if(length(uris_post81) > 0){    
    
    for(i in 1:length(uris_post81)){
      prism_webservice(uris_post81[i],keepZip)
      setTxtProgressBar(download_pb, i)
      
    }
    
  }
  
  
  counter <- length(uris_post81)+1
  
  
  ### Handle pre 1981 files
  if(length(uris_pre81) > 0){
    
    pre_files <-vector() 
    for(j in 1:length(uris_pre81)){
      pre_files[j] <- prism_webservice(uris_pre81[j],keepZip,returnName = T)
      setTxtProgressBar(download_pb, counter) 
      counter <- counter + 1
    }
    
    ### Process pre 1981 files
    
    pre_files <- unlist(strsplit(pre_files,"\\."))
    pre_files <- pre_files[seq(1,length(pre_files),by =2)]
    
    for(k in 1:length(pre_files)){
      to_split <-gsub(pattern = "_all",replacement = "",x = pre_files[k])
      process_zip(pre_files[k], to_split)
      
    }
    
  }
  
    close(download_pb)
  
}
