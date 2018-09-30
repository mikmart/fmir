#' Daily weather in Oulu, Finland, in 2010-2017
#'
#' A dataset downloaded from the Finnish Meteorological Institute's open data
#' API using **fmir**. Contains daily simple weather observations from Oulu,
#' Finland, covering the years 2010 to 2017. The data are made available by the
#' [Finnish Meteorological Institute](https://en.ilmatieteenlaitos.fi) and are
#' licensed under [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).
#'
#' @format A data frame with 2922 rows and 8 variables:
#' \describe{
#'   \item{place}{city name}
#'   \item{location}{coordinates of the observation station}
#'   \item{time}{date of observation}
#'   \item{rrday}{precipitation rate}
#'   \item{snow}{snow depth}
#'   \item{tday}{average temperature, degrees Celcius}
#'   \item{tg_pt12h_min}{?}
#'   \item{tmax}{maximum temperature, degrees Celcius}
#'   \item{tmin}{minimum temperature, degrees Celcius}
#' }
#'
"ouludaily10"
