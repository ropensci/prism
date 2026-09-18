orig_dl <- prism_get_dl_dir()
orig_ff <- prism_get_format()
teardown({
  prism_set_dl_dir(orig_dl)
  prism_set_format(orig_ff)
})

# calls in form of "prism_tmean_us_25m_200001.zip". should return .zip back if
# hasn't been downloaded, and otherwise return nothing
test_that("prism_not_downloaded() works as accepted", {
  prism_set_dl_dir(tif_dl)
  prism_set_format("geotiff")
  
  # simple
  x <- "prism_ppt_us_25m_2025.zip"
  expect_equal(prism_not_downloaded(x), character(0))
  x <- "prism_ppt_us_25m_2021.zip"
  expect_equal(prism_not_downloaded(x), x)
  
  # now check versions that include partial date matches and vectorized
  not_dl <- c("prism_ppt_us_25m_202506.zip", "prism_ppt_us_25m_20250609.zip",
              "prism_tmin_us_25m_2025.zip", 
              "prism_ppt_us_25m_202007_avg_30y.zip", 
              "prism_ppt_us_25m_20200704_avg_30y.zip")
  dl <- c("prism_ppt_us_25m_2025.zip", "prism_ppt_us_25m_2024.zip", 
          "prism_ppt_us_25m_2023.zip", "prism_ppt_us_25m_2020_avg_30y.zip")
  expect_equal(prism_not_downloaded(not_dl), not_dl)
  expect_equal(prism_not_downloaded(dl), character(0))
  expect_equal(prism_not_downloaded(c(not_dl, dl)), not_dl)
  
  # returns named vector when lgl = TRUE
  # test values
  expect_equivalent(
    prism_not_downloaded(c(not_dl, dl), lgl = TRUE), 
    c(rep(TRUE, length(not_dl)), rep(FALSE, length(dl)))
  )
  # and names
  expect_equal(
    names(prism_not_downloaded(c(not_dl, dl), lgl = TRUE)), 
    stringr::str_remove(c(not_dl, dl), ".zip")
  )
})
