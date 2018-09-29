context("Query parameters")

test_that("unnamed query parameters throw error", {
  expect_error(fmi_query_params(1), "must be named")
  expect_error(fmi_query_params(a = 1, 2), "must be named")

  # unless there aren't any
  expect_equal(fmi_query_params(), character())
})

test_that("query parameters are concatenated correctly", {
  expect_equal(fmi_query_params(a = 1), "a=1")
  expect_equal(fmi_query_params(a = 1, b = 2), "a=1&b=2")
  expect_equal(fmi_query_params(a = 1, a = 2), "a=1&a=2")
})

test_that("can extract parameters from queries", {
  q <- fmi_query(place = "Oulu", starttime = lubridate::make_date(2017))
  expect_equal(query_param(q, "place"), "Oulu")
  expect_equal(query_param(q, "starttime"), "2017-01-01T00:00:00Z")
  expect_equal(query_param(q, "endtime"), NA_character_)

  q <- fmi_query(place = c("Oulu", "Espoo"))
  expect_equal(query_param(q, "place"), c("Oulu", "Espoo"))
})

test_that("can add new query parameters", {
  q <- fmi_query()
  query_param(q, "place") <- "Espoo"

  expect_equal(query_param(q, "place"), "Espoo")
})

test_that("can replace existing query parameters", {
  q <- fmi_query(place = "Oulu")
  query_param(q, "place") <- "Espoo"

  expect_equal(query_param(q, "place"), "Espoo")
})
