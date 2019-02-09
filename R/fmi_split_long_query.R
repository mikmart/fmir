#' Split queries that exceed the maximum length for their type
#' @inheritParams fmi_data
#' @return A vector of queries with long queries split into multiple smaller
#'   ones.
#' @noRd
fmi_split_long_query <- function(query) {
  purrr::flatten_chr(purrr::map_if(query, is_long_query, query_split))
}

query_split <- function(query) {
  start <- query_param_dttm(query, "starttime")
  # start can't be NA here because this is only called on long queries,
  # and queries with a missing start can't be long queries

  end <- query_param_dttm(query, "endtime")
  end[is.na(end)] <- lubridate::now()

  width <- query_length_limit(query_type(query))
  timepoints <- purrr::map2(start, end, seq, by = width)

  # if width didn't equally divide the start-end interval, need to
  # ensure that it's still included in in the resulting intervals
  timepoints <- purrr::map2(timepoints, end, ~ unique(c(.x, .y)))

  # at this point we have "timelines" for each query
  # need to turn those into a list of start-end times
  intervals <- purrr::map(timepoints, timepoints2intervals)

  # transpose discards S3 classes so need times as character
  intervals <- purrr::modify_depth(intervals, 2, fmi_format_date)
  new <- purrr::map(purrr::transpose(intervals), purrr::flatten_chr)

  # how many sub-queries did each query get turned into?
  n_splits <- purrr::map_int(intervals, ~ length(.x$start))
  query <- rep(query, n_splits)

  query_param(query, "starttime") <- new$start
  query_param(query, "endtime") <- new$end

  query
}

timepoints2intervals <- function(x) {
  starts <- head(x, -1)
  ends <- tail(x, -1)

  # discrete intervals: ensure they don't overlap
  ends <- c(head(ends, -1) - 1, tail(ends, 1))

  list(start = starts, end = ends)
}
