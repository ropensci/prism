dl_dir <- file.path("prism_test")

# need to unzip all the zip files, then delete the unzipped folder when exiting
avail_ppt <- paste0(
  "PRISM_ppt_stable_4kmD2_",
  c("19810101", "19910101", "20110101"),
  "_bil"
)
avail_tmin <- paste0(
  "PRISM_tmin_stable_4kmD2_",
  c("19810101", "20110615"),
  "_bil"
)

all_avail <- c(avail_tmin, avail_ppt)

for (ff in all_avail) {
  unlink(file.path(dl_dir, ff), recursive = TRUE)
}

# revert prism path to its original state
orig_path <- getOption("prism.path.tmp")
options("prism.path.tmp" = NULL)
options("prism.path" = orig_path)
