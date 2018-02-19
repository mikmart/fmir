#' Download weather data from the FMI API
#'
#' Given a query, request data from the FMI API download service and parse the
#' XML response to a \code{tbl_df}.
#'
#' @param query a length 1 character vector containing the URL used to request
#'   data from the FMI API download service
#'
#' @return A \code{tbl_df} containing the requested data. Both the number and
#'   names of columns depend on the type and format of the query. See
#'   \code{\link{fmi_query}} for details.
#'
#' @seealso \code{\link{fmi_query}} for constructing the \code{query} argument
#' @export
fmi_data <- function(query)
{
  xml <- xml2::read_xml(query)

  tbl <- fmi_xml_to_tbl(xml)
  tbl <- tibble::as_tibble(tbl)
  
  if ("ParameterName" %in% names(tbl))
    tbl <- tidyr::spread_(tbl, "ParameterName", "ParameterValue")

  nm <- tolower(names(tbl))
  purrr::set_names(tbl, nm)
}

fmi_xml_to_tbl <- function(xml)
{
  vars <- purrr::set_names(fmi_xml_vars(xml))
  purrr::map_df(vars, fmi_xml_vals, xml = xml)
}

fmi_xml_vars <- function(xml)
{
  first_element <- xml2::xml_find_first(xml, "//BsWfs:BsWfsElement")
  purrr::map_chr(xml2::xml_children(first_element), xml2::xml_name)
}

fmi_xml_vals <- function(xml, variable_name, parser = readr::parse_guess, ...)
{
  variable_tag <- paste0("//BsWfs:", variable_name)
  xml_variable <- xml2::xml_find_all(xml, variable_tag)
  parser(xml2::xml_text(xml_variable), ...)
}
