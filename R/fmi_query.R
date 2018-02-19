#' Set your FMI API key
#'
#' Use \code{fmi_set_key} to save your personal API key in \code{options} for
#'   the duration of the R session so that it doesn't have to be manually
#'   specified each time you create a new query.
#'
#' @param api_key A length 1 character vector containing your personal FMI API
#'   key required to access the download service.
#' @seealso \href{https://en.ilmatieteenlaitos.fi/open-data}{FMI Open Data website}
#'   for obtaining a new API key.
#' @export
fmi_set_key <- function(api_key)
{
  stopifnot(is.character(api_key), length(api_key) == 1)
  options(fmir.api_key = api_key)
}


#' Construct a query to the FMI API
#'
#' @param type A length 1 character vector specifying the measurement interval
#'   of the observations to request
#' @param ... Name-value pairs of length 1 character vectors, used as query
#'   parameters. See details for possible values.
#' @inheritParams fmi_set_key
#'
#' @details
#' The list of possible parameters passed in \code{...} depends on the type and
#' format of the query being constructed. Query-specific parameters are fully
#' documented in the \href{http://en.ilmatieteenlaitos.fi/open-data-manual-fmi-wfs-services}{FMI Open Data Manual}.
#'
#' Common parameters include:
#'
#' \describe{
#'   \item{starttime, endtime}{A date or datetime specifying the start/end of the
#'     interval to request data for}
#'   \item{place}{A string specifying the place of measurement in general terms.
#'     E.g. \code{"Helsinki"}, \code{"Oulu"}}
#' }
#'
#' @return A length 1 character vector containing the URL for an FMI API query.
#' @seealso \code{\link{fmi_set_key}} for setting the API key for your session.
#' @export
fmi_query <- function(type = c("real-time", "daily", "monthly"),
                      ..., api_key = getOption("fmir.api_key"))
{
  stored_query <- fmi_stored_query(type)
  xml_url <- fmi_xml_url(stored_query, api_key)

  dots <- list(...)
  if (length(dots) == 0)
    return(xml_url)

  paste(xml_url, fmi_query_params(dots), sep = "&")
}


fmi_stored_query <- function(type = c("real-time", "daily", "monthly"),
                             format = c("simple", "timevaluepair"))
{
  type <- match.arg(type)
  format <- match.arg(format)

  if (format != "simple") {
    stop("invalid data format : ", format,
      "only simple format data is implemented at this time")
  }

  type <- if (type == "real-time") "" else paste0("::", type)
  paste0("fmi::observations::weather", type, "::simple")
}


fmi_xml_url <- function(stored_query, api_key = getOption("fmi.api_key"))
{
  if (is.null(api_key)) {
    warning("missing api key: you must supply `api_key` or set your ",
            "FMI API-key with `fmi_set_key` to generate a valid query url")
    api_key <- "insert-your-apikey-here"
  } else {
    stopifnot(is.character(api_key), length(api_key) == 1)
  }

  paste0("http://data.fmi.fi/fmi-apikey/", api_key,
         "/wfs?request=getFeature&storedquery_id=", stored_query)
}


fmi_query_params <- function(x)
{
  nm <- names(x)
  if (is.null(nm) || any(nm == ""))
    stop("unnamed query parameters supplied")

  if (any(lengths(x) > 1)) {
    vector_params <- x[lengths(x) > 1]
    stop("length > 1 parameters are not currently supported : ",
         paste(names(vector_params), collapse = ", "))
  }

  x <- purrr::map_if(x, is_date_or_dttm, dttm_iso_fmt)
  paste(collapse = "&", paste(nm, x, sep = "="))
}
