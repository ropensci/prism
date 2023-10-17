## Test environment

* Local: Windows 10 Enterprise: R 4.3.1
* Ubuntu 20.04 (using GitHub Actions): oldrel-3, oldrel-2, oldrel-1, release, devel
* MacOS-latest (using GitHub Actions): release
* Windows (using GitHub Actions): oldrel-2, oldrel-1, release, devel
* R-Hub: Windows, R-devel; Ubuntu Linux 20.04, R-release; Fedora Linux, R-devel

## R CMD check results

R-hub produced the following NOTES on Windows/R-devel:

* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
  
From all my checking, this appears to be an issue with R-hub and has an open issue (https://github.com/r-hub/rhub/issues/560). This is also not an issue locally or on GitHub Actions, so I submitted anyways. 

R-hub produced the following NOTE on Fedora Linux/R-devel and Ubuntu Linux 20.04/R-release: 

* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found

This also appears to be a known issue with R-hub and does not occur on GitHub Actions. 



## Downstream dependencies

There are no downstream dependencies.
