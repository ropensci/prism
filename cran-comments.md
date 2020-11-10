## Test environment

* Local: Windows 10 Enterprise: R 3.6.3
* Ubuntu 20.04 (using GitHub Actions): R 3.6.3, 4.0.3, and R-devel
* MacOS-latest (using GitHub Actions): R 3.6.3, 4.0.3, and R-devel
* Windows (using GitHub Actions): R 3.6.3, R 4.0.3, and R-devel; Win-builder R 4.0.3 and R-devel
* R-Hub: Windows, R-devel; Ubuntu Linux 16.04, R-release; Fedora Linux, R-devel

## R CMD check results

There were no ERRORs or WARNINGs.

There is 1 NOTE from R-hub regarding the size of the tarball. The size is due to data necessary for package tests. Care has been taken to include minimal downloaded prism data for the tests, and each dataset are individually zipped with sizes < 1.6 MB. 

## Downstream dependencies

There are no downstream dependencies.
