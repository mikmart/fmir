is_dateish <- function(x) {
  lubridate::is.Date(x) || lubridate::is.POSIXt(x)
}

fmi_format_date <- function(x) {
  stopifnot(is_dateish(x))
  format(x, format = "%Y-%m-%dT%H:%M:%SZ")
}

#' Turn a list into a character vector
#'
#' Use to turn a (possibly nested) list to a character vector. Names for the
#' output vector are taken from the names of the top level list.
#'
#' @param x list
#' @return named character vector
#' @noRd
squash_list <- function(x) {
  x <- purrr::map_if(x, purrr::is_bare_list, squash_list)
  nm <- rep(names(x), lengths(x))

  x <- purrr::map(x, as.character)
  x <- purrr::flatten(x)

  purrr::set_names(x, nm)
}
