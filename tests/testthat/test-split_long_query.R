context("test-split_long_query.R")

test_that("can identify long queries", {
  q <- fmi_query(starttime = lubridate::make_date(2017))
  expect_true(is_long_query(q))

  q <- fmi_query(endtime = lubridate::make_date(2017))
  expect_false(is_long_query(q))

  q <- fmi_query("daily",
    starttime = lubridate::make_date(2017),
    endtime = lubridate::make_date(2018, 12, 31)
  )

  expect_length(fmi_split_long_query(q), 2)
})
