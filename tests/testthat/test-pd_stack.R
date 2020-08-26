test_that("pd_stack() works", {
  # three days
  dd <- prism_archive_subset("ppt", "daily", mon = 1)
  expect_s4_class(x <- pd_stack(dd), "RasterStack")
  expect_equal(dim(x)[3], length(dd))
  expect_setequal(names(x), dd)
  
  # 2 months
  mm <- prism_archive_subset("tdmean", "monthly", years = 2005)
  expect_s4_class(x <- pd_stack(mm), "RasterStack")
  expect_equal(dim(x)[3], length(mm))
  expect_setequal(names(x), mm)
  
  # combo month and days
  cc <- c(dd, mm)
  expect_s4_class(x <- pd_stack(cc), "RasterStack")
  expect_equal(dim(x)[3], length(cc))
  expect_setequal(names(x), cc)
})
