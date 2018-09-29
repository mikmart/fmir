#' Construct a query to the FMI API
#'
#' @param type A length 1 character vector specifying the measurement interval
#'   of the observations to request
#' @param ... Name-value pairs of length 1 character vectors, used as query
#'   parameters. See details for possible values.
#' @inheritParams fmi_set_key
#'
#' @details
#' The list of possible parameters passed in `...` depends on the type and
#' format of the query being constructed. Query-specific parameters are fully
#' documented in the [FMI Open Data Manual](http://en.ilmatieteenlaitos.fi/open-data-manual-fmi-wfs-services).
#'
#' Common parameters include:
#'
#' \describe{
#'   \item{starttime, endtime}{A date or datetime specifying the start/end of the
#'     interval to request data for}
#'   \item{place}{A string specifying the place of measurement in general terms.
#'     E.g. `"Helsinki"`, `"Oulu"`}
#' }
#'
#' @return A length 1 character vector containing the URL for an FMI API query.
#' @seealso [fmi_set_key()] for setting the API key for your session.
#' @examples
#' fmi_query("real-time", place = "Helsinki", api_key = "dummy")
#' @export
fmi_query <- function(type = c("real-time", "daily", "monthly"),
                      ..., api_key = fmi_get_key()) {
  base_url <- fmi_base_url(type, api_key)

  dots <- list(...)
  if (length(dots) == 0) {
    return(base_url)
  }

  paste(base_url, fmi_query_params(dots), sep = "&")
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

fmi_query_params <- function(x) {
  nm <- names(x)

  if (is.null(nm) || any(nm == "")) {
    stop("All query parameters must be named", call. = FALSE)
  }

  if (any(lengths(x) != 1)) {
    bad <- x[lengths(x) != 1]
    bad <- paste("  *", names(bad), "has length", lengths(bad))

    msg <- paste0(
      "All query parameters must have length 1:\n",
      paste(bad, collapse = "\n")
    )

    stop(msg, call. = FALSE)
  }

  x <- purrr::map_if(x, is_dateish, fmi_format_date)
  paste(collapse = "&", paste(nm, x, sep = "="))
}
