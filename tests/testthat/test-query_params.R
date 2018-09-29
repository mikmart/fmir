library(fmir)
context("Query parameters")

test_that("unnamed query parameters throw error", {
  expect_error(fmi_query_params(list()))
  expect_error(fmi_query_params(NULL))
  expect_error(fmi_query_params(NA_character_))
  expect_error(fmi_query_params(1))
  expect_error(fmi_query_params(a = 1, 2))
})

test_that("length != 1 query parameters throw error", {
  expect_error(fmi_query_params(a = 1:10))
  expect_error(fmi_query_params(a = 1, b = letters))
  expect_error(fmi_query_params(a = 1, b = character(0)))
})

test_that("query parameters are concatenated correctly", {
  expect_equal(fmi_query_params(a = 1), "a=1")
  expect_equal(fmi_query_params(a = 1, b = 2), "a=1&b=2")
  expect_equal(fmi_query_params(a = 1, b = 2, c = 3), "a=1&b=2&c=3")
  expect_equal(fmi_query_params(a = 1, a = 2), "a=1&a=2")
})
