is_long_query <- function(query) {
  query_length(query) > query_length_limit(query)
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

query_length_limit <- function(query) {
  unname(query_max_hours[query_type(query)]) * 3600 # limit in seconds
}

query_max_hours <- c("real-time" = 168, "daily" = 8928, "monthly" = 87600)

query_type <- function(query) {
  rx <- "fmi::observations::weather::(\\w*)(::)?simple"
  type <- purrr::map_chr(regmatches(query, regexec(rx, query)), 2)
  replace(type, type == "", "real-time")
}
