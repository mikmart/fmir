context("test-split_long_query.R")

test_that("can identify long queries", {
  q <- fmi_query(starttime = make_date(2017))
  expect_true(is_long_query(q))

  q <- fmi_query(endtime = make_date(2017))
  expect_false(is_long_query(q))
})
