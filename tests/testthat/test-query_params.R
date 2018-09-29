context("Query parameters")

test_that("unnamed query parameters throw error", {
  expect_error(fmi_query_params(list()))
  expect_error(fmi_query_params(NULL))
  expect_error(fmi_query_params(NA_character_))
  expect_error(fmi_query_params(1))
  expect_error(fmi_query_params(a = 1, 2))
})

test_that("query parameters are concatenated correctly", {
  expect_equal(fmi_query_params(a = 1), "a=1")
  expect_equal(fmi_query_params(a = 1, b = 2), "a=1&b=2")
  expect_equal(fmi_query_params(a = 1, b = 2, c = 3), "a=1&b=2&c=3")
  expect_equal(fmi_query_params(a = 1, a = 2), "a=1&a=2")
})

test_that("can extract parameters from queries", {
  expect_equal(query_param("https://domain.com/q?foo=bar", "foo"), "bar")
  expect_equal(query_param("https://domain.com/q?foo=bar&baz=1", "foo"), "bar")
  expect_equal(query_param(c("?foo=bar", "?foo=2"), "foo"), c("bar", "2"))
  expect_equal(query_param(c("?foo=bar", ""), "foo"), c("bar", NA))

  q <- fmi_query(place = "Oulu", starttime = lubridate::make_date(2017))
  expect_equal(query_param(q, "place"), "Oulu")
  expect_equal(query_param(q, "starttime"), "2017-01-01T00:00:00Z")
  expect_equal(query_param(q, "endtime"), NA_character_)

  q <- fmi_query(place = c("Oulu", "Espoo"))
  expect_equal(query_param(q, "place"), c("Oulu", "Espoo"))
})
