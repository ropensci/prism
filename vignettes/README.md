To get around the RCMD checks on vignette which would fail b/c the PRISM data
only exists locally, I added a local PRISM_AUTHOR environment variable. 

This environment variable must be set to "true" locally, if you wish to build 
the vignette. 

Otherwise, the figures and output will not be correctly rendered. 