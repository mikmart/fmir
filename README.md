
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fmir

[![Travis build
status](https://travis-ci.com/mikmart/fmir.svg?branch=master)](https://travis-ci.com/mikmart/fmir)
[![Coverage
status](https://codecov.io/gh/mikmart/fmir/branch/master/graph/badge.svg)](https://codecov.io/github/mikmart/fmir?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

**fmir** provides simple tools for easily accessing up to date, open
weather data from Finland. The data are made available by the [Finnish
Meteorological Institute](https://en.ilmatieteenlaitos.fi) and are
licensed under
[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Key features in **fmir** include:

  - Use simple R syntax to create queries for the FMI API
  - Flexibly download XML weather data from the API
  - Parse the XML response into a regular data frame

In order to access the download services of the API, you’ll need to
obtain a key by
[registering](https://ilmatieteenlaitos.fi/rekisteroityminen-avoimen-datan-kayttajaksi)
for open data use with FMI. See [FMI’s open data
manual](https://en.ilmatieteenlaitos.fi/open-data) for details.

FMI provides varying types of data in [several different
formats](https://en.ilmatieteenlaitos.fi/open-data-manual-fmi-wfs-services)
in their API, implemented using OGC Web Feature Service (WFS). Currently
the only format supported by **fmir** is the “simple” weather format.
For a more comprehensive and feature-rich package for accessing the FMI
API, check out <https://github.com/rOpenGov/fmi>.

## Installation

At the moment, the easiest way to install **fmir** is from github with
`devtools`:

``` r
# install.packages("devtools")
devtools::install_github("mikmart/fmir")
```

## Usage

To get started, set your API key for the session with `fmi_set_key()`:

``` r
library(fmir)
library(ggplot2)

# set your api key for your session
fmi_set_key("insert-your-apikey-here")
```

Once your key is set, you can construct queries to the API with
`fmi_query()` and then execute them with `fmi_data()`. A simple query
with only a `place` parameter will return weather observations with a
10-minute interval for the past 12 hours:

``` r
# generate a query url with fmi_query
q <- fmi_query(place = c("Espoo", "Oulu", "Rovaniemi"))

# download the data corresponding to your query
weather <- fmi_data(q)
weather
#> # A tibble: 216 x 14
#>    place location  time                p_sea  r_1h    rh ri_10min snow_aws
#>    <chr> <chr>     <dttm>              <dbl> <dbl> <dbl>    <dbl>    <dbl>
#>  1 Espoo 60.17802~ 2018-09-29 21:30:00 1008. NaN      97      0.4       -1
#>  2 Espoo 60.17802~ 2018-09-29 21:40:00 1007. NaN      95      0         -1
#>  3 Espoo 60.17802~ 2018-09-29 21:50:00 1007. NaN      95      0.5       -1
#>  4 Espoo 60.17802~ 2018-09-29 22:00:00 1007    0.9    94      0.1       -1
#>  5 Espoo 60.17802~ 2018-09-29 22:10:00 1007. NaN      94      0         -1
#>  6 Espoo 60.17802~ 2018-09-29 22:20:00 1007. NaN      93      0         -1
#>  7 Espoo 60.17802~ 2018-09-29 22:30:00 1007. NaN      92      0         -1
#>  8 Espoo 60.17802~ 2018-09-29 22:40:00 1006. NaN      91      0         -1
#>  9 Espoo 60.17802~ 2018-09-29 22:50:00 1006. NaN      90      0         -1
#> 10 Espoo 60.17802~ 2018-09-29 23:00:00 1006.   0      89      0         -1
#> # ... with 206 more rows, and 6 more variables: t2m <dbl>, td <dbl>,
#> #   vis <dbl>, wd_10min <dbl>, wg_10min <dbl>, ws_10min <dbl>

# draw a simple line graph of the recent temperature
ggplot(weather, aes(time, t2m)) + geom_line(aes(colour = place))
```

![](man/figures/README-basic-usage-1.png)<!-- -->

## In the wild

For a real use-case, check out Pasi Haapakorva’s [blog
post](https://haapakorva.fi/2018/09/26/2018-09-26-keskil%C3%A4mp%C3%B6tilan-muutos-kuukausittain-oulussa-1955-2018/)
(in Finnish) looking at the trend in monthly average temperatures in
Oulu in 1955–2018. Spoiler alert: it’s been getting warmer.
