#' @import shiny
#' @export
clearnightskynearme <- function(cityList=NULL) {
    vars <- cityList
    if(is.null(vars)) {
        vars <- list(
            "Your location"=NULL,
            # "Helsinki" = "24.93545,60.16952",
            "Turku" = "22.0841291,60.431959",
            "Stockholm" = "17.8419722,59.3260668",
            "Tampere" = "23.78712,61.49911",
            "Jyväskylä" = "25.73333,62.23333",
            "Lappeenranta" =  "28.18871,61.05871"
        )
    }

    ui <- navbarPage(
        "Clear Night Sky",
        id = "nav",collapsible = TRUE,
        tabPanel(
            "Interactive map",
            sidebarLayout(
              mainPanel(leaflet::leafletOutput("map")),
                sidebarPanel(
                    selectInput("city", "Cities", NULL),
                    sliderInput(
                        "distance",
                        "Distance",
                        min = 25,
                        max = 100,
                        value = 100
                    ),
                    textOutput("result")
                )
            )
        ),
        tabPanel("Cloud data",
                 DT::dataTableOutput("table")),
        navbarMenu("More",
                   tabPanel("About",
                            fluidRow(
                                column(
                                    3,

                                    tags$small(
                                        "If you are interested about Aurora forecast then visit",
                                        "below link ",
                                        a(href = "http://www.aurora-service.eu/aurora-forecast/",
                                          "Aurora Forecast")
                                    )
                                )
                            ))),
        tags$script(
            '
      $(document).ready(function () {
        navigator.geolocation.getCurrentPosition(onSuccess, onError);

        function onError (err) {
          Shiny.onInputChange("geolocation", false);
        }

        function onSuccess (position) {
          setTimeout(function () {
            var coords = position.coords;
            console.log(coords.latitude + ", " + coords.longitude);
            Shiny.onInputChange("geolocation", true);
            Shiny.onInputChange("lat", coords.latitude);
            Shiny.onInputChange("long", coords.longitude);
          }, 1100)
        }
      });
              '
        )
    )




    server <- function(input, output, session) {
        # This is to get user location from browser which is not working at this moment
        user_locate <- reactive({
            list(lat=input$lat,
                 lon=input$long,
                 geolocation=input$geolocation)
        })

        observe({
            if(!is.null(user_locate()$geolocation)) {
                vars[["Your location"]] <-paste(user_locate()$lon,user_locate()$lat,sep=",")
            } else {
                vars[["Your location"]]<- ""
            }
            updateSelectInput(session,
                              "city",
                              label = "Cities",
                              choices = vars,
                              selected<-head(vars,1))
        })
        city_coor <- reactive({
            city_coor <- strsplit(input$city, split = ",")
        })
        mapData <- reactive({
            city_location <- list(lon=city_coor()[[1]][1],
                                  lat=city_coor()[[1]][2])
            if(!is.na(city_location$lon)) {
                progress <- Progress$new(session, min = 1, max = 15)
                on.exit(progress$close())
                progress$set(message = 'Calculation in progress',
                             detail = 'This may take a while...')
                mapData <- serVerLogic(user_location = city_location,
                                       distance = input$distance * 1000) # in meters
                # print(mapData$cloud_data %>% dim())
            }
            return(mapData)
        })



         output$map <- leaflet::renderLeaflet({
             if(length(mapData()) !=2 ) return(leaflet::leaflet())
             return(mapData()$leaf_map)
         })

         output$table <- DT::renderDataTable({
             DT::datatable(mapData()$cloud_data)
         })

        # output$result <- renderText({
        #     paste(
        #         "Your location",
        #         user_locate()
        #         # ,
        #         # "user_location",
        #         # user_locate
        #     )
        # })
    }

    shiny::shinyApp(ui, server)
}
