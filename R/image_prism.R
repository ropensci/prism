#' Quick image plot
#' @description Quickly make an image plot of a data set.  
#' @param f the name of a file to be plotted, this is most easily gotten through ls_prism_data()
#' @param col the color pattern to use.  The default is heat, the other valid option is "redblue"
#' @details This is meant for rapid vizualization, but more detailed plots will require other methods
#' @examples \dontrun{
#' image_prism(ls_prism_data()[1])
#' }
#' @export

prism_image <- function(prismfile, col = "heat"){
  if(length(prismfile) != 1){
    stop("You can only quick image one at a time")
  }
  prismfile <- paste(options("prism.path")[[1]],"/",prismfile,"/",prismfile,".bil",sep="")
  pname <- paste0(strsplit(prismfile,"_")[[1]][2:6],collapse = "_")
  
  col = match.arg(col,c("heat","redblue"))
  prism_cols <- 1405
  prism_rows <- 621
  prism_data <- readGDAL(prismfile,silent = TRUE)
  prism_image <- prism_data@data$band1
  prism_image <- prism_image[length(prism_image):1]
  prism_image <- matrix(prism_image, nrow = prism_rows, ncol = prism_cols,byrow=T)
  prism_image <- t(prism_image)
  prism_image <- prism_image[dim(prism_image)[1]:1,]
  if(col == "heat"){
    image(prism_image,main = pname )
  } else {
    tc <- colorRampPalette(c("blue","red"),space="rgb")
    image(prism_image,col=tc(12),main=pname)
  }
}