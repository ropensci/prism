# prism (development version)

This is a rather large update to bring the prism package up-to-date with the Oregon State PRISM API changes over the last few years. The biggest changes, that are expanded on more below are: 

- Data can now be downloaded in GeoTiff and NetCDF format, in addition to the previously supported bil format. 
- The package no longer works with the older (pre September 2025) API/data format. 
- Users can now set their preferences for format, and treatment of zip files once per archive and have it persist over R sessions. 

## Breaking changes

- **The package is no longer compatible with the pre 2025 prism API.** All `pd_*()` functions assume that all data are in the new folder name format. 
- Removed parameters that were deprecated in previous releases (#168)
  - Removed `check` parameter from `get_prism_dailys()`. Deprecated in 0.2.1.
  - Removed `keep_pre81_months` parameter from `get_prism_annual()` and `get_prism_monthlys()`. Deprecated in 0.3.0.
- Removed user functions that were deprecated in previous releases (#168)
  - Removed `prism_md()`, `prism_image()`, `get_prism_station_md()`, `prism_slice()`, `prism_stack()`, `del_early_prov()`, `ls_prism_data()`, `check_corrupt()`, `path_check()`, `prism_check()`. Deprecated in 0.2.0.
- `prism_archive_clean()` is now defunct because PRISM no longer uses early, provisional, and stable identifiers. (#150) See addition of `prism_archive_check_versions()` and `prism_archive_update()` below.
- Updated `pd_get_md()` so that it returns all variables that are found in the .info.txt file and no longer changes any names found in those files. If this is used programmatically, this could change the size and names of the data frame.

## Non-breaking user side changes

- PRISM data can now be downloaded in GeoTiff or NetCDF format, in addition to the previous format (bil) (#131)
  - It is recomended to pick one format, and stick with that format for the entire prism data archive. The package is not built to work with different formats within the same archive.
  - Kept bil as the default format for compatibility with previous versions; GeoTIFF is recommended for its smaller storage footprint and is planned as the default in a future release.
  - Added `prism_set_format()` and `prism_get_format()` to set and check the format. 
  - Updated `pd_*()` functions to work with all formats. 
  - 30-year normals are only available in GeoTiff format. A message posts indicating this if you are using a different format and ask for 30-year normals. 
- Updates to the `get_prism_*()` functions
  - They all now invisibly return the folder names (`pd`) that were downloaded. This should make it easier to download data and then immediately use it in the `pd_*()` functions. (#161)
  - Added `overwrite` argument to all `get_prism_*()` functions. When `TRUE` the existing data are overwritten. Useful for updating to more recently available data; see more below. (#167)
  - Added `get_prism_pd()`, which allows users to download based on folder name, i.e., `pd`, rather than using the `get_prism_dailys/monthlys/annual()`. Useful when you already know the `pd`, like when updating to the newest available version. 
- solslope and soltotal can now be downloaded in 800m and 4km daily, monthly, and annual time series data (#149)
- Added `prism_set_keepZip()` and `prism_get_keepZip()`. Changed the default assignment in all the calls to `get_prism_*()` to use this function. Now the user can easily change the default behavior for all downloads. The package defaults to `TRUE` to maintain previous default behavior. (#163)
- The time step and data class, i.e., normals vs. time series, were disentangled. This mostly affects  `prism_archive_subset()`. Instead of using `temp_period = "monthly normals"` users should now use `time_step = "monthly", data_class = "normals"`. (#162)
  - Added `data_class` argument `prism_archive_subset()`
  - Switched from `temp_period` to `time_step` and deprecated `temp_period` parameter. 
  - `temp_period` or `time_step` should not included "normals". They can for now but that's deprecated and user should be using `data_class`.
  - Also added several new `pd_get_*()` functions to support this change. 
- New `pd_*()` functions: `pd_get_time_step()`, `pd_get_data_class()` and `pd_get_resoultion()`
- Modified existing `pd_*()` functions
  - `pd_get_date()` now returns a date that matches the timestep of the prism data. The previous version added on months and days to monthly and annual data. That behavior is preserved by default using the `complete=TRUE` parameter, but users should switch to using `complete=FALSE`, which will be the default in a future release.
  - Updated `pd_get_station_md()` to work with different formats and expected combinations of time step, type, data class, and resolution. This should not affect output returned except that it no longer fails for certain data types, e.g., tmean, it returns an empty data frame since we don't expect there to be station meta data. (#158)
  - `pd_image()` gains the `draw` argument. It defaults to `TRUE` to maintain existing behavior, but ensures that the automatic drawing can be disabled.

### Archive Maintenance Improvements

- PRISM no longer uses early, provisional, and stable identifiers, but there are still up to 6 releases of the data from the most recent (yesterday) until it is finalized. (#150)
  - Messages now post in `get_prism_monthlys()` and `get_prism_datilys()` if requested data are within 7 months of today, indicating you may need to update data in the future. 
  - New function: `pd_check_versions()`. For any/all `pd` in the archive, check what version it is and returns the status of the data. A status of "update_available" lets the user know that there is more recent data availalbe.
  - New function: `get_prism_pd()`. This allows for easier downloading of data if you know the folder name, i.e., `pd`, rather that using `get_prism_annuals/dailys/monthlys()`.
  - New function: `prism_archive_update()`. This wraps `pd_check_versions()` and `get_prism_pd()` to update data in the archive that have updates available.
- The configuration (download format, and defualt value of `keepZip`) can be saved so that the user does not have to reset them at the beginning of every R session. Added `prism_archive_save_config()`. This function creates a configuration file that is saved in the currently specified prism archive. Then, when you use that archive in a different session, it will load the format and `keepZip` options that were previously set so you don't have to keep making those same calls over and over. 
- Added `prism_archive_setup()` to create and configure a new, empty archive in one call.
- If an archive contains any of the pre-September 2025 prism data, the `prism_archive_migrate_v1()` function can be used to update to the new prism data format. This searches the prism archive, and for any folders that appear to be from the v1 api (pre-September 2025) prompts the user to updated to the new format and remove the old format. This probably would have been more useful in the 0.3.0 release. (#164)

## Non-breaking internal changes

- Removed dependency on magrittr package; now depends on R >= 4.1.0. replaced %>% with |> throughout.
- Switched from `raster` package to `terra` package throughout the package. Package no longer depends on `raster`. 
- Reviewed & updated all tests for the different download formats (#152)
- Fixed bug that resulted in data not being skipped if it already existed. 

# prism 0.3.0

I am very sorry for the delay in getting a working version of prism updated based on the API changes that were made in September 2025. In the near future, we will be updating the entire package to take advantage of the newly available cloud optimized GeoTiff (COG) format. For now, most of the package still downloads the previously relied on .bil files. The exception is described more below. Thank you to @ran-codes for the heavy lifting in switching to the new API.

The package now posts a warning if the prism archive contains folders from the old API. Our recommendation is to start fresh, and re-download any old data you need. The package has probably not been fully stress tested with a combination of data from the old API with the new API.

## Breaking Changes

* `get_prism_normals()` no longer downloads .bil files, and instead downloads the data in COG format. For this reason, all of the helper functions, e.g., `pd_plot_slice()`, `pd_image()`, etc., do not work with the normals. 

## Major but Under-the-Hood Changes

* Switched all code to use the new API provided by Oregon State. (@ran-codes, #135)

## Minor Enhancements (non-API breaking changes)

* Based on the updated API, there is no longer any difference in the packaging of pre/post 1981 data. Therefore,  `keep_pre81_months` is deprecated in `get_prism_monthlys()` and `get_prism_annual()`.

# prism 0.2.3

**Released March 25, 2025**

* Changed `prism_check_dl_dir()` so that it no longer suggests ~/prismtmp as a default. The user must specify where the data should be downloaded to either using `prism_set_dl_dir()` or via the prompts in `prism_check_dl_dir()`. Additionally, if following the prompts in `prism_check_dl_dir()`, if a user specifies a folder that does not exist, then it confirms that user wants the folder to be created. 


# prism 0.2.2 

**Released March 18, 2025** - this version was pulled down from CRAN on March 20, 2025 for violating CRAN policies b/c `prism_check_dl_dir()` suggests a default directory (~/prismtmp) and the example files create this folder and leave it behind. This is resolved in the next patch version. 

## Minor Enhancements (non-API breaking changes)

* Added solar radiation (clear sky), solar radiation (sloped), solar radiation (total), and cloud transmittance as available variables to download for monthly and annual normals. The variables are `solclear`, `solslope`, `soltotal`, and `soltrans`. (#130, @brownag)
* Added ability to download daily normals for all variables except solar radiation (clear sky), solar radiation (sloped), solar radiation (total), and cloud transmittance (#123). The `day` parameter was added to `get_prism_dailys()` to specify which days to get the normals for. It was added as the last parameter so previous code that does not specify arguments by name will still work. Made sure all `pd_get_*()` functions work with daily normals.
* Added a better error message when the PRISM webservice is down (not returning status 200). (#122)

## Bug Fixes and Clean Up

* Fixed examples in the `prism_archive_subset()` to use correct syntax for a range of years. (#128, @Archaeo-Programmer)
* Internal updates to meet ROpenSci style guide including removing uses of `sapply()`, removing uses of `1:length(...)`, and removing global assignment inside `prism_webservice()`
* Documented return value for `pd_stack()`, `prism_set_dl_dir()` ,`pd_to_file()`, `pd_get_type()` & `get_prism_*()` functions.
* Added examples to documentation for `pd_to_file()`, `prism_archive_clean()`, `prism_archive_verify()`, `prism_set_dl_dir()`, & `pd_get_*()` functions.

# prism 0.2.1

**Released October 17, 2023**

## Minor Enhancements

* Added `service` parameter to `get_prism_dailys()`, `get_prism_monthlys()`, and `get_prism_annual()`, so user can provide subscription based URLs, instead of default public available 4km data. (@adamlilith)
* Changed defaults in get data functions (#104)
  * `get_prism_monthlys()` 
    * `mon` now defaults to `1:12`, so default now downloads all months for the specified years
    * `years` no longer has a default of `NULL`, so user will understand it has to be provided
  * `get_prism_annual()`
    * `years` no longer has a default of `NULL`, so user will understand it has to be provided
  * Minor updates to documentation of `mon` and `years` parameters

## Bug Fixes and Clean Up

* Fixing CRAN notes
  * Removed LazyData and LazyLoad from Description to fix CRAN note.
  * Removed lubridate from imports to fix CRAN note.
* Removed vignette that depended on too many other libraries; did not want to add them all to Suggests and also relied on external shape file. This may be linked to from README in the future. 
* Updated error message in `pd_image()` when input has length of 0.
* Fixed documentation for `get_prism_normals()` to reference the new period (1991-2020). (#111)
* Updated error message in `get_prism_dailys()` if a date before Jan. 1, 1981 is provided.
* Deprecated `check` parameter in `get_prism_dailys()` as it does not exist in monthly or annual functions. (#116)
* Removed purrr from imports by switching one call from `purrr:map()` to `lapply()`.

# prism 0.2.0

**Published December 5, 2020**

Thanks to @jsta for updating the README and helping with several other under the hood fixes. 

## Breaking Changes

* `prism_webservice()` is no longer exported as it is wrapped by `get_prism_*()` functions, and requires a correctly specified url. It can still be called with `prism:::prism_webservice()` if users really need it. (#83)
* `pr_parse()` is no longer exported. Use `pd_get_name()` or `pd_get_date()` instead. 


## Major Updates

There are two overall major updates with this release. (1) All functions should work with all temporal periods and all variables; previously some functions only worked with daily data and not all variables were able to be downloaded from the prism website. (2) A new API was implemented that results in many functions being deprecated in favor of the updated naming convention. This change was intended to provide consistent names for functions that apply to different steps in the work flow implemented in this package. The details of these changes are:

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
