read_data <- function() {
  # Lee los datos y los combina
  files <- list.files(here::here("datos"), full.names = TRUE, pattern = ".txt") 
  datos <- lapply(files, data.table::fread)
  
  data.table::rbindlist(datos)[, date := as.Date(date)][]
}


read_metadata <- function() {
  # Lee los metadatos de estación
  datos <- data.table::fread(here::here("datos", "METADATA_1960-2012.csv"))
  datos[, .(station_id, lon, lat, elev)]
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
