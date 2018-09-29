#' Download weather data from the FMI API
#'
#' Given a query, request data from the FMI API download service and parse the
#' XML response to a `tbl_df`.
#'
#' @param query a length 1 character vector containing the URL used to request
#'   data from the FMI API download service
#'
#' @return A `tbl_df` containing the requested data. Both the number and
#'   names of columns depend on the type and format of the query. See
#'   [fmi_query()] for details.
#'
#' @seealso [fmi_query()] for constructing the `query` argument
#' @export
fmi_data <- function(query)
{
  xml <- xml2::read_xml(validate_query(query))

  tbl <- fmi_xml_to_df(xml)
  tbl <- tibble::as_tibble(tbl)

  if ("ParameterName" %in% names(tbl))
    tbl <- tidyr::spread_(tbl, "ParameterName", "ParameterValue")

  nm <- tolower(names(tbl))
  purrr::set_names(tbl, nm)
}

fmi_xml_to_df <- function(xml)
{
  vars <- purrr::set_names(fmi_xml_vars(xml))
  purrr::map_df(vars, fmi_xml_vals, xml = xml)
}

fmi_xml_vars <- function(xml)
{
  first_element <- xml2::xml_find_first(xml, "//BsWfs:BsWfsElement")
  purrr::map_chr(xml2::xml_children(first_element), xml2::xml_name)
}

fmi_xml_vals <- function(xml, var, parser = readr::parse_guess, ...)
{
  var_tag <- paste0("//BsWfs:", var)
  xml_var <- xml2::xml_find_all(xml, var_tag)
  parser(xml2::xml_text(xml_var), ...)
}

validate_query <- function(x) {
  if (!is.character(x)) {
    msg <- paste0(
      "Query must be a character vector, not a ",
      typeof(x), if (is.atomic(x)) " vector"
    )

    stop(msg, call. = FALSE)
  }

  if (length(x) != 1) {
    msg <- paste0("Query must have length 1, not ", length(x))

    if (length(x) > 1) {
      msg <- paste0(
        msg, "\nDid your query get split into multiple",
        "queries automatically by `fmi_query()`?"
      )
    }

    stop(msg, call. = FALSE)
  }

  x
}
