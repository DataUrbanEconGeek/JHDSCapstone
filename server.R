
suppressPackageStartupMessages( c( 
        library(e1071),
        library(shiny),
        library(shinythemes),
        library(slam)
                                   ))

load(file = "./Models1.RData")
load(file = "./Models2.RData")

YourInputText <- function(x) {
        Tsplit <- strsplit(x, split = " ")
        Tfactor <- factor(unlist(Tsplit), levels = Unigram_levels)
        Tlist <- as.list(Tfactor)
        Tdf <- do.call(cbind.data.frame, Tlist)
        for (i in Tdf) {
                temp <- c(paste0("X", 1:length(Tdf)))
                names(Tdf) <- temp
        }
        return(Tdf)
}


Prediction <- function(s) {
        counts <- strsplit(s, split = " ")
        counts <- length(factor(unlist(counts)))
        answ <- c("NA")
        if (counts == 1) {
                answ <- predict(Bi_naiveBayes, YourInputText(s))
        } else if (counts == 2) {
                answ <- predict(Tri_naiveBayes, YourInputText(s))
        } else if (counts == 3) {
                answ <- predict(Quad_naiveBayes, YourInputText(s))
        } else if (counts >= 4) {
                InputText1 <- YourInputText(s)
                m <- length(InputText1) - 2
                InputText1 <- InputText1[, m:length(InputText1)]
                names(InputText1) <- c("X1", "X2", "X3")
                answ <- predict(Quad_naiveBayes, InputText1)
        }
        
        return(as.character(answ))
}



shinyServer(function(input, output) {
        
        wordPrediction <- reactive({
                s <- input$text
                s <- as.character(s)
                wordPrediction <- Prediction(s)})
        
        SentaPrediction <- reactive({
                t <- input$text
                t <- as.character(t)
                SentaPrediction <- paste(t, Prediction(t), sep = " ")})
        
        output$predictedWord <- renderText(wordPrediction())
        output$enteredWords <- renderText(SentaPrediction())
})



