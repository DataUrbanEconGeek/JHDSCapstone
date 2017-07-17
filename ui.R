
suppressPackageStartupMessages( c( 
        library(e1071),
        library(shiny),
        library(shinythemes),
        library(slam)
))




shinyUI(
        fluidPage( 
                theme = shinytheme("journal"),
                tabPanel("Next Word Prediction",
                        fluidRow(
                                column(3),
                                column(6,
                                        tags$h2(style = "color:skyblue", align="center", 
                                                "John Hopkins University Coursera Data Science Capstone Project"),
                                        tags$hr(),
                                        fluidRow(
                                                textInput("text", 
                                                        label = h3("Enter Text Here:"),
                                                        value = ""
                                                ),
                                                tags$span(style="color:grey",("App Supports English Only.")),
                                                br(),
                                                tags$hr(),
                                                selectInput("select", "Choose:", 
                                                        choices = c("Simple Prediction",
                                                                "Top 10 Predictions",
                                                                "Wordcloud"
                                                        ), selected = "Simple Prediction"
                                                ),
                                                conditionalPanel("input.select == 'Simple Prediction'",
                                                        h4("Next Word Prediction:"),
                                                        tags$span(
                                                                tags$strong(tags$h3(textOutput("predicted_word")))),
                                                        tags$hr(),
                                                        h4("Combined Output:"),
                                                        tags$em(tags$h4(textOutput("entered_words")))
                                                ),
                                                conditionalPanel("input.select == 'Top 10 Predictions'",
                                                        h4("Top 10 Predictions"),
                                                        tags$span(
                                                                tags$img(plotOutput("bar_plot"))
                                                        )
                                                ),
                                                conditionalPanel("input.select == 'Wordcloud'",
                                                        tags$span(
                                                                tags$img(plotOutput("cloud_plot"))
                                                        )
                                                ),
                                                tags$hr(),
                                                align="center"
                                        )
                                ),
                                column(3)
                        )
                )
        )
)