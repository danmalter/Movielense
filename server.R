#server.R

shinyServer(function(input, output) {
  
  # Text for the 3 boxes showing average scores
    formulaText1 <- reactive({
      paste(input$select)
    })
    formulaText2 <- reactive({
      paste(input$select2)
    })
    formulaText3 <- reactive({
      paste(input$select3)
    })

    output$movie1 <- renderText({
      formulaText1()
    })
    output$movie2 <- renderText({
      formulaText2()
    })
    output$movie3 <- renderText({
      formulaText3()
    })
    
  
    # Table containing recommendations
    output$table <- renderTable({
      
      movies2 <- subset(movies2, year >= input$range[1] & year <= input$range[2])
      movies2 <- subset(movies2, genre1 %in% input$genre| genre2 %in% input$genre | genre3 %in% input$genre
                        | genre4 %in% input$genre | genre5 %in% input$genre)  

      movie_recommendation <- function(input,input2,input3){
        row_num <- which(movies2[,3] == input)
        row_num2 <- which(movies2[,3] == input2)
        row_num3 <- which(movies2[,3] == input3)
        userSelect <- matrix(NA,8552)
        userSelect[row_num] <- 5 #hard code first selection to rating 5
        userSelect[row_num2] <- 4 #hard code second selection to rating 4
        userSelect[row_num3] <- 3 #hard code third selection to rating 3
        userSelect <- t(userSelect)
        
        ratingmat <- dcast(ratings, userId~movieId, value.var = "rating", na.rm=FALSE)
        ratingmat <- ratingmat[,-1]
        colnames(userSelect) <- colnames(ratingmat)
        ratingmat2 <- rbind(userSelect,ratingmat)
        ratingmat2 <- as.matrix(ratingmat2)
        
        #Convert rating matrix into a sparse matrix
        ratingmat2 <- as(ratingmat2, "realRatingMatrix")
        
        #Create Recommender Model. "UBCF" stands for user-based collaborative filtering
        recommender_model <- Recommender(ratingmat2, method = "UBCF",param=list(method="Cosine",nn=30))
        recom <- predict(recommender_model, ratingmat2[1], n=10)
        recom_list <- as(recom, "list")
        recom_result <- data.frame(matrix(NA,10))
        recom_result[1:10,1] <- movies2[as.integer(recom_list[[1]][1:10]),3]
        colnames(recom_result) <- "User-Based Collaborative Filtering Recommended Titles"
        return(recom_result)
      }

      
      movie_recommendation(input$select, input$select2, input$select3)
    })
    
    movie.ratings <- merge(ratings, movies2)
    output$tableRatings1 <- renderValueBox({
      movie.avg1 <- summarise(subset(movie.ratings, title==input$select),
                              Average_Rating1 = mean(rating, na.rm = TRUE))
      valueBox(
        value = format(movie.avg1, digits = 3),
        subtitle = input$select,
        icon = if (movie.avg1 >= 3) icon("thumbs-up") else icon("thumbs-down"),
        color = if (movie.avg1 >= 3) "aqua" else "red"
      )
    })
    
    movie.ratings <- merge(ratings, movies2)
    output$tableRatings2 <- renderValueBox({
      movie.avg2 <- summarise(subset(movie.ratings, title==input$select2),
                              Average_Rating = mean(rating, na.rm = TRUE))
      valueBox(
        value = format(movie.avg2, digits = 3),
        subtitle = input$select2,
        icon = if (movie.avg2 >= 3) icon("thumbs-up") else icon("thumbs-down"),
        color = if (movie.avg2 >= 3) "aqua" else "red"
      )
    })
    
    movie.ratings <- merge(ratings, movies2)
    output$tableRatings3 <- renderValueBox({
      movie.avg3 <- summarise(subset(movie.ratings, title==input$select3),
                Average_Rating = mean(rating, na.rm = TRUE))
      valueBox(
        value = format(movie.avg3, digits = 3),
        subtitle = input$select3,
        icon = if (movie.avg3 >= 3) icon("thumbs-up") else icon("thumbs-down"),
        color = if (movie.avg3 >= 3) "aqua" else "red"
      )
    })
  
    
    # Generate a table summarizing each players stats
    output$myTable <- renderDataTable({
      movies2[c("title", "genres")]
    })
    
}
)

