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