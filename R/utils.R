is_dateish <- function(x)
{
  lubridate::is.Date(x) || lubridate::is.POSIXt(x)
}

fmi_format_date <- function(x)
{
  stopifnot(is_dateish(x))
  format(x, format = "%Y-%m-%dT%H:%M:%SZ")
}
