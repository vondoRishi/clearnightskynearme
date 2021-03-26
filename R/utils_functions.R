#' @importFrom dplyr %>%
serVerLogic <- function(user_location, distance) {
    user_location_hrly <- get_onecall(lon = user_location$lon,
                                      lat = user_location$lat,
                                      exclude = "minutely,daily")


    user_location_night <- nightData(user_location_hrly)

    user_grid_points <-
        radial_grid(
            userLocation = as.numeric(user_location),
            userMaxDistance = distance,
            bearings = seq(from = 0, to = 360, by = 45),
            byDistance = 25 * 1000
        )


    grid_night_data <- get_bulk_onecall(user_grid_points)

    required_columns <- c("lon", "lat","clouds","dt_string")
    grid_min_cloud <-
        rbind(grid_night_data[, required_columns], user_location_night[, required_columns]) %>%
        dplyr::arrange(clouds) %>%
        dplyr::distinct(lon, lat, .keep_all = TRUE)

    grid_min_cloud <-
        grid_min_cloud %>%
        dplyr::mutate(time = stringr::str_extract(dt_string, pattern =  "\\S+$"))

    return( list(leaf_map=getLeafletMap(grid_min_cloud), cloud_data=grid_min_cloud))
}

#' @import leaflet
#' @importFrom dplyr %>%
getLeafletMap <- function(dataMinCloud) {
    myMap <- leaflet(dataMinCloud) %>% addTiles() %>% addCircleMarkers(
        lng = ~ lon,
        lat = ~ lat,
        group = "Grid",
        popup =  ~ (paste("Clouds " , clouds, "% <br/>", time, sep = "")),
        radius = 10
    ) %>% addPopups(
        data = dataMinCloud[1:2,],
        lng = ~ lon,
        lat = ~ lat,
        popup =  ~ (paste("Clouds " , clouds, "% <br/>", time, sep = "")),
        group = "Best Spot",
    )


    myMap <- myMap %>%
        fitBounds(
            min(dataMinCloud$lon),
            min(dataMinCloud$lat),
            max(dataMinCloud$lon),
            max(dataMinCloud$lat)
        ) %>%
        registerPlugin(heatPluginFile) %>%
        htmlwidgets::onRender(
            "function(el, x, data) {
    data = HTMLWidgets.dataframeToD3(data);
    data = data.map(function(val) { return [val.lat, val.lon, val.clouds*10]; });
L.heatLayer(data, {radius: 50}).addTo(this);
  }",
            data = dataMinCloud %>% dplyr::select(lat, lon, clouds)
        )

    return(
        myMap %>%
            addLayersControl(
                overlayGroups = c("Best Spot", "Grid"),
                options = layersControlOptions(collapsed = TRUE),
                position = "bottomleft"
            )
    )
}

# download.file('http://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js', '/srv/shiny-server/leaflet-heat.js', mode="wb")
heatPluginFile <- htmlDependency("Leaflet.heat", "99.99.99",
                                 src = c(file = normalizePath('/srv/shiny-server')),  script = "leaflet-heat.js"
)

heatPlugin <- htmltools::htmlDependency("Leaflet.heat", "99.99.99",
                             src = c(href = "http://leaflet.github.io/Leaflet.heat/dist/"),
                             script = "leaflet-heat.js"
)

registerPlugin <- function(map, plugin) {
    map$dependencies <- c(map$dependencies, list(plugin))
    map
}

radial_grid <- function(userLocation, userMaxDistance, bearings, byDistance ){
    grid <- NULL
    for (distance in seq(from=byDistance, to = userMaxDistance, by=byDistance)) {
        boundaries <- as.data.frame(
            geosphere::destPoint(userLocation,
                                 b = bearings,
                                 d = distance))
        if(is.null(grid)){
            grid <- boundaries
        }else {
            grid <- rbind(grid,boundaries)
        }
    }
    return(grid)
}


#' @importFrom dplyr %>%
get_onecall <- function (city = NA, ...)
{
    get <- owmr:::owmr_wrap_get("onecall")
    get(city, ...) %>% owmr:::owmr_parse() %>% owmr:::owmr_class("owmr_forecast")
}

get_bulk_onecall <- function(lon_lat_dataframe){
    result <- NULL
    for (id in 1:nrow(lon_lat_dataframe)) {
       hrly<- get_onecall(lon=lon_lat_dataframe[id,"lon"],
                          lat=lon_lat_dataframe[id,"lat"],
                          exclude="minutely,daily")
       hrly$hourly <- hrly$hourly[,1:14]
       location_night <-nightData(hrly)
        if(is.null(result)){
            result <- location_night
        }else {
            if(ncol(result)==ncol(location_night))
                result <- rbind(result,location_night)
            else
                print(paste("error",lon_lat_dataframe[id,"lon"],lon_lat_dataframe[id,"lat"]))
        }
    }
    return(result)

}

#' @importFrom dplyr %>%
nightData <- function(hourlyForecast){
    if(!("hourly" %in% names(hourlyForecast))){
        print("Not an hourly data")
        return()
    }
    hourlyForecast$hourly$dt_string <-
        hourlyForecast$hourly$dt %>% anytime::anytime(tz = hourlyForecast$timezone)

    hourlyForecast$hourly$lat <- hourlyForecast$lat
    hourlyForecast$hourly$lon <- hourlyForecast$lon
    ## We have hourly forecast for 48 hours
    ## We need only next dark hours (UVI = 0 but we will consider 0.5). Then we need to find next sunrise time

    sunrise_offSet <-    if (hourlyForecast$current$sunrise < hourlyForecast$current$dt)
        86400 else 0 #24*60*60
    nextSunrise <- hourlyForecast$current$sunrise+sunrise_offSet

    sunset_time <-
        if ((hourlyForecast$current$dt > hourlyForecast$current$sunset) |        # after_sunset
            (hourlyForecast$current$sunrise > hourlyForecast$current$dt))   # before sunrise
        {hourlyForecast$current$dt}else {hourlyForecast$current$sunset}


    if(sunset_time > nextSunrise) print("Error")

   return(hourlyForecast$hourly %>% dplyr::filter(dt > sunset_time &
                                                             dt < nextSunrise))

}


