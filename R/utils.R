is_dateish <- function(x) {
  lubridate::is.Date(x) || lubridate::is.POSIXt(x)
}

fmi_format_date <- function(x) {
  stopifnot(is_dateish(x))
  format(x, format = "%Y-%m-%dT%H:%M:%SZ")
}

delay_by <- function(ms, f) {
  force(f)
  force(ms)
  function(...) {
    Sys.sleep(ms / 1000)
    f(...)
  }
}

prepend_column <- function(.data, ...) {
  tibble::add_column(.data, ..., .before = 1L)
}
