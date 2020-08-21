#' Get name or date from downloaded prism data
#' 
#' `prism_data_get_name()` extracts a long, human readable name from the prism
#' folders or .bil files.
#' 
#' @param f 1 or more prism directories name or .bil files. 
#' 
#' @return Character vector of names/dates.
#' 
#' @export
#' @rdname prism_data_get
prism_data_get_name <- function(f) {
  p <- strsplit(f, "_")
  unlist(lapply(p, pr_parse, returnDate = FALSE))
}

#' @description 
#' `prism_data_get_date()` extracts the date from the prism folders or .bil 
#' files. Date is returned in yyyy-mm-dd format. For monthly data, dd is 01 and
#' for annual data mm is also 01. For normals, an empty character is returned.
#' 
#' @export
#' @rdname prism_data_get
prism_data_get_date <- function(f) {
  p <- strsplit(f, "_")
  unlist(lapply(p, pr_parse, returnDate = TRUE))
}

#' @description 
#' `prism_md()` is a deprecated function that has been replaced with 
#' `prism_data_get_name()` and `prism_data_get_date()`
#' 
#' @param returnDate TRUE or FALSE. If TRUE, an ISO date is returned.  By 
#'   default years will come back with YYYY-01-01 and months as YYYY-MM-01
#'   
#' @export
#' @rdname prism_data_get
prism_md <- function(f, returnDate = FALSE) {
  if (returnDate) {
    msg <- "`prism_data_get_name()`"
  } else {
    msg <- "`prism_data_get_date()`"
  }
  
  .Deprecated(msg)
  
  p <- strsplit(f,"_")
  unlist(lapply(p,pr_parse,returnDate = returnDate))
}

#' name parse
#' @description parse the directory name into relevant metadata (name or date)
#' 
#' @param p a prism file directory or bil file
#' 
#' @param returnDate TRUE or FALSE. If TRUE, an ISO date is returned. By default 
#'   years will come back with YYYY-01-01 and months as YYYY-MM-01
#'   
#' @return a properly parsed string of human readable names
#' @noRd

pr_parse <- function(p,returnDate = FALSE){
  ## Extract the climate variable
  type <- p[2]
  ## Extract the date the data is for
  normals <- FALSE
  
  if(grepl("normal",paste(p,collapse=""))){
    if(grepl("annual",paste(p,collapse=""))){mon <- "Annual"
      } else {
        mon <- month.abb[as.numeric(p[length(p)-1])]
      }
    ds <- paste(mon,"30-year normals",sep=" ")
    normals <- TRUE
    } else {
   
  
    d <- p[length(p)-1]
    yr <- substr(d,1,4)
    mon <- substr(d,5,6)
    day <- substr(d,7,8)
    ## Get resolution
    ### Create date string
    ifelse(
      !is.na(month.abb[as.numeric(mon)]),
      ds <- paste(month.abb[as.numeric(mon)],day,yr,sep=" "),
      ds <- paste(yr,sep=" ")
    )
    }
  
  ures <- ifelse(
    grepl("4km",paste(p,collapse="")),
    "4km resolution",
    "800m resolution"
  )
  
  type <- prism_var_names()[type]

  md_string <- paste(ds,ures,type,sep = " - ")
  if(!returnDate){
    out <- md_string
  } else {
    if (normals) {
      out <- ""
    } else {
      out <- paste(yr,ifelse(nchar(mon) > 0,mon,"01"),ifelse(nchar(day) > 0,day,"01"),sep="-")
    }
  }
  
  out
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

