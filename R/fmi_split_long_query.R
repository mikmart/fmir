#' Split queries that exceed the maximum length for their type
#' @inheritParams fmi_data
#' @return A vector of queries with long queries split into multiple smaller
#'   ones.
#' @export
fmi_split_long_query <- function(query) {
  purrr::flatten_chr(purrr::map_if(query, is_long_query, query_split))
}


# is_long_query -----------------------------------------------------------

is_long_query <- function(query) {
  query_length(query) > query_length_limit(query_type(query))
}

query_length <- function(query) {
  start <- query_param_dttm(query, "starttime")

  # if endtime is missing and start is present, the actual query length
  # will be determined at the time the server receives the query
  # here we approximate end with current time, which is often good enough
  end <- query_param_dttm(query, "endtime")
  end[is.na(end)] <- lubridate::now()

  d <- as.double(difftime(end, start, units = "secs"))
  replace(d, is.na(start), -1) # if start missing => not too long
}

query_param_dttm <- function(query, param) {
  lubridate::as_datetime(query_param(query, param))
}

query_param <- function(query, param) {
  purrr::map_chr(query, list(httr::parse_url, "query", param), .default = NA)
}

query_type <- function(query) {
  rx <- "fmi::observations::weather::(\\w*)(::)?simple"
  type <- stringr::str_match(query, rx)[, 2L]
  ifelse(type == "", "real-time", type)
}

query_length_limit <- function(query_type) {
  unname(query_max_hours[query_type]) * 3600 # limit in seconds
}

query_max_hours <- c("real-time" = 168, "daily" = 8928, "monthly" = 87600)

query_split <- function(query) {
  start <- query_param(query, "starttime")
  start <- lubridate::as_datetime(start)
  # start can't be NA here because only called on overly long queries

  end <- query_param(query, "endtime")
  end <- lubridate::as_datetime(end)
  end <- replace(end, is.na(end), lubridate::now())

  width <- query_length_limit(query_type(query))
  timepoints <- purrr::map2(start, end, seq, by = width)
  timepoints <- purrr::map2(timepoints, end, ~ unique(c(.x, .y)))

  int <- purrr::map(timepoints, timepoints2intervals)
  int <- purrr::modify_depth(int, 2, fmi_format_date)
  n_splits <- purrr::map_int(int, ~ length(.x$start))

  int <- purrr::transpose(int)
  new <- purrr::map(int, purrr::flatten_chr)

  query <- rep(query, n_splits)

  query_param(query, "starttime") <- new$start
  query_param(query, "endtime") <- new$end

  query
}

timepoints2intervals <- function(x) {
  s <- head(x, -1)
  e <- tail(x, -1)
  e <- c(head(e, -1) - 1, tail(e, 1))

  list(start = s, end = e)
}

`query_param<-` <- function(query, param, value) {
  old_value <- query_param(query, param)

  rx <- stringr::str_glue("(?<={param}=)[^&]+")
  query <- stringr::str_replace(query, rx, value)

  ifelse(is.na(old_value), query_add_param(query, param, value), query)
}

query_add_param <- function(query, param, value) {
  paste0(query, "&", param, "=", value)
}
