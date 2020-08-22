# global variables added so there are no notes in R CMD check

if(getRversion() >= "2.15.1"){
  # gloabl variables from prism_data_get_station_md()
  gv <- c("ELEV(m)", "elevation", "Elevation(m)", "ID", "LAT", "latitude",
          "Latitude", "LON", "longitude", "Longitude", "name", "Name", "NAME",
          "network", "Network", "station", "Station", "stnid", "station_id")
  utils::globalVariables(gv)
}
