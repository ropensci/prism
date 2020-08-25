#' Quick spatial image of prism data
#' 
#' `prism_image()` makes a spatial image plot of the specified prism 
#' data (single variable and time step.). It is meant for rapid visualization, 
#' but more detailed plots will require other methods.
#'  
#' @param prismfile the name of a single file to be plotted, this is most easily 
#'   gotten through [prism_archive_ls()] or [prism_archive_subset()]. It should be the
#'   folder name, not the .bil file.
#'   
#' @param col the color pattern to use.  The default is heat, the other valid 
#'   option is "redblue".
#'   
#' @return Invisibly returns `gg` object of the image. 
#' 
#' @seealso [prism_archive_ls()], [prism_archive_subset()], [ggplot2::geom_raster()]
#' 
#' @examples \dontrun{
#' get_prism_dailys(
#'   type = "tmean", 
#'   minDate = "2013-06-01", 
#'   maxDate = "2013-06-14", 
#'   keepZip = FALSE
#' )
#' 
#' # get June 5th 
#' pd <- prism_archive_subset("tmean", "daily", dates = "2013-06-05")
#' 
#' # and plot it
#' prism_image(pd)
#' }
#' 
#' @import ggplot2
#' 
#' @export

prism_image <- function(prismfile, col = "heat"){
  
  if(length(prismfile) != 1){
    stop("You can only quick image one file at a time.")
  }
  col = match.arg(col, c("heat", "redblue"))
  
  ### This works for recent data but a new file needs to be created for 
  pname <- pd_get_name(prismfile)
  
  prismfile <- normalizePath(
    file.path(
      prism_get_dl_dir(), 
      prismfile, 
      paste0(prismfile,".bil")
    ), 
    mustWork = TRUE
  )
  
  out <- raster(prismfile)
  out <- data.frame(raster::rasterToPoints(out))
  colnames(out) <- c("x","y","data")
  
  prPlot <- ggplot() + 
    geom_raster(data = out, aes_string(x='x',y='y',fill='data')) +
    theme_bw() +
    
    xlab("Longitude") + 
    ylab("Latitude") + 
    ggtitle(pname)  
  
  
  if(col == "heat"){
    prPlot <- prPlot + scale_fill_gradient(low = "yellow", high="red")
  } else {
    prPlot <- prPlot + scale_fill_gradient(low = "red", high="blue")   
  }
  
  print(prPlot)
  invisible(prPlot)
}
