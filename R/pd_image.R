#' Quick spatial image of prism data
#'
#' `pd_image()` makes a spatial image plot of the specified prism
#' data (single variable and time step.). It is meant for rapid visualization,
#' but more detailed plots will require other methods.
#'
#' @param pd,prismfile the name of a single file to be plotted, this is most 
#'   easily found through [prism_archive_ls()] or [prism_archive_subset()].
#'
#' @param col the color pattern to use.  The default is heat, the other valid
#'   option is "redblue".
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
#' }
#'
#' @import ggplot2
#'
#' @export

pd_image <- function(pd, col = "heat") {
  
  if (length(pd) != 1) {
    stop("You can only quick image one file at a time.")
  }
  col <- match.arg(col, c("heat", "redblue"))

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

  out <- raster(prismfile)
  out <- data.frame(raster::rasterToPoints(out))
  colnames(out) <- c("x", "y", "data")
  
  u <- get_units(ptype)
  
  prPlot <- ggplot() +
    geom_raster(data = out, aes_string(x = "x", y = "y", fill = "data")) +
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

  print(prPlot)
  invisible(prPlot)
}

#' @description `prism_image()` is the deprecated version of `pd_image()`.
#' @export
#' @rdname pd_image
prism_image <- function(prismfile, col = "heat") {
  .Deprecated("`pd_image()`")

  invisible(pd_image(prismfile, col = col))
}
