
prism_slice <- function(location,prismfile){

  prismfilexml <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".xml",sep="")
  prismfilerast <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".bil",sep="")
  
  dates <- sapply(prismfilexml,md_date)
  pstack <- prism_stack(ls_prism_data())
  data <- unlist(extract(pstack,matrix(location,nrow=1),buffer=10))
  data <- as.data.frame(data)
  data$date <- as.POSIXct(dates,format="%Y%m%d")
  ggplot(data,aes(x=date,y=data))+geom_path()+geom_point()
  
  
md_date <- function(f){
  m <- xmlParse(f)
  m <- xmlToList(m)
  out <- m$idinfo$timeperd$timeinfo$rngdates$begdate
  return(out)
}