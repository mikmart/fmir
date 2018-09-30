library(fmir)

# API key comes form envvar
q <- fmi_query("daily",
  place     = "Oulu",
  starttime = "2010-01-01",
  endtime   = "2017-12-31"
)

ouludaily10 <- fmi_data(q)

devtools::use_data(ouludaily10, overwrite = TRUE)
