
context("Test gen_dates")
d1 <- "2016-01-01"
test_that("gen_dates returns expected data", {
  expect_equal(
    class(gen_dates(minDate = "2016-01-01", maxDate = "2016-01-01", dates = NULL)),
    "Date"
  )
  expect_length(gen_dates(minDate = NULL, maxDate = NULL, dates = d1), 1)
  expect_length(
    gen_dates(minDate = NULL, maxDate = NULL, dates = c(d1,"2016-03-03", "2015-04-25")), 
    3
  )
  expect_length(
    gen_dates(minDate = "2015-01-01", maxDate = "2015-12-31", dates = NULL), 
    365
  )
  expect_length(gen_dates(minDate = d1, maxDate = "2016-12-31", dates = NULL), 366)
  expect_equal(
    gen_dates(minDate = d1, maxDate = d1, dates = NULL),
    gen_dates(minDate = NULL, maxDate = NULL, dates = d1)
  )
  expect_equal(
    gen_dates(minDate = NULL, maxDate = NULL, dates = d1),
    gen_dates(minDate = NULL, maxDate = NULL, dates = as.Date(d1))  
  )
})

test_that("gen_dates errors properly", {
  expect_error(gen_dates(minDate = "2016-01-01", maxDate = NULL, dates = "2016-01-02"),
               "You can enter a date range or a vector of dates, but not both")
  expect_error(gen_dates(minDate = NULL, maxDate = "2016-01-01", dates = "2016-01-02"),
               "You can enter a date range or a vector of dates, but not both")
  expect_error(gen_dates(minDate = "2016-01-01", maxDate = NULL, dates = NULL),
               "Both minDate and maxDate must be specified if specifying a date range")
  expect_error(gen_dates(minDate = NULL, maxDate = "2016-01-01", dates = NULL),
               "Both minDate and maxDate must be specified if specifying a date range")
  expect_error(gen_dates(minDate = "01-30-2016", maxDate = "2016-01-02", dates = NULL),
               "character string is not in a standard unambiguous format")
  expect_error(gen_dates(minDate = "2016-01-01", maxDate = "Jan 12, 2016", dates = NULL),
               "character string is not in a standard unambiguous format")
  expect_error(gen_dates(minDate = NULL, maxDate = NULL, dates = "12/15/2016"),
               "character string is not in a standard unambiguous format")
  expect_error(gen_dates(minDate = NULL, maxDate = NULL, dates = NULL),
               "You must specify either a date range (minDate and maxDate) or a vector of dates",
               fixed = TRUE)
  expect_error(gen_dates(minDate = "2016-01-10", maxDate = "2016-01-02", dates = NULL),
               "Your minimum date must be less than your maximum date")
  # check that dates that are specified wrong, but can convert to Date return an 
  # error because they fall outside the range of data available
  expect_error(gen_dates(minDate = "1/1/2016", maxDate = "2016/1/2", dates = NULL),
               "Please ensure minDate and maxData are within the available Prism data record")
  expect_error(gen_dates(minDate = NULL, maxDate = NULL, dates = c("1/1/2016", "1/2/2016", "2016/1/3")),
               "Please ensure all dates fall within the valid Prism data record")
})

