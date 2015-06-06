#' Process pre 1980 files
#' @description Files that come prior to 1980 come in one huge zip.  This will cause them to mimic all post 1980 downloads
#' @param pfile the name of the file, should include "all", that is unzipped
#' @param name a vector of names of files that you want to save.
#' @details This should match all other files post 1980
#' @example /dontrun {
#' process_zip("PRISM_tmean_stable_4kmM2_1980_all_bil","PRISM_tmean_stable_4kmM2_198001_bil")
#' process_zip("PRISM_tmean_stable_4kmM2_1980_all_bil",c("PRISM_tmean_stable_4kmM2_198001_bil","PRISM_tmean_stable_4kmM2_198002_bil"))
#' }
#' @export

process_zip <- function(pfile,name){
  stop("Fix errors in process_zip")
  tmpwd <- list.files(paste(options("prism.path")[[1]],pfile,sep="/"))
  ##Remove all.xml file
  file.remove(paste(options("prism.path")[[1]],file,grep("all",tmpwd,value = T),sep="/"))
  ## Get new list of files after removing all.xml
  tmpwd <- list.files(paste(options("prism.path")[[1]],pfile,sep="/"))

  fstrip <- strsplit(tmpwd,"\\.")
  fstrip <- unlist(lapply(fstrip,function(x) return(x[1])))
  unames <- unique(fstrip)
  unames <- unames[unames%in%name]
  for(j in 1:length(unames)){
    newdir <- paste(options("prism.path")[[1]],unames[j],sep="/")
    dir.create(newdir)
    f2copy <- grep(unames[j],tmpwd,value=T)
    sapply(f2copy,function(x){file.copy(from = paste(options("prism.path")[[1]],pfile,x,sep="/"),to = paste(newdir,x,sep="/")) })
    sapply(f2copy,function(x){file.remove(paste(options("prism.path")[[1]],pfile,x,sep="/")) })
    
    
    ### We lose all our metadata, so we need to rewrite it

  }
  ### Remove all files so the directory can be created.
  ## Update file list
  tmpwd <- list.files(paste(options("prism.path")[[1]],pfile,sep="/"))
  ## Now loop delete them all
  sapply(tmpwd,function(x){
    file.remove(paste(options("prism.path")[[1]],pfile,x,sep="/"))
  })


  file.remove(paste(options("prism.path")[[1]],pfile,sep="/"),recursive = T)


}

