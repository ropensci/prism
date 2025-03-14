#' Download prism data
#' 
#' Download grid cell data from the 
#' [prism project](https://prism.nacse.org/). Temperature (min, max, 
#' and mean), mean dewpoint temperature, precipitation, and vapor pressure 
#' deficit (min and max) can be downloaded for annual (`get_prism_annual()`), 
#' monthly (`get_prism_monthlys()`), daily (`get_prism_dailys()`), and 30-year
#' averages (`get_prism_normals()`). Data are at 4km resolution, except for the 
#' normals which can also be downloaded at 800m resolution.
#' 
#' @param type The type of data to download. Must be "ppt", "tmean", "tmin", 
#'   "tmax", "tdmean", "vpdmin", or "vpdmax". "solclear", "solslope", 
#'   "soltotal", and "soltrans" are also available only for 
#'   `get_prism_normals()`. Note that `tmean == mean(tmin, tmax)`.
#'   
#' @param years a valid numeric year, or vector of years, to download data for. 
#'   
#' @param keepZip if `TRUE`, leave the downloaded zip files in your 
#'   'prism.path', if `FALSE`, they will be deleted.
#'   
#' @param keep_pre81_months The pre-1981 data includes all monthly data and the 
#'   annual data for the specified year. If you need annual and monthly data it
#'   is advantageous to keep all the monthly data when downloading the annual 
#'   data so you don't have to download the zip file again. When downloading 
#'   annual data, this defaults to `FALSE`. When downloading monthly data, this
#'   defaults to `TRUE`.
#'   
#' @param service Either `NULL` (default) or a URL provided by PRISM staff
#'   for subscription-based service. Example:
#'   "http://services.nacse.org/prism/data/subscription/800m". To use the
#'	 subscription option, you must use an IP address registered with PRISM
#'   staff. When `NULL`, URL defaults to: 
#'   "http://services.nacse.org/prism/data/public/4km".
#'
#' @details 
#' A valid download directory must exist before downloading any prism data. This
#' can be set using [prism_set_dl_dir()] and can be verified using 
#' [prism_check_dl_dir()].
#' 
#' @section Annual and Monthly:
#' 
#' Annual and monthly prism data are available from 1891 to present. For 
#' 1891-1980 data, monthly and annual data are grouped together in one download 
#' file; `keep_pre81_months` determines if the other months/yearly data are kept
#' after the download.  Data will be downloaded for all specified months (`mon`)
#' in all the `years` in the supplied vectors.
#' 
#' @return Nothing is returned - an error will occcur if download is not 
#'   successful.
#' 
#' @examples \dontrun{
#' # Get all annual average temperature data from 1990 to 2000
#' get_prism_annual(type = "tmean", year = 1990:2000, keepZip = FALSE)
#' }
#' 
#' @rdname get_prism_data
#' 
#' @export
get_prism_annual <- function(type, years, keepZip = TRUE, 
                             keep_pre81_months = FALSE, service = NULL)
{
  ### parameter and error handling
  
  prism_check_dl_dir()
  type <- match.arg(type, prism_vars())
  
  ### Check year
  if(!is.numeric(years)){
    stop("You must enter a numeric year from 1895 onwards.")
  }
  
  if(any(years < 1895)){
    stop("You must enter a year from 1895 onwards.")
  }
    
  pre_1981 <- years[years < 1981]
  post_1981 <- years[years >= 1981]
  uris_pre81 <- vector()
  uris_post81 <- vector()
  
  if (is.null(service)) {
	  service <- "http://services.nacse.org/prism/data/public/4km"
  }  
  
  if (length(pre_1981)) {
    uris_pre81 <- gen_prism_url(pre_1981, type, service)
  }
  
  if (length(post_1981)) {  
    uris_post81 <- gen_prism_url(post_1981, type, service) 
  }
  
  download_pb <- txtProgressBar(
    min = 0,
    max = length(uris_post81) + length(uris_pre81),
    style = 3
  )
  
  counter <- 0
  
  ### Handle post 1980 data
  if(length(uris_post81) > 0){    
    
    for(i in seq_along(uris_post81)) {
      prism_webservice(uris_post81[i],keepZip)
      setTxtProgressBar(download_pb, i)
    }
  }
  
  counter <- length(uris_post81) + 1
  
  ### Handle pre 1981 files
  if (length(uris_pre81) > 0) {
    
    pre_files <-c() 
    for(j in seq_along(uris_pre81)){
      tmp <- prism_webservice(
        uris_pre81[j], 
        keepZip, 
        returnName = TRUE, 
        pre81_months = ""
      )
      
      if (!is.null(tmp)) {
        pre_files <- c(pre_files, tmp)
      }
      
      setTxtProgressBar(download_pb, counter) 
      counter <- counter + 1
    }
    
    ### Process pre 1981 files
    if (length(pre_files) > 0) {
      pre_files <- unlist(strsplit(pre_files,"\\."))
      pre_files <- pre_files[seq(1,length(pre_files),by =2)]
    
      for (k in seq_along(pre_files)) {
        if (keep_pre81_months) {
          # keep the annual data
          to_split <- gsub(pattern = "_all", replacement = "", x = pre_files[k])
          
          # and keep all 12 months of data
          all_months <- mon_to_string(1:12)
          for (m in all_months) {
            to_split <- c(
              to_split, 
              gsub(pattern = "_all", replacement = m, x = pre_files[k])
            )
          }
        } else {
          to_split <- gsub(pattern = "_all", replacement = "", x = pre_files[k])
        }
          
        process_zip(pre_files[k], to_split)
      }
    }
  }
  close(download_pb)
}
