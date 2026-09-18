orig_dl <- prism_get_dl_dir()
orig_ff <- prism_get_format()
teardown({
  prism_set_dl_dir(orig_dl)
  prism_set_format(orig_ff)
})

test_that("prism_archive_update() errors correctly", {
  expect_error(prism_archive_update("not_a_pd"))
  expect_error(prism_archive_update(c("not_a_pd", "not a ppd")))
  expect_error(prism_archive_update(1))
})

test_that("prism_archive_update() doesn't update when all data are final", {
  prism_set_dl_dir(tif_dl)
  prism_set_format("geotiff")
  
  result <- evaluate_promise(prism_archive_update())
  
  expect_equal(result$result, character(0))
  expect_length(result$messages, 2)
  expect_true(all(grepl(
    "No supported files below the finalized release threshold\\; nothing to query online\\.", 
    result$messages[1])
  ))
  expect_true(all(grepl(
    "Everything checked is already at the latest release\\. Nothing to update\\.", 
    result$messages[2])
  ))
  
  prism_set_dl_dir(nc_dl)
  prism_set_format("nc")
  
  result <- evaluate_promise(prism_archive_update())
  
  expect_equal(result$result, character(0))
  expect_length(result$messages, 2)
  expect_true(all(grepl(
    "No supported files below the finalized release threshold\\; nothing to query online\\.", 
    result$messages[1])
  ))
  expect_true(all(grepl(
    "Everything checked is already at the latest release\\. Nothing to update\\.", 
    result$messages[2])
  ))
})

test_that("prism_archive_update() interactive mode", {
  prism_set_dl_dir(check_versions_dl)
  expect_length(pd <- prism_archive_subset(mon = 5:6), 2)
  
  captured_choices <- NULL
  
  local_mocked_bindings(
    interactive = function() TRUE,
    select.list = function(choices, ...) {
      captured_choices <<- choices
      "None"
    }
  )
  
  result2 <- with_mock_dir("prism-daily-ppt-2", {
    prism_archive_update(pd = pd)
  })
  
  # confirms prism_archive_update() correctly identified BOTH pd as
  # update_available and offered them as selectable choices
  expect_setequal(captured_choices, c("All", "None", pd))
  
  # user selected "None" -> nothing downloaded
  expect_equal(result2, character(0))
})
