# prism 0.1.0.9000

*In development*

Thanks to @jsta for updating the README and other helping with several other under the hood fixes. 

## Breaking Changes

* `prism_webservice()` is no longer exported as it is wrapped by `get_prism_*()` functions, and requires a correctly specified url. It can still be called with `prism:::prism_webservice()` if users really need it. (#83)
* `pr_parse()` is no longer exported. Use `pd_get_name()` or `pd_get_date()` instead. 


## Major Updates

There are two overall major updates with this release. (1) All functions should work with all temporal periods and all variables; previously some functions only worked with daily data and not all variables were able to be downloaded from the prism website. (2) A new API was implemented that results in many functions being deprecated in favor of the update naming convention. This change was intended to provide consistent name for functions that apply to different steps in the work flow implemented in this package. The details of these changes are:

* Users can now download vpdmin, vpdmax, and tdmean variables for 30-year normals, daily, monthly, and annual data. (#68)
* There are now several functions (`prism_*_dl_dir()`) that set and check the prism download directory. These are hopefully easier to remember than using the base R `options()` and `getOption()` functions and the prism option variable name "prism.path". 
  * `prism_check_dl_dir()` replaces `check_path()`, which is deprecated and will be removed in the next release.
* The prism data are downloaded to this directory and then referred to as the "prism archive". These are the `prism_archive_*()` functions.
  * New function: `prism_archive_subset()`. This makes it much easier to get the data for a specific type/temporal period from the prism archive. (#69)
  * `prism_archive_ls()` replaces `ls_prism_data()`, which will be removed in a future release. 
    * The return type and options changed from `ls_prism_data()` to `prism_archive_ls()`, which now always returns only folder names as a vector, instead of a data.frame that could have between 1 and 3 columns.
    * The previous behavior can be achieved by applying new functions (`pd_get_name()` and `pd_to_file()`) to the vector returned by `prism_archive_ls()`. 
  * `prism_archive_clean()` replaces `del_early_prov()`, which will be removed in a future release. It also now works with all time steps and prompts user to select which folders will be removed before removing them (when R is in interactive mode). (#89)
  * `prism_archive_verify()` replaces `check_corrupt()`, which will be removed in a future release. It also now works with time steps other than daily and it gains a `download_corrupt` argument that controls whether corrupt files are automatically re-downloaded.
* `prism_archive_ls()` and `prism_archive_pd()` both return vectors of prism data folder names, i.e., prism data, i.e., `pd`. There are a number of functions that act on the prism data. These are the `pd_*()` functions. 
  * `pd_image()` replaces `prism_image()`.
  * `pd_plot_slice()` replaces `prism_slice()`.
  * `pd_stack()` replaces `prism_stack()`.
  * `pd_get_station_md()` replaces `get_prism_station_md()`. (#88)
  * `prism_md()` will be removed in a future release. It is replaced by:
    * `pd_get_name()`, which is equivalent to `prism_md(f, FALSE)`.
    * `pd_get_date()`, which is equivalent to `prism_md(f, TRUE)`.
  * Two new functions were added that convert the prism data to a full absolute path (`pd_to_file()`) and get the type (parameter) of the prism data (`pd_get_type()`).
  

## Other Changes

* The way pre 1981 data is handled has been updated. 
  * `get_prism_annual()` and `get_prism_monthlys()` gain a `keep_pre81_months` parameter. This lets the user determine if all of the monthly and annual data are kept, since the download includes all 12 months + the annual data for years before 1981. If this is `TRUE` then all monthly data are kept, instead of only those that were specified in the current call to `get_prism_*()`. (#82)
  * Because pre-1981 data might already have been downloaded based on `keep_pre81_months` parameter in previous downloads, the download functions now check that pre-1981 data does not exist before downloading it. To do this, `prism_webservice()` and `prism_check()` gain a `pre81_months` parameter, which allows the functions to know which months were requested for downloading. (#81)
* The prism web service only allows a user to download the same data twice in a 24-hour period. The download functions now report when the user has exceeded the allowable number of attempts to download the same file (in one day). If a user tries to download the same file more than two times in one day, the message is posted as a warning and the returned text file is saved in the prism archive. This is not posted as an error so that if a query of multiple files runs into this issue, it does not abort the full query. Another warning posts if the unzipped folder is empty. (#80)
* `prism_check()` is deprecated and will be no longer be exported in the next release.
* `get_prism_normals()` will now error if neither monthly nor annual data are specified to be downloaded and will download monthly and annual data simultaneously if asked to do so. (#77)
* all `get_prism_*()` functions are documented in same help page. (#79)
* Help pages for non-exported functions have been removed.
* More tests were added. Up to 50% coverage now. Some tests are only run locally to ensure prism download limits are not exceeded. 
* `pd_get_station_md()` (formerly `get_prism_station_md()`) now reports a warning if not all requested dates exist in the metadata data frame. (#87 related). It also now works for monthly and normals; not solely daily prism data. 
* `pd_get_md()` was added to parse .info.txt metadata, by converting an existing internal function. (#88)
* `prism_archive_clean()` (formerly `del_early_prov()`) now invisibly returns the folders that it removes.
* `pd_image()` (formerly `prism_image()`) invisibly returns the `gg` object it creates. It also shows the units for the prism variable in the fill legend. (#99)


# prism 0.1.0

## Minor changes

* New functions
    - `del_early_prov()` searches the download folder for duplicated PRISM data and keeps only the newest version.
    - `get_prism_station_md()` extracts metadata from daily PRISM data.
* `get_prism_dailys()` gains a `check` parameter that allows the user to specify how prism files are checked.


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

* Changed acquisition method to use prism webservice.  Prior to this change the FTP acquisition method often caused the server to time out when download request volume became too high.  

* Changed method of metadata extraction.  Originally we parsed XML metadata to get information about raster files.  However the XML for historical data is particularly sparse. The new method relies on parsing file names instead. While more universal, it may be less stable

### Bug fixes

* Fixed FTP time out error by switching to webservice

* Fixed `prism_stack` by adjusting to new metadata extraction method