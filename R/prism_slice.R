#' Plot a slice of a raster stack
#' @description This function will plot a slice of data at a single point location from a list of prism files 
#' @param location a vector of a single location in the form of long,lat
#' @param prismfile a vector of output from ls_prism_data() giving a list of prism files to extract data from and plot
#' @return a ggplot2 plot of the requested slice
#' @details the list of prism files should be from a continuous data set. Otherwise the plot will look erratic and incorrect.
#' @examples \dontrun{
#' ### Assumes you have a clean prism directory
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)
#' p <- prism_slice(c(-73.2119,44.4758),ls_prism_data())
#' print(p)
#' }
#' @import raster ggplot2 XML
#' @export


prism_slice <- function(location,prismfile){

  prismfilexml <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".xml",sep="")
  prismfilerast <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".bil",sep="")
  
  meta_d <- sapply(prismfilexml,prism_md,simplify=F)
  pstack <- prism_stack(prismfile)
  data <- unlist(extract(pstack,matrix(location,nrow=1),buffer=10))
  data <- as.data.frame(data)
  data$date <- unlist(lapply(meta_d,function(x){return(x[1])}))
  data$date <- as.POSIXct(data$date,format="%Y%m%d")
  ## Re order
  data <- data[order(data$date),]
  ifelse(grepl("temp",meta_d[[1]][3]),u <- "(C)", u <- "(mm)")
  
  
  out <- ggplot(data,aes(x=date,y=data))+geom_path()+geom_point()+xlab("Date") + ylab(paste(meta_d[[1]][3],u,sep=""))
  
  return(out)
}

#' Extract select prism metadat
#' @description used to extract some prism metadata used in other fxns
#' @export

prism_md <- function(f){
  m <- xmlParse(f)
  m <- xmlToList(m)
  date <- m$idinfo$timeperd$timeinfo$rngdates$begdate
  prod_title <- m$idinfo$citation$citeinfo$title 
  prod_name <- strsplit(m$eainfo$detailed$attr$attrlabl,'\\(')[[1]][1]
  return(c(date,prod_title,prod_name))
}
