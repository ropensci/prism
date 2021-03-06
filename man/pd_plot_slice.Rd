% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pd_plot_slice.R
\name{pd_plot_slice}
\alias{pd_plot_slice}
\alias{prism_slice}
\title{Plot a slice of a raster stack}
\usage{
pd_plot_slice(pd, location)

prism_slice(location, prismfile)
}
\arguments{
\item{pd, prismfile}{a vector of output from \code{\link[=prism_archive_ls]{prism_archive_ls()}} or
\code{\link[=prism_archive_subset]{prism_archive_subset()}} giving a list of prism files to extract data from
and plot. The latter is preferred as it will help ensure the prism data
are from the same variable and temporal period.}

\item{location}{a vector of a single location in the form of long,lat}
}
\value{
A \code{gg} object of the plot for the requested \code{location}.
}
\description{
\code{pd_plot_slice()} plots a slice of data at a single point location from the
specified prism data.

\code{prism_slice()} is the deprecated version of \code{pd_plot_slice()}.
}
\details{
The user should ensure the prism data comes from a continuous data
set and is made up of the same temporal period. Otherwise the plot will look
erratic and incorrect.
}
\examples{
\dontrun{
### Assumes you have a clean prism directory
get_prism_dailys(
  type="tmean", 
  minDate = "2013-06-01", 
  maxDate = "2013-06-14",
  keepZip = FALSE
)
p <- pd_plot_slice(
  prism_archive_subset("tmean", "daily", year = 2020), 
  c(-73.2119,44.4758)
)
print(p)
}

}
