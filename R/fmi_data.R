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
  query <- validate_query(query)
  query <- fmi_split_long_query(query)

  if (length(query) > 1) {
    return(purrr::map_df(query, delay_by(100, fmi_data)))
  }

  response <- httr::GET(query)
  fmi_validate_response(response)

  xml <- httr::content(response)

  tbl <- fmi_xml_to_df(xml)
  tbl <- fmi_data_tidy(tbl)

  place <- query_param(query, "place")
  prepend_column(tbl, place = place)
}

fmi_validate_response <- function(response) {
  if (!httr::http_error(response)) {
    return(response)
  }

  error_text <- fmi_parse_error(response)
  stop(error_text, call. = FALSE)
}

fmi_parse_error <- function(response) {
  content <- httr::content(response)

  nodes <- xml2::xml_find_all(content, "//d1:ExceptionText")
  text <- purrr::discard(xml2::xml_text(nodes), startsWith, "URI")

  message <- httr::http_status(response)$message
  paste(c(message, text), collapse = "\n")
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

fmi_data_tidy <- function(tbl) {
  if ("ParameterName" %in% names(tbl)) {
    tbl <- tidyr::spread(tbl, "ParameterName", "ParameterValue")
  }

  janitor::clean_names(tbl)
}
