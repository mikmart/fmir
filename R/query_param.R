query_param <- function(query, param) {
  purrr::map_chr(query, list(httr::parse_url, "query", param), .default = NA)
}

query_param_dttm <- function(query, param) {
  lubridate::as_datetime(query_param(query, param))
}

`query_param<-` <- function(query, param, value) {
  purrr::map2_chr(query, value, assign_param, param = param)
}

assign_param <- function(query, param, value) {
  url <- httr::parse_url(query)
  url$query[[param]] <- value
  httr::build_url(url)
}
