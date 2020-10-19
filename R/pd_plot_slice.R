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
#' @param pd,prismfile a vector of output from [prism_archive_ls()] or 
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
  
  meta_d <- pd_get_date(pd)
  meta_names <- pd_get_name(pd)[1]
  param_name <- strsplit(meta_names,"-")[[1]][3]

  pstack <- pd_stack(pd)
  data <- unlist(
    raster::extract(pstack, matrix(location, nrow = 1), buffer = 10)
  )
  data <- as.data.frame(data)
  data$date <- as.Date(meta_d)
  
  ## Re order
  data <- data[order(data$date),]
  
  # get units for plot
  if(ptype %in% c("tmin", "tmax", "tmean")) {
    u <- "(C)"
  } else if(ptype %in% c("tdmean", "vpdmax", "vpdmin")) {
    u <- "hPA"
  } else {
    # must be ppt
    u <- "(mm)"
  }
    
  out <- ggplot(data,aes(x=date,y=data)) +
    geom_path() +
    geom_point() +
    xlab("Date") + 
    ylab(paste(param_name,u,sep=" "))
  
  return(out)
}

#' @description `prism_slice()` is the deprecated version of `pd_plot_slice()`.
#' @export
#' @rdname pd_plot_slice
prism_slice <- function(location, prismfile) {
  .Deprecated(msg = paste0(
    "prism_slice() is deprecated.\n",
    "Use `pd_plot_slice()` instead.\n",
    "Note the order of paramters changed."
  ))
  
  pd_plot_slice(prismfile, location)
}
