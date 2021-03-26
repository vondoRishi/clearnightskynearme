## USER input ##
# owmr::owm_cities %>% dplyr::filter(countryCode=="FI" & nm=="Helsinki") %>% head()

cityList <- list(
    "Helsinki" = "24.93545,60.16952",
    "Turku" = "22.0841291,60.431959",
    "Stockholm" = "17.8419722,59.3260668",
    "Tampere" = "23.78712,61.49911",
    "Jyväskylä" = "25.73333,62.23333",
    "Lappeenranta" =  "28.18871,61.05871"
)

# clearnightskynearme(cityList = cityList)
city_location <- list(lon=24.93545,lat=60.16952) #Helsinki
Lappeenranta <- list(lon=28.18871,lat=61.05871)
distance <- 100*1000 # in meteres
# cloud_threshold <- 50
# mapData <- serVerLogic(user_location = Lappeenranta,distance = distance)
# mapData$leaf_map

# getLeafletMap(mapData$cloud_data)
