#' Process pre 1980 files
#' @description Files that come prior to 1980 come in one huge zip.  This will cause them to mimic all post 1980 downloads
#' @param file the name of the file, should include "all", that is unzipped
#' @param name a vector of names of files that you want to save.
#' @details This should match all other files post 1980
#' @export

process_zip <- function(file,name){
  tmpwd <- list.files(paste(options("prism.path")[[1]],file,sep="/"))
  ##Remove all.xml file
  file.remove(paste(options("prism.path")[[1]],file,grep("all",tmpwd,value = T),sep="/"))
  ## Get new list of files after removing all.xml
  tmpwd <- list.files(paste(options("prism.path")[[1]],file,sep="/"))

  fstrip <- strsplit(tmpwd,"\\.")
  fstrip <- unlist(lapply(fstrip,function(x) return(x[1])))
  unames <- unique(fstrip)
  unames <- unames[unames%in%name]
  for(j in 1:length(unames)){
    newdir <- paste(options("prism.path")[[1]],unames[j],sep="/")
    dir.create(newdir)
    f2copy <- grep(unames[j],tmpwd,value=T)
    sapply(f2copy,function(x){file.copy(from = paste(options("prism.path")[[1]],to_proc[i],x,sep="/"),to = paste(newdir,x,sep="/")) })
    sapply(f2copy,function(x){file.remove(paste(options("prism.path")[[1]],to_proc[i],x,sep="/")) })
    ### We lose all our metadata, so we need to rewrite it

  }
  ### Remove all files so the directory can be created.
  ## Update file list
  tmpwd <- list.files(paste(options("prism.path")[[1]],file,sep="/"))
  ## Now loop delete them all
  sapply(tmpwd,function(x){
    file.remove(paste(options("prism.path")[[1]],file,x,sep="/"))
  })


  file.remove(paste(options("prism.path")[[1]],to_proc[i],sep="/"),recursive = T)


}
