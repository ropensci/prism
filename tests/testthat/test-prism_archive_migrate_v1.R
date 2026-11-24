test_that("V1 folder names convert to V2 prism data names", {
  expect_identical(
    prism:::prism_v1_folder_to_v2_pd(
      "PRISM_ppt_stable_4kmD2_19910101_bil"
    ),
    "prism_ppt_us_25m_19910101"
  )
  expect_identical(
    prism:::prism_v1_folder_to_v2_pd(
      "PRISM_tmin_stable_4kmM3_198712_bil"
    ),
    "prism_tmin_us_25m_198712"
  )
  expect_identical(
    prism:::prism_v1_folder_to_v2_pd(
      "PRISM_tmax_stable_800mM2_200207_bil"
    ),
    "prism_tmax_us_30s_200207"
  )
  expect_identical(
    prism:::prism_v1_folder_to_v2_pd(
      "PRISM_ppt_stable_4kmD2_2000_bil"
    ),
    "prism_ppt_us_25m_2000"
  )
  expect_true(is.na(prism:::prism_v1_folder_to_v2_pd("prism_ppt_us_25m_2000")))
  expect_true(is.na(prism:::prism_v1_folder_to_v2_pd("PRISM_unknown_stable_4kmD2_2000_bil")))
})

test_that("prism_archive_migrate_v1() supports no-op and update modes", {
  root <- tempfile("prism-migrate-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE))

  old <- c(
    "PRISM_ppt_stable_4kmD2_19910101_bil",
    "PRISM_tmin_stable_4kmM3_198712_bil"
  )
  for (folder in old) dir.create(file.path(root, folder))

  downloaded_calls <- character(0)

  local_mocked_bindings(
    get_prism_pd = function(pd, keepZip, overwrite) {
      downloaded_calls <<- c(downloaded_calls, pd)
      for (folder in pd) dir.create(file.path(root, folder), recursive = TRUE)
      pd
    }
  )

  skipped <- prism_archive_migrate_v1(root, action = "none", quiet = TRUE)
  expect_setequal(skipped$status, "skipped")
  expect_length(downloaded_calls, 0)
  expect_true(all(dir.exists(file.path(root, old))))

  migrated <- prism_archive_migrate_v1(root, action = "update", quiet = TRUE)
  expect_setequal(migrated$status, "migrated")
  expect_setequal(downloaded_calls, c(
    "prism_ppt_us_25m_19910101",
    "prism_tmin_us_25m_198712"
  ))
  expect_true(all(!dir.exists(file.path(root, old))))
  expect_true(all(dir.exists(file.path(root, migrated$v2_pd))))
})

test_that("prism_archive_migrate_v1() supports all and selected folders", {
  root <- tempfile("prism-migrate-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE))

  old <- c(
    "PRISM_ppt_stable_4kmD2_19910101_bil",
    "PRISM_tmin_stable_4kmM3_198712_bil"
  )
  for (folder in old) dir.create(file.path(root, folder))

  captured_pd <- character(0)
  local_mocked_bindings(
    get_prism_pd = function(pd, keepZip, overwrite) {
      captured_pd <<- pd
      for (folder in pd) dir.create(file.path(root, folder), recursive = TRUE)
      pd
    }
  )

  selected <- prism_archive_migrate_v1(
    root,
    action = old[[1]],
    quiet = TRUE
  )
  expect_equal(nrow(selected), 1)
  expect_equal(selected$v1_folder, old[[1]])
  expect_false(dir.exists(file.path(root, old[[1]])))
  expect_true(dir.exists(file.path(root, old[[2]])))

  captured_pd <- character(0)
  selected <- prism_archive_migrate_v1(root, action = "all", quiet = TRUE)
  expect_equal(nrow(selected), 1)
  expect_equal(selected$v1_folder, old[[2]])
  expect_equal(captured_pd, "prism_tmin_us_25m_198712")
  expect_false(dir.exists(file.path(root, old[[2]])))
})

test_that("prism_archive_migrate_v1() is non-destructive on failed download", {
  root <- tempfile("prism-migrate-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE))

  old <- "PRISM_ppt_stable_4kmD2_19910101_bil"
  dir.create(file.path(root, old))

  local_mocked_bindings(
    get_prism_pd = function(pd, keepZip, overwrite) character(0)
  )

  result <- prism_archive_migrate_v1(root, action = "all", quiet = TRUE)

  expect_equal(result$status, "failed")
  expect_true(dir.exists(file.path(root, old)))
})

test_that("prism_archive_migrate_v1() prompts in interactive mode", {
  root <- tempfile("prism-migrate-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE))

  old <- "PRISM_ppt_stable_4kmD2_19910101_bil"
  dir.create(file.path(root, old))
  captured_choices <- NULL

  local_mocked_bindings(
    interactive = function() TRUE,
    select.list = function(choices, ...) {
      captured_choices <<- choices
      "None"
    },
    get_prism_pd = function(pd, keepZip, overwrite) pd
  )

  result <- prism_archive_migrate_v1(root, quiet = TRUE)

  expect_setequal(captured_choices, c("All", "None", old))
  expect_equal(result$status, "skipped")
  expect_true(dir.exists(file.path(root, old)))
})
