#' Download monthly prism data
#' 
#' Download monthly data from the prism project at 4km grid cell resolution for 
#' precipitation, mean, min, and max temperature
#' 
#' @inheritParams get_prism_annual
#' 
#' @param mon a valid numeric month, or vector of months.
#' 
#' @details Data is available from 1891 until 2014, however you have to download 
#' all data for years prior to 1981.  
#' Therefore if you enter a vector of years that bounds 1981, 
#' you will automatically download all data for all years in the vector.  
#' If the "all" parameter is set to TRUE, it will override any mon 
#' entered and download all data. Data will be downloaded for all mon 
#' in all the years in the vectors supplied. You must make sure 
#' that you have set up a valid download directory.  
#' This must be set as options(prism.path = "YOURPATH")
#' 
#' @examples \dontrun{
#' ### Get all the data for January from 1990 to 2000
#' get_prism_monthlys(type="tmean", years = 1990:2000, mon = 1, keepZip=FALSE)
#' }
#' 
#' @export
get_prism_monthlys <- function(type, years = NULL, mon = NULL, keepZip = TRUE,
                               keep_pre81_months = TRUE)
{
  ### parameter and error handling

  path_check()
  type <- match.arg(type, prism_vars())
 
  ### Check mon
  if(!is.numeric(mon)) {
    stop("You must enter a numeric month between 1 and 12")
  }
  
  if(any(mon < 1 | mon > 12)) {
    stop("You must enter a month between 1 and 12")
  }
  
  ### Check year
  if(!is.numeric(years)){
    stop("You must enter a numeric year from 1895 onwards.")
  }
  
  if(any(years < 1895)){
    stop("You must enter a year from 1895 onwards.")
  }
  
  pre_1981 <- years[years<1981]
  post_1981 <- years[years>=1981]
  uris_pre81 <- vector()
  uris_post81 <- vector()
  
  if (length(pre_1981)) {
    uris_pre81 <- sapply(
      pre_1981,
      function(x) {
        paste(
          "http://services.nacse.org/prism/data/public/4km", type, x, sep = "/"
        )
      }
    )
  }

  if (length(post_1981)) {  
    uri_dates_post81 <- apply(
      expand.grid(post_1981,mon_to_string(mon)), 
      1, 
      function(x) {paste(x[1], x[2], sep="")}
    )
    
    uris_post81 <- sapply(
      uri_dates_post81,
      function(x) {
        paste(
          "http://services.nacse.org/prism/data/public/4km",type,x,sep="/"
        )
      }
    )
  }
    
  download_pb <- txtProgressBar(
    min = 0, 
    max = length(uris_post81) + length(uris_pre81), 
    style = 3
  )
 
  counter <- 0

  ### Handle post 1981 data
  if(length(uris_post81) > 0){    
  
      for(i in 1:length(uris_post81)){
      prism_webservice(uris_post81[i],keepZip)
      setTxtProgressBar(download_pb, i)
      
    }
  }
    
  counter <- length(uris_post81)+1
   
  ### Handle pre 1981 files
  if (length(uris_pre81) > 0) {
  
    pre_files <-vector() 
    for (j in 1:length(uris_pre81)) {
      pre_files[j] <- prism_webservice(uris_pre81[j], keepZip, returnName = TRUE)
      setTxtProgressBar(download_pb, counter) 
      counter <- counter + 1
    }
   
    ### Process pre 1981 files
    pre_files <- unlist(strsplit(pre_files,"\\."))
    pre_files <- pre_files[seq(1,length(pre_files),by =2)]
    
    for (k in 1:length(pre_files)) {
      yr <- regmatches(pre_files[k],regexpr('[0-9]{4}',pre_files[k]))
      
      if (keep_pre81_months) {
        monstr <- c(mon_to_string(1:12), "")
      } else {
        monstr <- mon_to_string(mon)
      }
      
      to_split <-   sapply(monstr, function(x) {
        gsub(pattern = "_all", replacement = x, x = pre_files[k])
      })
      
      process_zip(pre_files[k], to_split)
    }
  }

  close(download_pb)
}
