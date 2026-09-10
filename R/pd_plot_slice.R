#' Plot a slice of a raster stack
#' 
#' `pd_plot_slice()` plots a slice of data at a single point location from the
#' specified prism data.
#' 
#' @details 
#' The user should ensure the prism data comes from a continuous data 
#' set and is made up of the same temporal period. Otherwise the plot will look 
#' erratic and incorrect.
#' 
#' @param location a vector of a single location in the form of long,lat
#' 
#' @param pd a vector of output from [prism_archive_ls()] or 
#'   [prism_archive_subset()] giving a list of prism files to extract data from 
#'   and plot. The latter is preferred as it will help ensure the prism data 
#'   are from the same variable and temporal period.
#'   
#' @return A `gg` object of the plot for the requested `location`.
#' 
#' @examples \dontrun{
#' ### Assumes you have a clean prism directory
#' get_prism_dailys(
#'   type="tmean", 
#'   minDate = "2013-06-01", 
#'   maxDate = "2013-06-14",
#'   keepZip = FALSE
#' )
#' p <- pd_plot_slice(
#'   prism_archive_subset("tmean", "daily", year = 2020), 
#'   c(-73.2119,44.4758)
#' )
#' print(p)
#' }
#' 
#' @export
pd_plot_slice <- function(pd, location) {
  
  if(!is.null(dim(pd))){
    stop("You must enter a vector of prism data, not a data frame.\n", 
         "Try  prism_archive_subset().")
  }
  
  if (length(location) != 2 || !is.numeric(location)) {
    stop("`location` should be a numeric vector with length=2.")
  }
  
  ptype <- unique(pd_get_type(pd))
  if (length(ptype) != 1) {
    stop(
      "`pd` includes multiple variables (", ptype, ").\n",
      "Please ensure that only one variable type is provided to `pd_slice()`."
    )
  }
  
  time_step <- unique(pd_get_time_step(pd))
  
  if (length(time_step) != 1L) {
    stop(
      "`pd` must contain a single time step for plotting.",
      call. = FALSE
    )
  }
  
  meta_d <- pd_get_date(pd, complete = FALSE)
  meta_names <- pd_get_name(pd)[1]
  param_name <- strsplit(meta_names,"-")[[1]][3]

  pstack <- pd_stack(pd)
  pt <- terra::vect(matrix(location, nrow = 1), crs = terra::crs(pstack[[1]]))
  pt_buf <- terra::buffer(pt, width = 10)
  
  data <- terra::extract(pstack, pt_buf, fun = mean)
  
  data <- as.data.frame(t(unlist(data)))
  data <- data[, -1, drop = FALSE]
  data <- utils::stack(data)
  colnames(data) <- c("data", "layer")
  data$date <- fully_specifiy_dates(meta_d)
  
  ## Re order
  data <- data[order(data$date),]
  
  # units
  u <- get_units(ptype, param_name)
  
  date_scale <- switch(
    time_step,
    
    daily = ggplot2::scale_x_date(
      date_breaks = "1 month",
      date_labels = "%b %d\n%Y"
    ),
    
    monthly = ggplot2::scale_x_date(
      date_breaks = "3 months",
      date_labels = "%b\n%Y"
    ),
    
    annual = ggplot2::scale_x_date(
      date_breaks = "1 year",
      date_labels = "%Y"
    ),
    
    stop(
      "Unsupported PRISM time step for plotting: `",
      time_step,
      "`.",
      call. = FALSE
    )
  )
    
  out <- ggplot(data,aes(x=date,y=data)) +
    geom_path() +
    geom_point() +
    xlab("Date") + 
    ylab(u) +
    date_scale
  
  return(out)
}

fully_specifiy_dates <- function(x) {
  n <- nchar(x)
  
  if (any(!n %in% c(4L, 7L, 10L))) {
    bad <- unique(x[!n %in% c(4L, 7L, 10L)])
    
    stop(
      "`x` must contain YYYY, YYYY-MM, or YYYY-MM-DD values. ",
      "Invalid value(s): ",
      paste(bad, collapse = ", "),
      call. = FALSE
    )
  }
  
  x[n == 4L] <- paste0(x[n == 4L], "-01-01")
  x[n == 7L] <- paste0(x[n == 7L], "-01")
  
  as.Date(x)
}

get_units <- function(type, pre_txt = NULL) {
  # get units for plot
  if(type %in% c("tmin", "tmax", "tmean")) {
    if (!is.null(pre_txt)) {
      u <- bquote(.(pre_txt) ~ (degree*C))
    } else {
      u <- expression(degree*C)
    }
  } else if(type %in% c("tdmean", "vpdmax", "vpdmin")) {
    if (!is.null(pre_txt)) {
      u <- paste(pre_txt, "(hPA)")
    } else {
      u <- "hPA"
    }
  } else {
    # must be ppt
    if (!is.null(pre_txt)) {
      u <- paste(pre_txt, "(mm)")
    } else {
      u <- "mm"
    }
  }
  
  u
}
