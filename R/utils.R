is_date_or_dttm <- function(x)
{
  lubridate::is.Date(x) || lubridate::is.POSIXt(x)
}

dttm_iso_fmt <- function(x)
{
  stopifnot(is_date_or_dttm(x))
  format(x, format = "%Y-%m-%dT%H:%M:%SZ")
}
