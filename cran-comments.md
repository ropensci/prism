# prism v0.3.0

## Test environment

* Local: Windows 11 Enterprise: R 4.5.2
* Ubuntu-latest (using GitHub Actions): oldrel-3, oldrel-2, oldrel-1, release, devel
* MacOS-latest (using GitHub Actions): release
* Windows (using GitHub Actions): oldrel-2, oldrel-1, release, devel
* MacOS: release using devtools::check_mac_release()
* Windows: devel using devtools::check_win_devl()

## R CMD check results

Local and R-project environments resulted in 1 NOTE: 

  checking CRAN incoming feasibility ... [11s] NOTE
  Maintainer: 'Alan Butler <rabutler@usbr.gov>'
  
  New submission
  
  Package was archived on CRAN
  
  CRAN repository db overrides:
    X-CRAN-Comment: Archived on 2025-03-20 for policy violation.
  
    Creates '~/prismtmp'.
    
This submission fixes this policy violation; more explanation at the beginning 
of this file. 

All other environments resulted in Status: OK; 0 notes; 0 errors. GitHub Actions
results: https://github.com/ropensci/prism/actions/runs/14041940552

## Downstream dependencies

There are no downstream dependencies.
