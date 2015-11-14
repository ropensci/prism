#' Download data for 30 year normals of climate variables
#' @description Download data from the prism project for 30 year normals at 4km or 800m grid cell resolution for precipitation, mean, min and max temperature
#' @inheritParams get_prism_dailys
#' @param resolution The spatial resolution of the data, must be either "4km" or "800m".
#' @param mon a numeric value for month, can be a numeric vector of months.
#' @param annual if TRUE download annual data
#' @param keepZip if TRUE, leave the downloaded zip files in your 'prism.path', if FALSE, they will be deleted
#' @details You must make sure that you have set up a valid download directory.  This must be set as options(prism.path = "YOURPATH")
#' @examples \dontrun{
#' ### Get 30 year normal values for rainfall
#' get_prism_normals(type="ppt",resolution = "4km",mon = 1, keepZip=FALSE)
#' 
#' }
#' @export
get_prism_normals <- function(type, resolution, mon =  NULL , annual =  FALSE,  keepZip = TRUE){
  ### parameter and error handling
  path_check()
  type <- match.arg(type, c("ppt","tmean","tmin","tmax","tdmean","vpdmax","vpdmin"))
  resolution<- match.arg(resolution, c("4km","800m"))
  

  
  if(!is.null(mon)){
    if(any(mon < 1 | mon > 12)) {
      stop("You must enter a month between 1 and 12")
    }
    mon <- mon_to_string(mon)
    match_list <- mon
  } else if(annual){
    match_list <- "annual"
    mon <- "14"
  }
  
  uris <- sapply(mon,function(x){paste("http://services.nacse.org/prism/data/public/normals",resolution,type,x,sep="/")})
  

  mpb <- txtProgressBar(min = 0, max =length(uris), style = 3)
 
  for(i in 1:length(uris)){
    prism_webservice(uris[i],keepZip)
    setTxtProgressBar(mpb, i)
    
  }
  
  
  close(mpb)
  
  
}
