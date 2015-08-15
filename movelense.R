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