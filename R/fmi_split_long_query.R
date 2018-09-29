#' Split queries that exceed the maximum length for their type
#' @inheritParams fmi_data
#' @return A vector of queries with long queries split into multiple smaller
#'   ones.
#' @export
fmi_split_long_query <- function(query) {
  purrr::flatten_chr(purrr::map_if(query, is_long_query, query_split))
}

is_long_query <- function(query) {
  query_length(query) > query_length_limit(query_type(query))
}

query_length <- function(query) {
  start <- query_param(query, "starttime")
  start <- lubridate::as_datetime(start)

  end <- query_param(query, "endtime")
  end <- lubridate::as_datetime(end)
  end <- replace(end, is.na(end), lubridate::now())

  d <- as.double(difftime(end, start, units = "secs"))
  replace(d, is.na(d), -1) # if NA => start missing => not too long
}

query_param <- function(query, name) {
  url <- purrr::map(query, httr::parse_url)
  param <- purrr::map(url, c("query", name))
  param <- purrr::modify_if(param, is.null, ~ NA)
  purrr::flatten_chr(param)
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

  new <- purrr::map(timepoints, timepoints2intervals)
  new <- purrr::modify_depth(new, 2, fmi_format_date)
  query <- rep(query, purrr::map_int(new, ~ length(.x$start)))

  new <- purrr::transpose(new)
  new <- purrr::map(new, purrr::flatten_chr)

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
