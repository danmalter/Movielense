#load data
movies <- read.csv("movies.csv", header = TRUE, stringsAsFactors=FALSE)
ratings <- read.csv("ratings.csv", header = TRUE)

library(reshape2)
#Create ratings matrix. Rows = userId, Columns = movieId
ratingmat <- dcast(ratings, userId~movieId, value.var = "rating", na.rm=FALSE)
ratingmat <- as.matrix(ratingmat[,-1]) #remove userIds

##################
#Model Creation###
##################

library(recommenderlab)
#Convert rating matrix into a recommenderlab sparse matrix
ratingmat <- as(ratingmat, "realRatingMatrix")

#Normalize the data
ratingmat_norm <- normalize(ratingmat)

#Create Recommender Model. "UBCF" stands for User-Based Collaborative Filtering
recommender_model <- Recommender(ratingmat_norm, method = "UBCF", param=list(method="Cosine",nn=30))
recom <- predict(recommender_model, ratingmat[1], n=10) #Obtain top 10 recommendations for 1st user in dataset
recom_list <- as(recom, "list") #convert recommenderlab object to readable list

#Obtain Top-10 recommendations
recom_result <- matrix(0,10)
for (i in c(1:10)){
  recom_result[i] <- as.integer(recom_list[[1]][i])
}
recom_result<-as.data.frame(subset(movies, movieId %in% recom_result)[,2])
colnames(recom_result)<-list("Top-10 Movies")
recom_result

##################
#Evaluate Model###
##################

#k=5 meaning a 5-fold cross validation. given=3 meaning 3 items withheld for evaluation
evaluation_scheme <- evaluationScheme(ratingmat, method="cross-validation", k=5, given=3, 
                                      goodRating=5) 
algorithms<-list(
  "random items"=list(name="RANDOM",param=NULL),
  "popular items"=list(name="POPULAR",param=NULL),
  "user-based CF"=list(name="UBCF",param=list(method="Cosine",nn=30))
)

evaluation_results<-evaluate(evaluation_scheme,algorithms,n=c(1,3,5,10,15,20)) #n=c denote top-N
plot(evaluation_results,legend="bottomright") #plot the avged ROC
plot(evaluation_results,"prec/rec") #plot the avged prec/rec

#get results for all runs of 'random items'
eval_results <- getConfusionMatrix(evaluation_results[[1]]) 
#alternatively, get avged result for 'random items'
avg(evaluation_results[[1]])
