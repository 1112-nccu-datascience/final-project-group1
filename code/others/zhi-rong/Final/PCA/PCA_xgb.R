library(tidyverse)
library(xgboost)
library(Matrix)

train <- read.csv("./data/Input/train.csv")
test <- read.csv("./data/Input/test.csv")

test.id <- test$ID
test$ID <- NULL

train$ID <- NULL
train.target <- train$TARGET
train$TARGET <- NULL

##### 0 count per line
count0 <- function(x) {
    return( sum(x == 0) )
}
train$n0 <- apply(train, 1, FUN=count0)
test$n0 <- apply(test, 1, FUN=count0)

##### Removing constant features
cat("\n## Removing the constants features.\n")
for (f in names(train)) {
    if (length(unique(train[[f]])) == 1) {
        cat(f, "is constant in train. We delete it.\n")
        train[[f]] <- NULL
        test[[f]] <- NULL
    }
}

##### Removing identical features
features_pair <- combn(names(train), 2, simplify = F)
toRemove <- c()
for(pair in features_pair) {
    f1 <- pair[1]
    f2 <- pair[2]
    
    if (!(f1 %in% toRemove) & !(f2 %in% toRemove)) {
        if (all(train[[f1]] == train[[f2]])) {
            cat(f1, "and", f2, "are equals.\n")
            toRemove <- c(toRemove, f2)
        }
    }
}

feature.names <- setdiff(names(train), toRemove)

train <- train[, feature.names]
test <- test[, feature.names]

## PCA
st.pca <- prcomp(train, center = TRUE, scale. = TRUE)
st.pca.pred <- predict(st.pca, test)

# show variance explained (first 10)
st.summary <- summary(st.pca)
st.summary$importance[2, 1:10]

# We need at least 100 PC too explain about 95% of variance
sum(st.summary$importance[2, 1:100])

train <- as.data.frame(st.pca$x[,1:100])
test <- as.data.frame(st.pca.pred[,1:100])

### PCA end

## XGB model
dtrain <- xgb.DMatrix(data = as.matrix(train), label = as.numeric(train.target))

params <- list(objective = "binary:logistic")

model <- xgb.train(
    params = params,
    data = dtrain,
    nrounds = 10
)

dtest <- xgb.DMatrix(data = as.matrix(test))
preds <- predict(model, dtest)

predict_df <- data.frame( ID = test.id, TARGET = preds )

write.csv(
    predict_df,
    file = './data/Output/submission_PCA_XGB_untuned.csv',
    quote = FALSE,
    row.names = FALSE
)