context("Flattening lists")

test_that("lists of any depth get flattened", {
  expect_equal(squash_list(list(a = 1)), list(a = "1"))
  expect_equal(squash_list(list(a = list(1, 2))), list(a = "1", a = "2"))
  expect_equal(squash_list(list(a = list(1, list(2)))), list(a = "1", a = "2"))
})

test_that("output names come from top level", {
  expect_equal(squash_list(list(a = list(b = 1))), list(a = "1"))
  expect_equal(squash_list(list(list(b = 1))), list("1"))
})
