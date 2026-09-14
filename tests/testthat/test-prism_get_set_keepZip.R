orig_keepZip <- prism_get_keepZip()
teardown({prism_set_keepZip})

test_that("get/set keepZip parameter works", {
  expect_error(prism_set_keepZip(c(TRUE, FALSE)))
  expect_error(prism_set_keepZip(1))
  expect_error(prism_set_keepZip("false"))
  
  expect_true(prism_set_keepZip(TRUE))
  expect_true(prism_get_keepZip())
  
  expect_false(prism_set_keepZip(FALSE))
  expect_false(prism_get_keepZip())
})