# prism 0.1.0.9000

*In development*

* Can now download vpdmin, vpdmax, and tdmean for normals, daily, monthly, and annual data (#68)
* `get_prism_annual()` and `get_prism_monthlys()` gain a `keep_pre81_months` parameter. This lets the user determine if all of the monthly and annual data are kept, since the download includes all 12 months + the annual data for years before 1981. If this is `TRUE` then all monthly data are kept, instead of only those that were specified in the current call to `get_prism_*()`. (#82)
* Check that pre-1981 data does not exist before downloading it. To do this, `prism_webservice()` and `prism_check()` gain a `pre81_months` parameter, which allows the functions to know which months were requested for downloading. (#81)
* Replacing `prism_check()` with `prism_not_downloaded()`. `prism_check()` is deprecated and will be removed in the next release.
* Replacing `check_path()` with `prism_check_dl_dir()`. `check_path()` is deprecated and will be removed in the next release.
* Added `prism_set_dl_dir()` as an easy way to set path and make sure it is valid.
* `get_prism_normals()` will now error if neither monthly nor annual data are specified to be downloaded. (#77)
* `get_prism_normals()` will now download monthly and annual data simultaneously if asked to do so. (#77)
* all `get_prism_*()` functions are documented in same man page. (#79)
* removed man pages for non-exported functions

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