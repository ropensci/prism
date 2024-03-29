% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pd_get.R
\name{pd_get_name}
\alias{pd_get_name}
\alias{pd_get_date}
\alias{pd_get_type}
\alias{prism_md}
\alias{pd_to_file}
\title{Perform action on "prism data"}
\usage{
pd_get_name(pd)

pd_get_date(pd)

pd_get_type(pd)

prism_md(f, returnDate = FALSE)

pd_to_file(pd)
}
\arguments{
\item{pd}{prism data character vector.}

\item{f}{1 or more prism directories name or .bil files.}

\item{returnDate}{TRUE or FALSE. If TRUE, an ISO date is returned.  By
default years will come back with YYYY-01-01 and months as YYYY-MM-01}
}
\value{
\code{pd_get_name()} and \code{pd_get_date()} return a character vector of
names/dates.

\code{pd_get_type()} returns a character vector of prism variable types,
e.g., 'ppt'.

\code{pd_to_file()} returns a character vector with the full path to the
bil file.
}
\description{
\code{pd_get_name()} extracts a long, human readable name from the prism
data.

\code{pd_get_date()} extracts the date from the prism data.
Date is returned in yyyy-mm-dd format. For monthly data, dd is 01 and
for annual data mm is also 01. For normals, an empty character is returned.

\code{pd_get_type()} parses the variable from the prism data.

\code{prism_md()} is a deprecated function that has been replaced with
\code{pd_get_name()} and \code{pd_get_date()}

\code{pd_to_file()} converts prism data  to a fully specified .bil file, i.e., the
full path to the file in the prism archive. A warning is posted if the
file does not exist in the local prism archive.
}
\details{
"prism data", i.e., \code{pd} are the folder names returned by
\code{\link[=prism_archive_ls]{prism_archive_ls()}} or \code{\link[=prism_archive_subset]{prism_archive_subset()}}. These functions get the
name or date from these data, or convert these data to a file name.
}
\examples{
\dontrun{
# Assumes 2000-2002 annual precipitation data is already downloaded
pd <- prism_archive_subset('ppt', 'annual', years = 2000:2002)
pd_get_name(pd)
## [1] "2000 - 4km resolution - Precipitation" "2001 - 4km resolution - Precipitation"
## [3] "2002 - 4km resolution - Precipitation"

pd_get_date(pd)
## [1] "2000-01-01" "2001-01-01" "2002-01-01"

pd_get_type(pd)
## [1] "ppt" "ppt" "ppt"

pd_to_file(pd[1])
## [1] "C:/prismdir/PRISM_ppt_stable_4kmM3_2000_bil/PRISM_ppt_stable_4kmM3_2000_bil.bil""
}

}
