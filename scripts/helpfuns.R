read_data <- function() {
  # Lee los datos y los combina
  files <- list.files(here::here("datos"), full.names = TRUE) 
  datos <- lapply(files, data.table::fread)
  
  data.table::rbindlist(datos)[, date := as.Date(date)][]
}