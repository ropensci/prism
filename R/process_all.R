#' Process all.zip files
#' @description Files that come in as all need to be turned into their own directories in prismtmp
#' @export

process_all <- function(){
  files <- list.files(options("prism.path")[[1]])
  to_proc <- files[grepl("all",files)]
  ## Strip zip files
  to_proc <- to_proc[!grepl("zip",to_proc)]
  for(i in 1:length(to_proc)){
    tmpwd <- list.files(paste(options("prism.path")[[1]],to_proc[i],sep="/"))
    ##Remove all.xml file
    file.remove(paste(options("prism.path")[[1]],to_proc[i],grep("all",tmpwd,value = T),sep="/"))
    ## Get new list of files after removing all.xml
    tmpwd <- list.files(paste(options("prism.path")[[1]],to_proc[i],sep="/"))
    
    fstrip <- strsplit(tmpwd,"\\.")
    fstrip <- unlist(lapply(fstrip,function(x) return(x[1])))
    unames <- unique(fstrip)
    for(j in 1:length(unames)){
      newdir <- paste(options("prism.path")[[1]],unames[j],sep="/")
      dir.create(newdir)
      f2copy <- grep(unames[j],tmpwd,value=T)
      sapply(f2copy,function(x){file.copy(from = paste(options("prism.path")[[1]],to_proc[i],x,sep="/"),to = paste(newdir,x,sep="/")) })
      sapply(f2copy,function(x){file.remove(paste(options("prism.path")[[1]],to_proc[i],x,sep="/")) })
      ### We lose all our metadata, so we need to rewrite it
      
    }
    file.remove(paste(options("prism.path")[[1]],to_proc[i],sep="/"),recursive = T)
  }
  
  
}
