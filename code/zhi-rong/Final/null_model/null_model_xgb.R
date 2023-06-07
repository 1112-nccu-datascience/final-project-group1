# All feature is used & no any preprocess or parameter tuning
# Submission names: null_submission_xgb.csv
# Private score: 0.81965
# Public score: 0.83217

library(tidyverse)
library(xgboost)
library(Matrix)

set.seed(1234)

train <- read.csv("./data/Input/train.csv")
test  <- read.csv("./data/Input/test.csv")

train_clean <- train %>% mutate(
    ID = NULL,
    TARGET = NULL
)
test_clean <- test %>% mutate(ID = NULL)

dtrain <- xgb.DMatrix(data = as.matrix(train_clean), label = as.numeric(train$TARGET))

params <- list(objective = "binary:logistic")

model <- xgb.train(
    params = params,
    data = dtrain,
    nrounds = 10
)


dtest <- xgb.DMatrix(data = as.matrix(test_clean))
preds <- predict(model, dtest)

predict_df <- data.frame( ID = test$ID, TARGET = preds )

write.csv(
    predict_df,
    file = './data/Output/null_submission_xgb.csv',
    quote = FALSE,
    row.names = FALSE
)