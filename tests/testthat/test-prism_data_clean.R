
setup({
  ofolder <- prism_get_dl_dir()
  last_char <- substr(
    prism_get_dl_dir(), 
    nchar(prism_get_dl_dir()), 
    nchar(prism_check_dl_dir())
  )
  if (last_char %in% c("/", "\\")) {
    ofolder <- substr(prism_get_dl_dir(), 1, nchar(prism_get_dl_dir()) - 1)
  }
  
  unzip(
    file.path("prism_test", "test_prism_archive_clean.zip"), 
    # must remove trailing slash for this to work
    exdir =  ofolder
  )
})

mon_keep <- c(
  "PRISM_ppt_stable_4kmM3_202001_bil", 
  "PRISM_ppt_provisional_4kmM3_202007_bil"
)
mon_delete <- c("PRISM_ppt_provisional_4kmM3_202001_bil")
day_keep <- c(
  "PRISM_ppt_stable_4kmD2_20200115_bil", 
  "PRISM_ppt_provisional_4kmD2_20200731_bil",
  "PRISM_ppt_provisional_4kmD2_20200515_bil", 
  "PRISM_ppt_early_4kmD2_20200815_bil"
)
day_delete <- c(
  "PRISM_ppt_provisional_4kmD2_20200115_bil",
  "PRISM_ppt_early_4kmD2_20200515_bil",
  "PRISM_ppt_early_4kmD2_20200115_bil"
)

teardown(
  unlink(file.path(prism_get_dl_dir(), c(mon_keep, day_keep)), recursive = TRUE)
)

test_that("prism_archive_clean() works", {
  expect_setequal(
    prism_data_subset("ppt", "daily", years = 2020),
    c(day_keep, day_delete)
  )
  expect_setequal(
    prism_data_subset("ppt", "monthly", years = 2020),
    c(mon_keep, mon_delete)
  )
  
  expect_setequal(prism_archive_clean("ppt", "daily", years = 2020), day_delete)
  expect_setequal(prism_data_subset("ppt", "daily", years = 2020), day_keep)
  
  expect_setequal(prism_archive_clean("ppt", "monthly", years = 2020), mon_delete)
  expect_setequal(prism_data_subset("ppt", "monthly", years = 2020), mon_keep)
})
