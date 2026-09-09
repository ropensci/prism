# ------------------------------------------------------------------
# PRISM R package (v0.3.0) capability test matrix
#
# Tests every combination of:
#   variable  x  resolution  x  download function
# recording whether the call succeeds and, for successes, whether the
# downloaded folder contains a *.txt file and a *.stn.csv file.
#
# Each test uses a clean, temporary download directory that is deleted
# after inspection (keepZip = FALSE, delete after inspection).
# ------------------------------------------------------------------

.libPaths(c("/home/user/Rlibs", .libPaths()))
library(prism)
options(timeout = 600)   # per-file download timeout (seconds)

vars <- c("tmean", "tmin", "tmax", "tdmean", "ppt",
          "vpdmin", "vpdmax",
          "solclear", "solslope", "soltotal", "soltrans")
resolutions <- c("4km", "800m")

# single, recent test period for every function
TEST_YEAR  <- 2023
TEST_MONTH <- 6
TEST_DAY   <- "2023-06-15"
NORM_MONTH <- 6
NORM_DAY   <- "0615"   # normals ignore the year

root <- "/home/user/workspace/prism_runs"
dir.create(root, showWarnings = FALSE, recursive = TRUE)
out_csv <- "/home/user/workspace/prism_test_matrix.csv"

# ---- one test ----------------------------------------------------
run_one <- function(fun_label, var, res, expr_fun) {
  dl <- file.path(root, paste0("t_", as.integer(runif(1, 1, 1e9))))
  dir.create(dl, showWarnings = FALSE, recursive = TRUE)
  suppressMessages(prism_set_dl_dir(dl))

  msgs <- character(0)
  t0 <- Sys.time()
  status <- "success"
  err <- ""

  res_try <- try(
    withCallingHandlers(
      suppressMessages(expr_fun(var, res)),
      warning = function(w) {
        msgs <<- c(msgs, paste0("WARN: ", conditionMessage(w)))
        invokeRestart("muffleWarning")
      }
    ),
    silent = TRUE
  )

  if (inherits(res_try, "try-error")) {
    status <- "fail"
    err <- gsub("[\r\n]+", " ", conditionMessage(attr(res_try, "condition")))
  }

  all_files <- list.files(dl, recursive = TRUE, full.names = FALSE)
  folders   <- list.dirs(dl, recursive = FALSE, full.names = FALSE)
  data_files <- grep("\\.(bil|tif|tiff)$", all_files, ignore.case = TRUE, value = TRUE)

  # a call that "worked" but downloaded nothing is recorded as no_data
  if (status == "success" && length(data_files) == 0) {
    status <- "no_data"
    if (length(msgs)) err <- paste(msgs, collapse = " | ")
  }
  if (status == "fail" && length(msgs)) err <- paste(c(err, msgs), collapse = " | ")

  has_txt <- any(grepl("\\.txt$", all_files, ignore.case = TRUE))
  has_stn <- any(grepl("\\.stn\\.csv$", all_files, ignore.case = TRUE))

  size_mb <- round(sum(file.info(list.files(dl, recursive = TRUE,
                                            full.names = TRUE))$size,
                       na.rm = TRUE) / 1024^2, 2)

  row <- data.frame(
    fun          = fun_label,
    variable     = var,
    resolution   = res,
    status       = status,
    n_folders    = length(folders),
    folder_name  = if (length(folders)) folders[1] else "",
    n_files      = length(all_files),
    data_format  = if (length(data_files))
                     paste(unique(toupper(tools::file_ext(data_files))), collapse = ",") else "",
    has_txt      = if (status == "success") has_txt else NA,
    has_stn_csv  = if (status == "success") has_stn else NA,
    all_ext      = paste(sort(unique(tolower(sub("^.*?(\\.stn\\.csv|\\.[^.]+)$", "\\1",
                                                 basename(all_files))))), collapse = " "),
    size_mb      = size_mb,
    secs         = round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1),
    message      = substr(err, 1, 400),
    stringsAsFactors = FALSE
  )

  unlink(dl, recursive = TRUE, force = TRUE)   # delete after inspection
  row
}

# ---- the six function/mode combinations --------------------------
funs <- list(
  "get_prism_annual()" = function(v, r)
    get_prism_annual(type = v, years = TEST_YEAR, keepZip = FALSE, resolution = r),

  "get_prism_monthlys()" = function(v, r)
    get_prism_monthlys(type = v, years = TEST_YEAR, mon = TEST_MONTH,
                       keepZip = FALSE, resolution = r),

  "get_prism_dailys()" = function(v, r)
    get_prism_dailys(type = v, dates = TEST_DAY, keepZip = FALSE, resolution = r),

  "get_prism_normals() annual" = function(v, r)
    get_prism_normals(type = v, resolution = r, annual = TRUE, keepZip = FALSE),

  "get_prism_normals() monthly" = function(v, r)
    get_prism_normals(type = v, resolution = r, mon = NORM_MONTH, keepZip = FALSE),

  "get_prism_normals() daily" = function(v, r)
    get_prism_normals(type = v, resolution = r, day = NORM_DAY, keepZip = FALSE)
)

# resume support: skip combinations already logged
done <- character(0)
results <- list()
if (file.exists(out_csv)) {
  prev <- read.csv(out_csv, stringsAsFactors = FALSE)
  if (nrow(prev)) {
    done <- paste(prev$fun, prev$variable, prev$resolution)
    results <- split(prev, seq_len(nrow(prev)))
  }
}

i <- 0
for (fl in names(funs)) {
  for (v in vars) {
    for (r in resolutions) {
      i <- i + 1
      if (paste(fl, v, r) %in% done) next
      cat(sprintf("[%3d/132] %-28s %-9s %-5s ... ", i, fl, v, r))
      row <- run_one(fl, v, r, funs[[fl]])
      cat(row$status, sprintf("(%.0fs)\n", row$secs))
      results[[length(results) + 1]] <- row
      write.csv(do.call(rbind, results), out_csv, row.names = FALSE)
    }
  }
}

cat("\nDone. Results written to ", out_csv, "\n", sep = "")
