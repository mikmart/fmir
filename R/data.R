#' Daily weather in Oulu, Finland, in 2010-2017
#'
#' A dataset downloaded from the Finnish Meteorological Institute's open data
#' API using `fmir`. Contains daily simple weather observations from Oulu,
#' Finland, covering the years 2010 to 2017.
#'
#' @format A data frame with 2922 rows and 8 variables:
#' \describe{
#'   \item{location}{coordinates of the observation station}
#'   \item{time}{date of observation, UTC + 2}
#'   \item{rrday}{precipitation rate}
#'   \item{snow}{snow depth}
#'   \item{tday}{average temperature of the day, degrees Celcius}
#'   \item{tg_pt12h_min}{?}
#'   \item{tmax}{maximum temperature of the day, degrees Celcius}
#'   \item{tmin}{minimum temperature of the day, degrees Celcius}
#' }
#'
"ouludaily10"