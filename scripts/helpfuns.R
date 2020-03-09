read_data <- function() {
  # Lee los datos y los combina
  files <- list.files(here::here("datos"), full.names = TRUE, pattern = ".txt") 
  datos <- lapply(files, data.table::fread, na.strings = "-99.9")
  
  data <- data.table::rbindlist(datos)[, date := as.Date(date)]
  data <- data.table::setDT(tidyr::complete(data, station_id, date))[]
  
  return(data)
}


read_metadata <- function() {
  # Lee los metadatos de estación
  datos <- data.table::fread(here::here("datos", "METADATA_1960-2012.csv"))
  datos[, .(station_id, lon, lat, elev)]
}