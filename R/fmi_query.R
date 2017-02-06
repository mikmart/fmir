fmi_query <- function(type = c("real-time", "daily", "monthly"),
                      ..., api_key = getOption("fmi.api_key"))
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
