
suppressPackageStartupMessages( c( 
        library(data.table),
        library(dplyr),
        library(RWeka),
        library(tm),
        library(stringr),
        library(shiny),
        library(shinythemes),
        library(slam),
        library(wordcloud),
        library(RColorBrewer),
        library(scales),
        library(ggplot2)
                                   ))

load(file = "./training_data.RData")


prediction <- function(x){
        text_split <- unlist(strsplit(x, split = " "))
        if(length(text_split) == 1){
                group_predictors <- bigram_df[first_terms == text_split]
                if(nrow(group_predictors) > 0){
                        sort <- group_predictors[order(probs, decreasing = TRUE)]
                        if(nrow(sort) >= 50){
                                top_prob <- sort[1:50, ]
                                term_and_prob <- data.frame(word = top_prob$last_term, 
                                                            probability = top_prob$probs)
                        } else {
                                top_prob <- sort[1:nrow(sort), ]
                                temp_df <- data.frame(word = top_prob$last_term, 
                                                      probability = top_prob$probs)
                                uni_temp <- unigram_df[!(unigram_df$last_term %in%
                                                                 top_prob$last_term)]
                                beta_lop <- bigram_lop[first_terms == text_split]$leftoverprob
                                n_freq <- sum(unigram_df$frequency)
                                alpha <- beta_lop / sum((uni_temp$frequency * uni_temp$discount)
                                                        / n_freq)
                                top_prob2 <- mutate(uni_temp, final_proba = alpha * probs)
                                temp_df2 <- data.frame(word = top_prob2$last_term, 
                                                       probability = top_prob2$probs)
                                term_and_prob <- rbind(temp_df, temp_df2)
                                term_and_prob <- term_and_prob[1:50, ]
                        }
                } else {
                        sort <- unigram_df[order(probs, decreasing = TRUE)]
                        top_prob <- sort[1:50, ]
                        term_and_prob <- data.frame(word = top_prob$last_term, probability =
                                                            top_prob$probs)
                }
        } else {
                last_2 <- tail(text_split, 2)
                gram_recon <- paste(last_2[-2], last_2[-1], sep = " ")
                group_predictors <- trigram_df[first_terms == gram_recon]
                if(nrow(group_predictors) > 0){
                        sort <- group_predictors[order(probs, decreasing = TRUE)]
                        if(nrow(sort) >= 50){
                                top_prob <- sort[1:50, ]
                                term_and_prob <- data.frame(word = top_prob$last_term,
                                                            probability = top_prob$probs)
                        } else {
                                top_prob <- sort[1:nrow(sort), ]
                                temp_df <- data.frame(word = top_prob$last_term, 
                                                      probability = top_prob$probs)
                                beta_lop <- trigram_lop[first_terms == gram_recon]$leftoverprob
                                subset_group <- bigram_df[first_terms == last[2]]
                                n_freq <- sum(subset_group$frequency)
                                bi_temp <- subset_group[!(subset_group$last_term %in%
                                                                  top_prob$last_term)]
                                alpha <- beta_lop / sum((bi_temp$frequency * bi_temp$discount)
                                                        / n_freq)
                                top_prob2 <- mutate(bi_temp, final_proba = alpha * probs)
                                temp_df2 <- data.frame(word = top_prob2$last_term, 
                                                       probability = top_prob2$probs)
                                temp_df3 <- rbind(temp_df, temp_df2)
                                if(nrow(temp_df3) >= 50){
                                        term_and_prob <- temp_df3[1:50, ]
                                } else {
                                        n_freq <- sum(unigram_df$frequency)
                                        uni_temp <- unigram_df[!(unigram_df$last_term %in%
                                                                         temp_df3$word)]
                                        alpha <- beta_lop / sum((uni_temp$frequency * 
                                                                         uni_temp$discount) / 
                                                                        n_freq)
                                        top_prob3 <- mutate(uni_temp, final_proba = 
                                                                    alpha * probs)
                                        temp_df4 <- data.frame(word = top_prob3$last_term, 
                                                               probability = top_prob3$probs)
                                        temp_df5 <- rbind(temp_df3, temp_df4)
                                        term_and_prob <- temp_df5[1:50, ]
                                }
                        }
                } else {
                        last <- last_2[2]
                        group_predictors2 <- bigram_df[first_terms == last]
                        if(nrow(group_predictors2) > 0){
                                sort <- group_predictors2[order(probs, decreasing = TRUE)]
                                if(nrow(sort) >= 50){
                                        top_prob <- sort[1:50, ]
                                        term_and_prob <- data.frame(word = top_prob$last_term,
                                                                    probability = top_prob$probs)
                                } else {
                                        top_prob <- sort[1:nrow(sort), ]
                                        temp_df <- data.frame(word = top_prob$last_term, 
                                                              probability = top_prob$probs)
                                        uni_temp <- unigram_df[!(unigram_df$last_term %in%
                                                                         top_prob$last_term)]
                                        beta_lop <- bigram_lop[first_terms == 
                                                                       last]$leftoverprob
                                        n_freq <- sum(unigram_df$frequency)
                                        alpha <- beta_lop / sum((uni_temp$frequency * 
                                                                         uni_temp$discount)
                                                                / n_freq)
                                        top_prob2 <- mutate(uni_temp, final_proba = alpha * 
                                                                    probs)
                                        temp_df2 <- data.frame(word = top_prob2$last_term, 
                                                               probability = top_prob2$probs)
                                        term_and_prob <- rbind(temp_df, temp_df2)
                                        term_and_prob <- term_and_prob[1:50, ]
                                }
                        } else {
                                sort <- unigram_df[order(probs, decreasing = TRUE)]
                                top_prob <- sort[1:50, ]
                                term_and_prob <- data.frame(word = top_prob$last_term,
                                                            probability = top_prob$probs)
                        }
                }
        }
        return(term_and_prob) 
}

simple_output <- function(x){
        df <- prediction(x)
        one_obs <- as.character(df$word[1])
        return(one_obs)
}

color_set2 <- rev(hue_pal()(9))

cloud_output <- function(x){
        df <- prediction(x)
        df_ext <- mutate(df, fake_freq = probability * 500000)
        cloud <- wordcloud(na.omit(df_ext$word[1:50]), 
                                df_ext$fake_freq[1:50], 
                                scale = c(5,1), min.freq = 1, 
                                colors = color_set2,
                                rot.per=0.35, use.r.layout=FALSE, 
                                random.order = FALSE)
        return(cloud)
}

shinyServer(function(input, output) {
        
        word_prediction <- reactive({
                x <- input$text
                x <- as.character(x)
                word_prediction <- simple_output(x)
        })
        
        sentance_put_together <- reactive({
                x <- input$text
                x <- as.character(x)
                sentance_put_together <- paste(x, word_prediction(), sep = " ")
        })
        
        cloud <- reactive({
                x <- input$text
                x <- as.character(x)
                cloud <- cloud_output(x)
        })
        
        bar <- reactive({
                x <- input$text
                x <- as.character(x)
                bar <- barplot_output(x)
        })
        
        output$predicted_word <- renderText(word_prediction())
        output$entered_words <- renderText(sentance_put_together())
        output$cloud_plot <- renderPlot(cloud())
        output$bar_plot <- reactivePlot(function() {
                x <- input$text
                x <- as.character(x)
                df <- prediction(x)
                df$word <- factor(df$word, levels = df[order(df$probability, decreasing = TRUE), "word"])
                df_top_10 <- df[1:10,]
                ggbar_plot <- ggplot(df_top_10, aes(x = word, y = probability)) +
                        geom_bar(stat = "identity", fill = "blue") + 
                        theme(legend.position = "none")
                print(ggbar_plot)
        })
})



