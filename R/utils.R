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
