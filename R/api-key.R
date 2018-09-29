#' Set or get your FMI API key
#'
#' Use `fmi_set_key()` to save your personal API key in `options` for the
#' duration of the R session so that it doesn't have to be manually specified
#' each time you create a new query. Alternatively, you can also set an
#' environment variable called `FMIR_API_KEY` in your `.Renviron` file to
#' persistently remember the API key. `fmi_get_key()` gets your API key by
#' checking the session option first (so you can change the key for your
#' session) and falls back to checking the environment variable.
#'
#' @param api_key A length 1 character vector containing your personal FMI API
#'   key required to access the download service.
#' @seealso \href{https://en.ilmatieteenlaitos.fi/open-data}{FMI Open Data
#'   website} for obtaining a new API key.
#' @export
fmi_set_key <- function(api_key) {
  options(fmir.api_key = validate_api_key(api_key))
}

#' @export
#' @rdname fmi_set_key
#' @importFrom purrr %||%
fmi_get_key <- function() {
  validate_api_key(getOption("fmir.api_key") %||% Sys.getenv("FMIR_API_KEY"))
}

validate_api_key <- function(x) {
  if (is.null(x)) {
    msg <- paste0(
      "API key not found, using dummy key instead. ",
      "The query will not be valid.\n",
      "  Did you know that you can use `fmi_set_key()` ",
      "to remember your key for the session?"
    )
    warning(msg, call. = FALSE)
    return("insert-your-apikey-here")
  }

  if (is.na(x)) {
    stop("The API key must not be missing (NA)", call. = FALSE)
  }

  if (!is.character(x) || length(x) != 1) {
    msg <- paste0(
      "The API key must be a character vector of length 1, not a ",
      typeof(x), if (is.atomic(x)) " vector", " of length ", length(x)
    )
    stop(msg, call. = FALSE)
  }

  x
}
