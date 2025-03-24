This submission fixes the policy violation that resulted in the package being 
archived on 2025-3-20 b/c it creates '~/prismtmp'. 

A user must call prism_set_dl_dir('some/path') to tell the package where to 
download data to. If one of the functions that downloads data from the PRISM API 
is called before this happens, then prism_check_dl_dir() will see that it 
doesn't know where to download the data to. In this case: if R is in interactive 
mode, it will prompt the user asking them where to download the data to. If the 
folder the user provides does not exist it will confirm from the user that the 
user wants the folder created. If R is not in interactive mode it will fail. 
There is no suggestion of a default anymore (~/prismtmp) - it is entirely left 
to the user to say where the data should go to. The "~/prismtmp" path shows up 
in the vignette, but nowhere else in the package. I assume this is ok as it is 
an example of where a user might want to save the data. 

## Test environment

* Local: Windows 10 Enterprise: R 4.4.3
* Ubuntu 20.04 (using GitHub Actions): oldrel-3, oldrel-2, oldrel-1, release, devel
* MacOS-latest (using GitHub Actions): release
* Windows (using GitHub Actions): oldrel-2, oldrel-1, release, devel
* R-project Win-Builder: devel

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
