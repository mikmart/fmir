#' Set your FMI API key
#'
#' \code{fmi_set_key} saves your API key in your \code{options} for the duration
#'   of your R session so that you don't have to manually specify it each time
#'   you create a new query.
#'
#' @param api_key a length 1 character vector containing your personal FMI API
#'   key required to access the download service
#' @export
fmi_set_key <- function(api_key)
{
  stopifnot(is.character(api_key), length(api_key) == 1)
  options(fmi.api_key = api_key)
}

is_date_or_dttm <- function(x)
{
  lubridate::is.Date(x) || lubridate::is.POSIXt(x)
}

dttm_iso_fmt <- function(x)
{
  stopifnot(is_date_or_dttm(x))
  format(x, format = "%Y-%m-%dT%H:%M:%SZ")
}
