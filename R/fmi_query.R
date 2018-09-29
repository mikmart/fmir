#' Construct a query to the FMI API
#'
#' @param type A length 1 character vector specifying the measurement interval
#'   of the observations to request
#' @param ... Name-value pairs of character vectors, used as query parameters.
#'   See details for possible values.
#' @inheritParams fmi_set_key
#'
#' @details The list of possible parameters passed in `...` depends on the type
#' and format of the query being constructed. Query-specific parameters are
#' fully documented in the [FMI Open Data
#' Manual](http://en.ilmatieteenlaitos.fi/open-data-manual-fmi-wfs-services).
#'
#' Common parameters include:
#'
#' \describe{
#'   \item{starttime, endtime}{A date or datetime specifying the
#'   start/end of the interval to request data for}
#'   \item{place}{A string specifying the place of measurement in general
#'   terms. E.g. `"Helsinki"`, `"Oulu"`}
#' }
#'
#' @return A character vector containing query URLs for the FMI API.
#' @seealso [fmi_set_key()] for setting the API key for your session.
#' @examples
#' fmi_query("real-time", place = "Helsinki", api_key = "dummy")
#' @export
fmi_query <- function(type = c("real-time", "daily", "monthly"),
                      ..., api_key = fmi_get_key()) {
  base_url <- fmi_base_url(type, api_key)
  params <- fmi_query_params(...)

  validate_query(new_query(base_url, params))
}

new_query <- function(base_url, params) {
  if (length(params) == 0) {
    return(base_url)
  }

  paste(base_url, params, sep = "&")
}

fmi_base_url <- function(type, api_key = fmi_get_key()) {
  paste0(
    "http://data.fmi.fi/fmi-apikey/", validate_api_key(api_key),
    "/wfs?request=getFeature&storedquery_id=", fmi_stored_query(type)
  )
}

fmi_stored_query <- function(type = c("real-time", "daily", "monthly")) {
  type <- match.arg(type)
  type <- if (type == "real-time") "" else paste0("::", type)
  paste0("fmi::observations::weather", type, "::simple")
}

fmi_query_params <- function(...) {
  x <- vctrs::vec_recycle(...)
  nm <- names(x)

  if (is.null(nm) || any(nm == "")) {
    stop("All query parameters must be named", call. = FALSE)
  }

  x <- purrr::map_if(x, is_dateish, fmi_format_date)
  purrr::pmap_chr(x, combine_params)
}

combine_params <- function(...) {
  x <- list(...)
  nm <- names(x)
  paste(collapse = "&", paste(nm, x, sep = "="))
}

validate_query <- function(x) {
  if (!is.character(x)) {
    type <- paste0(typeof(x), if (is.atomic(x)) " vector", ".")
    stop("Query must be a character vector, not a ", type, call. = FALSE)
  }

  x
}
