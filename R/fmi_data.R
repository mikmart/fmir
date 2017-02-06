#' Download weather data from the FMI API
#'
#' @param query a length 1 character vector containing the URL used to request data from the FMI API download service
#'
#' @return a \code{tbl_df} containing the requested data
#' @export
fmi_data <- function(query)
{
  xml <- xml2::read_xml(query)

  tbl <- fmi_xml_to_tbl(xml)
  if ("ParameterName" %in% names(tbl))
    tbl <- tidyr::spread_(tbl, "ParameterName", "ParameterValue")

  nm <- tolower(names(tbl))
  purrr::set_names(tbl, nm)
}

fmi_xml_to_tbl <- function(xml)
{
  var_names <- purrr::set_names(fmi_xml_vars(xml))
  df <- purrr::map_df(var_names, fmi_xml_vals, xml = xml)
  tibble::as_tibble(df)
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
