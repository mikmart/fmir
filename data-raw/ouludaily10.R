library(lubridate)
library(purrr)

devtools::load_all()

# My API key: not pushed to GitHub
fmi_set_key(readLines("data-raw/api-key.txt"))

years <- 2010:2017

ouludaily10 <- map_df(years, function(y) {
  s <- make_date(y)
  e <- s + years(1) - days(1)
  q <- fmi_query("daily", place = "Oulu", starttime = s, endtime = e)
  fmi_data(q)
})

devtools::use_data(ouludaily10, overwrite = TRUE)
