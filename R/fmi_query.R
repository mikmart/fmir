#' Construct a query to the FMI API
#'
#' @param type A length 1 character vector specifying the measurement interval
#'   of the observations to request
#' @param ... Name-value pairs of character vectors, used as query parameters.
#'   See details for possible values.
#'
#' @details The list of possible parameters passed in `...` depends on the type
#'   and format of the query being constructed. Query-specific parameters are
#'   fully documented in the [FMI Open Data
#'   Manual](http://en.ilmatieteenlaitos.fi/open-data-manual-fmi-wfs-services).
#'
#'   Common parameters include:
#'
#'   \describe{ \item{starttime, endtime}{A date or datetime specifying the
#'   start/end of the interval to request data for. These must be in the
#'   ISO-8601 format.} \item{place}{A string specifying the place of measurement
#'   in general terms. E.g. `"Helsinki"`, `"Oulu"`} }
#'
#' @return A character vector containing query URLs for the FMI API.
#' @seealso [fmi_data()] to request data from the API.
#' @examples
#' fmi_query("real-time", place = "Helsinki")
#' @export
fmi_query <- function(type = c("real-time", "daily", "monthly"), ...) {
  base_url <- fmi_base_url(type)
  params <- fmi_query_params(...)

  validate_query(new_query(base_url, params))
}

new_query <- function(base_url, params) {
  if (length(params) == 0) {
    return(base_url)
  }

  paste(base_url, params, sep = "&")
}

fmi_base_url <- function(type) {
  paste0(wfs_server_url, wfs_request("GetFeature"), fmi_stored_query(type))
}

wfs_server_url <- "https://opendata.fmi.fi/wfs?service=WFS&version=2.0.0"

wfs_request <- function(type) {
  switch(type,
    GetFeature = "&request=GetFeature&storedquery_id=",
    stop("Unknown request type supplied: ", type, call. = FALSE)
  )
}

fmi_stored_query <- function(type = c("real-time", "daily", "monthly")) {
  type <- match.arg(type)
  type <- if (type == "real-time") "" else paste0("::", type)
  paste0("fmi::observations::weather", type, "::simple")
}

fmi_query_params <- function(...) {
  x <- vctrs::vec_recycle_common(...)
  if (length(x) == 0) {
    return(character())
  }

  x <- purrr::map_if(x, is_dateish, fmi_format_date)
  purrr::pmap_chr(x, combine_params)
}

combine_params <- function(...) {
  x <- list(...)
  nm <- names(x)

  if (is.null(nm) || any(nm == "")) {
    stop("All query parameters must be named", call. = FALSE)
  }

  paste(collapse = "&", paste0(nm, "=", x))
}

validate_query <- function(x) {
  if (!is.character(x)) {
    type <- paste0(typeof(x), if (is.atomic(x)) " vector", ".")
    stop("Query must be a character vector, not a ", type, call. = FALSE)
  }

  x
}
