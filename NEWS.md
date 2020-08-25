# prism 0.1.0.9000

*In development*

* Can now download vpdmin, vpdmax, and tdmean for normals, daily, monthly, and annual data (#68)
* `get_prism_annual()` and `get_prism_monthlys()` gain a `keep_pre81_months` parameter. This lets the user determine if all of the monthly and annual data are kept, since the download includes all 12 months + the annual data for years before 1981. If this is `TRUE` then all monthly data are kept, instead of only those that were specified in the current call to `get_prism_*()`. (#82)
* Check that pre-1981 data does not exist before downloading it. To do this, `prism_webservice()` and `prism_check()` gain a `pre81_months` parameter, which allows the functions to know which months were requested for downloading. (#81)
* `prism_check()` is deprecated and will be removed in the next release.
* Replacing `check_path()` with `prism_check_dl_dir()`. `check_path()` is deprecated and will be removed in the next release.
* Added `prism_set_dl_dir()` as an easy way to set path and make sure it is valid. Added `prism_get_dl_dir()` as an easy way to get the download directory path without remembering the option ("prism.path"). 
* `get_prism_normals()` will now error if neither monthly nor annual data are specified to be downloaded. (#77)
* `get_prism_normals()` will now download monthly and annual data simultaneously if asked to do so. (#77)
* all `get_prism_*()` functions are documented in same man page. (#79)
* removed man pages for non-exported functions
* more tests
* new function: `prism_archive_subset()`. This makes it much easier to get the data for a specific type/temporal period, once it has been downloaded onto the system. (#69)
* Now report when user has exceeded the allowable number of attempts to download the same file (in one day). If user tries to download the same file more than two times in one day, the message is posted as a warning. It is not posted as an error so that if a query of multiple files runs into this issue, it does not abort the full query. Another warning posts if the unzipped folder is empty. (#80)
* `get_prism_station_md()` now reports a warning if not all requested dates exist in the metadata data frame. (#87 related) and works for monthly and normals; not only daily. 
  * Changed to `prism_data_get_station_md()` (#88)
* Breaking change. No longer exporting `prism_webservice()` as it is wrapped by `get_prism_*()` functions, and requires the correctly specified url. Can still be called with `prism:::prism_webservice()` if users really need it. (#83)
* breaking change: re-organized `pr_parse()` and `prism_md()` (#88). 
  * No longer exporting `pr_parse()`. `prism_md()` is the user facing wrapper around it. 
  * Deprecated `prism_md()` in favor of `prism_data_get_name()` (= `prism_md(f, FALSE)`) and `prism_data_get_date()` (= `prism_md(f, TRUE)`). 
* added `prism_data_get_md()` to parse .info.txt metadata, by converting an existing internal function. (#88)
* `del_early_prov()` now invisibly returns the folders that it removes.
* `prism_archive_clean()` replaces `del_early_prov()` and works with all time steps. It also prompts user to select which folders will be removed before removing them (when R is in interactive mode). (#89)
* `prism_image()` invisibly returns the `gg` object it creates.
* `prism_archive_ls()` replaces `ls_prism_data()`
* added `pd_to_file()`

# prism 0.1.0

## Minor changes

* New functions
    - `del_early_prov()` searches the download folder for duplicated PRISM data and keeps only the newest version.
    - `get_prism_station_md()` extracts metadata from daily PRISM data.
* `get_prism_dailys ()` gains a `check` parameter that allows the user to specify how prism files are checked.


## Bug fixes

* `get_prism_monthlys()` can now download 1981 data. (@sdtaylor #59, #63)
* `get_prism_annual()` can now download pre 1981 data by itself. (@rabutler #64)
* `get_prism_dailys()` now correctly sets the progress bar.
* fixed bug in `gen_dates()` so that `get_prism_dailys()` works with only the `dates` parameter specified. (@rabutler #66)

## Under the hood

* added internal `gen_dates()` function for determining the specified dates (either from `minDate` and `maxDate`. or `dates`) used by the `get_prism_*()` functions.
* added tests for `gen_dates()` .

# prism 0.0.7

### Changes

* Changed aquisition method to use prism webservice.  Prior to this change the FTP aquisition method often caused the server to time out when download request volume became too high.  

* Changed method of metadata extraction.  Originally we parsed XML metadata to get inforamtion about raster files.  However the XML for historical data is particularly sparse. The new method relies on parsing file names instead. While more universal, it may be less stable

### Bug fixes

* Fixed FTP time out error by switching to webservice

* Fixed `prism_stack` by adjusting to new metadata extraction method