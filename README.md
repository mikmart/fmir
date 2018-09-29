
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fmir

[![Travis build
status](https://travis-ci.org/mikmart/fmir.svg?branch=master)](https://travis-ci.org/mikmart/fmir)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

The `fmir` package provides tools for easily accessing up to date, open
weather data from Finland. The data are made available by the [Finnish
Meteorological Institute](https://en.ilmatieteenlaitos.fi) and are
licensed under
[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/). Key features
of the package include:

  - Use simple R syntax to create queries for the FMI API
  - Download XML weather data from the API
  - Parse the XML data to a regular data frame

FMI provides data in [several different
formats](https://en.ilmatieteenlaitos.fi/open-data-manual-fmi-wfs-services)
in their API, implemented using OGC Web Feature Service (WFS). Currently
the only format supported by `fmir` is the “simple” format.

In order to access the download services of the FMI open data API,
you’ll need to obtain an API key by registering with the Finnish
Meteorological Institute. See [FMI’s open data
manual](https://en.ilmatieteenlaitos.fi/open-data) for details.

**Note:** `fmir` is still very early in development. Basic functionality
is available, but several issues remain: documentation is scarce, and
none of the implementation details or even function names can be
considered stable.

## Installation

At the moment, the easiest way to install `fmir` is from github with
`devtools`:

``` r
# install.packages("devtools")
devtools::install_github("mikmart/fmir")
```

## Usage

To get started, set your API key for the session first:

``` r
library(fmir)
library(ggplot2)

# set your api key for your session
fmi_set_key("insert-your-apikey-here")
```

Once your key is set, you can construct queries to the API with
`fmi_query()`and then execute the queries with `fmi_data()`. A default
query with only a `place` parameter will return observations with a
10-minute interval for the past 24 hours:

``` r
# generate a query url with fmi_query
q <- fmi_query(place = "Oulu")

# download the data corresponding to your query
weather <- fmi_data(q)
head(weather)
#> # A tibble: 6 x 13
#>   location   time                p_sea  r_1h    rh ri_10min snow_aws   t2m
#>   <chr>      <dttm>              <dbl> <dbl> <dbl>    <dbl>    <dbl> <dbl>
#> 1 65.00639 ~ 2018-09-29 04:10:00 1011.   NaN    95      NaN      NaN   0.1
#> 2 65.00639 ~ 2018-09-29 04:20:00 1011.   NaN    95      NaN      NaN  -0.1
#> 3 65.00639 ~ 2018-09-29 04:30:00 1011.   NaN    96      NaN      NaN   0.1
#> 4 65.00639 ~ 2018-09-29 04:40:00 1011.   NaN    96      NaN      NaN  -0.1
#> 5 65.00639 ~ 2018-09-29 04:50:00 1011.   NaN    96      NaN      NaN   0  
#> 6 65.00639 ~ 2018-09-29 05:00:00 1011.   NaN    96      NaN      NaN   0  
#> # ... with 5 more variables: td <dbl>, vis <dbl>, wd_10min <dbl>,
#> #   wg_10min <dbl>, ws_10min <dbl>

# draw a simple line graph of the recent temperature
ggplot(weather, aes(time, t2m)) + geom_line()
```

![](man/figures/README-basic-usage-1.png)<!-- -->
