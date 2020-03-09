read_data <- function() {
  # Lee los datos y los combina
  files <- list.files(here::here("datos"), full.names = TRUE, pattern = ".txt") 
  datos <- lapply(files, data.table::fread, na.strings = "-99.9")
  
  data <- data.table::rbindlist(datos)[, date := as.Date(date)]
  data <- data.table::as.data.table(tidyr::complete(data, station_id, date))[]
  
  return(data)
}


read_metadata <- function() {
  # Lee los metadatos de estación
  datos <- data.table::fread(here::here("datos", "METADATA_1960-2012.csv"))
  datos[, .(station_id, name, lon, lat, elev)]
}

roll_mean_na <- function(x, w, na.tol) {
  # Calcula una media móvil teniendo en cuenta una tolerancia a los NA
  m <- rep(NA, length(x))
  for (i in ceiling(w/2):(length(x) - floor(w/2))){
    y <- x[(i - floor(w/2)):(i + floor(w/2))]
    if (sum(is.na(y)) <= na.tol){
      m[i] <- mean(y, na.rm = T)
    }
  }
  m
}


filter_anual_cycle <- function(date, x, n = 0:3) {
  data <- data.table(date = date, x = x) 
  seasonal <- data %>% 
    .[, yday := update(date, year = 1000)] %>% 
    .[, mean(x, na.rm = TRUE), by = .(yday)] %>% 
    .[, seasonal := metR::FilterWave(V1, 0:3)] %>%
    .[, .(yday, seasonal)]
  
  seasonal[data, on = .NATURAL] %>% 
    .[, x := x - seasonal] %>% 
    .$x
}


seasonal <- datos %>% 
  .[, yday := update(date, year = 1000)] %>% 
  .[, mean(dtr, na.rm = TRUE), by = .(station_id, yday)] %>% 
  .[, seasonal := metR::FilterWave(V1, 0:3), by = station_id] %>%
  .[, .(yday, seasonal, station_id)]
