#' Download weather data from the FMI API
#'
#' Given a query, request data from the FMI API download service and parse the
#' XML response to a `tbl_df`.
#'
#' @param query a character vector containing the URL used to request data from
#'   the FMI API download service
#'
#' @return A `tbl_df` containing the requested data. Both the number and names
#'   of columns depend on the type and format of the query. See [fmi_query()]
#'   for details.
#'
#' @seealso [fmi_query()] for constructing the `query` argument
#' @export
fmi_data <- function(query) {
  query <- fmi_split_long_query(query)
  if (length(query) > 1) {
    return(purrr::map_df(query, fmi_data))
  }

  xml <- xml2::read_xml(validate_query(query))

  tbl <- fmi_xml_to_df(xml)
  tbl <- tibble::as_tibble(tbl)

  if ("ParameterName" %in% names(tbl)) {
    tbl <- tidyr::spread_(tbl, "ParameterName", "ParameterValue")
  }

  janitor::clean_names(tbl)
}

fmi_xml_to_df <- function(xml) {
  vars <- purrr::set_names(fmi_xml_vars(xml))
  purrr::map_df(vars, fmi_xml_vals, xml = xml)
}

fmi_xml_vars <- function(xml) {
  first_element <- xml2::xml_find_first(xml, "//BsWfs:BsWfsElement")
  purrr::map_chr(xml2::xml_children(first_element), xml2::xml_name)
}

fmi_xml_vals <- function(xml, var) {
  var_tag <- paste0("//BsWfs:", var)
  xml_var <- xml2::xml_find_all(xml, var_tag)
  readr::parse_guess(xml2::xml_text(xml_var))
}
