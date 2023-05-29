start_time <- Sys.time()
options(warn = -1)

library(tidyverse)
library(xgboost)
library(Matrix)
library(ROSE)   # For oversampling the minority class
library(caret)  # For Classification And Regression Training

train_path <- './data/train.csv'
test_path <- './data/test.csv'

print("loading Data......")
train <- read.csv(train_path)
test <- read.csv(test_path)

#########################################################

train_preprocess <- function(origin_data, replace_data = train) {
    new_data <-
        origin_data %>%
        mutate(
            ID = NULL,
        )
    
    return(new_data)
}

print("Data preprocessing......")
train_clean <-
    train %>%
    train_preprocess()