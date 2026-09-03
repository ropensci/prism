# get current prism path, store it, so it can be reverted after tests
cur_prism <- getOption("prism.path")
options("prism.path.tmp" = cur_prism)

# Fixture PRISM archive ---------------------------------------------------

fixture_dir <- testthat::test_path("fixtures")
prism_fixture_dir <- file.path(tempdir(), "prismdata")

# Start each test run with a clean temporary fixture archive.
if (dir.exists(prism_fixture_dir)) {
  unlink(prism_fixture_dir, recursive = TRUE, force = TRUE)
}

dir.create(prism_fixture_dir, recursive = TRUE, showWarnings = FALSE)

# Find all fixture ZIPs, e.g.
# tests/testthat/fixtures/bil/prism_data.zip
# tests/testthat/fixtures/asc/prism_data.zip
# tests/testthat/fixtures/tif/prism_data.zip
# tests/testthat/fixtures/nc/prism_data.zip
zip_files <- list.files(
  fixture_dir,
  pattern = "\\.zip$",
  recursive = TRUE,
  full.names = TRUE
)

if (length(zip_files) == 0L) {
  stop(
    "No PRISM fixture ZIP files found under `",
    fixture_dir,
    "`.",
    call. = FALSE
  )
}

for (zip_file in zip_files) {
  format <- basename(dirname(zip_file))
  
  # Copy the ZIP into the temporary format-specific folder.
  format_dir <- file.path(prism_fixture_dir, format)
  
  dir.create(format_dir, recursive = TRUE, showWarnings = FALSE)
  
  zip_copy <- file.path(
    format_dir,
    basename(zip_file)
  )
  
  if (!file.copy(zip_file, zip_copy, overwrite = TRUE)) {
    stop(
      "Could not copy PRISM fixture ZIP: `",
      zip_file,
      "`.",
      call. = FALSE
    )
  }
  
  # Extract each ZIP into its matching format subdirectory.
  format_dir <- file.path(format_dir, stringr::str_remove(basename(zip_file), ".zip"))
  utils::unzip(
    zipfile = zip_copy,
    exdir = format_dir
  )
}

# set default format/dl location so tests that assume it is set work. other 
# tests will set/update it for testing the different formats
prism_set_dl_dir(file.path(tempdir(), 'prismdata', 'tif'))
prism_set_format('geotiff')

bil_dl <- file.path(tempdir(), 'prismdata', 'bil')
asc_dl <- file.path(tempdir(), 'prismdata', 'asc')
nc_dl <- file.path(tempdir(), 'prismdata', 'nc')
tif_dl <- file.path(tempdir(), 'prismdata', 'tif')
corrupt_dl <- file.path(tempdir(), 'prismdata', 'corrupt')
