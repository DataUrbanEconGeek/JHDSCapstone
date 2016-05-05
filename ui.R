
suppressPackageStartupMessages( c( 
        library(e1071),
        library(shiny),
        library(shinythemes),
        library(slam)
))




shinyUI(fluidPage( 
                   theme = shinytheme("journal"),
                   tabPanel("Next Word Prediction",
                        fluidRow(
                                column(3),
                                column(6,
                                        tags$h2(style = "color:skyblue", align="center", "John Hopkins University Coursera Data Science Capstone Project"),
                                        tags$hr(),
                                        tags$div(textInput("text", 
                                                label = h3("Enter Text Here:"),
                                                value = ),
                                        tags$span(style="color:grey",("App Supports English Only.")),
                                        br(),
                                        tags$hr(),
                                        h4("Next Word Prediction:"),
                                        tags$span(
                                                tags$strong(tags$h3(textOutput("predictedWord")))),
                                        tags$hr(),
                                        h4("Combined Output:"),
                                        tags$em(tags$h4(textOutput("enteredWords"))),
                                        align="center")
                                        ),
                                column(3)
                            )
                   )
))
                   