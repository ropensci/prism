#' Quick image plot
#' @description Quickly make an image plot of a data set.  
#' @param prismfile the name of a file to be plotted, this is most easily gotten through ls_prism_data()
#' @param col the color pattern to use.  The default is heat, the other valid option is "redblue"
#' @details This is meant for rapid vizualization, but more detailed plots will require other methods
#' @examples \dontrun{
#' get_prism_dailys(type="tmean", minDate = "2013-06-01", maxDate = "2013-06-14", keepZip=F)
#' prism_image(ls_prism_data()[1])
#' }
#' @import ggplot2
#' @export

prism_image <- function(prismfile, col = "heat"){
  
  ### This works for recent data but a new file needs to be created for 
  pname <- unlist(prism_md(prismfile))
  
  if(length(prismfile) != 1){
    stop("You can only quick image one at a time")
  }
  prismfile <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".bil",sep="")  
  col = match.arg(col,c("heat","redblue"))
  out <- raster(prismfile)
  out <- data.frame(rasterToPoints(out))
  colnames(out) <- c("x","y","data")
    
  if(col == "heat"){
    prPlot <- ggplot() + geom_raster(data = out, aes(x=x,y=y,fill=data))+theme_bw()+scale_fill_gradient(low = "yellow", high="red") + xlab("Longitude") + ylab("Latitude")+ggtitle(pname)  
    print(prPlot)
  } else {
    prPlot <- ggplot() + geom_raster(data = out, aes(x=x,y=y,fill=data))+theme_bw()+scale_fill_gradient(low = "red", high="blue") + xlab("Longitude") + ylab("Latitude")+ggtitle(pname)  
    print(prPlot)
  }
}