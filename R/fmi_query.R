#' Construct a query to the FMI API
#'
#' @param type A length 1 character vector specifying the measurement interval
#'   of the observations to request
#' @param ... Name-value pairs of length 1 character vectors, used as query
#'   parameters. See details for possible values.
#' @param api_key A length 1 character vector containing your personal FMI
#'   API key required to access the download service.
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
#' @examples
#' fmi_query("real-time", place = "Helsinki", api_key = "dummy")
#' @export
fmi_query <- function(type = c("real-time", "daily", "monthly"),
                      ..., api_key = getOption("fmir.api_key"))
{
  base_url <- fmi_base_url(type, api_key)

  dots <- list(...)
  if (length(dots) == 0)
    return(base_url)

  paste(base_url, fmi_query_params(dots), sep = "&")
}

fmi_base_url <- function(type, api_key = getOption("fmir.api_key"))
{
  paste0("http://data.fmi.fi/fmi-apikey/", validate_api_key(api_key),
         "/wfs?request=getFeature&storedquery_id=", fmi_stored_query(type))
}

fmi_stored_query <- function(type = c("real-time", "daily", "monthly"))
{
  type <- match.arg(type)
  type <- if (type == "real-time") "" else paste0("::", type)
  paste0("fmi::observations::weather", type, "::simple")
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

  x <- purrr::map_if(x, is_dateish, fmi_format_date)
  paste(collapse = "&", paste(nm, x, sep = "="))
}


#' Set or get your FMI API key
#'
#' Use \code{fmi_set_key} to save your personal API key in \code{options} for
#'   the duration of the R session so that it doesn't have to be manually
#'   specified each time you create a new query. \code{fmi_get_key} is a
#'   convenience wrapper around \code{getOptions} so that you don't have to
#'   remember what the name of the option is to get your key.
#'
#' @param x A length 1 character vector containing your personal FMI API
#'   key required to access the download service.
#' @seealso \href{https://en.ilmatieteenlaitos.fi/open-data}{FMI Open Data website}
#'   for obtaining a new API key.
#' @export
fmi_set_key <- function(x)
{
  options(fmir.api_key = validate_api_key(x))
}

#' @export
#' @rdname fmi_set_key
fmi_get_key <- function()
{
  validate_api_key(getOption("fmir.api_key"))
}

validate_api_key <- function(x)
{
  if (is.null(x)) {
    warning("missing api key: you must supply `api_key` or set your ",
            "FMI API-key with `fmi_set_key` to generate a valid query url")
    return("insert-your-apikey-here")
  }
  stopifnot(is.character(x), length(x) == 1)
  x
}
