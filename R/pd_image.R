#' Quick spatial image of prism data
#'
#' `pd_image()` makes a spatial image plot of the specified prism
#' data (single variable and time step.). It is meant for rapid visualization,
#' but more detailed plots will require other methods.
#'
#' @param pd the name of a single file to be plotted, this is most 
#'   easily found through [prism_archive_ls()] or [prism_archive_subset()].
#'
#' @param col the color pattern to use.  The default is heat, the other valid
#'   option is "redblue".
#'   
#' @param draw Logical. Should the plot be drawn to the active graphics
#'   device? Defaults to `TRUE`.
#'
#' @return Invisibly returns `gg` object of the image.
#'
#' @seealso [prism_archive_ls()], [prism_archive_subset()],
#' [ggplot2::geom_raster()]
#'
#' @examples
#' \dontrun{
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
#' pd_image(pd)
#' 
#' # or don't draw to active graphics device
#' p <- pd_image(pd, draw = FALSE)
#' }
#'
#' @import ggplot2
#'
#' @export

pd_image <- function(pd, col = "heat", draw = TRUE) {
  
  if (length(pd) > 1) {
    stop("You can only quick image one file at a time.")
  }
  
  if (length(pd) == 0) {
    stop("Provided `pd` has a length of 0 (should be 1).")
  }
  
  col <- match.arg(col, c("heat", "redblue"))
  
  if (length(draw) > 1 | is.null(draw) | !is.logical(draw)) {
    stop("`draw` should be a single, non-null logical.")
  }

  pname <- pd_get_name(pd)
  ptype <- pd_get_type(pd)

  stop_file <- function(x) {
    stop(paste0(pd, " was not found in prism archive."))
  }
  
  prismfile <- tryCatch(
    pd_to_file(pd),
    error = stop_file,
    warning = stop_file
  )

  out <- terra::rast(prismfile)
  out <- as.data.frame(out, xy=TRUE)
  colnames(out) <- c("x", "y", "data")
  
  u <- get_units(ptype)
  
  prPlot <- ggplot() +
    geom_raster(
      data = out, 
      aes(x = .data[["x"]], y = .data[["y"]], fill = .data[["data"]])
    ) +
    theme_bw() +
    labs(
      title = pname,
      x = "Longitude", y = "Latitude",
      fill = u
    )


  if (col == "heat") {
    prPlot <- prPlot + scale_fill_gradient(low = "yellow", high = "red")
  } else {
    prPlot <- prPlot + scale_fill_gradient(low = "red", high = "blue")
  }

  if (draw) {
    print(prPlot)
  }
  
  invisible(prPlot)
}
