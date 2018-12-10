#' Extract select prism metadata
#' 
#' @description used to extract some prism metadata used in other functions
#' 
#' @param f a simple directory name
#' 
#' @param returnDate TRUE or FALSE. If TRUE, an ISO date is returned.  By 
#'   default years will come back with YYYY-01-01 and months as YYYY-MM-01
#'   
#' @return a character vector of metadata.
#' 
#' @export
prism_md <- function(f,returnDate = FALSE){
  p <- strsplit(f,"_")
  return(lapply(p,pr_parse,returnDate = returnDate))
}

#' name parse
#' @description parse the directory name into relevant metadata
#' 
#' @param p a prism file directory
#' 
#' @param returnDate TRUE or FALSE. If TRUE, an ISO date is returned. By default 
#'   years will come back with YYYY-01-01 and months as YYYY-MM-01
#'   
#' @return a properly parsed string of human readable names
#' 
#' @export

pr_parse <- function(p,returnDate = FALSE){
  ## Extract the climate variable
  type <- p[2]
  ## Extract the date the data is for
  
  if(grepl("normal",paste(p,collapse=""))){
    if(grepl("annual",paste(p,collapse=""))){mon <- "Annual"
      } else {
        mon <- month.abb[as.numeric(p[length(p)-1])]
      }
    ds <- paste(mon,"30-year normals",sep=" ")
    
    } else {
   
  
    d <- p[length(p)-1]
    yr <- substr(d,1,4)
    mon <- substr(d,5,6)
    day <- substr(d,7,8)
    ## Get resolution
    ### Create date string
    ifelse(!is.na(month.abb[as.numeric(mon)]) ,ds <- paste(month.abb[as.numeric(mon)],day,yr,sep=" "),ds <- paste(yr,sep=" "))
    
    
  }
  ures <- ifelse(grepl("4km",paste(p,collapse="")),"4km resolution","800m resolution")
  
  if(type == "tmin"){
    type <- "Minimum temperature"
    } else if(type=="tmax"){
      type <- "Maximum temperature"
    } else if(type == "tmean"){
      type <- "Mean temperature"
    } else if(type == "ppt"){
      type <- "Precipitation"
    }

  md_string <- paste(ds,ures,type,sep = " - ")
  if(!returnDate){
    return(md_string)
  } else {
    return(paste(yr,ifelse(nchar(mon) > 0,mon,"01"),ifelse(nchar(day) > 0,day,"01"),sep="-"))
  }
  
}

#' Extract select prism metadata
#' 
#' used to extract some prism metadata used in other functions
#' 
#' @param f a location of xml metadata.
#' 
#' @return a character vector of metadata.
#' 
#' @details Archived function, was really useful, but non-standarded metadata 
#' across files prevents this from being a useable solution atm
#' 

#prism_md <- function(f){
#  m <- xmlParse(f)
#  m <- xmlToList(m)
#  date <- m$idinfo$timeperd$timeinfo$rngdates$begdate
#  prod_title <- m$idinfo$citation$citeinfo$title 
#  prod_name <- strsplit(m$eainfo$detailed$attr$attrlabl,'\\(')[[1]][1]
#  return(c(date,prod_title,prod_name))
#}

