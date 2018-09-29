library(fmir)
context("API key validation")

test_that("null API key warns and returns dummy", {
  expect_warning(validate_api_key(NULL), "not found")
  expect_is(suppressWarnings(validate_api_key(NULL)), "character")
})

test_that("non-null API key validation works", {
  expect_error(validate_api_key(1))
  expect_error(validate_api_key(mtcars))
  expect_error(validate_api_key(letters))
  expect_error(validate_api_key(NA_character_))
})
